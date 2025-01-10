package uart_pkg;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = $clog2(DATA_WIDTH);

    parameter logic [4:0] OS_16_BCLK_CNT = 16;
    parameter logic [3:0] DATA_MID_POINT = OS_16_BCLK_CNT / 2;

    typedef enum { TX_IDLE, TX_START, TX_SEND, TX_PARITY, TX_STOP }    tx_state_e;
    typedef enum { RX_IDLE, RX_START, RX_RECEIVE, RX_PARITY, RX_STOP } rx_state_e;

endpackage