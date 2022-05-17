module mlp_vec_loader #(
  parameter DATA_WIDTH = 27,
  parameter ARR_ROW_SIZE,
  parameter ARR_COLUMN_SIZE,
  parameter PARTITION_SIZE
)
(clk, rst, en_cnt, en_wrt, array, load_addr, load_data, load_done, addr_begin );

input logic clk, rst, en_cnt, en_wrt;
input logic [$clog2(ARR_ROW_SIZE)-1:0] addr_begin;
input logic signed [DATA_WIDTH-1:0] load_data;

output logic [$clog2(ARR_ROW_SIZE)-1:0] load_addr;
output logic load_done;
output logic  signed [DATA_WIDTH-1:0] array [PARTITION_SIZE-1:0];

logic load_done_pipe, load_done_pipe_2, load_done_pipe_3;
logic [$clog2(PARTITION_SIZE)-1:0] write_addr,write_addr_pipe;
mlp_arr_addr_gen #(
  	.PARTITION_SIZE(PARTITION_SIZE),
  	.HEIGHT('d1),
  	.ARRAY_SIZE(ARR_ROW_SIZE),
    .ARRAY_WIDTH(ARR_ROW_SIZE)
  ) Addr_gen

  ( .clk(clk),
    .run(en_cnt & (!rst) ),
    .address_in(addr_begin),
    .address_out(load_addr),
    .done(load_done_pipe),
    .write_addr(write_addr_pipe)
);
integer i;
always@(posedge clk) begin
  write_addr <= write_addr_pipe; 
load_done_pipe_3<= load_done_pipe_2;
  load_done_pipe_2 <= load_done;
  load_done <= load_done_pipe;
  if (en_wrt && (!load_done_pipe_3)) begin
    array[write_addr] <= load_data;
  end
  else begin
    for (i=0; i< PARTITION_SIZE; i = i +1)
      array[i] <= array[i];
  end
end
endmodule


module mlp_arr_loader #(
  parameter DATA_WIDTH = 27,
  parameter ARR_ROW_SIZE,
  parameter ARR_COLUMN_SIZE,
  parameter PARTITION_SIZE
)
(clk, rst, en_cnt, en_wrt, array, load_addr, load_data, load_done, addr_begin );
parameter ARRAY_SIZE = ARR_ROW_SIZE * ARR_COLUMN_SIZE;
input logic clk, rst, en_cnt, en_wrt;
input logic [$clog2(ARRAY_SIZE)-1:0] addr_begin;
input logic signed [DATA_WIDTH-1:0] load_data;

output logic [$clog2(ARRAY_SIZE)-1:0] load_addr;
output logic load_done;
output logic  signed [DATA_WIDTH-1:0] array [PARTITION_SIZE*ARR_COLUMN_SIZE-1:0];

logic load_done_pipe,load_done_pipe_1 ;
logic [$clog2(PARTITION_SIZE*ARR_COLUMN_SIZE)-1:0] write_addr, write_addr_pipe;
mlp_arr_addr_gen #(
  	.PARTITION_SIZE(PARTITION_SIZE),
  	.HEIGHT(ARR_COLUMN_SIZE),
  	.ARRAY_SIZE(ARRAY_SIZE),
    .ARRAY_WIDTH(ARR_ROW_SIZE)
  ) Addr_gen

  ( .clk(clk),
    .run(en_cnt & (!rst) ),
    .address_in(addr_begin),
    .address_out(load_addr),
    .done(load_done_pipe),
    .write_addr(write_addr_pipe)
);
integer i;
always@(posedge clk) begin
  write_addr <= write_addr_pipe;  
  load_done_pipe_1 <= load_done_pipe;
  load_done<= load_done_pipe_1;
  if (en_wrt)
    array[write_addr] <= load_data;
  else begin
    for (i=0; i< PARTITION_SIZE*ARR_COLUMN_SIZE; i = i +1)
      array[i] <= array[i];
  end
end
endmodule
