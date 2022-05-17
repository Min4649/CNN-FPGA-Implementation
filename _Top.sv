module Top (
	input logic clk,
	input logic reset_in,
	input logic start_in,
	input logic [ADDR_WIDTH-1:0] mnist_waddr; /* connect to source */
	input logic mnist_wen; /* connect to source */
	input logic [DATA_WIDTH-1:0]mnist_wdata; /* connect to source */
	output logic [$clog2(NUM_CLASSIFICATION)-1:0] classification; /* connect to sink */
);

parameter DATA_WIDTH = 27;
parameter FRACTION_WIDTH = 9;
parameter ADDR_WIDTH = 10;
parameter NUM_CLASSIFICATION = 10;

// source and sink


//=======================================================
// Board Logistics instantiations
//=======================================================

logic reset, reset_0;
always@(posedge clk) begin
	reset_0 <= reset_in;
	reset <= reset_0;
end

logic start, start_0;
always@(posedge clk) begin
	if (reset) start <= 'b0;
	else begin
		if (start == 0)
			start <= start_in;
		else	
			start <= start;
	end
end
always@(posedge clk) begin
	if (reset) start_0 <= 'b0;
	else begin
		if (start_0 == 0)
			start_0 <= start;
		else	
			start_0 <= start_0;
	end
end

logic run;
assign run = !start_0 && start;
 
//=======================================================
// Board Logistics Ends
//=======================================================

//=======================================================
// CONV instantiations
//=======================================================

logic [DATA_WIDTH-1:0] conv_data;
logic [ADDR_WIDTH-1:0] conv_data_addr;
mem_input	mem_input_inst (
	.clock (clk),
	.data (mnist_wdata),
	.rdaddress (conv_data_addr),
	.wraddress (mnist_waddr),
	.wren (mnist_wen),
	.q (conv_data)
	);

logic [DATA_WIDTH-1:0] mlp_m10k_0_data, mlp_m10k_1_data,mlp_m10k_2_data;
	
//conv1
logic [DATA_WIDTH -1 :0] conv_1_out, conv_1_out_0, conv_1_out_1;
logic [ADDR_WIDTH-1:0] channel_count, conv_1_read_address;
assign conv_1_out = (channel_count=='d0) ? conv_1_out_0 : conv_1_out_1;
logic convL1Done;
ConvL1Wrapper0#(
    .DATA_WIDTH(DATA_WIDTH),
    .FRACTION_WIDTH(FRACTION_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CONV_PARTITION_WIDTH(5),
    .CONV_PARTITION_HEIGHT(5),
    .CONV_LAYER_WIDTH(28),
    .CONV_LAYER_HEIGHT(28),
    .CHANNEL_NUM(1),
    .CONV_RESULT_WIDTH(24),
    .CONV_RESULT_HEIGHT(24)
) convL1Wrapper0
(
    .clk(clk), 
    .reset(reset), 
    .run(run),
    .M10K_read_select(),
    .conv_data(conv_data),
    .conv_data_addr(conv_data_addr),
    .result_read_address(conv_1_read_address),
    .result(conv_1_out_0),
    .done(convL1Done)
);

ConvL1Wrapper1#(
    .DATA_WIDTH(DATA_WIDTH),
    .FRACTION_WIDTH(FRACTION_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CONV_PARTITION_WIDTH(5),
    .CONV_PARTITION_HEIGHT(5),
    .CONV_LAYER_WIDTH(28),
    .CONV_LAYER_HEIGHT(28),
    .CHANNEL_NUM(1),
    .CONV_RESULT_WIDTH(24),
    .CONV_RESULT_HEIGHT(24)
) convL1Wrapper1
(
    .clk(clk), 
    .reset(reset), 
    .run(run),
    .M10K_read_select(),
    .conv_data(conv_data),
    .conv_data_addr(),
    .result_read_address(conv_1_read_address),
    .result(conv_1_out_1),
    .done()
);

//conv2
logic convL2Done;
 Conv2Wrapper0 #(
    .DATA_WIDTH (DATA_WIDTH),
    .FRACTION_WIDTH(FRACTION_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CONV_PARTITION_WIDTH(3),
    .CONV_PARTITION_HEIGHT(3),
    .CONV_LAYER_WIDTH(12),
    .CONV_LAYER_HEIGHT(12),
    .CHANNEL_NUM(2),
    .CONV_RESULT_WIDTH(10),
    .CONV_RESULT_HEIGHT(10)
)conv2Wrapper0(
	.run (convL1Done),
	.clk (clk),
	.reset (reset),
	.M10K_read_select (),
	.data_in (conv_1_out),
	.addr_in (mlp_read_addr_out),//kejia
	.out_result_test (mlp_m10k_0_data),//kejia
	.addr_out (conv_1_read_address), //layer1_result ONLY
	.channel_count (channel_count), //
	.done (convL2Done) //kejia run
);

 Conv2Wrapper1 #(
    .DATA_WIDTH (DATA_WIDTH),
    .FRACTION_WIDTH(FRACTION_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CONV_PARTITION_WIDTH(3),
    .CONV_PARTITION_HEIGHT(3),
    .CONV_LAYER_WIDTH(12),
    .CONV_LAYER_HEIGHT(12),
    .CHANNEL_NUM(2),
    .CONV_RESULT_WIDTH(10),
    .CONV_RESULT_HEIGHT(10)
)conv2Wrapper1(
	.run (convL1Done),
	.clk (clk),
	.reset (reset),
	.M10K_read_select (SW[9:7]),
	.data_in (conv_1_out),
	.addr_in (mlp_read_addr_out),//kejia
	.out_result_test (mlp_m10k_1_data),//kejia
	.addr_out (), //layer1_result ONLY
	.channel_count (), //
	.done () //kejia run
);

 Conv2Wrapper2 #(
    .DATA_WIDTH (DATA_WIDTH),
    .FRACTION_WIDTH(FRACTION_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .CONV_PARTITION_WIDTH(3),
    .CONV_PARTITION_HEIGHT(3),
    .CONV_LAYER_WIDTH(12),
    .CONV_LAYER_HEIGHT(12),
    .CHANNEL_NUM(2),
    .CONV_RESULT_WIDTH(10),
    .CONV_RESULT_HEIGHT(10)
)conv2Wrapper2(
	.run (convL1Done),
    .clk (clk),
    .reset (reset),
    .M10K_read_select (),
	.data_in (conv_1_out),
	.addr_in (mlp_read_addr_out),//kejia
	.out_result_test (mlp_m10k_2_data),//kejia
	.addr_out (), //layer1_result ONLY
	.channel_count (), //
	.done () //kejia run
);

//=======================================================
// CONV Ends
//=======================================================

//=======================================================
// MLP instantiations
//=======================================================

//mlp parameters
parameter MLP_ARR_ROW_SIZE = 75;
parameter MLP_ARR_COLUMN_SIZE = 10;
parameter MLP_DATA_WIDTH = 27;
parameter MLP_FRACTION_WIDTH = 9;
parameter MLP_PARTITION_SIZE = 5; 

parameter MLP_VEC_SIZE = MLP_ARR_ROW_SIZE;
parameter MLP_ARR_SIZE = MLP_ARR_ROW_SIZE * MLP_ARR_COLUMN_SIZE;
logic [DATA_WIDTH-1:0:0] mlp_arr_data;
logic [DATA_WIDTH-1:0] mlp_data_in;
logic [ADDR_WIDTH-1:0] mlp_vec_read_addr, mlp_arr_read_addr, mlp_read_addr_out;

logic [MLP_DATA_WIDTH-1:0] result_0, result_1, result_2,result_3,result_4,result_5,result_6,result_7,result_8,result_9;
mlp_matrix_mul_vect_top_wrapper #(
	.ARR_ROW_SIZE(MLP_ARR_ROW_SIZE),
	.ARR_COLUMN_SIZE(MLP_ARR_COLUMN_SIZE),
	.DATA_WIDTH(MLP_DATA_WIDTH),
	.FRACTION_WIDTH(MLP_FRACTION_WIDTH),
	.PARTITION_SIZE(MLP_PARTITION_SIZE)) mlpmmvtw
(	.clk(clk),
	.start(convL2Done),
	.rst(reset),
	.vec_read_addr(mlp_vec_read_addr),
	.vec_read_data(mlp_data_in),
	.arr_read_addr(mlp_arr_read_addr),
	.arr_read_data(mlp_arr_data[DATA_WIDTH-1:0]),
	.done(mlp_done),
	.result_0(result_0),
	.result_1(result_1),
	.result_2(result_2),
	.result_3(result_3),
	.result_4(result_4),
	.result_5(result_5),
	.result_6(result_6),
	.result_7(result_7),
	.result_8(result_8),
	.result_9(result_9)
	
);
		
mlp_comparator mc(
	.clk(clk),
	.mlp_done(mlp_done),
	.data_0(result_0),
	.data_1(result_1),
	.data_2(result_2),
	.data_3(result_3),
	.data_4(result_4),
	.data_5(result_5),
	.data_6(result_6),
	.data_7(result_7),
	.data_8(result_8),
	.data_9(result_9),
	.hex_in(classification));

mlp_input_m10k_decoder mlp_input_data_decoder
( .rst(reset),
  .clk(clk),
  .read_addr_in(mlp_vec_read_addr),//from module
  .data_m10k0(mlp_m10k_0_data),
  .data_m10k1(mlp_m10k_1_data),
  .data_m10k2(mlp_m10k_2_data),
  .read_addr_out(mlp_read_addr_out),//to m10ks
  .data_forward(mlp_data_in)
);
		
mlp_weight mlp_weight_m10k(
	.clock(clk),
	.data(),
	.rdaddress(mlp_arr_read_addr),
	.wraddress('d0),
	.wren('d0),
	.q(mlp_arr_data));
	
//=======================================================
//  MLP Ends
//=======================================================
endmodule