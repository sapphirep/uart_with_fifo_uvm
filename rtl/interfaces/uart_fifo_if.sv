interface uart_fifo_if
#(parameter DATA_WIDTH = 8, FIFO_DEPTH = 16)
(
    input logic clk
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic                  wr, rd;
    logic                  rst;
    logic [ADDR_WIDTH-1:0] trig_level;
    logic [DATA_WIDTH-1:0] wr_data, rd_data;
    logic                  full, empty;
    logic                  overflow, underflow;
    logic                  thr_trig;
    logic [ADDR_WIDTH:0]   count;

    clocking driver_cb @(posedge clk);
        default input #1step output #2ns;
        input full, empty;
        input overflow, underflow;
        input rd_data;
        output rst;
        output wr, rd;
        output wr_data;
        output trig_level;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1step output #2ns;
        input rst;
        input count;
        input wr, rd;
        input wr_data, rd_data;
        input full, empty;
        input overflow, underflow;
        input thr_trig;
    endclocking

    modport FIFO_CTRL (input wr, rd, trig_level, clk, rst,
                       output count, full, empty, overflow, underflow, thr_trig);

    modport DRIVER  (clocking driver_cb, output rst);

    modport MONITOR (clocking monitor_cb);

endinterface: uart_fifo_if