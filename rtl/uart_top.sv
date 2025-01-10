module uart_top 
#(parameter CLK_FREQ_HZ = 100 * 10**6, BAUD_RATE = 9600)
(
    uart_if vif
);
    logic bclk;

    uart_bclk_gen #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD_RATE)) 
                    bclk_gen (.clk(vif.clk), .rst(vif.rst), .bclk);
                    
    uart_tx  tx (.vif, .bclk);
    uart_rx  rx (.vif, .bclk);

endmodule: uart_top