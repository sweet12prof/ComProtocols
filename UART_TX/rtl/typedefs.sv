package typedefs;
    typedef enum logic [1:0] 
    { 
        IDLE_START_DRIVE = 2'b00, 
        TX_SERIAL_DRIVE  = 2'b01, 
        TX_STOP_DRIVE    = 2'b10
    } tx_state_t;
endpackage
