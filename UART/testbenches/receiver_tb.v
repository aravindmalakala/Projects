`timescale 1ns/1ps

module receiver_tb;

reg clk;
reg rst;
reg baud_tick;
reg rx;

wire [7:0] data_out;
wire parity_error;
wire data_ready;

// Instantiate Receiver
receiver uut(
    .clk(clk),
    .rx(rx),
    .baud_tick(baud_tick),
    .rst(rst),
    .data_out(data_out),
    .parity_error(parity_error),
    .data_ready(data_ready)
);

//---------------------------------
// Clock Generation
//---------------------------------
initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

//---------------------------------
// Baud Tick Generation
//---------------------------------
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

//---------------------------------
// Stimulus
//---------------------------------
initial
begin

    $dumpfile("receiver.vcd");
    $dumpvars(0,receiver_tb);

    rst = 1;
    rx = 1;

    #20;
    rst = 0;

    repeat(5) @(posedge clk);

    // Start Bit
    rx = 0;
    @(posedge baud_tick);

    // Data = 10101101 (LSB First)
    rx = 1; @(posedge baud_tick);   // bit0
    rx = 0; @(posedge baud_tick);   // bit1
    rx = 1; @(posedge baud_tick);   // bit2
    rx = 1; @(posedge baud_tick);   // bit3
    rx = 0; @(posedge baud_tick);   // bit4
    rx = 1; @(posedge baud_tick);   // bit5
    rx = 0; @(posedge baud_tick);   // bit6
    rx = 1; @(posedge baud_tick);   // bit7

    // Even Parity
    rx = 1;
    @(posedge baud_tick);

    // Stop Bit
    rx = 1;
    @(posedge baud_tick);

    repeat(20) @(posedge clk);

    $finish;

end

endmodule