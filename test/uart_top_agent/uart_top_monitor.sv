`define MONITOR_CB vif.MONITOR.monitor_cb

class uart_top_monitor extends uvm_monitor;
    `uvm_component_utils(uart_top_monitor)

    virtual uart_top_if vif;

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

        forever begin
            tr = uart_transaction::type_id::create("tr");

            @(posedge `MONITOR_CB.wr_uart, `MONITOR_CB.rd_uart)
            tr.wr_uart       = `MONITOR_CB.wr_uart;
            tr.rd_uart       = `MONITOR_CB.rd_uart;
            tr.din           = `MONITOR_CB.tx_din;
            tr.dout          = `MONITOR_CB.rx_dout;
            tr.tx_fifo_full  = `MONITOR_CB.tx_fifo_full;
            tr.tx_fifo_empty = `MONITOR_CB.tx_fifo_empty;
            tr.rx_fifo_full  = `MONITOR_CB.rx_fifo_full;
            tr.rx_fifo_empty = `MONITOR_CB.rx_fifo_empty;
        
            analysis_port.write(tr);
        end
    endtask: run_phase
    
endclass: uart_top_monitor