module mlp_m10k_interface
( input rst, 
  input clk,
  input [$clog2(75)-1:0] read_addr_in,
  input [26:0] data_m10k0,
  input [26:0] data_m10k1,
  input [26:0] data_m10k2,

  output logic [$clog2(25)-1:0]read_addr_out,
  output [26:0] data_forward
);

logic [1:0] mem_sel_pipe_1,mem_sel_pipe_2;
logic [1:0] mem_sel_in;


always_comb begin 
   if(read_addr_in < 25) begin
       mem_sel_in = 2'b00;
       read_addr_out = read_addr_in; 
   end
   else if(read_addr_in < 50) begin
 	mem_sel_in =2'b01;
	read_addr_out = read_addr_in - 25; 
   end
   else begin
 	mem_sel_in = 2'b11;
	read_addr_out = read_addr_in - 50; 
   end
end

always_ff@(posedge clk) begin
   if(rst) begin
	mem_sel_pipe_1 <= 'd0;
	mem_sel_pipe_2 <= 'd0;
   end
   else begin
	mem_sel_pipe_1 <= mem_sel_in;
	mem_sel_pipe_2 <= mem_sel_pipe_1;
   end
end

assign data_forward = ( mem_sel_pipe_2 == 2'b00 ) ? data_m10k0 : (mem_sel_pipe_2 == 2'b01 ? data_m10k1 : data_m10k2);

endmodule