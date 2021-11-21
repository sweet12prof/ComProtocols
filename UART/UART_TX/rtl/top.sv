module top (
    input logic         i_clk, rst,
                       i_tx_start, 
    //input logic [7:0]  i_data,
    output logic       o_tx_serial,
                       o_tx_busy
                       //o_tx_done,                 
                       //o_tick_debug
);
    logic o_tx_done;
    logic [2:0] count;
    logic [7:0] someDat;
    UART_TX U_T
(
    .i_clk, 
    .rst,
    .i_tx_start, 
    .i_data(someDat),
    .o_tx_serial,
    .o_tx_busy(), 
    .o_tx_done, 
    .o_tick_debug()
);

    always_ff @(posedge o_tx_done, negedge rst) 
    begin 
        if(!rst)
            count <= '0;
        else
            if(count < 6)
                count <= count + 1;
            else
                count <= '0;
    end

    always_comb begin : some_bloc
        case(count)
            3'd0 : someDat = 8'd99;
            3'd1 : someDat = 8'd104;
            3'd2 : someDat = 8'd114;
            3'd3 : someDat = 8'd105;
            3'd4 : someDat = 8'd115;
            default: someDat = 8'd13;
        endcase
    end
endmodule