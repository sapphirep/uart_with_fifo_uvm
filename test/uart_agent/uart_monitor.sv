`define MONITOR_CB vif.MONITOR.monitor_cb

class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)

    virtual uart_if vif;

    // Used for broadcasting rx_done and tx_done
    uvm_analysis_port #(uart_transaction) analysis_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        analysis_port = new("analysis_port", this);
    endfunction: build_phase

    task run_phase (uvm_phase phase);
        uart_transaction tr;

        super.run_phase(phase);
        forever begin
            @(posedge `MONITOR_CB.tx_done, `MONITOR_CB.rx_done)
            tr = uart_transaction::type_id::create("tr");
            tr.din     = `MONITOR_CB.din;
            tr.dout    = `MONITOR_CB.dout;
            tr.tx_done = `MONITOR_CB.tx_done;
            tr.rx_done = `MONITOR_CB.rx_done;
            analysis_port.write(tr);
        end
    endtask

endclass: uart_monitor