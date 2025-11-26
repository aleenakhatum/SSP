`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 05:33:32 PM
// Design Name: 
// Module Name: tb_clk_div2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_clk_div2;
    
    //instantiate inputs and outputs
    reg PCLK;
    reg reset;
    wire SSPCLKOUT;
    
    //instantiate module instance
    clk_div2 this_clkdiv(.PCLK(PCLK), .reset(reset), .SSPCLKOUT(SSPCLKOUT));
    
    //generate PCLK signal
    initial PCLK = 0;
    always begin
        #5 PCLK = ~PCLK;
    end
    
    //testbench
    initial begin
        reset = 1;
        #20;
        reset = 0;
        #20;
        $stop;
    end
endmodule
