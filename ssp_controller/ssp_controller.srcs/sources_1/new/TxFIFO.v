module TxFIFO (
    input PSEL,
    input PWRITE,
    input tx_read,
    input CLEAR_B,
    input PCLK,
    input wire [7:0] PWDATA,
    output wire [7:0] TxData,
    output wire full, //SSPTXINTR   
    output wire empty,
    output wire SSPTXINTR
);

    //local wires
    wire CLEAR = ~CLEAR_B;
    
    //instantiate fifo
    fifo4_8 u_fifo (
        .reset(CLEAR),
        .clk(PCLK), //uses external clock 
        .select(PSEL),
        .write(PWRITE), //write when PWRITE is high
        .read(tx_read), //tx_rx logic 
        .data_in(PWDATA),
        .full(full),
        .empty(empty),
        .data_out(TxData)        
    );
    
    assign SSPTXINTR = full;
endmodule