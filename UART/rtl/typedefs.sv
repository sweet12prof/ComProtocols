package typedefs;
    typedef enum logic[1:0] {
            IDLE        = 2'b00, 
            CHECK_START = 2'b01, 
            SAMPLE      = 2'b10, 
            CHECK_STOP  = 2'b11 
               // ERR     = 3'b100
    } rx_states;
endpackage