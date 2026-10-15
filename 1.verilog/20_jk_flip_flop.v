module jk_flip_flop (
    input  wire clk,
    input  wire rst,
    input  wire j,
    input  wire k,
    output reg  q
);

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else begin
            case ({j, k})
                2'b00:   q <= q;     // Hold
                2'b01:   q <= 1'b0;  // Clear
                2'b10:   q <= 1'b1;  // Set
                2'b11:   q <= ~q;    // Toggle
                default: q <= q;     // Hold
            endcase
        end
    end

endmodule