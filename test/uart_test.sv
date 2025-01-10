`timescale 1ns / 1ns

class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)

    uart_env env;
    uart_vseq_base vseq;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase (uvm_phase phase);
        uvm_factory factory = uvm_factory::get();
        super.end_of_elaboration_phase(phase);
        this.print();
        factory.print();
    endfunction

    task run_phase (uvm_phase phase);
        vseq = uart_vseq_base::type_id::create("vseq");
        phase.raise_objection(this);
        vseq.start(env.vsqr);
        phase.drop_objection(this);
    endtask

endclass: uart_base_test


class uart_half_duplex_test extends uart_base_test;
    `uvm_component_utils(uart_half_duplex_test)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(uart_vseq_base::get_type(), uart_vseq_half_duplex::get_type());
    endfunction

endclass: uart_half_duplex_test


class uart_full_duplex_test extends uart_base_test;
    `uvm_component_utils(uart_full_duplex_test)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(uart_vseq_base::get_type(), uart_vseq_full_duplex::get_type());
    endfunction

endclass: uart_full_duplex_test