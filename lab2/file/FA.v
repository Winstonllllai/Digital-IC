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
assign {c_out, s} = x + y + c_in;

endmodule

