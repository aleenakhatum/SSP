module ssp_test;
    reg clock, clear_b, pwrite, psel;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire sspoe_b, tx_to_rx, clk_wire, fss_wire, ssptxintr, ssprxintr, oe_b;

    initial begin
        clock = 1'b0;
        clear_b = 1'b0;
        psel = 1'b1;
        @(posedge clock);
        #1;
        @(posedge clock);
    data_in = 8'b11111111; //8'hFF, dummy data. should not enter into SSP.
        #1;
        clear_b = 1'b1;
        #15 
        pwrite = 1'b1;
        data_in = 8'b10010101; //8'h95
        #50
        psel = 1'b0;
        #870
        pwrite = 1'b0;
    $stop;
    
    end
    always 
    #20 clock = ~clock;

// serial output from SSP is looped back to the serial input.
    ssp ssp2 (.PCLK(clock), .CLEAR_B(clear_b), .PSEL(psel), .PWRITE(pwrite), .SSPCLKIN(clk_wire), .SSPFSSIN(fss_wire), .SSPRXD(tx_to_rx), .PWDATA(data_in), .PRDATA(data_out), .SSPCLKOUT(clk_wire), .SSPFSSOUT(fss_wire), .SSPTXD(tx_to_rx), .SSPOE_B(oe_b), .SSPTXINTR(ssptxintr), .SSPRXINTR(ssprxintr));

endmodule