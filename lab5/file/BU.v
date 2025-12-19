module  BU(
    input       [22:0] X,
    input       [22:0] Y,
    input       [22:0] TF,
    output      [22:0] A,
    output      [22:0] B
);

/*
	Write Your Design Here ~
*/
wire [45:0] mul_1;
wire [39:0] mul_2;
wire [45:0] U;
wire [23:0] V, W, Q;
wire [24:0] V1;
wire [25:0] V2;
wire [35:0] V3;
wire [46:0] s_1;
wire [24:0] s_2, s_4, s_5;
wire [11:0] s_3;
wire [34:0] c_1;
wire [23:0] c_2;
wire [22:0] Product;
wire [23:0] sum_raw, sum_mod;
wire [23:0] diff_pos, diff_neg;


assign Q = 24'd8380417;
assign mul_1 = (TF * Y[22:17])<<17;
assign mul_2 = TF * Y[16:0];
RCA #(46, 40, 46)adder1(.x(mul_1), .y(mul_2), .c_in(1'b0), .s(s_1[45:0]), .c_out(s_1[46]));
assign U = s_1[45:0];
assign V = U[45:22];
RCA #(24, 14, 24)adder2(.x(V[23:0]), .y(V[23:10]), .c_in(1'b0), .s(V1[23:0]), .c_out(V1[24]));
assign c_1 = {V1, V[9:0]};
RCA #(23, 24, 24)adder3(.x(V[23:1]), .y(V[23:0]), .c_in(1'b0), .s(s_2[23:0]), .c_out(s_2[24]));
RCA #(25, 25, 25)adder4(.x(s_2), .y({V,1'b0}), .c_in(1'b0), .s(V2[24:0]), .c_out(V2[25]));
RCA #(14, 35, 35)adder5(.x(V2[25:12]), .y(c_1), .c_in(1'b0), .s(V3[34:0]), .c_out(V3[35]));
assign W = V3[34:11];
assign s_3 = W[23:13] - W[10:0];
assign c_2 = {(W[0]^s_3[10]), s_3[9:0], W[12:0]};
assign s_4 = U[23:0] - c_2[23:0];
assign s_5 = s_4 - Q;
assign Product = s_5[24] ? s_4[22:0] : s_5[22:0];
assign sum_raw = {1'b0, X} + {1'b0, Product};
assign sum_mod = sum_raw - Q;
assign A = sum_mod[23] ? sum_raw[22:0] : sum_mod[22:0];
assign diff_pos = {1'b0, X} - {1'b0, Product};
assign diff_neg = ({1'b0, X} + Q) - {1'b0, Product};
assign B = (X >= Product) ? diff_pos[22:0] : diff_neg[22:0];

endmodule

module HA(
	input  x,
	input  y,
	output s, 
	output c
);

/*
	Write Your Design Here ~
*/
assign {c, s} = x + y;

endmodule

module FA(
	input 	   x,
	input 	   y,
	input 	c_in,
	output     s, 
	output  c_out
);

/*
	Write Your Design Here ~
*/
wire s1, c_out1, c_out2;
HA adder1(
	.x(x),
	.y(y),
	.s(s1),
	.c(c_out1)
);
HA adder2(
	.x(c_in),
	.y(s1),
	.s(s),
	.c(c_out2)
);
assign c_out = c_out1 | c_out2;
endmodule

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
assign padded_x = {{S_WIDTH-X_WIDTH{1'b0}}, x};
assign padded_y = {{S_WIDTH-Y_WIDTH{1'b0}}, y};
assign carry[0] = c_in;
assign c_out = carry[S_WIDTH];
genvar i;

generate
	for(i=0;i<S_WIDTH;i=i+1) begin: adder_block
		FA adder(
			.x(padded_x[i]),
			.y(padded_y[i]),
			.c_in(carry[i]),
			.s(s[i]),
			.c_out(carry[i+1])
		);
	end
endgenerate
endmodule
