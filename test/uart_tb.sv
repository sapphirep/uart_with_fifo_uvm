module uart_tb;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import uart_test_pkg::*;

    logic clk1 = 0, clk2 = 0;

    uart_top_if #(.DATA_WIDTH(UART_DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) vif1 (clk1),
                                                                         vif2 (clk2);

    uart_top #(.CLK_FREQ_HZ(CLK1_FREQ_HZ), .BAUD_RATE(BAUD_RATE)) dut1 (vif1);
    uart_top #(.CLK_FREQ_HZ(CLK2_FREQ_HZ), .BAUD_RATE(BAUD_RATE)) dut2 (vif2);

    assign vif1.rx = vif2.tx;
    assign vif2.rx = vif1.tx;

    // Clock generation
    always #(CLK_CYCLE1/2) clk1 = ~clk1;
    always #(CLK_CYCLE2/2) clk2 = ~clk2;

    initial begin
        $dumpfile("uart_test.vcd");
        $dumpvars(0, uart_tb);
    end

    initial begin
        uvm_config_db #(virtual uart_top_if)::set(null, "*", "top_vif1", vif1);
        uvm_config_db #(virtual uart_top_if)::set(null, "*", "top_vif2", vif2);
        uvm_config_db #(virtual uart_if)::set(null, "*", "uart_vif1", dut1.uart_if);
        uvm_config_db #(virtual uart_if)::set(null, "*", "uart_vif2", dut2.uart_if);
        run_test();
    end
    
endmodule: uart_tb