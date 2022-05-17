module ConvL1Wrapper0#(
    parameter DATA_WIDTH,
    parameter FRACTION_WIDTH,
    parameter ADDR_WIDTH,
    parameter CONV_PARTITION_WIDTH,
    parameter CONV_PARTITION_HEIGHT,
    parameter CONV_LAYER_WIDTH,
    parameter CONV_LAYER_HEIGHT,
    parameter CHANNEL_NUM,
    parameter CONV_RESULT_WIDTH,
    parameter CONV_RESULT_HEIGHT
)
(
    input clk, reset, run,

    input logic [2:0] M10K_read_select,

    input logic [DATA_WIDTH-1:0] conv_data,
    output logic [ADDR_WIDTH-1:0] conv_data_addr,

    input logic [ADDR_WIDTH-1:0] result_read_address,
    output logic [DATA_WIDTH-1:0] result,
    
    output logic done
);

logic [DATA_WIDTH-1:0] conv_kernel;
logic [ADDR_WIDTH-1:0] conv_kernel_addr;

conv_1_weight_0	conv_1_weight_0_inst (
	.clock (clk),
	.data (),
	.rdaddress (conv_kernel_addr),
	.wraddress (),
	.wren (),
	.q (conv_kernel)
	);

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
    .M10K_read_select(M10K_read_select),
    .conv_data(conv_data),
    .conv_kernel(conv_kernel),
    .conv_bias('d9),
    .conv_data_addr(conv_data_addr),
    .conv_kernel_addr(conv_kernel_addr),
    .read_address(result_read_address),
    .out_result_test(result),
    .channel_count(),
    .done(done)
);

endmodule