module johnson_counter_concat (
    input  wire       clk,
    input  wire       rst,
    output reg  [3:0] out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 4'b0000;
        else
            out <= {~out[0], out[3:1]};
    end

endmodule