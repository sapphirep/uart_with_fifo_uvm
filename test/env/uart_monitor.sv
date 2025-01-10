`define MONITOR_CB vif.MONITOR.monitor_cb

class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)

    uvm_analysis_port #(uart_transaction) rx_analysis_port, tx_analysis_port;
    virtual uart_if vif;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        rx_analysis_port = new("rx_analysis_port", this);
        tx_analysis_port = new("tx_analysis_port", this);
    endfunction

    task run_phase (uvm_phase phase);
        fork 
            monitor_tx();
            monitor_rx();
        join_none
    endtask

    task monitor_tx ();
        forever begin
            uart_transaction tr = uart_transaction::type_id::create("tr");

            @(posedge `MONITOR_CB.tx_start)
            tr.din = `MONITOR_CB.din;
            tr.tx_start = 1'b1;

            @(posedge `MONITOR_CB.tx_done)
            `uvm_info("MON TX", $sformatf("%s mon: DIN=%8b", get_parent().get_name(), tr.din), UVM_DEBUG)
            tx_analysis_port.write(tr);
        end
    endtask

    task monitor_rx ();
        forever begin
            uart_transaction tr = uart_transaction::type_id::create("tr");

            @(posedge `MONITOR_CB.rx_done)
            tr.dout = `MONITOR_CB.dout;
            `uvm_info("MON RX", $sformatf("%s mon: DOUT=%8b", get_parent().get_name(), tr.dout), UVM_DEBUG)
            rx_analysis_port.write(tr);
        end
    endtask

endclass: uart_monitor