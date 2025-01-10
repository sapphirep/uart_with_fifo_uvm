module uart_rx 
(   
    uart_if.UART_RX  vif,
    input logic      bclk
);

    import uart_pkg::*;

    rx_state_e              state, state_next;
    logic [3:0]             bclk_cnt, bclk_cnt_next;
    logic [DATA_WIDTH-1:0] dout;
    logic [ADDR_WIDTH-1:0] dout_idx, dout_idx_next;

    logic rx_done;

    always_ff @(posedge vif.clk, posedge vif.rst)
    begin
        if (vif.rst)
        begin
            state    <= RX_IDLE;
            bclk_cnt <= 0;
            dout_idx <= 0;
        end
        else
        begin
            state     <= state_next;
            bclk_cnt  <= bclk_cnt_next;
            dout_idx  <= dout_idx_next;
        end
    end

    always_comb
    begin
        state_next    = state;
        bclk_cnt_next = bclk_cnt;
        dout_idx_next  = dout_idx;
        rx_done       = 1'b0;

        case (state)
            RX_IDLE:
            begin
                if (vif.rx == 1'b0) begin
                    state_next    = RX_START;
                    bclk_cnt_next = 0;
                end
            end

            RX_START:
            begin
                if (bclk)
                begin
                    if (bclk_cnt == DATA_MID_POINT - 1) begin
                        // Sample in the middle of the START bit
                        state_next    = RX_RECEIVE;
                        bclk_cnt_next = 0;
                        dout_idx_next  = 0;
                    end
                    else
                        bclk_cnt_next = bclk_cnt + 1;
                end
            end

            RX_RECEIVE:
            begin
                dout[dout_idx] = vif.rx;
                if (bclk) 
                begin
                    if (bclk_cnt == OS_16_BCLK_CNT - 1) begin
                        // Sample in the middle of the data bit
                        if (dout_idx == DATA_WIDTH - 1) begin
                            state_next    = RX_STOP;
                            dout_idx_next = 0;
                        end
                        else
                            // There are more data bits left to receive
                            dout_idx_next  = dout_idx + 1;

                        bclk_cnt_next = 0;
                    end
                    else
                        bclk_cnt_next = bclk_cnt + 1; 
                end
            end

            RX_STOP:
            begin
                if (bclk)
                begin
                    if (bclk_cnt == OS_16_BCLK_CNT - 1) begin
                        // Sample in the middle of STOP bit
                        state_next = RX_IDLE;
                        rx_done = 1'b1;
                    end
                    else
                        bclk_cnt_next = bclk_cnt + 1;
                end
            end
        endcase
    end

    assign vif.dout = dout;
    assign vif.rx_done = rx_done;

endmodule: uart_rx