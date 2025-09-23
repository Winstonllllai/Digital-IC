module Mul_Mod (
    input  [22:0] A,
    input  [22:0] B,
    output [23:0] Z
);
/*
	Write Your Design Here ~
*/
wire [45:0] mul_1;
wire [39:0] mul_2;
wire [45:0] U;
wire [23:0] V;
wire [23:0] W;
wire [23:0] Y;
wire [23:0] Q;
wire [24:0] V1;
wire [25:0] V2;
wire [35:0] V3;
wire [46:0] s_1;
wire [24:0] s_2;
wire [11:0] s_3;
wire [24:0] s_4;
wire [24:0] s_5;
wire [34:0] c_1;
wire [23:0] c_2;

assign Q = 24'd8380417;
assign mul_1 = (A * B[22:17])<<17;
assign mul_2 = A * B[16:0];
FA #(46, 40, 46)adder1(.x(mul_1), .y(mul_2), .c_in(1'b0), .s(s_1[45:0]), .cout(s_1[46]));
assign U = s_1[45:0];
assign V = U[45:22];
FA #(24, 14, 24)adder2(.x(V[23:0]), .y(V[23:10]), .c_in(1'b0), .s(V1[23:0]), .cout(V1[24]));
assign c_1 = {V[9:0], V1};
FA #(23, 24, 24)adder3(.x(V[23:1]), .y(V[23:0]), .c_in(1'b0), .s(s_2[23:0]), .cout(s_2[24]));
FA #(25, 25, 25)adder4(.x(s_2), .y(({V[23:0],1'b0})), .c_in(1'b0), .s(V2[24:0]), .cout(V2[25]));
FA #(14, 35, 35)adder5(.x(V2[25:12]), .y(c_1), .c_in(1'b0), .s(V3[34:0]), .cout(V3[35]));
assign W = V3[34:11];
FA #(11, 11, 11)adder6(.x(~W[10:0]), .y(W[23:13]), .c_in(1'b0), .s(s_3[10:0]), .cout(s_3[11]));
assign c_2 = {W[12:0], s_3[9:0], (W[0]^s_3[10])};
assign Y = U[23:0];
FA #(24, 24, 24)adder7(.x(~c_2), .y(Y), .c_in(1'b0), .s(s_4[23:0]), .cout(s_4[24]));
FA #(24, 24, 24)adder8(.x(s_4[23:0]), .y(Q), .c_in(1'b0), .s(s_5[23:0]), .cout(s_5[24]));
assign Z = s_5[23]? s_4[23:0] : s_5[23:0];

endmodule
