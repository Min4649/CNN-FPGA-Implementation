module DataProcessBranch_tb();

// parameter DATA_WIDTH = 27;
// parameter FRACTION_WIDTH = 8;
// parameter ADDR_WIDTH = 10;
// parameter CONV_PARTITION_WIDTH = 5;
// parameter CONV_PARTITION_HEIGHT = 5;
// parameter CONV_LAYER_WIDTH = 28;
// parameter CONV_LAYER_HEIGHT = 28;
// parameter CHANNEL_NUM = 1;
// parameter CONV_RESULT_WIDTH = 24;
// parameter CONV_RESULT_HEIGHT = 24;

parameter DATA_WIDTH = 27;
parameter FRACTION_WIDTH = 8;
parameter ADDR_WIDTH = 10;
parameter CONV_PARTITION_WIDTH = 3;
parameter CONV_PARTITION_HEIGHT = 3;
parameter CONV_LAYER_WIDTH = 12;
parameter CONV_LAYER_HEIGHT = 12;
parameter CHANNEL_NUM = 2;
parameter CONV_RESULT_WIDTH = 10;
parameter CONV_RESULT_HEIGHT = 10;


logic clk;
logic reset;
logic run;

always
   #5 clk = ~ clk;

initial begin
clk = 0;
run = 0;
reset = 1;
#25
reset = 0;
#10
run = 1;
#10
run = 0;
end

DataProcessBranch#(
    DATA_WIDTH,
    FRACTION_WIDTH,
    ADDR_WIDTH,
    CONV_PARTITION_WIDTH,
    CONV_PARTITION_HEIGHT,
    CONV_LAYER_WIDTH,
    CONV_LAYER_HEIGHT,
    CHANNEL_NUM,
    CONV_RESULT_WIDTH,
    CONV_RESULT_HEIGHT
) dataProcessBranch
(
    .clk(clk), 
    .reset(reset), 
    .run(run),
    .conv_data(),
    .conv_kernel(),
    .conv_data_addr(),
    .conv_kernel_addr(),
    .read_address(),
    .out_result_test()
);

endmodule