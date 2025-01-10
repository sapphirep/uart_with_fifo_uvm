class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_export   #(uart_transaction) rx_axps[NUM_OF_UARTS],  tx_axps[NUM_OF_UARTS];
    uvm_tlm_analysis_fifo #(uart_transaction) rx_fifos[NUM_OF_UARTS], tx_fifos[NUM_OF_UARTS];

    int err_cnt = 0;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);
    extern function void extract_phase (uvm_phase phase);
    extern function void report_phase (uvm_phase phase);

    extern task compare_channel1();
    extern task compare_channel2();

    task run_phase (uvm_phase phase);
        fork
            // Compare UART1's TX din with UART2's RX dout
            compare_channel1();
            // Compare UART2's TX din with UART1's RX dout
            compare_channel2();
        join_none
    endtask

endclass: uart_scoreboard


function void uart_scoreboard::build_phase (uvm_phase phase);
    super.build_phase(phase);
    for (int i = 0; i < NUM_OF_UARTS; i++)
    begin
        rx_axps [i] = new($sformatf("rx_axps[%0d]", i), this);
        tx_axps [i] = new($sformatf("tx_axps[%0d]", i), this);
        rx_fifos[i] = new($sformatf("rx_fifos[%0d]", i), this);
        tx_fifos[i] = new($sformatf("tx_fifos[%0d]", i), this);
    end
endfunction: build_phase


function void uart_scoreboard::connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    for (int i = 0; i < NUM_OF_UARTS; i++)
    begin
        rx_axps[i].connect(rx_fifos[i].analysis_export);
        tx_axps[i].connect(tx_fifos[i].analysis_export);
    end
endfunction: connect_phase


//===========================================================
// UART1's TX din should be equal to UART2's RX dout.
//===========================================================
task uart_scoreboard::compare_channel1();
    uart_transaction uart1_tr, uart2_tr;
    forever begin
        tx_fifos[`UART1].get_peek_export.get(uart1_tr);
        rx_fifos[`UART2].get_peek_export.get(uart2_tr);

        if (uart1_tr.din !== uart2_tr.dout) 
        begin
            `uvm_info("SCB ERR", $sformatf("Device 1 DIN (%8b) != Device 2 DOUT (%8b)", uart1_tr.din, uart2_tr.dout), UVM_LOW)
            err_cnt++;
        end
        else
            `uvm_info("SCB PASS", $sformatf("Device 1 DIN (%8b)  = Device 2 DOUT (%8b)", uart1_tr.din, uart2_tr.dout), UVM_LOW)
    end
endtask: compare_channel1


//===========================================================
// UART2's TX din should be equal to UART1's RX dout.
//===========================================================
task uart_scoreboard::compare_channel2();
    uart_transaction uart1_tr, uart2_tr;
    forever begin
        tx_fifos[`UART2].get_peek_export.get(uart2_tr);
        rx_fifos[`UART1].get_peek_export.get(uart1_tr);

        if (uart2_tr.din !== uart1_tr.dout) 
        begin
            `uvm_info("SCB ERR", $sformatf("Device 2 DIN (%8b) != Device 1 DOUT (%8b)", uart2_tr.din, uart1_tr.dout), UVM_LOW)
            err_cnt++;
        end
        else
            `uvm_info("SCB PASS", $sformatf("Device 2 DIN (%8b)  = Device 1 DOUT (%8b)", uart2_tr.din, uart1_tr.dout), UVM_LOW)
    end
endtask: compare_channel2


//===========================================================
// After the test ends, there should not be any unprocessed
// transactions left in the analysis FIFOs.
//===========================================================
function void uart_scoreboard::extract_phase (uvm_phase phase);
    uart_transaction tr;
    super.extract_phase(phase);
    if (rx_fifos[`UART1].try_get(tr)) 
    begin
        `uvm_info("SCB ERR", "Found unprocessed transaction in UART 1 RX FIFO", UVM_LOW)
        err_cnt++;
    end

    if (rx_fifos[`UART2].try_get(tr)) 
    begin
        `uvm_info("SCB ERR", "Found unprocessed transaction in UART 2 RX FIFO", UVM_LOW)
        err_cnt++;
    end

    if (tx_fifos[`UART1].try_get(tr)) 
    begin
        `uvm_info("SCB ERR", "Found unprocessed transaction in UART 1 TX FIFO", UVM_LOW)
        err_cnt++;
    end

    if (tx_fifos[`UART2].try_get(tr))
    begin
        `uvm_info("SCB ERR", "Found unprocessed transaction in UART 2 TX FIFO", UVM_LOW)
        err_cnt++;
    end
endfunction: extract_phase


function void uart_scoreboard::report_phase (uvm_phase phase);
    if (err_cnt > 0)
        `uvm_info("SCB TEST FAIL", "Test failed with %4d errors!", UVM_LOW)
    else
        `uvm_info("SCB TEST SUCCESS", "Test passed with no errors!", UVM_LOW)
endfunction: report_phase