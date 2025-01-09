interface uart_top_if
#(parameter DATA_WIDTH = 8, FIFO_DEPTH = 16)
(
    input logic clk
);
    localparam FIFO_DATA_WIDTH = $clog2(FIFO_DEPTH);

    logic [DATA_WIDTH-1:0]    tx_din, rx_dout;
    logic [FIFO_DATA_WIDTH:0] rx_fifo_cnt, tx_fifo_cnt;
    logic                     rx, tx;
    logic                     rd_uart, wr_uart;
    logic                     tx_fifo_empty, tx_fifo_full;
    logic                     rx_fifo_empty, rx_fifo_full;
    logic                     rst;

    clocking driver_cb @(posedge clk);
        default input #1step output #2ns;
        input  rx_fifo_empty;
        output tx_din;
        output rd_uart, wr_uart;
    endclocking: driver_cb

    clocking monitor_cb @(posedge clk);
        default input #1step output #2ns;
        input tx_din, rx_dout;
        input rd_uart, wr_uart;
        input tx_fifo_cnt, rx_fifo_cnt;
        input tx_fifo_empty, tx_fifo_full;
        input rx_fifo_empty, rx_fifo_full;
    endclocking: monitor_cb

    modport DUT (input tx_din, rd_uart, wr_uart, rx, clk, rst,
                 output rx_dout, tx, rx_fifo_cnt, tx_fifo_cnt, rx_fifo_full, 
                        rx_fifo_empty, tx_fifo_full, tx_fifo_empty);

    modport DRIVER  (clocking driver_cb, output rst);

    modport MONITOR (clocking monitor_cb);

endinterface: uart_top_if