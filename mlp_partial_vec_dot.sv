module mlp_partial_vector_dot #(
	parameter SIZE,
	parameter DATA_WIDTH,
	parameter FRACTION_WIDTH
)
( clk, run,
  data_in, weights_in, bias_in,
  result_out, finished_out);
input logic clk, run;
input logic signed [DATA_WIDTH-1:0] data_in [SIZE];
input logic signed [DATA_WIDTH-1:0] weights_in [SIZE];
input logic signed [DATA_WIDTH-1:0] bias_in;

output logic signed [DATA_WIDTH-1:0] result_out;
output logic finished_out;

logic [31:0] counter;
//logic finished;
assign finished_out = (counter == SIZE);
always@(posedge clk) begin
    if (!run) begin
        counter <= 0;
    end
    else if (!finished_out) begin
        counter <= counter + 1;
    end
end

/* always@(posedge clk) begin
	if (!run) begin
        finished_out <= 0;
    end
    else begin
        finished_out <= finished;
    end
end */

logic [DATA_WIDTH-1:0] single_result;

wire [DATA_WIDTH-1:0] test_data_in;
assign test_data_in = data_in[counter];
wire [DATA_WIDTH-1:0] test_weights_in;
assign test_weights_in = weights_in[counter];

mlp_fixed_mul #(
	(DATA_WIDTH-FRACTION_WIDTH),
	FRACTION_WIDTH
	)
	dot (
    .a(test_data_in),
    .b(test_weights_in),
    .result(single_result)
);

logic signed [DATA_WIDTH-1:0] result;
assign result_out = result + bias_in;
always@(posedge clk) begin
    if (!run) begin
        result <= 0;
    end
    else if (!finished_out) begin
        result <= result + single_result;
    end
end

endmodule
