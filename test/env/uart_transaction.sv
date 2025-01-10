class uart_transaction extends uvm_sequence_item;
    `uvm_object_utils (uart_transaction)

    rand logic [DATA_WIDTH-1:0] din;
    bit tx_start;

    logic [DATA_WIDTH-1:0] dout;
    logic tx_done, rx_done;

    function new (string name = "uart_transaction");
        super.new(name);
    endfunction

    function string convert2string();
        string s = $sformatf("DIN=%2h, TX_START=%0b, DOUT=%2h, TX_DONE=%0b, RX_DONE=%0b",
                     din, tx_start, dout, tx_done, rx_done);
    endfunction

endclass: uart_transaction