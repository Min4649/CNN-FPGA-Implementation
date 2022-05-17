module MaxPool2x2ReluTop_tb();

parameter DATA_WIDTH = 27;
parameter FRACTION_WIDTH = 8;
parameter ADDR_WIDTH = 10;
parameter LAYER_WIDTH = 10;
parameter LAYER_HEIGHT = 20;
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

MaxPool2x2ReluL2 #(
 LAYER_WIDTH,
 LAYER_HEIGHT,
 DATA_WIDTH,
 ADDR_WIDTH
) maxPool2x2ReluL2
(   .clk(clk),
    .reset(reset),
    .run(run),
    .data_0_in(),
    .read_address_0_out(),

    .result_out(),
    .write_address_out(),
    .we_out(),
    .maxrelu_done()
    );
endmodule
