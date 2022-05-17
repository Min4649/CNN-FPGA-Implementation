//con declear
module Conv2Wrapper2 #(
    parameter DATA_WIDTH,
    parameter FRACTION_WIDTH,
    parameter ADDR_WIDTH,
    parameter CONV_PARTITION_WIDTH,
    parameter CONV_PARTITION_HEIGHT,
    parameter CONV_LAYER_WIDTH,
    parameter CONV_LAYER_HEIGHT,
    parameter CHANNEL_NUM,
    parameter CONV_RESULT_WIDTH,
    parameter CONV_RESULT_HEIGHT
)(
	input run,
	input clk,
	input reset,
	input  [2:0] M10K_read_select,
	input [DATA_WIDTH -1 :0] data_in,
	input [ADDR_WIDTH - 1:0] addr_in,
	output [DATA_WIDTH -1 :0] out_result_test,
	output [ADDR_WIDTH - 1:0] addr_out, 
	output [ADDR_WIDTH-1:0] channel_count,
	output done
);


logic [DATA_WIDTH -1 :0] conv_kernel_out;
logic [DATA_WIDTH -1 :0] conv_kernell;
logic [DATA_WIDTH -1 :0] conv_kernel2;

logic [ADDR_WIDTH - 1:0] conv_kernel_addr;

DataProcessBranch#(
    DATA_WIDTH,
    FRACTION_WIDTH,
    ADDR_WIDTH,
    CONV_PARTITION_WIDTH,
    CONV_PARTITION_HEIGHT,
    CONV_LAYER_WIDTH,
    CONV_LAYER_HEIGHT,
    CHANNEL_NUM,
    CONV_RESULT_WIDTH,
    CONV_RESULT_HEIGHT
) dataProcessBranch
(
    .clk(clk), 
    .reset(reset), 
    .run(run),
	 .M10K_read_select(M10K_read_select),
    .conv_data(data_in),
    .conv_kernel(conv_kernel_out),
    .conv_bias('h7ffffe5),
    .conv_data_addr(addr_out),
    .conv_kernel_addr(conv_kernel_addr),
    .read_address(addr_in),
    .out_result_test(out_result_test),
	 .channel_count(channel_count),
	 .done (done)
);

assign conv_kernel_out = (channel_count=='d0) ? conv_kernell : conv_kernel2;


//memory instance
conv_2_weight_4	conv_2_weight_4_inst (
	.clock ( clk ),
	.data ( ),
	.rdaddress ( conv_kernel_addr ),
	.wraddress ( ),
	.wren (  ),
	.q ( conv_kernell )
	);
	
conv_2_weight_5	conv_2_weight_5_inst (
	.clock ( clk ),
	.data (  ),
	.rdaddress ( conv_kernel_addr ),
	.wraddress (  ),
	.wren (  ),
	.q ( conv_kernel2 )
	);
	
endmodule