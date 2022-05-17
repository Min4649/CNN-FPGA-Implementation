module mlp_matrix_mul_vect_top_wrapper #(
 parameter PARTITION_SIZE = 2,
//parameter for input data array size
 parameter ARR_ROW_SIZE = 4, // 4 elements per row
 parameter ARR_COLUMN_SIZE = 2,
// parameter for fixed point number, default is 22.5 (include sign bit)
 parameter DATA_WIDTH = 27,
 parameter FRACTION_WIDTH =9,
//parameter that not need to be initialized
 parameter VEC_SIZE = ARR_ROW_SIZE,
 parameter ARR_SIZE = ARR_ROW_SIZE * ARR_COLUMN_SIZE,
 parameter ITE_NUM = ARR_ROW_SIZE/PARTITION_SIZE
)
(clk,start, rst, vec_read_addr,vec_read_data, arr_read_addr, arr_read_data, done,
result_0,result_1,result_2,result_3,result_4,result_5,result_6,result_7,result_8,result_9,
);
//ports
input logic clk, rst, start;
output logic [$clog2(VEC_SIZE) - 1:0] vec_read_addr;
output logic [$clog2(ARR_SIZE) - 1 :0] arr_read_addr;
input logic signed [DATA_WIDTH-1:0] vec_read_data,  arr_read_data;
//for pio
output logic [DATA_WIDTH-1:0] result_0;
output logic [DATA_WIDTH-1:0] result_1;
output logic [DATA_WIDTH-1:0] result_2;
output logic [DATA_WIDTH-1:0] result_3;
output logic [DATA_WIDTH-1:0] result_4;
output logic [DATA_WIDTH-1:0] result_5;
output logic [DATA_WIDTH-1:0] result_6;
output logic [DATA_WIDTH-1:0] result_7;
output logic [DATA_WIDTH-1:0] result_8;
output logic [DATA_WIDTH-1:0] result_9;
output logic done;



parameter PE_NUM = ARR_COLUMN_SIZE; // each row has a PE
logic signed [DATA_WIDTH-1:0] data_arr [PARTITION_SIZE*ARR_COLUMN_SIZE-1 :0];
logic signed [DATA_WIDTH-1:0] wgt_vec  [PARTITION_SIZE-1 :0];
logic signed [DATA_WIDTH-1:0] result_vec [ARR_COLUMN_SIZE-1 :0];
logic signed [DATA_WIDTH-1:0] vec_doc_out [ARR_COLUMN_SIZE-1 :0];
logic signed [DATA_WIDTH-1:0] result_vec_in [ARR_COLUMN_SIZE-1 :0];


assign result_0 = result_vec[0];
assign result_1 = result_vec[1];
assign result_2 = result_vec[2];
assign result_3 = result_vec[3];
assign result_4 = result_vec[4];
assign result_5 = result_vec[5];
assign result_6 = result_vec[6];
assign result_7 = result_vec[7];
assign result_8 = result_vec[8];
assign result_9 = result_vec[9];

//========================== Control FSM =========================================
  //define states and regs
  logic [2:0] state_reg;
  logic [2:0] state_next;
  parameter STATE_IDLE = 'd0;
  parameter STATE_READ = 'd1;
  parameter STATE_CALC = 'd2;
  parameter STATE_COMP = 'd3;
  parameter STATE_DONE = 'd4;
  parameter STATE_PRE_READ = 'd5;
  parameter STATE_PRE_CALC = 'd6;
  // control signal to data path
  logic read_vec_done, read_done;
  logic arr_loader_en, vec_loader_en, vec_loader_en_pipe, arr_loader_en_pipe ;
  logic run_PE;
  logic [PE_NUM-1:0]pe_done;
  logic read_arr_done;
  logic all_pe_done;
  logic [$clog2(ITE_NUM)-1:0] ite_cnt;
  logic [$clog2(ITE_NUM)-1:0] ite_cnt_in;
  assign all_pe_done = & pe_done;
  assign read_done = read_arr_done & read_vec_done;
  // state transition
  integer n;
  always @(posedge clk) begin
    if(rst) begin
      state_reg <= STATE_IDLE;
      ite_cnt <= 0;
      for(n=0;n<PE_NUM;n=n+1) begin
        result_vec[n]<= 0;
      end
    end
    else begin
      result_vec <= result_vec_in;
      state_reg <= state_next;
      ite_cnt <= ite_cnt_in;
    end
  end
  always@(posedge clk) begin
    vec_loader_en_pipe <= vec_loader_en;
    arr_loader_en_pipe <= arr_loader_en;
  end


  integer i;
  always@(*) begin
    //--------- STATE_IDLE --------
    if(state_reg == STATE_IDLE)begin
      done = 0;
      run_PE = 0;
      ite_cnt_in = 0;
      arr_loader_en = 0;
      vec_loader_en = 0;
      for(i=0;i<PE_NUM;i=i+1) begin
        result_vec_in[i] = 0;
      end
      if(start) state_next = STATE_READ;
      else state_next = STATE_IDLE;
    end
    //---------- STATE_READ --------
    else if(state_reg == STATE_READ) begin
      done = 0;
      ite_cnt_in = ite_cnt;
      run_PE = 0;
      arr_loader_en = 1;
      vec_loader_en = 1;
      for(i=0;i<PE_NUM;i=i+1) begin
        result_vec_in[i] = 0;
      end
      if(read_done) state_next = STATE_CALC;
      else state_next = STATE_READ;
    end
    //---------- STATE_CALC --------
    else if(state_reg == STATE_CALC) begin
      done = 0;
      run_PE = 1;
      arr_loader_en = 0;
      vec_loader_en = 0;
      for(i=0;i<PE_NUM;i=i+1) begin
        result_vec_in[i] = vec_doc_out[i];
      end
      if(all_pe_done) begin
        if(ite_cnt == ITE_NUM-1) begin state_next = STATE_COMP; ite_cnt_in = ite_cnt; end
        else begin
          state_next = STATE_PRE_READ;
          ite_cnt_in = ite_cnt + 1;
        end
      end
      else begin state_next = STATE_CALC; ite_cnt_in = ite_cnt; end
    end
    //---------- STATE_PRE_READ --------
    else if(state_reg == STATE_PRE_READ) begin
      done = 0;
      ite_cnt_in = ite_cnt;
      run_PE = 0;
      arr_loader_en = 0;
      vec_loader_en = 0;
      for(i=0;i<PE_NUM;i=i+1) begin
        result_vec_in[i] = result_vec[i];
      end
      state_next = STATE_READ;
    end

    //---------- STATE_COMP --------
    else if(state_reg == STATE_COMP) begin
      done = 0;
      run_PE = 0;
		ite_cnt_in = ite_cnt;
      arr_loader_en = 0;
      vec_loader_en = 0;
      for(i=0;i<PE_NUM;i=i+1) begin
        result_vec_in[i] = vec_doc_out[i];
      end
      if(all_pe_done) state_next = STATE_DONE;
      else state_next = STATE_COMP;
    end
    //---------- STATE_DONE --------
    else if(state_reg == STATE_DONE) begin
      done = 1;
      run_PE = 0;
		ite_cnt_in = ite_cnt;
      arr_loader_en = 0;
      vec_loader_en = 0;
      for(i=0;i<PE_NUM;i=i+1) begin
        result_vec_in[i] = result_vec[i];
      end
      // if(all_pe_done) state_next = STATE_WRITE;
      // else state_next = STATE_COMP;
      state_next = STATE_DONE;
    end
	 else begin
		done = 0;
		run_PE = 0;
		ite_cnt_in = 0;
		arr_loader_en = 0;
		vec_loader_en = 0;
		state_next = STATE_IDLE;
	 end
  end

//=============== data path ========================
mlp_vec_loader #(.DATA_WIDTH(DATA_WIDTH), .ARR_ROW_SIZE(ARR_ROW_SIZE), .ARR_COLUMN_SIZE(ARR_COLUMN_SIZE), .PARTITION_SIZE(PARTITION_SIZE)) vec_loader (
  .clk(clk),
  .rst(rst),
  .en_cnt(vec_loader_en),
  .en_wrt(vec_loader_en),
  .array(wgt_vec),
  .load_addr(vec_read_addr),
  .load_data(vec_read_data),
  .load_done(read_vec_done),
  .addr_begin(ite_cnt*PARTITION_SIZE)
);

mlp_arr_loader #(.DATA_WIDTH(DATA_WIDTH), .ARR_ROW_SIZE(ARR_ROW_SIZE), .ARR_COLUMN_SIZE(ARR_COLUMN_SIZE), .PARTITION_SIZE(PARTITION_SIZE)) arr_loader (
  .clk(clk),
  .rst(rst),
  .en_cnt(arr_loader_en),
  .en_wrt(arr_loader_en),
  .array(data_arr),
  .load_addr(arr_read_addr),
  .load_data(arr_read_data),
  .load_done(read_arr_done),
  .addr_begin(ite_cnt*PARTITION_SIZE)
);


  genvar k;
  generate
  for (k=0; k<PE_NUM; k = k+1) begin: arr_dot_gen
    mlp_complete_vector_dot #(.SIZE(PARTITION_SIZE),
    	.DATA_WIDTH(DATA_WIDTH),
    	.FRACTION_WIDTH(FRACTION_WIDTH)
    ) dot_k
    ( .clk(clk),
      .run(run_PE),
      .reset(rst),
      .data_in(data_arr[PARTITION_SIZE*k+PARTITION_SIZE-1:PARTITION_SIZE*k]),
      .weights_in(wgt_vec),
      .bias_in('d0),
      .result_out(vec_doc_out[k]),
      .finished_out(pe_done[k])
    );
  end
  endgenerate
endmodule
