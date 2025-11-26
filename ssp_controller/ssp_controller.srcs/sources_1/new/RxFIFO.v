module RxFIFO (
    input PSEL,
    input rx_write,
    input PWRITE,
    input CLEAR_B,
    input PCLK,
    input wire [7:0] RxData,
    output wire [7:0] PRDATA,
    output wire full,   
    output wire empty, 
    output wire SSPRXINTR
);

    //local wires
    wire CLEAR = ~CLEAR_B;
    
    //instantiate fifo
    fifo4_8 u_fifo (
        .reset(CLEAR),
        .clk(PCLK), //uses external clock 
        .select(PSEL),
        .write(rx_write),
        .read(~PWRITE), //when PWRITE is 0, read signal is high
        .data_in(RxData),
        .full(full),
        .empty(empty),
        .data_out(PRDATA)        
    );
    
    assign SSPRXINR = full;
    
endmodule