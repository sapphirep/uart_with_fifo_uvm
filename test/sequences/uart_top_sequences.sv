`ifndef RANDOMIZE_FAIL
`define RANDOMIZE_FAIL \
    `uvm_fatal("SEQ", "Sequence randomization failed!")
`endif

class uart_seq_base extends uvm_sequence #(uart_transaction);
    `uvm_object_utils(uart_seq_base)

    uart_transaction tr;
    randc int iteraions;

    constraint loop {
        iteraions inside {[1:20]};
    }

    function new (string name = "uart_sequence");
        super.new(name);
    endfunction
    
endclass: uart_seq_base


class uart_write_seq extends uart_seq_base;
    `uvm_object_utils(uart_write_seq)

    function new (string name = "uart_write_seq");
        super.new(name);
    endfunction

    task body();
        repeat(iteraions)
        begin
            tr = uart_transaction::type_id::create("tr");
            if(!(tr.randomize())) `RANDOMIZE_FAIL
            tr.wr_uart = 1'b1;
            start_item(tr);
            finish_item(tr);
        end
    endtask

endclass: uart_write_seq

class uart_read_seq extends uart_seq_base;
    `uvm_object_utils(uart_read_seq)

    function new (string name = "uart_read_seq");
        super.new(name);
    endfunction

    task body();
        repeat(iteraions)
        begin
            tr = uart_transaction::type_id::create("tr");
            if(!(tr.randomize())) `RANDOMIZE_FAIL
            tr.rd_uart = 1'b1;
            start_item(tr);
            finish_item(tr);
        end
    endtask

endclass: uart_read_seq