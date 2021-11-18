module testbench;
    
    logic i_rx_serial, 
          i_clk,
          o_done,
          err, tick; 

    logic [7:0] o_rx_byte, rx_byte_buff;
    int a;
    bit dat;
    int count;

    clocking cb1 @(posedge tick); 
        default input #1step;
        default output negedge;
        
        output  i_rx_serial;
        input   o_done, err, 
                o_rx_byte;
    endclocking

    clocking cb2 @(negedge i_clk); 
        default input #1step;
       // default output negedge;
        
       // output  i_rx_serial;
        input   o_done, err, 
                o_rx_byte;
    endclocking
    
    RX_UART R_U (
                    .i_clk,
                    .i_rx_serial, 
                    .o_done, 
                    .err,
                    .o_rx_byte
    );

    initial 
    begin
         i_clk = 1'b0;   
         count <= 0; 
    end
    
    always 
    begin
        #10 i_clk <= ~ i_clk;    
    end

   initial
    begin : input_drive
        //@(cb1);
        cb1.i_rx_serial <= 1'b0;
        @(cb1);
        a = randomize(dat);
        for(int i=0; i<8; i++)
            begin
                cb1.i_rx_serial <= dat;
                rx_byte_buff[i] = dat;
                a = randomize(dat);
                @cb1;
            end
        cb1.i_rx_serial <= 1'b1;
        @(cb1);
        @(cb1);
        @(cb1);
        //@(posedge i_clk);
        if(rx_byte_buff == o_rx_byte)
            begin
                $display("SIMULATION SUCCEEDED");
                 $finish;
            end       
        else
            begin
                $display("SIMULATION FAILED");
                $finish;
            end
    end

    always @(posedge i_clk) 
    begin
        if(count == 837)
            begin
                count <= 0; 
                tick <= 1'b1;
            end
        else
            begin
                count <= count + 1;
                tick <= 1'b0;
            end    
    end

endmodule