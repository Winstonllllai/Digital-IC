
`timescale 1ns / 10ps

module FourBankFIFO(
    input           clk         ,
    input           rst         ,
    input           wr_en_M0    ,
    input  [7:0]    data_in_M0  ,
    input           rd_en_M0    ,
    input  [1:0]    rd_id_M0    ,
    input           wr_en_M1    ,
    input  [7:0]    data_in_M1  ,
    input           rd_en_M1    ,
    input  [1:0]    rd_id_M1    ,
    output [7:0]    data_out_M0 ,
    output [7:0]    data_out_M1 ,
    output          valid_M0    ,
    output          valid_M1
);

    wire        to_M0, to_M1;
    wire        get_wr_en;
    wire        get_rd_en;
    wire        real_read_act;
    wire [7:0]  get_data_in;
    wire [1:0]  get_rd_id;
    wire [3:0]  full_vec, empty_vec;
    wire [3:0]  wr_en_vec, rd_en_vec;
    wire [7:0]  selected_data_out;
    wire [7:0]  data_out_vec [0:3];
    reg         r_valid_M0, r_valid_M1;
    reg [1:0]   last_rd_bank_id;

    MasterArbiter u_MasterArbiter(
        .clk(clk), .rst(rst),
        .wr_en_M0(wr_en_M0), .data_in_M0(data_in_M0), .rd_en_M0(rd_en_M0), .rd_id_M0(rd_id_M0),
        .wr_en_M1(wr_en_M1), .data_in_M1(data_in_M1), .rd_en_M1(rd_en_M1), .rd_id_M1(rd_id_M1),
        .to_M0(to_M0), .to_M1(to_M1),
        .get_data_in(get_data_in), .get_wr_en(get_wr_en), .get_rd_en(get_rd_en), .get_rd_id(get_rd_id)
    );

    FIFO_BankArbiter u_FIFO_BankArbiter(
        .clk(clk), .rst(rst),
        .get_wr_en(get_wr_en),
        .get_rd_en(get_rd_en),
        .get_rd_id(get_rd_id),
        .full_vec(full_vec),
        .empty_vec(empty_vec),
        .wr_en_vec(wr_en_vec),
        .rd_en_vec(rd_en_vec)
    );

    FIFO_sync Bank0 (.clk(clk), .rst(rst), .wr_en(wr_en_vec[0]), .rd_en(rd_en_vec[0]), .data_in(get_data_in), .data_out(data_out_vec[0]), .full(full_vec[0]), .empty(empty_vec[0]));
    FIFO_sync Bank1 (.clk(clk), .rst(rst), .wr_en(wr_en_vec[1]), .rd_en(rd_en_vec[1]), .data_in(get_data_in), .data_out(data_out_vec[1]), .full(full_vec[1]), .empty(empty_vec[1]));
    FIFO_sync Bank2 (.clk(clk), .rst(rst), .wr_en(wr_en_vec[2]), .rd_en(rd_en_vec[2]), .data_in(get_data_in), .data_out(data_out_vec[2]), .full(full_vec[2]), .empty(empty_vec[2]));
    FIFO_sync Bank3 (.clk(clk), .rst(rst), .wr_en(wr_en_vec[3]), .rd_en(rd_en_vec[3]), .data_in(get_data_in), .data_out(data_out_vec[3]), .full(full_vec[3]), .empty(empty_vec[3]));

    assign real_read_act = |rd_en_vec;
    assign data_out_M0 = selected_data_out;
    assign valid_M0    = r_valid_M0;
    assign data_out_M1 = selected_data_out;
    assign valid_M1    = r_valid_M1;
    assign selected_data_out = data_out_vec[last_rd_bank_id];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_valid_M0 <= 1'b0;
            r_valid_M1 <= 1'b0;
            last_rd_bank_id <= 2'b0;
        end 
        else begin
            if (to_M0 && real_read_act) r_valid_M0 <= 1'b1;
            else r_valid_M0 <= 1'b0;

            if (to_M1 && real_read_act) r_valid_M1 <= 1'b1;
            else r_valid_M1 <= 1'b0;

            if (real_read_act) begin
                last_rd_bank_id <= get_rd_id;
            end
        end
    end

endmodule

module MasterArbiter(
    input           clk,
    input           rst,
    input           wr_en_M0,
    input  [7:0]    data_in_M0,
    input           rd_en_M0,
    input  [1:0]    rd_id_M0,
    input           wr_en_M1,
    input  [7:0]    data_in_M1,
    input           rd_en_M1,
    input  [1:0]    rd_id_M1,
    output reg      to_M0,
    output reg      to_M1,
    output reg [7:0] get_data_in,
    output reg       get_wr_en,
    output reg       get_rd_en,
    output reg [1:0] get_rd_id
);
    wire req_M0;
    wire req_M1;
    reg nextM;
    reg nextM_comb;

    assign req_M0 = wr_en_M0 | rd_en_M0;
    assign req_M1 = wr_en_M1 | rd_en_M1;

    always @(posedge clk or posedge rst) begin
        if (rst) nextM <= 1'b0;
        else     nextM <= nextM_comb;
    end

    always @(*) begin
        to_M0 = 1'b0;
        to_M1 = 1'b0;
        get_data_in = 8'b0;
        get_wr_en   = 1'b0;
        get_rd_en   = 1'b0;
        get_rd_id   = 2'b0;
        nextM_comb = nextM;

        if (req_M0 && req_M1) begin
            if (nextM == 1'b0) begin
                to_M0 = 1'b1;
                nextM_comb = 1'b1;
            end else begin
                to_M1 = 1'b1;
                nextM_comb = 1'b0;
            end
        end 
        else if (req_M0) begin
            to_M0 = 1'b1;
            nextM_comb = 1'b1;
        end 
        else if (req_M1) begin
            to_M1 = 1'b1;
            nextM_comb = 1'b0;
        end

        if (to_M0) begin
            get_data_in = data_in_M0;
            get_wr_en   = wr_en_M0;
            get_rd_en   = rd_en_M0;
            get_rd_id   = rd_id_M0;
        end 
        else if (to_M1) begin
            get_data_in = data_in_M1;
            get_wr_en   = wr_en_M1;
            get_rd_en   = rd_en_M1;
            get_rd_id   = rd_id_M1;
        end
    end
endmodule

module FIFO_BankArbiter(
    input            clk,
    input            rst,
    input            get_wr_en,
    input            get_rd_en,
    input [1:0]      get_rd_id,
    input [3:0]      full_vec,
    input [3:0]      empty_vec,
    output reg [3:0] wr_en_vec,
    output reg [3:0] rd_en_vec
);
    reg [1:0] lru_prio [0:3];
    wire wr_en;

    assign wr_en = |wr_en_vec;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lru_prio[0] <= 2'd0;
            lru_prio[1] <= 2'd1;
            lru_prio[2] <= 2'd2;
            lru_prio[3] <= 2'd3;
        end
        else if (wr_en) begin
            lru_prio[0] <= lru_prio[1];
            lru_prio[1] <= lru_prio[2];
            lru_prio[2] <= lru_prio[3];
            lru_prio[3] <= lru_prio[0];
        end
    end

    always @(*) begin
        wr_en_vec = 4'b0;
        rd_en_vec = 4'b0;

        if (get_wr_en) begin
            if(!full_vec[lru_prio[0]]) wr_en_vec[lru_prio[0]] = 1'b1;
        end

        if (get_rd_en) begin
            if(!empty_vec[get_rd_id]) rd_en_vec[get_rd_id] = 1'b1;
        end
    end

endmodule