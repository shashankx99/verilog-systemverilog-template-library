module ring_counter_concat (
    input  wire       clk,  // Clock signal
    input  wire       rst,  // Asynchronous active-high reset
    output reg  [3:0] out   // 4-bit counter output
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize the counter to the starting state (1000)
            out <= 4'b1000;
        end else begin
           
            out <= {out[0], out[3:1]};
        end
    end

endmodule