module MaxPool2x2Relu #(
	parameter DATA_WIDTH,
	parameter ADDR_WIDTH
)
(input logic clk, 
input logic reset,
input logic clear,
input logic run,
input logic signed [DATA_WIDTH-1:0] data_in,

output logic signed [DATA_WIDTH-1:0] result_out,
output logic [ADDR_WIDTH-1:0] address_out
);

logic signed [DATA_WIDTH-1:0] max0, max1, max2;
assign max0 = (data_in[0] > data_in [1]) ? data_in[0] : data_in[1];
assign max1 = (data_in[2] > data_in [3]) ? data_in[2] : data_in[3];
assign max2 = (max0 > max1) ? max0 : max1;

logic signed [DATA_WIDTH-1:0] result, result_in;
logic signed [ADDR_WIDTH-1:0] address, address_in;
logic signed [DATA_WIDTH-1:0] zero;
assign zero = 'b0;
assign result_out = result;
assign address_out = address;
always@(*) begin
	result_in = result;
	address_in = address;
	if (run)
		result_in = (data_in > result) ? data_in : result;
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
