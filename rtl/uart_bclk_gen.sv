module uart_bclk_gen
#(parameter CLK_FREQ_HZ = 100 * 10**6, BAUD_RATE = 9600)
(
    input  logic clk, rst,
    output logic bclk
);

    localparam logic [15:0] DIVISOR = CLK_FREQ_HZ / BAUD_RATE / 16;

    logic [15:0] cnt;
    logic [15:0] cnt_next;

    // State register
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst)
            cnt <= DIVISOR;
        else
            cnt <= cnt_next;
    end

    // Next-state & output logic
    always_comb
    begin
        cnt_next = (cnt == DIVISOR) ? 1 : cnt + 1;
        bclk = (cnt == 1);
    end

endmodule: uart_bclk_gen