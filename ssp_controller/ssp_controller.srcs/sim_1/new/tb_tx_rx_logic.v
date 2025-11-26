`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 10:34:48 PM
// Design Name: 
// Module Name: tb_tx_rx_logic
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


module tb_tx_rx_logic;
    //instantiate clocks
    reg PCLK = 0;
    reg CLEAR_B = 0;
    wire SSPCLKOUT;
    always #10 PCLK = ~PCLK;
    clk_div2 u_div(
        .PCLK(PCLK),
        .reset(~CLEAR_B),
        .SSPCLKOUT(SSPCLKOUT)
    );
    
    //output
    wire SSPOE_B;
    wire SSPTXD;
    wire SSPFSSOUT;
    wire tx_read;
    
    //instantiate signals coming from tx logic
    reg [7:0] TxData;
    reg SSPFSSIN = 0;
    
    //instantiate external SSP signals (into rx logic)
    reg SSPRXD = 0;
    
    //instantiate fifos
    wire [7:0] tx_data_from_fifo;
    wire tx_empty; 
    wire tx_full; //not used
    wire rx_empty; //not used
    wire rx_full; 
    wire [7:0] rx_data_to_fifo;

    // Instantiate your FIFOs (use the exact same fifo.v from the lab)
    TxFIFO tx_fifo (
        .PCLK(PCLK),
        .CLEAR_B(CLEAR_B),
        .PSEL(1'b1),
        .PWDATA(8'h00),           // we'll force data below
        .PWRITE(1'b0),          // we'll force write pulses
        .tx_read(tx_read),
        .TxData(tx_data_from_fifo),
        .full(tx_full)
    );

    RxFIFO rx_fifo (
        .PCLK(PCLK),
        .CLEAR_B(CLEAR_B),
        .PSEL(1'b1),
        .RxDATA(rx_data_to_fifo),
        .rx_write(rx_write),
        .PWRITE(1'b0),           // always reading
        .PRDATA(),
        .full(rx_full)
    );
    
    //instantiate logic
    tx_rx_logic dut (
        .CLEAR_B(CLEAR_B),
        .PCLK(PCLK),                    // not used inside, but port exists
        .SSPCLKOUT(SSPCLKOUT),
        .SSPOE_B(SSPOE_B),
        .TxData(tx_data_from_fifo),
        .tx_empty(tx_empty),
        .tx_full(),
        .SSPTXD(SSPTXD),
        .SSPFSSOUT(SSPFSSOUT),
        .tx_read(tx_read),
        .SSPFSSIN(SSPFSSOUT), //loopback
        .SSPRXD(SSPTXD), //loopback
        .rx_empty(),
        .rx_full(rx_full),
        .rx_write(rx_write)
    );
    
    //Task send serial byte
    task send_serial;
        input [7:0] byte;
        integer i;
        begin 
            @(posedge SSPCLKOUT);
            SSPFSSIN = 1;
            for (i = 7; i >= 0; i = i - 1) begin
                @ (posedge SSPCLKOUT);
                SSPRXD = byte[i];
            end
            @(posedge SSPCLKOUT);
            SSPFSSIN = 0;
            SSPRXD = 0;
        end
     endtask
     
    // =============================================================
    // Main Test Sequence
    // =============================================================
    initial begin
        $display("=== tx_rx_logic Standalone Testbench ===");
        $dumpfile("tx_rx_logic.vcd");
        $dumpvars(0, tb_tx_rx_logic);

        // Reset
        CLEAR_B = 0;
        #80;
        CLEAR_B = 1;
        #100;
        
        // ------------ Test 1: TX Back-to-Back ------------
        $display("\n[Test 1] TX: 4 bytes back-to-back (55 AA C3 3C)");
        force tx_fifo.PWRITE = 1'b1;
        force tx_fifo.PWDATA   = 8'h55;  @(posedge PCLK);
        force tx_fifo.PWDATA   = 8'hAA;  @(posedge PCLK);
        force tx_fifo.PWDATA   = 8'hC3;  @(posedge PCLK);
        force tx_fifo.PWDATA   = 8'h3C;  @(posedge PCLK);
        force tx_fifo.PWRITE = 1'b0;
        release tx_fifo.PWDATA;
        release tx_fifo.PWRITE;

        // Wait for all 4 bytes to finish transmitting
        repeat(40) @(posedge SSPCLKOUT);
        #500;

        // ------------ Test 2: RX Normal Reception ------------
        $display("\n[Test 2] RX: Receive 0xA5 then 0x5A");
        //rx_full = 0;  // space available
        send_serial(8'hA5);
        #200;
        send_serial(8'h5A);
        #800;

        // ------------ Test 3: RX Full → Reject Frame ------------
        $display("\n[Test 3] RX Full Test: Frame should be ignored");
        //rx_full = 1;  // FIFO full
        send_serial(8'hFF);  // This byte must NOT generate rx_write pulse
        send_serial(8'hFF);  // This byte must NOT generate rx_write pulse
        send_serial(8'hFF);  // This byte must NOT generate rx_write pulse
        send_serial(8'hFF);  // This byte must NOT generate rx_write pulse
        //should be full at this point

        send_serial(8'hAA);  // This byte must NOT generate rx_write pulse
        #800;
        
        $display("=== All tests completed ===\n");
        #1000;
        $finish;
    end

    // Optional monitor
    initial begin
        $monitor("t=%0t | FSSOUT=%b TXD=%b | FSSIN=%b RXD=%b | tx_read=%b rx_write=%b",
                 $time, SSPFSSOUT, SSPTXD, SSPFSSIN, SSPRXD, tx_read, rx_write);
    end
endmodule
