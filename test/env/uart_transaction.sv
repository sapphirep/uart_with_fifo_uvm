`define DATA_WIDTH UART_DATA_WIDTH

class uart_transaction extends uvm_sequence_item;
    `uvm_object_utils(uart_transaction)

    rand bit [`DATA_WIDTH-1:0] din;
    bit wr_uart = 0, rd_uart = 0;

    bit [`DATA_WIDTH-1:0] dout;
    bit tx_start, tx_done = 0, rx_done = 0;
    bit tx_fifo_full, tx_fifo_empty;
    bit rx_fifo_full, rx_fifo_empty;

    extern function      new (string name = "uart_transaction");
    extern function void do_copy (uvm_object rhs);

    extern function string input2string();
    extern function string output2string();
    extern function string convert2string();

endclass

function uart_transaction::new (string name = "uart_transaction");
        super.new(name);
endfunction

function void uart_transaction::do_copy (uvm_object rhs);
    uart_transaction tr;
    if (!$cast(tr, rhs))
        `uvm_fatal("UART TX", "Failed to cast during copy!")

    din     = tr.din;
    wr_uart = tr.wr_uart;
    rd_uart = tr.rd_uart;

    dout          = tr.dout;
    tx_start      = tr.tx_start;
    tx_done       = tr.tx_done;
    rx_done       = tr.rx_done;
    tx_fifo_full  = tr.tx_fifo_full;
    tx_fifo_empty = tr.tx_fifo_empty;
    rx_fifo_full  = tr.rx_fifo_full;
    rx_fifo_empty = tr.rx_fifo_empty;
endfunction: do_copy

function string uart_transaction::convert2string();
    return $sformatf({input2string(), "\n", output2string()});
endfunction: convert2string

function string uart_transaction::input2string();
    string s = $sformatf("DIN=%2h, WR_UART=%0b, RD_UART=%0b", din, wr_uart, rd_uart);
    return s;
endfunction: input2string

function string uart_transaction::output2string();
    string s = $sformatf(
        "DOUT=%2h, TX_DONE=%0b, RX_DONE=%0b, tx_fifo_full=%0b, tx_fifo_empty=%0b, rx_fifo_full=%0b, rx_fifo_empty=%0b",
        dout, tx_done, rx_done, tx_fifo_full, tx_fifo_empty, rx_fifo_full, rx_fifo_empty
    );
    return s;
endfunction: output2string
