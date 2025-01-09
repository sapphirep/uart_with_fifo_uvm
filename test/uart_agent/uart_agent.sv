class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    virtual uart_if vif;
    
    uart_driver    drv;
    uart_sequencer sqr;
    uart_monitor   mon;

    uvm_analysis_port #(uart_transaction) analysis_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if (is_active)
        begin
            drv = uart_driver::type_id::create("drv", this);
            sqr = uart_sequencer::type_id::create("sqr", this);
        end
        
        mon = uart_monitor::type_id::create("mon", this);
    
        analysis_port = new("analysis_port", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);

        mon.analysis_port.connect(analysis_port);

        if (is_active)
            drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    function void end_of_elaboration_phase (uvm_phase phase);
        if (is_active)
            drv.vif = vif;
        mon.vif = vif;
    endfunction

endclass: uart_agent