class uart_coverage extends uvm_component;
    `uvm_component_utils(uart_coverage)

    // Analysis ports & FIFOs for receiving wr_uart and rd_uart from UART_TOP monitor
    uvm_analysis_export   #(uart_transaction) uart_top_axps[NUM_OF_UARTS];
    uvm_tlm_analysis_fifo #(uart_transaction) uart_wr_rd_fifos[NUM_OF_UARTS];
    
    uart_transaction trs[NUM_OF_UARTS];

    covergroup uart1_fifo_stat;
        tx_fifo_full:  coverpoint trs[`UART1].tx_fifo_full;
        tx_fifo_empty: coverpoint trs[`UART1].tx_fifo_empty;
        rx_fifo_full:  coverpoint trs[`UART1].rx_fifo_full;
        rx_fifo_empty: coverpoint trs[`UART1].rx_fifo_empty;
    endgroup

    covergroup uart2_fifo_stat;
        tx_fifo_full:  coverpoint trs[`UART2].tx_fifo_full;
        tx_fifo_empty: coverpoint trs[`UART2].tx_fifo_empty;
        rx_fifo_full:  coverpoint trs[`UART2].rx_fifo_full;
        rx_fifo_empty: coverpoint trs[`UART2].rx_fifo_empty;
    endgroup

    extern function      new (string name, uvm_component parent);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);

    task run_phase (uvm_phase phase);
        fork
            sample_cvg(`UART1);
            sample_cvg(`UART2);
        join_none
    endtask

    task sample_cvg (int index);
        uart_transaction tr;
        forever begin
            uart_wr_rd_fifos[index].get_peek_export.get(tr);
            trs[index] = tr;
            if (index == `UART1)
                uart1_fifo_stat.sample();
            else
                uart2_fifo_stat.sample();
        end
    endtask

endclass: uart_coverage


function uart_coverage::new (string name, uvm_component parent);
    super.new(name, parent);
    uart1_fifo_stat = new();
    uart2_fifo_stat = new();
endfunction: new


function void uart_coverage::build_phase (uvm_phase phase);
    super.build_phase(phase);

    for (int i = 0; i < NUM_OF_UARTS; i++) begin
        uart_top_axps[i]  = new($sformatf("uart_top_axps[%0d]",i), this);
        uart_wr_rd_fifos[i] = new($sformatf("uart_wr_rd_fifos[%0d]",i), this);
        trs[i] = uart_transaction::type_id::create($sformatf("trs[%0d]", i));
    end
endfunction: build_phase


function void uart_coverage::connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    for (int i = 0; i < NUM_OF_UARTS; i++)
        uart_top_axps[i].connect(uart_wr_rd_fifos[i].analysis_export);
endfunction: connect_phase