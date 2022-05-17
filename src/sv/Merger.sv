module Merger #(
 parameter PARTITION_WIDTH,
 parameter PARTITION_HEIGHT,
 parameter DATA_WIDTH,
 parameter ADDR_WIDTH,
 parameter ADDRESS_0_IN,
 parameter ADDRESS_1_IN
)
(   input logic clk,
    input logic reset,
    input logic run,
    input logic signed [DATA_WIDTH-1:0] data_in,
    output logic [ADDR_WIDTH-1:0] read_address_out,

    output logic signed [DATA_WIDTH-1:0] result_out,
    output logic [ADDR_WIDTH-1:0] write_address_out,
    output logic we_out,
    output logic merge_done
    );

typedef enum
{ STATE_WAIT,
  STATE_REQUEST_A,
  STATE_REQUEST_B,
  STATE_LOAD_A,
  STATE_LOAD_B,
  STATE_UPDATE_PARAMETERS,
  STATE_FINISHED
  } states;

states current_state, next_state;

always @( posedge clk ) begin
  if ( reset )
    current_state <= STATE_WAIT;
  else
    current_state <= next_state;
end

logic done;
logic signed [DATA_WIDTH-1:0] a, a_in, b, b_in;
assign result_out = a + b;
logic update;
assign we_out = update;

always @( posedge clk ) begin
    if (reset) begin
	  a <= 'b0;
	  b <= 'b0;
    end
    else begin
        a <= a_in;
        b <= b_in;
    end
end

logic [ADDR_WIDTH-1:0] column_count;
logic [ADDR_WIDTH-1:0] row_count;

assign done = (column_count == PARTITION_WIDTH - 1) && (row_count == PARTITION_HEIGHT - 1);
	
always@(posedge clk) begin
	if (reset) begin
	  column_count <= 'b0;
	  row_count <= 'b0;
	end
	else if (update) begin
	  column_count <= (column_count < PARTITION_WIDTH - 1) ? column_count + 'b1 : 'b0;
	  row_count <= (column_count == PARTITION_WIDTH - 1) ? row_count + 'b1 : row_count;
    end
end

logic [ADDR_WIDTH-1:0] read_address_0, read_address_1;
always@(posedge clk) begin
	if (reset) begin
      write_address_out <= 'b0;
	  read_address_0 <= ADDRESS_0_IN;
	  read_address_1 <= ADDRESS_1_IN;
    end
	else if (update) begin
      write_address_out <= write_address_out + 'b1;
	  read_address_0 <= read_address_0 + 'b1;
	  read_address_1 <= read_address_1 + 'b1;
    end
end

logic load_a_temp;
logic load_b_temp;
always@(*) begin
  next_state = current_state;
  a_in = a;
  b_in = b;
  read_address_out = 'b0;
  update = 'b0;
  load_a_temp = 'b0;
  load_b_temp = 'b0;
  merge_done = 'b0;
  case ( current_state )
    STATE_WAIT: begin
      if (run) begin
          next_state = STATE_REQUEST_A;
      end
    end
    STATE_REQUEST_A: begin
        read_address_out = read_address_0;
        next_state = STATE_REQUEST_B;
    end
    STATE_REQUEST_B: begin
        read_address_out = read_address_1;
        next_state = STATE_LOAD_A;
    end
    STATE_LOAD_A: begin
        a_in = data_in;
        load_a_temp = 1;
        next_state = STATE_LOAD_B;
    end
    STATE_LOAD_B: begin
        b_in = data_in;
        load_b_temp = 1;
        next_state = STATE_UPDATE_PARAMETERS;
    end
    STATE_UPDATE_PARAMETERS: begin
        update = 'b1;
        if (done) next_state = STATE_FINISHED;
        else next_state = STATE_REQUEST_A;
    end
    STATE_FINISHED: begin
        merge_done = 'b1;
        next_state = STATE_WAIT;
    end
    default: next_state = STATE_WAIT;
  endcase 
end

endmodule