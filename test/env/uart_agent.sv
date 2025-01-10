class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)

    virtual uart_if vif;
    uart_driver     drv;
    uart_sequencer  sqr;
    uart_monitor    mon;

    uvm_analysis_port #(uart_transaction) rx_analysis_port, tx_analysis_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        drv = uart_driver::type_id::create("drv", this);
        sqr = uart_sequencer::type_id::create("sqr", this);
        mon = uart_monitor::type_id::create("mon", this);
        
        rx_analysis_port = new("rx_analysis_port", this);
        tx_analysis_port = new("tx_analysis_port", this);

        drv.vif = vif;
        mon.vif = vif;
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        mon.rx_analysis_port.connect(rx_analysis_port);
        mon.tx_analysis_port.connect(tx_analysis_port);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

endclass: uart_agent