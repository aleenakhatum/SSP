module fifo4_8(
    input reset,
    input clk,
    input select,
    input write,
    input read,
    input wire [7:0] data_in,
    output wire full,
    output wire empty, //unused
    output reg [7:0] data_out
    );
    
    reg [7:0] fifo [3:0];
    reg [1:0] wptr, rptr;
    reg [2:0] count;
    
    assign full = (count == 4);
    assign empty = (count == 0);
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            wptr <= 2'd0;
            rptr <= 2'd0;
            count <= 3'd0;
            data_out <= 8'd0;
        end
        
        if (write == 1'b1 && full == 1'b0 && select == 1'b1) begin //write signal high
            fifo[wptr] <= data_in;
            wptr <= wptr + 1;
            count <= count + 1;
        end
        else if (read == 1'b1 && empty == 1'b0 && select == 1'b1) begin //read signal high
            data_out <= fifo[rptr];
            rptr <= rptr + 1;
            count <= count - 1;
        end
    end
endmodule 