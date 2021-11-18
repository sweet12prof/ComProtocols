module  UART_TX import typedefs::*;
(
    input logic        i_clk, rst,
                       i_tx_start, 
    input logic [7:0]  i_data,
    output logic       o_tx_serial,
                       o_tx_busy, 
                       o_tx_done, 
                       o_tick_debug
);
    parameter tick_full = 837;
    parameter tick_half = 433;
    
    tx_state_t NS;

    logic [7:0] i_data_buff;
    integer count, bitPos;

    always_ff @( posedge i_clk , negedge rst) 
    begin : proc
        if(!rst)
            NS <= IDLE_START_DRIVE;
        else 
            begin
                case(NS)
            IDLE_START_DRIVE:
                begin
                     i_data_buff <= i_data;
                    if(i_tx_start)
                        begin
                            count       <= 0;
                            bitPos      <= 0;
                            o_tx_serial <= 1'b1;
                            o_tx_busy   <= 1'b0;
                            o_tx_done   <= 1'b0;
                            o_tick_debug <= 1'b0;
                            NS          <= IDLE_START_DRIVE;
                        end
                    else 
                            bitPos       <= 0;
                            o_tx_busy    <= 1'b1;
                            o_tx_done    <= 1'b0;
                            o_tx_serial  <= 1'b0;
                            
                            if(count != tick_full)
                                begin
                                    count       <= count + 1;
                                    NS           = IDLE_START_DRIVE;
                                    o_tick_debug <= 1'b0;
                                end
                            else 
                                begin
                                    o_tick_debug <= 1'b1;
                                    count        <= 0;
                                    NS           <= TX_SERIAL_DRIVE;
                                end
                end 

            TX_SERIAL_DRIVE:
                begin
                    o_tx_busy   <= 1'b1;
                    o_tx_done   <= 1'b0;

                    if (bitPos < 8) 
                    begin
                        o_tx_serial <= i_data_buff[bitPos];
                        if(count != tick_full)
                            begin
                                o_tick_debug <= 1'b0;
                                 count = count + 1;
                                 NS <= TX_SERIAL_DRIVE;
                            end
                               
                        else 
                            begin
                                o_tick_debug <= 1'b1;
                                count  <= 0;
                                bitPos <= bitPos + 1;
                                NS <= TX_SERIAL_DRIVE;
                            end
                            
                    end

                    else
                        begin 
                            count       <= 0;
                            NS          <= TX_STOP_DRIVE;
                        end 
                end
            
            TX_STOP_DRIVE:
                begin 
                    o_tx_serial <= 1'b1;
                    bitPos  <= 0;
                    if(count != tick_full)
                        begin 
                            o_tick_debug <= 1'b0;
                            count       <= count + 1;
                            o_tx_busy   <= 1'b1;
                            o_tx_done   <= 1'b0;
                            NS <= TX_STOP_DRIVE;
                        end 
                    else
                        begin 
                            o_tick_debug <= 1'b1;
                            count       <= 0;
                            o_tx_busy   <= 1'b1;
                            o_tx_done   <= 1'b1;
                            NS <= IDLE_START_DRIVE;
                        end 
                end
                        
            default:
                begin 
                        o_tick_debug <= 1'b0;
                        o_tx_serial <= 1'b1;
                        count       <= 0;
                        bitPos      <= 0;
                        o_tx_busy   <= 1'b1;
                        o_tx_done   <= 1'b0;
                        NS <= IDLE_START_DRIVE;
                end


       endcase
    end
            
       
    end
endmodule