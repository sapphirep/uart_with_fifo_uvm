`define top_agt1 top_env1.uart_top_agt
`define top_agt2 top_env2.uart_top_agt
`define uart_agt1 top_env1.uart_agt
`define uart_agt2 top_env2.uart_agt

class uart_test_env extends uvm_env;
    `uvm_component_utils(uart_test_env)

    virtual uart_top_if top_vif1, top_vif2;
    virtual uart_if     uart_vif1, uart_vif2;

    uart_top_env        top_env1, top_env2;
    uart_scoreboard     scb;
    uart_coverage       cvg;
    uart_top_vsequencer vsqr;

    extern function      new (string name, uvm_component parent);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);

    extern function void get_interfaces();
    extern function void connect_analysis_ports();

endclass: uart_test_env

function uart_test_env::new (string name, uvm_component parent);
    super.new(name, parent);
endfunction: new

function void uart_test_env::build_phase (uvm_phase phase);

    super.build_phase(phase);

    get_interfaces();
        
    top_env1 = uart_top_env::type_id::create("top_env1", this);
    top_env2 = uart_top_env::type_id::create("top_env2", this);
    scb      = uart_scoreboard::type_id::create("scb", this);
    cvg      = uart_coverage::type_id::create("cvg", this);
    vsqr     = uart_top_vsequencer::type_id::create("vsqr", this);

    // Store virtual sequencer handle into uvm_resource_db
    uvm_resource_db #(uart_top_vsequencer)::set("vsqr::*", "vsqr", vsqr, this);

endfunction: build_phase

function void uart_test_env::connect_phase (uvm_phase phase);

    super.connect_phase(phase);

    // Assign agent interfaces
    `top_agt1.vif  = top_vif1;
    `uart_agt1.vif = uart_vif1;
    `top_agt2.vif  = top_vif2;
    `uart_agt2.vif = uart_vif2;

    // Connect virtual sequencer sub-sequencers
    vsqr.agt1_sqr = `top_agt1.sqr;
    vsqr.agt2_sqr = `top_agt2.sqr;

    connect_analysis_ports();

endfunction: connect_phase


function void uart_test_env::get_interfaces();
    if (!uvm_config_db #(virtual uart_top_if)::get(null, "*", "top_vif1", top_vif1))
        `uvm_error("TEST ENV IF", "Failed to get uart top vif1")

    if (!uvm_config_db #(virtual uart_top_if)::get(null, "*", "top_vif2", top_vif2))
        `uvm_error("TEST ENV IF", "Failed to get uart top vif2")

    if (!uvm_config_db #(virtual uart_if)::get(null, "*", "uart_vif1", uart_vif1))
        `uvm_error("TEST ENV IF", "Failed to get uart vif1")

    if (!uvm_config_db #(virtual uart_if)::get(null, "*", "uart_vif2", uart_vif2))
        `uvm_error("TEST ENV IF", "Failed to get uart vif2")
endfunction: get_interfaces


function void uart_test_env::connect_analysis_ports();
    // Monitor to scoreboard port connection
    `top_agt1.analysis_port.connect(scb.uart_top_axps[`UART1]);
    `uart_agt1.analysis_port.connect(scb.uart_axps[`UART1]);
    
    `top_agt2.analysis_port.connect(scb.uart_top_axps[`UART2]);
    `uart_agt2.analysis_port.connect(scb.uart_axps[`UART2]);

    // Monitor to coverage port connection
    `top_agt1.analysis_port.connect(cvg.uart_top_axps[`UART1]);
    `top_agt2.analysis_port.connect(cvg.uart_top_axps[`UART2]);
endfunction: connect_analysis_ports