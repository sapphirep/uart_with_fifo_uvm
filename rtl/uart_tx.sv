`define DATA_WIDTH vif.DATA_WIDTH
`define ADDR_WIDTH vif.ADDR_WIDTH

module uart_tx 
(
    uart_if.UART_TX vif,
    input logic     bclk
);

    import uart_pkg::*;

    tx_state_e              state, state_next;
    logic [3:0]             bclk_cnt, bclk_cnt_next;
    logic [`DATA_WIDTH-1:0] din, din_next;
    logic [`ADDR_WIDTH-1:0] din_idx, din_idx_next;

    logic tx;
    logic tx_done;

    always_ff @(posedge vif.clk, posedge vif.rst)
    begin
        if (vif.rst)
        begin
            state    <= TX_IDLE;
            bclk_cnt <= 0;
            din      <= 0;
            din_idx  <= 0;
        end
        else
        begin
            state    <= state_next;
            bclk_cnt <= bclk_cnt_next;
            din      <= din_next;
            din_idx  <= din_idx_next;
        end
    end

    always_comb
    begin
        state_next    = state;
        bclk_cnt_next = bclk_cnt;
        din_next      = din;
        din_idx_next  = din_idx;
        tx_done       = 1'b0;

        case (state)
            TX_IDLE:
            begin
                tx = 1'b1;
                if (vif.tx_start) begin
                    state_next    = TX_START;
                    din_next      = vif.din;
                    bclk_cnt_next = 0;
                end
            end

            TX_START:
            begin
                tx = 1'b0;
                if (bclk)
                begin
                    if (bclk_cnt == OS_16_BCLK_CNT - 1) begin
                        // START bit lasts 16 BCLK cycles
                        state_next    = TX_SEND;
                        bclk_cnt_next = 0;
                        din_idx_next  = 0;
                    end
                    else
                        // In the middle of sending START bit
                        bclk_cnt_next = bclk_cnt + 1;
                end
            end

            TX_SEND:
            begin
                tx = din[din_idx];
                if (bclk) 
                begin
                    if (bclk_cnt == OS_16_BCLK_CNT - 1) begin
                        // Each data lasts 16 BCLK cycles
                        if (din_idx == `DATA_WIDTH - 1) begin
                            state_next   = TX_STOP;
                            din_idx_next = 0;
                        end
                        else
                            // There are more data left to send
                            din_idx_next  = din_idx + 1;

                        bclk_cnt_next = 0;
                    end
                    else
                        // In the middle of sending current data
                        bclk_cnt_next = bclk_cnt + 1; 
                end
            end

            TX_STOP:
            begin
                tx = 1'b1;
                if (bclk)
                begin
                    if (bclk_cnt == OS_16_BCLK_CNT - 1) begin
                         // STOP bit lasts 16 BCLK cycles
                        state_next = TX_IDLE;
                        tx_done = 1'b1;
                    end
                    else
                        // In the middle of sending STOP bit
                        bclk_cnt_next = bclk_cnt + 1;
                end
            end
        endcase
    end

    assign vif.tx = tx;
    assign vif.tx_done = tx_done;

endmodule: uart_tx