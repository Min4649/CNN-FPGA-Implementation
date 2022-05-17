module MatrixDot #(
	parameter DATA_WIDTH,
	parameter FRACTION_WIDTH,
	parameter ADDR_WIDTH
)
(input logic clk, 
input logic reset,
input logic clear,
input logic run,
input logic signed [DATA_WIDTH-1:0] data_in,
input logic signed [DATA_WIDTH-1:0] weights_in,
input logic signed [DATA_WIDTH-1:0] bias_in,


output logic signed [DATA_WIDTH-1:0] result_out,
output logic [ADDR_WIDTH-1:0] address_out
);


logic [DATA_WIDTH-1:0] single_result;
FixedMul #(
	(DATA_WIDTH-FRACTION_WIDTH),
	FRACTION_WIDTH
	)
	fixedMul (
    .a(data_in),
    .b(weights_in),
    .result(single_result)
);

logic signed [DATA_WIDTH-1:0] result, result_in;
logic signed [ADDR_WIDTH-1:0] address, address_in;
assign result_out = result + bias_in;
assign address_out = address;
always@(*) begin
	result_in = result;
	address_in = address;
	if (run)
		result_in = result + single_result;
	else if (clear) begin
		result_in = 'b0;
		address_in = address + 'b1;
	end
end
always@(posedge clk) begin
	if (reset) begin
		result <= 'b0;
		address <= 'b0;
	end
    else begin
		result <= result_in;
		address <= address_in;
	end
end

endmodule
