interface uart_if
#(parameter DATA_WIDTH = 8)
(
    input logic clk
);

    localparam ADDR_WIDTH = $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0]   din, dout;
    logic                    tx, rx;
    logic                    rst;
    logic                    tx_start;
    logic                    tx_done, rx_done;

    clocking driver_cb @(posedge clk);
        default input #1step output #2ns;
        input  tx_done;
        output din;
        output tx_start;
    endclocking: driver_cb

    clocking monitor_cb @(posedge clk);
        default input #1step output #2ns;
        input din, dout;
        input tx, rx;
        input tx_start;
        input tx_done, rx_done;
    endclocking: monitor_cb

    modport UART_TX  (input clk, rst, din, tx_start,
                      output tx, tx_done);
    
    modport UART_RX  (input clk, rst, rx,
                      output dout, rx_done);

    modport DRIVER  (clocking driver_cb, output rst);

    modport MONITOR (clocking monitor_cb);

endinterface: uart_if