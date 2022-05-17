module merger_tb();

parameter PARTITION_WIDTH = 5;
parameter PARTITION_HEIGHT = 5;
parameter DATA_WIDTH = 27;
parameter ADDR_WIDTH = 10;
parameter ADDRESS_0_IN = 0;
parameter ADDRESS_1_IN = 25;


logic clk;
logic reset;
logic run;

logic  [DATA_WIDTH-1:0] m10k_vec [0:50-1];
logic [$clog2(50)-1:0] vec_read_addr;
//  addr high -----> low
assign m10k_vec = {'d1 ,
'd2 ,
'd3 ,
'd4 ,
'd5 ,
'd6 ,
'd7 ,
'd8 ,
'd9 ,
'd10,
'd11,
'd12,
'd13,
'd14,
'd15,
'd16,
'd17,
'd18,
'd19,
'd20,
'd21,
'd22,
'd23,
'd24,
'd25,
'd26,
'd27,
'd28,
'd29,
'd30,
'd31,
'd32,
'd33,
'd34,
'd35,
'd36,
'd37,
'd38,
'd39,
'd40,
'd41,
'd42,
'd43,
'd44,
'd45,
'd46,
'd47,
'd48,
'd49,
'd50};

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

Merger #(
 PARTITION_WIDTH,
 PARTITION_HEIGHT,
 DATA_WIDTH,
 ADDR_WIDTH,
 ADDRESS_0_IN,
 ADDRESS_1_IN
) merger
(   .clk(clk),
    .reset(reset),
    .run(run),
    .data_in(vec_data),
    .read_address_out(vec_read_addr),

    .result_out(),
    .write_address_out()
    );
endmodule
