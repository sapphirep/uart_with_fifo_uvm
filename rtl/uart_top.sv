module uart_top 
#(parameter CLK_FREQ_HZ = 100 * 10**6, BAUD_RATE = 9600)
(
    uart_top_if.DUT uart_top_if
);

    logic clk, rst;

    uart_fifo_if  tx_fifo_if (.clk), rx_fifo_if (.clk);
    uart_if uart_if (.clk);

    uart_fifo tx_fifo (tx_fifo_if);
    uart_fifo rx_fifo (rx_fifo_if);

    uart #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD_RATE)) uart (uart_if);

    // Connect global clock and reset
    assign clk = uart_top_if.clk;
    assign rst = uart_top_if.rst;

    assign uart_if.rst = rst;
    assign rx_fifo_if.rst = rst;
    assign tx_fifo_if.rst = rst;

    // Connect RX and TX signals
    assign uart_top_if.tx = uart_if.tx;
    assign uart_if.rx = uart_top_if.rx;

    // UART top module to TX FIFO connection
    assign tx_fifo_if.wr_data        = uart_top_if.tx_din;
    assign tx_fifo_if.wr             = uart_top_if.wr_uart;
    assign uart_top_if.tx_fifo_empty = tx_fifo_if.empty;
    assign uart_top_if.tx_fifo_full  = tx_fifo_if.full;
    assign uart_top_if.tx_fifo_cnt   = tx_fifo_if.count;

    // UART TX module and TX FIFO connection
    assign tx_fifo_if.rd    = uart_if.tx_done;
    assign uart_if.din      = tx_fifo_if.rd_data;
    assign uart_if.tx_start = ~tx_fifo_if.empty;

    // UART top module to RX FIFO connection
    assign uart_top_if.rx_dout       = rx_fifo_if.rd_data;
    assign rx_fifo_if.rd             = uart_top_if.rd_uart;
    assign uart_top_if.rx_fifo_empty = rx_fifo_if.empty;
    assign uart_top_if.rx_fifo_full  = rx_fifo_if.full;
    assign uart_top_if.rx_fifo_cnt   = rx_fifo_if.count;

    // UART RX module and RX FIFO connection
    assign rx_fifo_if.wr_data = uart_if.dout;
    assign rx_fifo_if.wr      = uart_if.rx_done;

endmodule: uart_top