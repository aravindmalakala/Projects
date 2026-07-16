`timescale 1ns/1ps

module uart_top_tb;

reg clk;
reg rst;
reg tx_start;
reg [7:0] tx_data;

wire tx_busy;
wire [7:0] rx_data;
wire data_ready;
wire parity_error;

// Instantiate UART Top
uart_top uut(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy),
    .rx_data(rx_data),
    .data_ready(data_ready),
    .parity_error(parity_error)
);

//--------------------------------------------------
// Clock Generation (50 MHz)
//--------------------------------------------------
initial
begin
    clk = 0;
    forever #10 clk = ~clk;   // 20 ns period = 50 MHz
end

//--------------------------------------------------
// Stimulus
//--------------------------------------------------
initial
begin
    $dumpfile("uart_top.vcd");
    $dumpvars(0, uart_top_tb);

    rst = 1;
    tx_start = 0;
    tx_data = 8'hAD;

    #100;
    rst = 0;

    // Wait a few clock cycles
    repeat(10) @(posedge clk);

    // Start transmission
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
end

//--------------------------------------------------
// Timeout / Result Checking
//--------------------------------------------------
initial
begin
    fork

        // UART Completed Successfully
        begin
            wait(data_ready);

            $display("--------------------------------");
            $display("UART TEST PASSED");
            $display("Transmitted = %h", 8'hAD);
            $display("Received    = %h", rx_data);
            $display("Parity Error= %b", parity_error);
            $display("--------------------------------");

            #100;
            $finish;
        end

        // Timeout
        begin
            repeat(70000) @(posedge clk);

            $display("--------------------------------");
            $display("UART TEST FAILED (TIMEOUT)");
            $display("--------------------------------");

            $finish;
        end

    join
end

endmodule