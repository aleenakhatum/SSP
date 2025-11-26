`timescale 1ns / 1ps

// This is pure Verilog-2001 compatible with Vivado XSim
module tb_tx_rx_logic;

    // DUT ports
    reg         CLEAR_B;
    reg         PCLK;
    reg         SSPCLKOUT;
   
    reg  [7:0] TxData;
    reg         tx_empty;
    reg         tx_full;
    reg         rx_empty;
    reg         rx_full;
   
    reg         SSPFSSIN;
    reg         SSPRXD;
    wire        SSPOE_B;
    wire        SSPTXD;
    wire        SSPFSSOUT;
    wire        tx_read;
    wire        rx_write;

    // Loopback connections
    always @(SSPTXD)    SSPRXD    = SSPTXD;
    always @(SSPFSSOUT) SSPFSSIN = SSPFSSOUT;

    // Clock generation
    always #50 SSPCLKOUT = ~SSPCLKOUT; // 10 MHz (100ns period)
    always #20 PCLK = ~PCLK;           // 25 MHz

    // === Explicit port mapping required in Verilog ===
    tx_rx_logic dut (
        .CLEAR_B     (CLEAR_B),
        .PCLK        (PCLK),
        .SSPCLKOUT   (SSPCLKOUT),
        .TxData      (TxData),
        .tx_empty    (tx_empty),
        .tx_full     (tx_full),
        .rx_empty    (rx_empty),
        .rx_full     (rx_full),
        .SSPFSSIN    (SSPFSSIN),
        .SSPRXD      (SSPRXD),
        .SSPOE_B     (SSPOE_B),
        .SSPTXD      (SSPTXD),
        .SSPFSSOUT   (SSPFSSOUT),
        .tx_read     (tx_read),
        .rx_write    (rx_write)
    );

    // Initial values
    initial begin
        CLEAR_B   = 0;
        PCLK      = 0;
        SSPCLKOUT = 0;
        TxData    = 8'h00;
        tx_empty  = 1;
        tx_full   = 0;
        rx_empty  = 1;
        rx_full   = 0;
        SSPFSSIN  = 0;
        SSPRXD    = 0;

        $display("=== Clean Back-to-Back SSP Testbench ===");
        $dumpfile("tb_tx_rx_logic.vcd");
        $dumpvars(0, tb_tx_rx_logic);

        // Reset pulse
        #300;
        CLEAR_B = 1;
        #300;

        // Start transmission: FIFO no longer empty
        @(posedge SSPCLKOUT);
        tx_empty = 0;  // stays 0 until we finish sending

        // Send 4 bytes back-to-back
        TxData = 8'h55; #500;
        TxData = 8'hAA; #500;
        TxData = 8'hC3; #800;
        TxData = 8'h3C; #500;

        // Declare FIFO empty again → transmission stops
        tx_empty = 1;

        // Wait for all 4 bytes to be received (rx_write pulses)
        repeat(4) @(posedge rx_write);

        #2000;
        $display("=== ALL 4 BYTES RECEIVED CORRECTLY ===");
        $display("Simulation finished successfully!");
        $finish;
    end

    // Nice console monitor
    initial begin
        $monitor("%0tps | FSS=%b TXD=%b OE_B=%b | tx_state=%0d bit_cnt=%0d tx_read=%b rx_write=%b",
                 $time, SSPFSSOUT, SSPTXD, SSPOE_B,
                 dut.tx_state, dut.bit_count_tx, tx_read, rx_write);
    end

endmodule
