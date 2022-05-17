module mlp_arr_addr_gen #(
	parameter PARTITION_SIZE,
	parameter HEIGHT,
	parameter ARRAY_SIZE,
	parameter ARRAY_WIDTH
)
( clk, run,
  address_in,
  address_out, done, write_addr);


input logic clk, run;
input logic [$clog2(ARRAY_SIZE)-1:0] address_in;
output logic [$clog2(ARRAY_SIZE)-1:0] address_out;
output logic done;
output logic [$clog2(PARTITION_SIZE*HEIGHT)-1:0] write_addr;
logic [$clog2(PARTITION_SIZE)-1:0] column_count;
logic [$clog2(HEIGHT)-1:0] row_count;
logic [$clog2(PARTITION_SIZE*HEIGHT)-1:0] write_addr_pipe;

always@(posedge clk) begin
  if (!run) begin
	  column_count <= 'b0;
	  row_count <= 'b0;
	  done <= 'b0;
    write_addr_pipe <= 'b0;
    write_addr <= 'b0;
	end
	else begin
	  column_count <= (column_count < PARTITION_SIZE - 1) ? column_count + 'b1 : 'b0;
	  row_count <= (column_count == PARTITION_SIZE - 1) ? row_count + 'b1 : row_count;
	  done <= ((column_count == PARTITION_SIZE - 2) && (row_count == HEIGHT - 1)) ? 1'b1: done;
    write_addr_pipe <=  (write_addr_pipe < PARTITION_SIZE*HEIGHT - 1) ? write_addr_pipe + 'b1 : write_addr_pipe;
    write_addr <= write_addr_pipe;
	end
end

always@(posedge clk) begin
	if (!run)
	  address_out <= address_in;
	else
	  address_out <= (column_count < PARTITION_SIZE - 1) ? address_out + 'b1 : address_out + (ARRAY_WIDTH-PARTITION_SIZE+1);
end


// always@(posedge clk) begin
// 	if (!run)
// 	  result_out <= 'b0;


endmodule
