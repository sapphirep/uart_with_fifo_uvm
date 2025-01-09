class uart_top_agent extends uvm_agent;
    `uvm_component_utils(uart_top_agent)

    virtual uart_top_if vif;

    uart_top_driver    drv;
    uart_top_monitor   mon;
    uart_top_sequencer sqr;

    uvm_analysis_port #(uart_transaction) analysis_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        drv = uart_top_driver::type_id::create("drv", this);
        mon = uart_top_monitor::type_id::create("mon", this);
        sqr = uart_top_sequencer::type_id::create("sqr", this);

        analysis_port = new("analysis_port", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);

        mon.analysis_port.connect(analysis_port);
    endfunction

    function void end_of_elaboration_phase (uvm_phase phase);
        drv.vif = vif;
        mon.vif = vif;
    endfunction

endclass: uart_top_agent