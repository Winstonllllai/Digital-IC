module FIFO_sync(
    input             clk     ,
    input             rst     ,
    input             wr_en   ,
    input             rd_en   ,
    input       [7:0] data_in ,
    output            full    ,
    output            empty   ,
    output      [7:0] data_out
);

/*
	Write Your Design Here ~
*/
    wire wr_avail;
    wire rd_avail;
    wire [4:0] wr_ptr;
    wire [4:0] rd_ptr;

    FIFO_mem u_FIFO_mem (
        .clk    (clk    ),
        .rst    (rst    ),
        .wr_en  (wr_en  ),
        .rd_en  (rd_en  ),
        .wr_ptr (wr_ptr ),
        .rd_ptr (rd_ptr ),
        .data_in(data_in),
        .data_out(data_out),
        .empty  (empty  ),
        .full   (full   ),
        .wr_avail(wr_avail),
        .rd_avail(rd_avail)
    );
    FIFO_wr_ctrl u_FIFO_wr_ctrl (
        .clk    (clk    ),
        .rst    (rst    ),
        .wr_en (wr_avail),
        .wr_ptr (wr_ptr )
    );
    FIFO_rd_ctrl u_FIFO_rd_ctrl (
        .clk    (clk    ),
        .rst    (rst    ),
        .rd_en (rd_avail),
        .rd_ptr (rd_ptr )
    );

endmodule

module FIFO_mem(
    input             clk     ,
    input             rst     ,
    input             wr_en   ,
    input             rd_en   ,
    input        [4:0] wr_ptr ,
    input        [4:0] rd_ptr ,
    input       [7:0] data_in ,
    output reg  [7:0] data_out,
    output            full    ,
    output            empty   ,
    output            wr_avail,
    output            rd_avail
);
    reg [7:0] mem[0:31];
    reg [5:0] data_count;

    assign full = (data_count == 6'd32) ? 1'b1 : 1'b0;
    assign empty = (data_count == 6'd0) ? 1'b1 : 1'b0;
    assign wr_avail = !full && wr_en;
    assign rd_avail = !empty && rd_en;

    always@(posedge clk)begin
        if(rst)begin
            data_count <= 6'd0;
        end
        else begin
            case({wr_avail, rd_avail})
                2'b10: begin
                    data_count <= data_count + 1'b1;
                    mem[wr_ptr] <= data_in;
                end
                2'b01: begin
                    data_count <= data_count - 1'b1;
                    data_out <= mem[rd_ptr];
                end
                2'b11: begin
                    mem[wr_ptr] <= data_in;
                    data_out <= mem[rd_ptr];
                end
                default: begin
                    data_count <= data_count;
                    if(rd_en && empty) data_out <= 8'd0;
                end
            endcase
        end
    end
endmodule

module FIFO_wr_ctrl(
    input             clk     ,
    input             rst     ,
    input             wr_en   ,
    output    reg [4:0] wr_ptr
);
    always@(posedge clk)begin
        if(rst)begin
            wr_ptr <= 5'd0;
        end
        else if(wr_en)begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
endmodule

module FIFO_rd_ctrl(
    input             clk     ,
    input             rst     ,
    input             rd_en   ,
    output    reg [4:0] rd_ptr
);
    always@(posedge clk)begin
        if(rst)begin
            rd_ptr <= 5'd0;
        end
        else if(rd_en)begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
endmodule
