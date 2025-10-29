
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
    parameter IDLE       = 3'b000, 
            GRAY_READ   = 3'b001, 
            LBP_READ    = 3'b010, 
            WRITE_GRAY  = 3'b011, 
            WRITE_LBP   = 3'b100, 
            FINISH      = 3'b101;
    reg [7:0] gray_mem [0:16383];
    reg [2:0] state, next_state;
    reg [13:0] gray_counter;
    reg [6:0] lbp_row, lbp_col;
    wire gray_enable, lbp_enable;
    wire [13:0] lbp_counter;

    assign RGB_req = (state == GRAY_READ) ? 1'b1 : 1'b0;
    assign RGB_addr = (gray_counter < 16384) ? gray_counter : 14'd0;
    assign gray_addr = gray_counter;
    assign gray_valid = (state == WRITE_GRAY) ? 1'b1 : 1'b0;
    assign lbp_counter = (lbp_row << 7) + lbp_col;
    assign lbp_addr = lbp_counter;
    assign lbp_valid = (state == WRITE_LBP) ? 1'b1 : 1'b0;
    assign gray_enable = (state == WRITE_GRAY) ? 1'b1 : 1'b0;
    assign lbp_enable = (state == WRITE_LBP) ? 1'b1 : 1'b0;
    assign finish = (state == FINISH) ? 1'b1 : 1'b0;


    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            gray_counter <= 14'b0;
            lbp_row <= 7'd1;
            lbp_col <= 7'd1;
        end else begin
            state <= next_state;

            if(state == WRITE_GRAY) begin
                gray_mem[gray_counter] <= gray_data;
                gray_counter <= gray_counter + 1;
            end

            if(state == WRITE_LBP) begin
                if(lbp_col == 126) begin
                    lbp_row <= lbp_row + 1;
                    lbp_col <= 7'd1;
                end else begin
                    lbp_col <= lbp_col + 1;
                end
            end
        end
    end
    

    always @(*) begin
        case(state)
            IDLE: begin
                if(RGB_ready) next_state = GRAY_READ;
                else next_state = IDLE;
            end
            GRAY_READ: begin
                next_state = WRITE_GRAY;
            end
            LBP_READ: begin
                next_state = WRITE_LBP;
            end
            WRITE_GRAY: begin
                if(gray_counter == 16383) next_state = LBP_READ;
                else next_state = GRAY_READ;
            end
            WRITE_LBP: begin
                if(lbp_counter == 16254) next_state = FINISH;
                else next_state = LBP_READ;
            end
            FINISH: next_state = FINISH;
            default: next_state = IDLE;
        endcase 
    end

    rgb2gray u_rgb2gray (
        .enable(gray_enable),
        .rgb(RGB_data),
        .gray(gray_data)
    );
    
    gray2lbp u_gray2lbp (
        .enable(lbp_enable),
        .center(gray_mem[lbp_counter]),
        .neighbors({gray_mem[lbp_counter + 129], gray_mem[lbp_counter + 128], gray_mem[lbp_counter + 127],
                    gray_mem[lbp_counter + 1],                                gray_mem[lbp_counter - 1],
                    gray_mem[lbp_counter - 127], gray_mem[lbp_counter - 128], gray_mem[lbp_counter - 129]}),
        .lbp(lbp_data)
    );

endmodule


module rgb2gray (
    input         enable,
    input  [23:0] rgb,
    output [7:0]  gray
);
    wire [9:0] sum;
    assign sum = rgb[23:16] + rgb[15:8] + rgb[7:0];
    assign gray = enable? sum / 3 : 0;
endmodule


module gray2lbp (
    input         enable,
    input  [7:0] center,
    input  [63:0] neighbors,
    output reg [7:0] lbp
);
    reg [7:0] result [0:7];
    integer i;
    
    always @(*) begin
        for(i = 0; i < 8; i = i + 1) begin
            result[i] = (neighbors[8*i +: 8] >= center) ? (1 << i) : 0;
        end
        lbp = enable ? ((result[0] + result[1]) + (result[2] + result[3]) + (result[4] + result[5]) + (result[6] + result[7])) : 0;
    end
endmodule
