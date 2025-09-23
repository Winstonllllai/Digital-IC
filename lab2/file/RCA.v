module RCA#(
	parameter X_WIDTH = 4,
	parameter Y_WIDTH = 4,
	parameter S_WIDTH = 4
)(
	input  [X_WIDTH-1:0]   x,
	input  [Y_WIDTH-1:0]   y,
	input 		c_in,
	output [S_WIDTH-1:0]   s,
	output     c_out
);
/*
	Write Your Design Here ~
*/
wire [S_WIDTH:0] carry;
wire [S_WIDTH-1:0] padded_x;
wire [S_WIDTH-1:0] padded_y;
assign padded_x = x;
assign padded_y = y;
assign carry[0] = c_in;
assign c_out = carry[S_WIDTH];
genvar i;

generate
	for(i=0;i<S_WIDTH;i=i+1) begin: adder_block
		FA adder(
			.x(padded_x[i]),
			.y(y[i]),
			.c_in(carry[i]),
			.s(s[i]),
			.c_out(carry[i+1])
		);
	end
endgenerate
endmodule
