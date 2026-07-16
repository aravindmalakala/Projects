`timescale 1ns/1ps

module testone;

reg clk;
reg rst;
reg baud_tick;
reg tx_start;
reg [7:0] data;

wire tx;
wire tx_busy;

transmitter uut(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .data(data),
    .tx(tx),
    .tx_busy(tx_busy)
);

//-------------------------
// Clock Generation
//-------------------------
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

//-------------------------
// Baud Tick Generation
//-------------------------
initial
begin
    baud_tick = 0;

    forever
    begin
        repeat(10) @(posedge clk);
        baud_tick = 1;
        @(posedge clk);
        baud_tick = 0;
    end
end

//-------------------------
// Stimulus
//-------------------------
initial
begin

    $dumpfile("uart_parity.vcd");
    $dumpvars(0,testone);

    rst = 1;
    tx_start = 0;

    // 10101101 has FIVE 1's
    // Even parity bit should become 1
    data = 8'b10101101;

    #20;
    rst = 0;

    repeat(5) @(posedge clk);

    tx_start = 1;
    @(posedge clk);
    tx_start = 0;

    repeat(170) @(posedge clk);

    $finish;

end

endmodule