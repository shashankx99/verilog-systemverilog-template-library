// D flip-flop with synchronous active-high reset
module dff_sync_reset (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule


// D flip-flop with asynchronous active-high reset
module dff_async_reset (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule