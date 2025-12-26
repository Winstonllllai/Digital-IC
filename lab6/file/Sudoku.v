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
	parameter INIT = 3'b000, SEARCH = 3'b001,TRY = 3'b010, BACKTRACK = 3'b011, WRITE = 3'b100, DONE = 3'b101;

	reg [2:0] state, next_state;
	reg [3:0] board [0:80];
	reg [80:0] fix_mask;
	reg [9:0] row_mask[0:8];
	reg [9:0] col_mask[0:8];
	reg [9:0] block_mask[0:8];
	reg [3:0] cur_x;
	reg [3:0] cur_y;
	reg [3:0] cur_box;
	reg backtracking;
	reg [3:0] next_val;
	wire [7:0] cur_ptr;
	wire [9:0] used_num;
	wire [9:0] available_num;
	
	integer i;
	reg rom_step;

	// Controller
	always @(posedge clk or posedge rst)begin
		if(rst) state <= INIT;
		else state <= next_state;
	end

	always @(*)begin
		case(state)
			INIT:begin
				next_state = INIT;
				if(cur_y == 8 && cur_x == 8 && rom_step == 1'b1) next_state = SEARCH;
			end
			SEARCH:begin
                next_state = SEARCH;
				if(cur_y == 9) next_state = WRITE;
				else if(fix_mask[cur_ptr] == 1'b0) next_state = TRY;
			end
			TRY:begin
                next_state = (next_val <= 9)? SEARCH : BACKTRACK;
			end
			BACKTRACK:begin
                next_state = SEARCH;
			end
			WRITE:begin
                next_state = WRITE;
				if(cur_ptr == 80) next_state = DONE;
			end
			DONE:begin
                next_state = DONE;
			end
			default:begin
				next_state = INIT;
			end
		endcase
	end

	//Datapath
	assign cur_ptr = (cur_y << 3) + (cur_y + cur_x);

	always @(*) begin
		if(cur_x <= 2)begin
			cur_box = (cur_y <= 2)? 4'b0000 : ((cur_y <= 5)? 4'b0001 : 4'b0010);
		end
		else if(cur_x <= 5)begin
			cur_box = (cur_y <= 2)? 4'b0011 : ((cur_y <= 5)? 4'b0100 : 4'b0101);
		end
		else begin
			cur_box = (cur_y <= 2)? 4'b0110 : ((cur_y <= 5)? 4'b0111 : 4'b1000);
		end
	end

	always @(*)begin
		next_val = 4'd15;
		for (i = 9; i >= 1; i = i - 1) begin
			if (available_num[i] && (i > board[cur_ptr])) begin
				next_val = i;
			end
		end
	end

	assign ROM_A = cur_ptr;
	assign RAM_A = cur_ptr;
	assign ROM_rd = (state == INIT)? 1'b1 : 1'b0;
	assign RAM_ceb = (state == WRITE);
	assign RAM_web = (state == WRITE)? 1'b0 : 1'b1;
	assign RAM_D = board[cur_ptr];
	assign done = (state == DONE)? 1'b1 : 1'b0;
	assign used_num = row_mask[cur_y] | col_mask[cur_x] | block_mask[cur_box];
	assign available_num = ~used_num;

	
	always @(posedge clk or posedge rst)begin
		if(rst) begin
			cur_x <= 4'b0;
			cur_y <= 4'b0;
			for(i=0;i<9;i=i+1)begin
				row_mask[i] <= 0;
				col_mask[i] <= 0;
				block_mask[i] <= 0;
			end
			rom_step <= 1'b0;
			backtracking <= 1'b0;
		end
		else begin
			case(state)
				INIT:begin
					if(rom_step == 1'b0) begin
						rom_step <= 1'b1;
					end
					else begin
						if(ROM_Q != 8'b0)begin
							board[cur_ptr] <= ROM_Q;
							fix_mask[cur_ptr] <= 1'b1;
							row_mask[cur_y] <= row_mask[cur_y] | (1 << ROM_Q);
							col_mask[cur_x] <= col_mask[cur_x] | (1 << ROM_Q);
							block_mask[cur_box] <= block_mask[cur_box] | (1 << ROM_Q);
						end
						else begin
							board[cur_ptr] <= 4'b0;
							fix_mask[cur_ptr] <= 1'b0;
						end
						if(cur_x == 8)begin
							cur_x <= 0;
							if(cur_y == 8) cur_y <= 0;
							else cur_y <= cur_y + 1;
						end
						else cur_x <= cur_x + 1;
						
						rom_step <= 1'b0;
					end
				end
				SEARCH:begin
					if(cur_ptr <= 80)begin
						if(fix_mask[cur_ptr] == 1'b1)begin
							case(backtracking)
								1'b0:begin
									if(cur_x == 8)begin
										cur_x <= 0;
										cur_y <= cur_y + 1;
									end
									else cur_x <= cur_x + 1;
								end
								1'b1:begin
									if(cur_x == 0)begin
										cur_x <= 8;
										cur_y <= cur_y - 1;
									end
									else cur_x <= cur_x - 1;
								end
							endcase
						end
					end
					else begin
						cur_x <= 4'b0;
						cur_y <= 4'b0;
					end
				end
				TRY:begin
					if (next_val <= 9) begin
                        row_mask[cur_y]   <= (row_mask[cur_y]   & ~(1 << board[cur_ptr])) | (1 << next_val);
                        col_mask[cur_x]   <= (col_mask[cur_x]   & ~(1 << board[cur_ptr])) | (1 << next_val);
                        block_mask[cur_box] <= (block_mask[cur_box] & ~(1 << board[cur_ptr])) | (1 << next_val);
                        
                        board[cur_ptr] <= next_val;
                        backtracking   <= 1'b0;
                        
                        if(cur_x == 8) begin
                            cur_x <= 0;
                            cur_y <= cur_y + 1;
                        end
                        else cur_x <= cur_x + 1;
					end
				end
				BACKTRACK:begin
					board[cur_ptr] <= 4'b0;
					row_mask[cur_y]   <= row_mask[cur_y]   & ~(1 << board[cur_ptr]);
					col_mask[cur_x]   <= col_mask[cur_x]   & ~(1 << board[cur_ptr]);
					block_mask[cur_box] <= block_mask[cur_box] & ~(1 << board[cur_ptr]);
					backtracking <= 1'b1;
					if(cur_x == 0)begin
						cur_x <= 8;
						cur_y <= cur_y - 1;
					end
					else cur_x <= cur_x - 1;
				end
				WRITE:begin
					if(cur_ptr < 80)begin
						if(cur_x == 8)begin
							cur_x <= 0;
							cur_y <= cur_y + 1;
						end
						else cur_x <= cur_x + 1;
					end
					else begin
						cur_x <= 4'b0;
						cur_y <= 4'b0;
					end
				end
			endcase
		end
	end

endmodule