`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 09:04:15 PM
// Design Name: 
// Module Name: tb_fifo4_8
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


module tb_fifo4_8;
    
    //define inputs
    reg CLEAR;
    reg SSPCLKOUT = 0;
    reg PSEL;
    reg PWRITE;
    reg [7:0] data_in;
    
    //define output
    wire full;
    wire empty;
    wire [7:0] data_out;
    
    //instantiate fifo
    fifo4_8 dut(
    .reset(CLEAR),
    .clk(SSPCLKOUT),
    .select(PSEL),
    .write(PWRITE),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
    );
    
    //generate clk
    //initial begin
        //SSPCLKOUT = 0;
    //end
    always begin
        #5 SSPCLKOUT = ~SSPCLKOUT;
    end  
    
    //task define
    task write(input [7:0] val);
    begin
        @(negedge SSPCLKOUT);
        PSEL = 1;
        PWRITE = 1;
        data_in = val;
        @(posedge SSPCLKOUT); 
    end
    endtask
    
    task write_no_sel(input [7:0] val);
    begin
        @(negedge SSPCLKOUT);
        PSEL = 0;
        PWRITE = 1;
        data_in = val;
        @(posedge SSPCLKOUT);
    end
    endtask

    
    task read;
    begin
        @(negedge SSPCLKOUT);
        PSEL = 1;
        PWRITE = 0;
        @(posedge SSPCLKOUT);
        $display("[%0t] READ %0d  full=%b empty=%b", $time, data_out, full, empty);
    end
    endtask
    
    //stimulus
    initial begin
    
        //inialize
        CLEAR = 0;
        PSEL = 0;
        PWRITE = 0;
        data_in = 8'd0;
        
        //Apply reset
        @(posedge SSPCLKOUT);
        CLEAR = 1;
        @(posedge SSPCLKOUT);
        CLEAR = 0;
        
        ///*****TEST1*****
        //Set select high and try to write
        //should not write anything to fifo
        
        //Attempt to write values while select is 0
        write_no_sel(8'd10);
        write_no_sel(8'd20);
        write_no_sel(8'd30);
        write_no_sel(8'd40);
        
        // FIFO should be empty at this point
        @(posedge SSPCLKOUT);
        $display("[%0t] After writes: full=%0b empty=%0b", $time, full, empty);
        
        ///*****TEST2*****
        //write to fifo while select signal high
        //should write all values
        
        //Attempt to write values while select is 0
        write(8'd10);
        write(8'd20);
        write(8'd30);
        write(8'd40);
        
        // FIFO should be full at this point
        @(posedge SSPCLKOUT);
        $display("[%0t] After writes: full=%0b empty=%0b", $time, full, empty);
        
        ///*****TEST3*****
        //read 4 values
        //fifo should be empty after
        read();
        read();
        read();
        read();
        
        // FIFO should now be empty
        @(posedge SSPCLKOUT);
        $display("[%0t] After reads: full=%0b empty=%0b", $time, full, empty);

        // End simulation
        #20;
        $stop;
    end
endmodule
