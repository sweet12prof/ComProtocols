
module RX_UART import typedefs::*; (
    input logic  i_clk,
                 i_rx_serial, 
    output logic o_done, err,
    output logic [7:0] o_rx_byte
);
    rx_states PS, NS;
    integer countCurr, countNext;
    integer bitPosCurr, bitPosNext, count;
    logic [7:0] rx_byte, rx_byte_Curr;

    //int countA= 0;
    logic tick;
    
    parameter  tick_per_bit = 867;
    parameter  tick_per_bit_half = 433;


    always_ff @( posedge i_clk) 
    begin : PS_NS_LOGIC
        PS <= NS;
        countCurr  <= countNext;
        bitPosCurr <= bitPosNext;
        rx_byte_Curr <= rx_byte;
    end

    always_comb 
    begin : NS_comb_proc
        case (PS)
                IDLE:
                    begin 
                        countNext  = 0;
                        bitPosNext = 0;
                        o_done     = 1'b0;
                        err       = 1'b0;
                        rx_byte   = 8'b0;

                         if(i_rx_serial)                            
                            NS = IDLE;
                        else 
                            NS = CHECK_START;
                    end 
                
                CHECK_START:
                    begin
                        o_done      = 1'b0;
                        err         = 1'b0;
                        bitPosNext  = 0;
                        rx_byte     = 8'b0;
                        if(countCurr == tick_per_bit_half)
                            begin
                                if(!i_rx_serial)
                                    begin
                                        NS  = SAMPLE;
                                        countNext = 0;
                                    end
                                else
                                    begin
                                       countNext = 0;
                                             NS  = IDLE; 
                                    end
                            end
                        else
                            begin
                                countNext = countCurr + 1;
                                       NS = CHECK_START;
                            end
                    end
                
                SAMPLE:
                    begin
                        o_done     = 1'b0;
                         err       = 1'b0;
                        if(bitPosCurr < 8)
                            begin 
                                if(countCurr == tick_per_bit)
                                    begin 
                                        NS = SAMPLE;
                                        countNext           = 0;
                                        bitPosNext          = bitPosCurr + 1;
                                        //rx_byte[bitPosCurr] <= i_rx_serial;
                                        for(int i=0; i<8; i++)
                                            if(i == bitPosCurr)
                                                rx_byte[bitPosCurr] = i_rx_serial;
                                            else 
                                                rx_byte[i] = rx_byte_Curr[i];
                                    end
                                else
                                    begin
                                        rx_byte    = rx_byte_Curr;
                                        countNext  = countCurr + 1;
                                        bitPosNext = bitPosCurr;
                                        NS = SAMPLE;
                                    end                       
                            end
                        else
                            begin
                                rx_byte    = rx_byte_Curr;
                                countNext  = 0;
                                bitPosNext = bitPosCurr;
                                NS         = CHECK_STOP;
                            end 
                    end

                CHECK_STOP:
                    begin
                         rx_byte    = rx_byte_Curr;
                         bitPosNext = 0;
                          err       = 1'b0;
                         if(countCurr == tick_per_bit)
                            begin 
                                countNext = 0;
                                if(i_rx_serial)
                                    begin
                                    o_done = 1'b1;
                                        NS = IDLE;
                                    end
                                else 
                                    begin 
                                        o_done = 1'b0;
                                            NS = IDLE;
                                    end
                            end 
                        else 
                            begin
                                countNext = countCurr + 1;
                                o_done    = 1'b0;
                                NS        = CHECK_STOP;
                            end
                    end 


                default: 
                    begin 
                        rx_byte    = '0;
                        bitPosNext = 0;
                        o_done = 1'b0;
                        countNext = 0;
                        err       = 1'b0;
                        NS = IDLE;
                    end
        endcase
    end
    
    always_ff @( posedge i_clk ) begin : FF_count
        if(count != tick_per_bit)
            begin
                tick  <= 1'b0;
                count <= count + 1;
            end
        else 
            begin
                tick  <= 1'b1;
                count <= 0;
            end
    end


    //assign o_rx_byte = rx_byte_Curr;
    
    always_ff @(posedge i_clk)
        begin
            if(o_done)
                o_rx_byte <= rx_byte_Curr;
        end  

    property CHK_UART;
        @(posedge tick)
            i_rx_serial ##1 !i_rx_serial |-> ##7 i_rx_serial; 
    endproperty

    CHK_UART_ASSRT : assert property(CHK_UART);
endmodule