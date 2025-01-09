// Interfaces
`include "uart_if.sv"
`include "uart_fifo_if.sv"
`include "uart_top_if.sv"

// UART TX & RX modules
`include "uart_bclk_gen.sv"
`include "uart_rx.sv"
`include "uart_tx.sv"
`include "uart.sv"

// FIFO module
`include "uart_fifo.sv"

// UART top level module
`include "uart_top.sv"