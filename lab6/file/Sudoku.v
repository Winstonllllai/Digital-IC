module Sudoku(
	input        clk     , 
	input        rst     , 
	output       ROM_rd  , 
	output [6:0] ROM_A   , 
	input  [7:0] ROM_Q   , 
	output       RAM_ceb , 
	output       RAM_web ,
	output [7:0] RAM_D   , 
	output [6:0] RAM_A   ,
	input  [7:0] RAM_Q	 , 
	output       done      
);

endmodule