class uart_vseq_base extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(uart_vseq_base)
    `uvm_declare_p_sequencer(uart_vsequencer)

    uart_sequencer agt1_sqr;
    uart_sequencer agt2_sqr;

    function new (string name = "uart_vseq_base");
        super.new(name);
    endfunction

    virtual task body();
        agt1_sqr = p_sequencer.agt1_sqr;
        agt2_sqr = p_sequencer.agt2_sqr;
    endtask

endclass: uart_vseq_base;


class uart_vseq_half_duplex extends uart_vseq_base;
    `uvm_object_utils(uart_vseq_half_duplex)

    uart_seq agt1_seq = uart_seq::type_id::create("agt1_seq");
    uart_seq agt2_seq = uart_seq::type_id::create("agt2_seq");
    
    function new (string name = "uart_vseq_half_duplex");
        super.new(name);
    endfunction

    virtual task body();
        super.body();

        `uvm_info("VSEQ_HD", "Executing sequence on Agent 1 sequencer...", UVM_LOW)
        agt1_seq.start(agt1_sqr);

        `uvm_info("VSEQ_HD", "Executing sequence on Agent 2 sequencer...", UVM_LOW)
        agt2_seq.start(agt2_sqr);

    endtask

endclass: uart_vseq_half_duplex


class uart_vseq_full_duplex extends uart_vseq_base;
    `uvm_object_utils(uart_vseq_full_duplex)

    uart_seq agt1_seq = uart_seq::type_id::create("agt1_seq");
    uart_seq agt2_seq = uart_seq::type_id::create("agt2_seq");

    function new (string name = "uart_vseq_full_duplex");
        super.new(name);
    endfunction

    virtual task body();
        super.body();

        fork
            `uvm_info("VSEQ_FD", "Executing sequence on Agent 1 sequencer...", UVM_LOW)
            agt1_seq.start(agt1_sqr);

            `uvm_info("VSEQ_FD", "Executing sequence on Agent 2 sequencer...", UVM_LOW)
            agt2_seq.start(agt2_sqr);
        join
    endtask

endclass: uart_vseq_full_duplex