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
