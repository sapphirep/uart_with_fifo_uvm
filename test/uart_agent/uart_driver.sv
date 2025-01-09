`define DRIVER_CB vif.DRIVER.driver_cb

class uart_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uart_driver)

    virtual uart_if  vif;
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
            `uvm_info("DRV RCV", tr.convert2string(), UVM_DEBUG);
            drive_dut(tr);
            seq_item_port.item_done();
        end
    endtask

endclass: uart_driver


task uart_driver::reset_dut ();
    repeat (2) @(posedge vif.clk);
    #2ns vif.DRIVER.rst <= 1;
    repeat (2) @(posedge vif.clk);
    #2ns vif.DRIVER.rst <= 0; 
endtask: reset_dut


task uart_driver::drive_dut (uart_transaction tr);
    @(`DRIVER_CB);
    `DRIVER_CB.tx_start <= tr.tx_start;
    `DRIVER_CB.din <= tr.din;

    @(`DRIVER_CB);
    `DRIVER_CB.tx_start <= 0;
    
    wait(`DRIVER_CB.tx_done);
endtask: drive_dut