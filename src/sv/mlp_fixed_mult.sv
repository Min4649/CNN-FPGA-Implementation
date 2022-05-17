module mlp_fixed_mul #(
// parameter for fixed point number, default is 11.5 (include sign bit)
 parameter INT_DIGIT,
 parameter DECIMAL_DIGIT
)
(input logic  signed [INT_DIGIT + DECIMAL_DIGIT - 1:0] a,
 input logic signed [INT_DIGIT + DECIMAL_DIGIT - 1:0] b,
 output logic signed [INT_DIGIT + DECIMAL_DIGIT - 1:0] result
 );

logic signed [2* (INT_DIGIT + DECIMAL_DIGIT) - 1 : 0] partial;
assign partial =  a * b;
assign result = partial [  INT_DIGIT + 2 * DECIMAL_DIGIT - 1: DECIMAL_DIGIT] ;

endmodule
