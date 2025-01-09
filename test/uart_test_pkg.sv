package uart_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `define UART1 0
    `define UART2 1
    parameter NUM_OF_UARTS = 2;

    parameter real BAUD_RATE = 9600;

    parameter CLK1_FREQ_HZ = 100 * 10**6; // 100MHz
    parameter CLK2_FREQ_HZ = 50 * 10**6;  // 50MHz
    
    parameter CLK_CYCLE1 = 10ns;
    parameter CLK_CYCLE2 = 20ns;

    parameter UART_DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    `include "uart_transaction.sv"
    
    `include "uart_agent_incl.svh"
    `include "uart_top_agent_incl.svh"

    `include "uart_top_vsequencer.sv"
    `include "uart_top_sequences.sv"
    `include "uart_top_vsequences.sv"

    `include "uart_coverage.sv"
    `include "uart_model.sv"
    `include "uart_scoreboard.sv"
    
    `include "uart_top_env.sv"
    `include "uart_test_env.sv"
    `include "uart_test.sv"

endpackage: uart_test_pkg