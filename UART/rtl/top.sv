module top (
                input logic  i_clk, 
                             i_rx_serial, 
                output logic LED1, 
                             LED2
);

    logic [7:0] o_rx_byte, rx_byte_final;
    logic o_done, err, someVar;
    //someVar = i_rx_serial ? 
    
    RX_UART R_U (
        .i_clk    ,   
        .i_rx_serial,
        .o_rx_byte   , 
        .o_done       ,
        .err         
    );

//    always_ff @( posedge i_clk ) 
//    begin : blockName
//        if(o_done && !err)    
//            begin
//                rx_byte_final <= o_rx_byte;
//            end
//    end
    assign rx_byte_final = o_rx_byte;
    always_comb 
    begin : R_O
        if(rx_byte_final == 8'b01100001)
            begin
                LED1 <= 1'b1;
                LED2 <= 1'b0;
            end
        else
            begin
                LED1 <= 1'b0;
                LED2 <= 1'b1;
            end
    end
endmodule