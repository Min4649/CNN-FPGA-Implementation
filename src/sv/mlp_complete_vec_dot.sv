module mlp_complete_vector_dot #(
	parameter SIZE,
	parameter DATA_WIDTH,
	parameter FRACTION_WIDTH
)
( clk, run, reset,
  data_in, weights_in, bias_in,
  result_out, finished_out);
  
  input logic clk, run, reset;
  input logic signed [DATA_WIDTH-1:0] data_in [SIZE];
  input logic signed [DATA_WIDTH-1:0] weights_in [SIZE];
  input logic signed [DATA_WIDTH-1:0] bias_in;
  
  output logic signed [DATA_WIDTH-1:0] result_out;
  output logic finished_out;
  
  logic finished_out_buf;
  always@(posedge clk) begin
    finished_out_buf <= finished_out;
  end
  
  logic load_result;
  assign load_result = (!finished_out_buf) && finished_out;
  
  logic signed [DATA_WIDTH-1:0] temp_result;
  always@(posedge clk) begin
    if (reset) begin
      result_out <= 0;
    end
    else if (load_result) begin
      result_out <= result_out + temp_result;
    end
  end
  
  mlp_partial_vector_dot #(
	SIZE,
	DATA_WIDTH,
	FRACTION_WIDTH
	) dut
	(
	.clk(clk),
	.run(run),
	.data_in(data_in),
	.weights_in(weights_in),
	.bias_in(bias_in),
	.result_out(temp_result),
	.finished_out(finished_out)
	);

endmodule