module DataProcessBranch#(
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
    input logic [DATA_WIDTH-1:0] conv_kernel,
    input logic [DATA_WIDTH-1:0] conv_bias,
    output logic [ADDR_WIDTH-1:0] conv_data_addr,
    output logic [ADDR_WIDTH-1:0] conv_kernel_addr,

    input logic [ADDR_WIDTH-1:0] read_address,
    output logic [DATA_WIDTH-1:0] out_result_test,

    output logic [ADDR_WIDTH-1:0] channel_count,
    
    output logic done
);

logic [DATA_WIDTH-1:0] conv_result_in;
logic [ADDR_WIDTH-1:0] conv_result_write_addr;
logic conv_result_write_en;

logic [DATA_WIDTH-1:0] merger_result_out, maxrelu_result_in;
logic [ADDR_WIDTH-1:0] merger_result_read_addr, maxrelu_result_write_addr;
logic maxrelu_result_write_en;

logic [DATA_WIDTH-1:0] conv_result_out, merger_result_in;
logic [ADDR_WIDTH-1:0] conv_result_read_addr, merger_result_write_addr;
logic merger_result_write_en;

logic [ADDR_WIDTH-1:0] max_relu_result_read_addr;
logic [DATA_WIDTH-1:0] max_relu_result_out;

always@(*) begin
    if (M10K_read_select == 3'b001) begin
        out_result_test = conv_result_out;
    end
    else if (M10K_read_select == 3'b010) begin
        out_result_test = merger_result_out;
    end
    else if (M10K_read_select == 3'b100) begin
        out_result_test = max_relu_result_out;
    end
    else begin
        out_result_test = max_relu_result_out;
    end
end

generate 
    if (CHANNEL_NUM > 1) begin
        wire conv_done;
        ConvTop #(
        .PARTITION_WIDTH(CONV_PARTITION_WIDTH),
        .PARTITION_HEIGHT(CONV_PARTITION_HEIGHT),
        .LAYER_WIDTH(CONV_LAYER_WIDTH),
        .LAYER_HEIGHT(CONV_LAYER_HEIGHT),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACTION_WIDTH(FRACTION_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .CHANNEL_NUM(CHANNEL_NUM)
        ) conv
        (   .clk(clk),
            .reset(reset),
            .run(run),
            .data_0_in(conv_data),
            .data_1_in(conv_kernel),
            .bias_in(conv_bias),
            .read_address_0_out(conv_data_addr),
            .read_address_1_out(conv_kernel_addr),
            
            .write_address_out(conv_result_write_addr),
            .we_out(conv_result_write_en),
            .result_out(conv_result_in),
            .conv_done(conv_done),

            .channel_count(channel_count)
            );
            
        M10K #(
            .ITE_NUM(CONV_RESULT_WIDTH*CONV_RESULT_HEIGHT*CHANNEL_NUM),
            .ADDR_WIDTH(ADDR_WIDTH),
            .DATA_WIDTH (DATA_WIDTH)
        ) conv_2_result_mem(
            .clk(clk),	 
            .d (conv_result_in),
            .write_address (conv_result_write_addr),
            .we (conv_result_write_en),
            
            .read_address ((M10K_read_select == 3'b001) ? read_address:conv_result_read_addr),
            .q (conv_result_out)
            );
            
        wire merge_done;
        Merger #(
        .PARTITION_WIDTH(CONV_RESULT_WIDTH),
        .PARTITION_HEIGHT(CONV_RESULT_HEIGHT),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ADDRESS_0_IN(0),
        .ADDRESS_1_IN(CONV_RESULT_WIDTH*CONV_RESULT_HEIGHT)
        ) merger
        (   .clk(clk),
            .reset(reset),
            .run(conv_done),
            .data_in(conv_result_out),
            .read_address_out(conv_result_read_addr),

            .result_out(merger_result_in),
            .write_address_out(merger_result_write_addr),
            .we_out(merger_result_write_en),
            .merge_done(merge_done)
            );

        M10K #(
            .ITE_NUM(CONV_RESULT_WIDTH*CONV_RESULT_HEIGHT),
            .ADDR_WIDTH(ADDR_WIDTH),
            .DATA_WIDTH (DATA_WIDTH)
        ) merger_result_mem(
            .clk(clk),
            .d (merger_result_in),
            .write_address (merger_result_write_addr),
            .we (merger_result_write_en),
            
            .q (merger_result_out),
            .read_address ((M10K_read_select == 3'b010) ? read_address:merger_result_read_addr)
            );
        
        logic maxrelu_done;
        assign done = maxrelu_done;
        MaxPool2x2ReluTop #(
        .LAYER_WIDTH(CONV_RESULT_WIDTH),
        .LAYER_HEIGHT(CONV_RESULT_HEIGHT),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
        ) maxPool2x2Relu
        (   .clk(clk),
            .reset(reset),
            .run(merge_done),
            .data_0_in(merger_result_out),
            .read_address_0_out(merger_result_read_addr),

            .result_out(maxrelu_result_in),
            .write_address_out(maxrelu_result_write_addr),
            .we_out(maxrelu_result_write_en),
            .maxrelu_done(maxrelu_done)
            );
            
        M10K #(
            .ITE_NUM(CONV_RESULT_HEIGHT/2*CONV_RESULT_HEIGHT/2),
            .ADDR_WIDTH(ADDR_WIDTH),
            .DATA_WIDTH (DATA_WIDTH)
        ) maxrelu_result_in_mem(
            .clk(clk),
            .d (maxrelu_result_in),
            .write_address (maxrelu_result_write_addr),
            .we (maxrelu_result_write_en),

            .read_address ((M10K_read_select == 3'b100) ? read_address:read_address),
            .q (max_relu_result_out)
            );
    end
    else begin
        wire conv_done;
        ConvTop #(
        .PARTITION_WIDTH(CONV_PARTITION_WIDTH),
        .PARTITION_HEIGHT(CONV_PARTITION_HEIGHT),
        .LAYER_WIDTH(CONV_LAYER_WIDTH),
        .LAYER_HEIGHT(CONV_LAYER_HEIGHT),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACTION_WIDTH(FRACTION_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .CHANNEL_NUM(CHANNEL_NUM)
        ) conv
        (   .clk(clk),
            .reset(reset),
            .run(run),
            .data_0_in(conv_data),
            .data_1_in(conv_kernel),
				.bias_in(conv_bias),
            .read_address_0_out(conv_data_addr),
            .read_address_1_out(conv_kernel_addr),
            
            .write_address_out(conv_result_write_addr),
            .we_out(conv_result_write_en),
            .result_out(conv_result_in),
            .conv_done(conv_done),

            .channel_count(channel_count)
            );
            
        M10K #(
            .ITE_NUM(CONV_RESULT_WIDTH*CONV_RESULT_HEIGHT*CHANNEL_NUM),
            .ADDR_WIDTH(ADDR_WIDTH),
            .DATA_WIDTH (DATA_WIDTH)
        ) conv_2_result_mem(
            .clk(clk),	 
            .d (conv_result_in),
            .write_address (conv_result_write_addr),
            .we (conv_result_write_en),
            
            .read_address ((M10K_read_select == 3'b001) ? read_address:conv_result_read_addr),
            .q (conv_result_out)
            );

        logic maxrelu_done;
        assign done = maxrelu_done;
        MaxPool2x2ReluTop #(
        .LAYER_WIDTH(CONV_RESULT_WIDTH),
        .LAYER_HEIGHT(CONV_RESULT_HEIGHT),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
        ) maxPool2x2Relu
        (   .clk(clk),
            .reset(reset),
            .run(conv_done),
            .data_0_in(conv_result_out),
            .read_address_0_out(conv_result_read_addr),

            .result_out(maxrelu_result_in),
            .write_address_out(maxrelu_result_write_addr),
            .we_out(maxrelu_result_write_en),
            .maxrelu_done(maxrelu_done)
            );
            
        M10K #(
            .ITE_NUM(CONV_RESULT_HEIGHT/2*CONV_RESULT_HEIGHT/2),
            .ADDR_WIDTH(ADDR_WIDTH),
            .DATA_WIDTH (DATA_WIDTH)
        ) maxrelu_result_in_mem(
            .clk(clk),
            .d (maxrelu_result_in),
            .write_address (maxrelu_result_write_addr),
            .we (maxrelu_result_write_en),

            .read_address ((M10K_read_select == 3'b100) ? read_address:read_address),
            .q (max_relu_result_out)
            );
    end
endgenerate
endmodule