
`timescale 1ns/10ps
module LBP ( 
    input         clk       , 
    input         reset     , 
    output [13:0] RGB_addr  , 
    output        RGB_req   , 
    input         RGB_ready , 
    input  [23:0] RGB_data  ,
    output [13:0] lbp_addr  , 
    output        lbp_valid , 
    output [7:0]  lbp_data  , 
    output [13:0] gray_addr , 
    output        gray_valid, 
    output [7:0]  gray_data , 
    output        finish
);

/*
	Write Your Design Here ~
*/

endmodule
