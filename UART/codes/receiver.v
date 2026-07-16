module receiver(
    input clk,
    input rx,
    input baud_tick,
    input rst,
    output reg [7:0] data_out,
    output reg parity_error,
    output reg data_ready
);
reg [2:0] state, bit_count;
reg [7:0] shift_reg;
parameter IDLE = 3'b000;
parameter START = 3'b001;
parameter DATA = 3'b010;
parameter PARITY = 3'b011;
parameter STOP = 3'b100;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= IDLE;
        shift_reg <=0;
        bit_count <=0;
        data_out <=0;
        data_ready<=0;
        parity_error<=0;
    end
    else 
    begin 
        case(state) 
        IDLE :
        begin
            parity_error <=0;
            data_ready <= 1'b0;
            if(rx==0) begin
                state <= START;
                bit_count <=0;
            end
        end
        START : 
        begin
            if(baud_tick) begin
                state <= DATA;
            end
        end
        DATA :
        begin
            if(baud_tick) begin
                shift_reg[bit_count]<=rx;
                if(bit_count == 3'd7) begin
                    state <= PARITY;
                end
                else begin
                    bit_count <= bit_count+1;
                end
            end
        end
        PARITY :
        begin
            if(baud_tick) begin
                if(^shift_reg == rx) begin
                    state <= STOP;
                end
                else begin
                    parity_error <= 1'b1;
                    state<=IDLE;
                end
            end
        end
        STOP:
        begin
            if(baud_tick) begin
                if(rx==1) begin
                    data_out <= shift_reg;
                    data_ready <=1 ;
                    state <= IDLE;
                end
                else begin
                    data_ready <=1'b0;
                    state <= IDLE;
                end
            end
        end
        endcase
    end
end
endmodule


