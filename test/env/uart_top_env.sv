class uart_top_env extends uvm_env;
    `uvm_component_utils(uart_top_env)

    uart_top_agent uart_top_agt;
    uart_agent     uart_agt;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        uart_top_agt = uart_top_agent::type_id::create("uart_top_agt", this);
        uart_agt     = uart_agent::type_id::create("uart_agt", this);

        // Configure the UART agent as passive, UART_TOP agent is driving
        uart_agt.is_active = UVM_PASSIVE;
    endfunction

endclass: uart_top_env