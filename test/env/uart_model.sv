`define DATA_WIDTH UART_DATA_WIDTH

class uart_model;

    uart_model receiver;
    
    // Keep track of successfully sent TX data.
    // Data not received by receiver side due to RX buffer overflow is not added.
    bit [`DATA_WIDTH-1:0] tx_din[$] = {};

    // Keep track of all data read out from UART RX FIFO
    bit [`DATA_WIDTH-1:0] rx_dout[$] = {}; 

    // UART TX and RX FIFOs
    bit [`DATA_WIDTH-1:0] tx_fifo[$] = {};
    bit [`DATA_WIDTH-1:0] rx_fifo[$] = {};

    bit rx_fifo_overflow;

    function void connect (uart_model receiver);
        this.receiver = receiver;
    endfunction

    function void receive (bit [`DATA_WIDTH-1:0] data);
        if (rx_fifo.size() < FIFO_DEPTH)
        begin
            rx_fifo.push_back(data);
            rx_fifo_overflow = 0;
        end
        else
            rx_fifo_overflow = 1;
    endfunction

    function bit [`DATA_WIDTH-1:0] transmit();
        logic [`DATA_WIDTH-1:0] data = 0;
        if (tx_fifo.size() > 0)
            data = tx_fifo.pop_front();
        return data;
    endfunction

    function void write_uart (bit [`DATA_WIDTH-1:0] data);
        if (tx_fifo.size() < FIFO_DEPTH) 
            tx_fifo.push_back(data);
    endfunction

    function bit [`DATA_WIDTH-1:0] read_uart ();
        bit [`DATA_WIDTH-1:0] data = 0;
        if (rx_fifo.size() > 0)
        begin
            data = rx_fifo.pop_front();
            rx_dout.push_back(data);
        end
        return data;
    endfunction

    function void print();
        $display("TX FIFO: %p", tx_fifo);
        $display("RX FIFO: %p", rx_fifo);
        $display("TX DIN:  %p", tx_din);
        $display("RX DOUT: %p", rx_dout);
    endfunction

endclass: uart_model