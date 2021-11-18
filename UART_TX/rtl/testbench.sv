module testbench; 

    logic i_clk, rst,
          i_tx_start;
    logic [7:0] i_data;
    logic o_tx_serial,
          o_tx_busy,
          o_tx_done, 
          o_tick_debug;

    logic [9:0] i_data_res;

   

    UART_TX U_T
        (
            .rst,
            .i_clk, 
            .i_tx_start, 
            .i_data,
            .o_tx_serial,
            .o_tx_busy, 
            .o_tx_done,
            .o_tick_debug
        );
    
    clocking cb1 @(posedge o_tick_debug);
        default output negedge input #1step; 
        input   o_tx_serial, 
                o_tx_busy, 
                o_tx_done;
    endclocking

    initial begin
        i_clk = 1'b0;
    end

    initial begin
        rst = 1'b0; 
        #22;
        rst = 1'b1;
    end
    always  begin
        #10 i_clk <= ~ i_clk; 
    end

    initial begin
        i_tx_start = 1'b0;
        i_data = 	8'b01100001;
        @(cb1);
            i_data_res[0] = o_tx_serial; 
        for(int i=1; i<9; i++)
            begin
                @(cb1);
                    i_data_res[i] = o_tx_serial;
            end
        @(cb1);
            i_data_res[9] = o_tx_serial;
            i_tx_start = 1'b1;
        @(cb1);
            if(({1'b1, i_data, 1'b0 }) == i_data_res)
                begin
                    $display("SIMULATION SUCEEDED!");
                    $finish;    
                end 
            else 
                begin
                    $display("SIMULATION FAILED!");
                    $finish;  
            end   
            
    end

    // always begin
    //     @(posedge o_tx_done) 

                
    //  end
endmodule