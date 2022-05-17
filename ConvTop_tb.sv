module conv_l2_tb();

parameter PARTITION_WIDTH = 3;
parameter PARTITION_HEIGHT = 3;
parameter DATA_WIDTH = 27;
parameter FRACTION_WIDTH = 8;
parameter ADDR_WIDTH = 10;
parameter LAYER_WIDTH = 12;
parameter LAYER_HEIGHT = 12;
parameter KERNEL_SWITCH_NUM = 1;
parameter VEC_LEN = 50;


logic clk;
logic reset;
logic run;

logic  [DATA_WIDTH-1:0] m10k_vec [0:VEC_LEN-1];
logic [$clog2(VEC_LEN)-1:0] vec_read_addr;
// assign m10k_vec = {}

logic  [DATA_WIDTH-1:0] vec_data, vec_data_pipe,vec_data_pipe_1;
assign vec_data_pipe = m10k_vec[vec_read_addr];
always@(posedge clk) begin
    vec_data_pipe_1 <= vec_data_pipe;
    vec_data <= vec_data_pipe_1;
end

always
   #5 clk = ~ clk;

initial begin
clk = 0;
run = 0;
reset = 1;
#25
reset = 0;
#10
run = 1;
#10
run = 0;
end

ConvL2 #(
 PARTITION_WIDTH,
 PARTITION_HEIGHT,
 LAYER_WIDTH,
 LAYER_HEIGHT,
 DATA_WIDTH,
 FRACTION_WIDTH,
 ADDR_WIDTH,
 KERNEL_SWITCH_NUM
) convL2
(   .clk(clk),
    .reset(reset),
    .run(run),
    .data_0_in(),
    .data_1_in(),
    .read_address_0_out(),
    .read_address_1_out(),

    .result_out(),
    .write_address_out(),
    .we_out(),
    .conv_done()
    );
endmodule
