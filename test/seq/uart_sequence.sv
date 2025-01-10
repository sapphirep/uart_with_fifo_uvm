`ifndef RANDOMIZE_FAIL
`define RANDOMIZE_FAIL \
    `uvm_fatal("SEQ", "Sequence randomization failed!")
`endif

class uart_seq_base extends uvm_sequence #(uart_transaction);
    `uvm_object_utils(uart_seq_base)

    uart_transaction tr;

    function new (string name = "uart_sequence");
        super.new(name);
    endfunction
    
endclass: uart_seq_base

class uart_seq extends uart_seq_base;
    `uvm_object_utils(uart_seq)

    function new (string name = "uart_seq");
        super.new(name);
    endfunction

    task body();
        repeat(20)
        begin
            tr = uart_transaction::type_id::create("tr");
            if(!(tr.randomize())) `RANDOMIZE_FAIL
            tr.tx_start = 1'b1;
            `uvm_info("SEQ", $sformatf("Generated sequence with TX_START = %0b", tr.tx_start), UVM_LOW)
            start_item(tr);
            finish_item(tr);
        end
    endtask
    
endclass: uart_seq