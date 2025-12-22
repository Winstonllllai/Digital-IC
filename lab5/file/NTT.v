`include "BU.v"
module  NTT(
    input         clk, 
    input         rst, 
    output        input_ready,
    input         input_valid,
    input  [22:0] input_data,
    output  [7:0] tf_addr,
    input  [22:0] tf_data,
    output        output_valid,
    output [22:0] output_data
);

/*
	Write Your Design Here ~
*/  
    wire [22:0] x, y, tf, a, b;

    reg [7:0] len;
    reg [7:0] m, rd_count, wr_count;
    reg [8:0] start, j;
    reg [1:0] state, next_state;
    reg [22:0] w_mem [0:255];

    parameter IDLE = 2'b00, LOAD = 2'b01, CALC = 2'b10, OUT = 2'b11;

    always @(posedge clk or posedge rst)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*)begin
        case(state)
            IDLE:begin
                if(input_valid)next_state = LOAD;
                else next_state = IDLE;
            end
            LOAD:begin
                next_state = LOAD;
                if(rd_count == 255 && input_valid) next_state = CALC;
            end
            CALC:begin
                next_state = CALC;
                if(len < 1) next_state = OUT;
            end
            OUT:begin
                next_state = OUT;
                if(wr_count >= 255) next_state = IDLE;
            end
            default:begin
                next_state = IDLE;
            end
        endcase
    end

    assign tf_addr = m;
    assign x = w_mem[j];
    assign y = w_mem[j+len];
    assign tf = tf_data;
    assign output_valid = (state == OUT);
    assign output_data = w_mem[wr_count];
    assign input_ready = (state == IDLE || state == LOAD);

    always @(posedge clk or posedge rst)begin
        if(rst) begin
            m <= 1;
            len <= 128;
            start <= 0;
            j <= 0;
            rd_count <= 0;
            wr_count <= 0;
        end
        else begin
            case(state)
                IDLE:begin
                    len <= 128;
                    m <= 1;
                    start <= 0;
                    j <= 0;
                    rd_count <= 0;
                    wr_count <= 0;
                    if(input_valid) begin
                        w_mem[0] <= input_data;
                        rd_count <= 1;
                    end
                end
                LOAD:begin
                    if(input_valid)begin
                        rd_count <= rd_count + 1;
                        w_mem[rd_count] <= input_data;
                    end
                end
                CALC:begin
                    if(len >= 1)begin
                        if(start < 256)begin
                            if(j < (start + len - 1))begin
                                w_mem[j+len] <= b;
                                w_mem[j] <= a;
                                j <= j + 1;
                            end
                            else begin
                                w_mem[j+len] <= b;
                                w_mem[j] <= a;
                                m <= m + 1;
                                start <= start + (len << 1);
                                j <= start + (len << 1);
                            end
                        end
                        else begin
                            len <= len >> 1;
                            start <= 0;
                            j <= 0;
                        end
                    end
                end
                OUT:begin
                    wr_count <= wr_count + 1;
                end
                default:begin
                    
                end
            endcase 
        end
    end

    BU butterfly(
        .X(x),
        .Y(y),
        .TF(tf),
        .A(a),
        .B(b)
    );
endmodule