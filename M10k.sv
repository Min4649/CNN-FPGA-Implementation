module M10K#(
    parameter ITE_NUM = 100,
    parameter DATA_WIDTH = 10,
    parameter ADDR_WIDTH = 10
)
(
    output reg [DATA_WIDTH - 1:0] q,
    input [DATA_WIDTH - 1:0] d,
    input [ADDR_WIDTH - 1:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 307200 words of 8 bits
    reg [DATA_WIDTH-1:0] mem [ITE_NUM-1:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 reg [DATA_WIDTH - 1:0] out_q;
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        out_q <= mem[read_address]; // q doesn't get d in this clock cycle
		q <= out_q;
	 end
endmodule
