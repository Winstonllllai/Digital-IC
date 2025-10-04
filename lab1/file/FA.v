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

