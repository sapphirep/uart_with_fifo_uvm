`define DATA_WIDTH UART_DATA_WIDTH

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)
    
    // Ports & FIFOs to receive rd_uart and wr_uart commands from UART_TOP monitors
    // UART_TOP monitor -> uart_top_axp -> uart_wr_rd_fifo
    uvm_analysis_export   #(uart_transaction) uart_top_axps[NUM_OF_UARTS];
    uvm_tlm_analysis_fifo #(uart_transaction) uart_wr_rd_fifos[NUM_OF_UARTS];

    // Ports & FIFOs to receive rx_done and tx_done from UART monitors
    // UART monitor -> uart_axp -> uart_tx_rx_fifo
    uvm_analysis_export   #(uart_transaction) uart_axps[NUM_OF_UARTS];
    uvm_tlm_analysis_fifo #(uart_transaction) uart_tx_rx_fifos[NUM_OF_UARTS];

    uart_model uart[NUM_OF_UARTS];

    int err_cnt = 0;

    extern function      new (string name, uvm_component parent);
    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);
    extern task          run_phase (uvm_phase phase);
    extern function void extract_phase (uvm_phase phase);
    extern function void report_phase (uvm_phase phase);

    extern function void initialize_models ();

    extern task          process_tx_rx_done (int index);       
    extern task          process_wr_rd_uart (int index);
    extern function void check_uart_rx_fifo (int index, uart_transaction tr);
    extern function void check_uart_tx_fifo (int index, uart_transaction tr);

endclass: uart_scoreboard


function uart_scoreboard::new (string name, uvm_component parent);
    super.new(name, parent);
    initialize_models();
endfunction: new


function void uart_scoreboard::initialize_models ();
    // Initialize UART models and connect them
    uart[`UART1] = new();
    uart[`UART2] = new();
    uart[`UART1].connect(uart[`UART2]);
    uart[`UART2].connect(uart[`UART1]);
endfunction: initialize_models


function void uart_scoreboard::build_phase (uvm_phase phase);
    super.build_phase(phase);
    for (int i = 0; i < NUM_OF_UARTS; i++) 
    begin
        // Initialize analysis exports
        uart_top_axps[i] = new($sformatf("uart_top_axps[%0d]", i), this);
        uart_axps[i]     = new($sformatf("uart_axps[%0d]", i), this);

        // Initialize analysis fifos
        uart_wr_rd_fifos[i] = new($sformatf("uart_wr_rd_fifos[%0d]", i), this);
        uart_tx_rx_fifos[i] = new($sformatf("uart_tx_rx_fifos[%0d]", i), this);
    end
endfunction: build_phase


function void uart_scoreboard::connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    // Connect analysis exports to analysis FIFO's exports
    for (int i = 0; i < NUM_OF_UARTS; i++) 
    begin
        uart_top_axps[i].connect(uart_wr_rd_fifos[i].analysis_export);
        uart_axps[i].connect(uart_tx_rx_fifos[i].analysis_export);
    end
endfunction: connect_phase


task uart_scoreboard::run_phase (uvm_phase phase);
    super.run_phase(phase);
    fork
        process_tx_rx_done(`UART1);
        process_wr_rd_uart(`UART1);
        process_tx_rx_done(`UART2);
        process_wr_rd_uart(`UART2);
    join_none
endtask: run_phase


// ======================================================================
// Process TX/RX done (from UART monitor):
//  After detecting tx_done, the scoreboard:
//   1. Compares received TX din with expected data from UART model's TX FIFO.
//   2. If the receiver's RX buffer is not full, TX din will be added to the 
//      TX side's queue of successfully transmitted data.
//  
//  After detecting rx_done, the received data is added to the UART 
//  receiver model's RX FIFO.
// ======================================================================
task uart_scoreboard::process_tx_rx_done (int index);
    bit [`DATA_WIDTH-1:0] expected;
    uart_transaction tr;
    forever begin
        uart_tx_rx_fifos[index].get_peek_export.get(tr);

        if (tr.tx_done)
        begin
            // Get data from TX FIFO
            expected = uart[index].transmit();
            if (expected != tr.din)
            begin
                `uvm_info("SCB ERR", $sformatf("UART[%0d] TX complete. Data = %2h != expected %2h", index+1, tr.din, expected), UVM_LOW)
                err_cnt++;
            end
            
            // Keep track of successfully sent TX data.
            // Data not received by receiver side due to RX buffer overflow is not added.
            if (!uart[index].receiver.rx_fifo_overflow)
                uart[index].tx_din.push_back(tr.din);
        end

        if (tr.rx_done)
        begin
            `uvm_info("SCB", $sformatf("UART[%0d] RX complete: dout = %8b(%2h).", index+1, tr.dout, tr.dout), UVM_DEBUG)
            uart[index].receive(tr.dout);
        end
    end
endtask: process_tx_rx_done


// ======================================================================
// Process write/read uart commands (from UART_TOP monitor):
//  After detecting wr_uart commands, the scoreboard:
//   1. Compares received TX FIFO status with expected status from model.
//   2. Adds received data into TX FIFO
//
//  After detecting rd_uart commands, the scoreboard:
//   1. Compares received RX FIFO status with expected status from model.
//   2. Compares received data with the data read from RX FIFO (if not empty).
// ======================================================================
task uart_scoreboard::process_wr_rd_uart (int index);
    uart_transaction tr;
    forever begin
        uart_wr_rd_fifos[index].get_peek_export.get(tr);

        if (tr.wr_uart)
        begin
            check_uart_tx_fifo(index, tr);
            `uvm_info("SCB", $sformatf("UART[%0d] received wr command: din = %8b(%2h)", index+1, tr.din, tr.din), UVM_DEBUG)
            uart[index].write_uart(tr.din);
        end
        
        if (tr.rd_uart)
        begin
            bit [`DATA_WIDTH-1:0] expected;
            check_uart_rx_fifo(index, tr);

            if (uart[index].rx_fifo.size > 0) begin
                expected = uart[index].read_uart();
                if (tr.dout != expected) begin
                    `uvm_info("SCB ERR", $sformatf("UART[%0d] read: %2h != exp: %2h", index+1, tr.dout, expected), UVM_LOW)
                    err_cnt++;
                end
            end
        end
    end
endtask: process_wr_rd_uart


function void uart_scoreboard::check_uart_tx_fifo (int index, uart_transaction tr);
    if (uart[index].tx_fifo.size == 0 && !tr.tx_fifo_empty) begin
        `uvm_info("SCB ERR", "Expecting TX FIFO to be empty but it's not!", UVM_LOW)
        err_cnt++;
    end
    else if (uart[index].tx_fifo.size == FIFO_DEPTH && !tr.tx_fifo_full) begin
        `uvm_info("SCB ERR", "Expecting TX FIFO to be full but it's not!", UVM_LOW)
        err_cnt++;
    end
endfunction: check_uart_tx_fifo


function void uart_scoreboard::check_uart_rx_fifo (int index, uart_transaction tr);
    if (uart[index].rx_fifo.size == 0 && !tr.rx_fifo_empty) begin
        `uvm_info("SCB ERR", "Expecting RX FIFO to be empty but it's not!", UVM_LOW)
        err_cnt++;
    end
    else if (uart[index].rx_fifo.size == FIFO_DEPTH && !tr.rx_fifo_full) begin
        `uvm_info("SCB ERR", "Expecting RX FIFO to be full but it's not!", UVM_LOW)
        err_cnt++;
    end
endfunction: check_uart_rx_fifo


// ======================================================================
// After test has ended:
//  - There could still be data remaining in the RX FIFO (rx_fifo).
//  - All data already read out from the RX FIFO is kept inside the UART model's
//    rx_dout queue. 
//  - UART model's tx_din queue contains all data successfully sent 
//    through TX and received by RX. Excluding the ones ignored by RX side
//    to RX buffer overflow.
//  - Therefore:
//    * UART1's tx_din queue should be equal to UART2's rx_dout + rx_fifo. 
//    * UART2's tx_din queue should be equal to UART1's rx_dout + rx_fifo.
// ======================================================================
function void uart_scoreboard::extract_phase (uvm_phase phase);
    // Combine RX data already read out with data remaining in RX FIFO
    bit [`DATA_WIDTH-1:0] uart1_rx[$] = {uart[`UART1].rx_dout[0:$], uart[`UART1].rx_fifo[0:$]};
    bit [`DATA_WIDTH-1:0] uart2_rx[$] = {uart[`UART2].rx_dout[0:$], uart[`UART2].rx_fifo[0:$]};

    if (uart1_rx != uart[`UART2].tx_din) 
    begin
        `uvm_info("SCB ERR", "Mismatch! uart1_rx != uart2.tx_din", UVM_LOW)
        err_cnt++;
    end
    else
        `uvm_info("SCB PASS", "UART1 received correctly!", UVM_LOW)

    if (uart2_rx != uart[`UART1].tx_din)
    begin
        `uvm_info("SCB ERR", "Mismatch! uart2_rx != uart1.tx_din", UVM_LOW)
        err_cnt++;
    end
    else
        `uvm_info("SCB PASS", "UART2 received correctly!", UVM_LOW)

    // $display("==== DUT1 ====");
    // uart[0].print();
    // $display("==== DUT2 ====");
    // uart[1].print();
endfunction: extract_phase


function void uart_scoreboard::report_phase (uvm_phase phase);
    if (err_cnt > 0)
        `uvm_info("SCB TEST FAIL", "Test failed with %2d errors!", UVM_LOW)
    else
        `uvm_info("SCB TEST SUCCESS", "Test passed with no errors!", UVM_LOW)
endfunction: report_phase