class uart_vsequencer extends uvm_sequencer;
    `uvm_component_utils(uart_vsequencer)

    uart_sequencer agt1_sqr;
    uart_sequencer agt2_sqr;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
endclass: uart_vsequencer