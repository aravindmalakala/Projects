module uart_top(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,

    output tx_busy,
    output [7:0] rx_data,
    output data_ready,
    output parity_error
);

wire baud_tick;
wire tx;

// Baud Generator
baud_gen baud(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
);

// Transmitter
transmitter tx_unit(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

// Receiver
receiver rx_unit(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .rx(tx),
    .data_out(rx_data),
    .data_ready(data_ready),
    .parity_error(parity_error)
);

endmodule