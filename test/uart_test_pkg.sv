`ifndef TB_PKG
`define TB_PKG

package uart_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `define UART1 0
    `define UART2 1
    parameter int NUM_OF_UARTS = 2;

    parameter DATA_WIDTH = 8;

    `include "uart_transaction.sv"
    `include "uart_sequencer.sv"
    `include "uart_sequence.sv"
    `include "uart_vsequencer.sv"
    `include "uart_vsequence.sv"
    `include "uart_scoreboard.sv"
    `include "uart_driver.sv"
    `include "uart_monitor.sv"
    `include "uart_agent.sv"
    `include "uart_env.sv"
    `include "uart_test.sv"

    parameter real BAUD_RATE = 9600;

    parameter CLK1_FREQ_HZ = 100 * 10**6; // 100MHz
    parameter CLK2_FREQ_HZ = 50 * 10**6;  // 50MHz
    
    parameter CLK_CYCLE1 = 10ns;
    parameter CLK_CYCLE2 = 20ns;

endpackage: uart_test_pkg

`endif