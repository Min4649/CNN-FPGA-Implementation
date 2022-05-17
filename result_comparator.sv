module mlp_comparator(
	input clk,
	input mlp_done,
	input logic [26:0]  data_0,
	input logic [26:0]  data_1,
	input logic  [26:0]  data_2,
	input logic [26:0]  data_3,
	input logic [26:0]  data_4,
	input logic [26:0]  data_5,
	input logic  [26:0]  data_6,
	input logic [26:0]  data_7,
	input logic  [26:0]  data_8,
	input  logic [26:0]  data_9,

	output logic [3:0] hex_in
);	
	//layer 0
	logic signed [26:0] comp_result_00, comp_result_01, comp_result_02, comp_result_03, comp_result_04;
	max comp00 (.a(data_0), .b(data_1), .out(comp_result_00));
	max comp01 (.a(data_2), .b(data_3), .out(comp_result_01));
	max comp02 (.a(data_4), .b(data_5), .out(comp_result_02));
	max comp03 (.a(data_6), .b(data_7), .out(comp_result_03));
	max comp04 (.a(data_8), .b(data_9), .out(comp_result_04));

	//layer 1
	logic signed [26:0] comp_result_10, comp_result_11;
	max comp10 (.a(comp_result_00), .b(comp_result_01), .out(comp_result_10));
	max comp11 (.a(comp_result_02), .b(comp_result_03), .out(comp_result_11));

	//layer 2
	logic signed [26:0] comp_result_20;
	max comp20 (.a(comp_result_10), .b(comp_result_11), .out(comp_result_20));
	
	logic signed [26:0] max_value;
	max comp30 (.a(comp_result_20), .b(comp_result_04), .out(max_value));
	

	always_comb begin
		if(!mlp_done) hex_in = 'hf;
		else if(max_value == data_0) hex_in = 4'd0;
		else if(max_value == data_1) hex_in = 4'd1;
		else if(max_value == data_2) hex_in = 4'd2;
		else if(max_value == data_3) hex_in = 4'd3;
		else if(max_value == data_4) hex_in = 4'd4;
		else if(max_value == data_5) hex_in = 4'd5;
		else if(max_value == data_6) hex_in = 4'd6;
		else if(max_value == data_7) hex_in = 4'd7;
		else if(max_value == data_8) hex_in = 4'd8;
		else if(max_value == data_9) hex_in = 4'd9;
		else hex_in = 4'hf;
	end
endmodule

module max (input [26:0]  a, 
            input [26:0]  b, 
            output reg [26:0]   out);
  always @(*) begin
    if ($signed(a)>$signed(b))
      out = a;
    else
      out = b;
  end
endmodule