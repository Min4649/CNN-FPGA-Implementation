module ReadAddressGen #(
	parameter PARTITION_WIDTH,
	parameter PARTITION_HEIGHT,
	parameter ARRAY_SIZE,
	parameter ARRAY_WIDTH,
	parameter ADDRESS_WIDTH
)
( clk, run,
  address_in,
  address_out,
  done);
input logic clk, run;
input logic [ADDRESS_WIDTH-1:0] address_in;
output logic [ADDRESS_WIDTH-1:0] address_out;
output logic done;

logic [ADDRESS_WIDTH-1:0] column_count;
logic [ADDRESS_WIDTH-1:0] row_count;
assign done = (column_count == PARTITION_WIDTH - 1) && (row_count == PARTITION_HEIGHT - 1);
always@(posedge clk) begin
	if (!run) begin
	  column_count <= 'b0;
	  row_count <= 'b0;
	end
	else begin
	  column_count <= (column_count < PARTITION_WIDTH - 1) ? column_count + 'b1 : 'b0;
	  row_count <= (column_count == PARTITION_WIDTH - 1) ? row_count + 'b1 : row_count;
	end
end

always@(posedge clk) begin
	if (!run)
	  address_out <= address_in;
	else
	  address_out <= (column_count < PARTITION_WIDTH - 1) ? address_out + 'b1 : address_out + (ARRAY_WIDTH-PARTITION_WIDTH+1);
end


// always@(posedge clk) begin
// 	if (!run)
// 	  result_out <= 'b0;


endmodule
