class uart_top_vsequencer extends uvm_sequencer;
    `uvm_component_utils(uart_top_vsequencer)

    uart_top_sequencer agt1_sqr;
    uart_top_sequencer agt2_sqr;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
endclass: uart_top_vsequencer