module transmitter(
    input clk,
    input rst,
    input baud_tick,
    input tx_start,
    input [7:0] data,
    output reg tx,
    output reg tx_busy
);

reg [2:0] state;
reg [7:0] shift_reg;
reg [2:0] bit_count;
reg parity_bit;
parameter IDLE  = 3'b000;
parameter START = 3'b001;
parameter DATA  = 3'b010;
parameter PARITY= 3'b011;
parameter STOP  = 3'b100;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        tx <= 1'b1;
        tx_busy <= 1'b0;
        shift_reg <= 8'd0;
        bit_count <= 3'd0;
        parity_bit <=0;
    end
    else
    begin
        case(state)

            IDLE:
            begin
                tx <= 1'b1;
                tx_busy <= 1'b0;

                if(tx_start)
                begin
                    shift_reg <= data;
                    bit_count <= 3'd0;
                    tx_busy <= 1'b1;
                    state <= START;
                    parity_bit <= ^data;
                end
            end

            START:
            begin
                tx <= 1'b0;
                tx_busy <= 1'b1;

                if(baud_tick)
                    state <= DATA;
            end

            DATA:
            begin
                tx_busy <= 1'b1;
                tx <= shift_reg[0];

                if(baud_tick)
                begin
                    shift_reg <= shift_reg >> 1;

                    if(bit_count == 3'd7)
                        state <= PARITY;
                    else
                        bit_count <= bit_count + 1'b1;
                end
            end
            PARITY:
            begin
                tx <= parity_bit;
                tx_busy <=1;
                if(baud_tick) begin
                    state <= STOP;
                end
            end

            STOP:
            begin
                tx <= 1'b1;
                tx_busy <= 1'b1;

                if(baud_tick)
                begin
                    tx_busy <= 1'b0;
                    state <= IDLE;
                end
            end

            default:
                state <= IDLE;

        endcase
    end
end

endmodule