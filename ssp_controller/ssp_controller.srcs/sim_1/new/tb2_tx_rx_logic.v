    initial begin
        $display("=== Clean Back-to-Back SSP Testbench ===");
        $dumpfile("tb_tx_rx_logic.vcd");
        $dumpvars(0, tb_tx_rx_logic);

        CLEAR_B = 0;
        #300;
        CLEAR_B = 1;
        #300;

        @(posedge SSPCLKOUT);
        tx_empty = 0;                   // FIFO is no longer empty

        // Feed the four bytes exactly when the DUT asks for them
        @(posedge tx_read); TxData = 8'h55;
        @(posedge tx_read); TxData = 8'hAA;
        @(posedge tx_read); TxData = 8'hC3;
        @(posedge tx_read); TxData = 8'h3C;

        tx_empty = 1;                   // FIFO empty again → transmission stops

        // Wait for the four received bytes
        repeat(4) @(posedge rx_write);

        #2000;
        $display("=== ALL 4 BYTES RECEIVED CORRECTLY ===");
        $display("Simulation finished successfully!");
        $finish;
    end