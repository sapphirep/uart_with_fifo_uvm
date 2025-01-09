`define DRIVER_CB vif.DRIVER.driver_cb

class uart_top_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uart_top_driver)

    virtual uart_top_if vif;
    uart_transaction tr;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    extern task reset_dut ();
    extern task drive_dut (uart_transaction tr);

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        reset_dut();
        forever begin
            seq_item_port.get_next_item(tr);
            drive_dut(tr);
            seq_item_port.item_done();
        end
    endtask

endclass: uart_top_driver

task uart_top_driver::reset_dut ();
    repeat (2) @(posedge vif.clk);
    #2ns vif.DRIVER.rst <= 1;
    repeat (2) @(posedge vif.clk);
    #2ns vif.DRIVER.rst <= 0;

    `DRIVER_CB.wr_uart <= 1'b0;
    `DRIVER_CB.rd_uart <= 1'b0;
endtask: reset_dut

task uart_top_driver::drive_dut (uart_transaction tr);
    @(`DRIVER_CB);
    `DRIVER_CB.wr_uart <= tr.wr_uart;
    `DRIVER_CB.rd_uart <= tr.rd_uart;
    `DRIVER_CB.tx_din  <= tr.din;

    @(`DRIVER_CB);
    `DRIVER_CB.wr_uart <= 1'b0;
    `DRIVER_CB.rd_uart <= 1'b0;
endtask: drive_dut