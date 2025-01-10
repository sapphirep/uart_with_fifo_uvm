class uart_env extends uvm_env;
    `uvm_component_utils(uart_env);

    virtual uart_if vif1, vif2;

    uart_agent      agt1;
    uart_agent      agt2;
    uart_scoreboard scb;
    uart_vsequencer vsqr;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual uart_if)::get(null, "*", "vif1", vif1))
            `uvm_error("ENV IF", "Failed to get vif1")
        if (!uvm_config_db #(virtual uart_if)::get(null, "*", "vif2", vif2))
            `uvm_error("ENV IF", "Failed to get vif2")
            
        agt1 = uart_agent::type_id::create("agt1", this);
        agt2 = uart_agent::type_id::create("agt2", this);
        scb  = uart_scoreboard::type_id::create("scb", this);
        vsqr = uart_vsequencer::type_id::create("vsqr", this);

        agt1.vif = vif1;
        agt2.vif = vif2;
    endfunction
    
    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        
        agt1.rx_analysis_port.connect(scb.rx_axps[`UART1]);
        agt1.tx_analysis_port.connect(scb.tx_axps[`UART1]);
        agt2.rx_analysis_port.connect(scb.rx_axps[`UART2]);
        agt2.tx_analysis_port.connect(scb.tx_axps[`UART2]);

        vsqr.agt1_sqr = agt1.sqr;
        vsqr.agt2_sqr = agt2.sqr;
    endfunction

endclass: uart_env