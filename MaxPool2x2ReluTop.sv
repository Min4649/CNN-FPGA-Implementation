module MaxPool2x2ReluTop #(
 parameter LAYER_WIDTH,
 parameter LAYER_HEIGHT,
 parameter DATA_WIDTH,
 parameter ADDR_WIDTH
)
(   input logic clk,
    input logic reset,
    input logic run,
    input logic signed [DATA_WIDTH-1:0] data_0_in,
    output logic [ADDR_WIDTH-1:0] read_address_0_out,

    output logic signed [DATA_WIDTH-1:0] result_out,
    output logic [ADDR_WIDTH-1:0] write_address_out,
    output logic we_out,
    output logic maxrelu_done
    );

parameter PARTITION_WIDTH = 2;
parameter PARTITION_HEIGHT = 2;
typedef enum
{ STATE_WAIT,
  STATE_STREAM_DATA,
  STATE_UPDATE_PARAMETERS,
  STATE_UPDATE_WAIT,
  STATE_FINISHED
  } states;
states current_state, next_state;

always @( posedge clk ) begin
  if ( reset )
    current_state <= STATE_WAIT;
  else
    current_state <= next_state;
end

logic [ADDR_WIDTH-1:0] column_count;
logic [ADDR_WIDTH-1:0] row_count;
logic update;

wire done;
assign done = (column_count == LAYER_WIDTH - PARTITION_WIDTH) && (row_count == LAYER_HEIGHT - PARTITION_HEIGHT);
	
always@(posedge clk) begin
	if (reset) begin
	  column_count <= 'b0;
	  row_count <= 'b0;
	end
	else if (update) begin
	  column_count <= (column_count < LAYER_WIDTH - PARTITION_WIDTH) ? column_count + 'd2 : 'b0;
	  row_count <= done ? 'b0 : (column_count == LAYER_WIDTH - PARTITION_WIDTH) ? row_count + 'd2 : row_count;
    end
end

logic [ADDR_WIDTH-1:0] data_start_address;

always@(posedge clk) begin
	if (reset) begin
	  data_start_address <= 'b0;
    end
	else if (update) begin
	  data_start_address <= done ? 'b0 : (column_count == LAYER_WIDTH - PARTITION_WIDTH) ? data_start_address + 2 + LAYER_WIDTH : data_start_address + 'd2;
    end
end

logic address_gen_run;
logic address_gen_done;
logic maxrelu_run_pipe0, maxrelu_run_pipe1, maxrelu_run;
logic we_pipe0, we_pipe1;
always@(posedge clk) begin
    if (reset) begin
	  maxrelu_run_pipe1 <= 'b0;
	  maxrelu_run <= 'b0;
      we_pipe1 <= 'b0;
    end
    else begin
	  maxrelu_run_pipe1 <= maxrelu_run_pipe0;
	  maxrelu_run <= maxrelu_run_pipe1;
	  we_pipe1 <= we_pipe0;
	  we_out <= we_pipe1;
    end
end

always@(*) begin
  next_state = current_state;
  update = 'b0;
  maxrelu_done = 'b0;
  address_gen_run = 'b0;
  maxrelu_run_pipe0 = 'b0;
  we_pipe0 = 'b0;
  case ( current_state )
    STATE_WAIT: begin
      if (run) begin
          next_state = STATE_STREAM_DATA;
      end
    end
    STATE_STREAM_DATA: begin
        maxrelu_run_pipe0 = 1;
        address_gen_run = 1;
        if (address_gen_done)
            next_state = STATE_UPDATE_PARAMETERS;
    end
    STATE_UPDATE_PARAMETERS: begin
        we_pipe0 = 'b1;
        update = 'b1;
        if (done) begin
            next_state = STATE_FINISHED;
        end
        else next_state = STATE_UPDATE_WAIT;
    end
    STATE_UPDATE_WAIT: begin
        next_state = STATE_STREAM_DATA;
    end
    STATE_FINISHED: begin
        maxrelu_done = 'b1;
        next_state = STATE_WAIT;
    end
    default: next_state = STATE_WAIT;
  endcase 
end

ReadAddressGen #(
	PARTITION_WIDTH,
	PARTITION_HEIGHT,
	LAYER_HEIGHT*LAYER_WIDTH,
	LAYER_WIDTH,
  ADDR_WIDTH
) dataReadAddressGen
( .clk(clk), 
  .run(address_gen_run),
  .address_in(data_start_address),
  .address_out(read_address_0_out),
  .done(address_gen_done));

MaxPool2x2Relu #(
	DATA_WIDTH,
	ADDR_WIDTH
) maxPool2x2Relu
(.clk(clk), 
 .reset(reset),
 .clear(we_out),
 .run(maxrelu_run),
 .data_in(data_0_in),

 .result_out(result_out),
 .address_out(write_address_out)
);

endmodule