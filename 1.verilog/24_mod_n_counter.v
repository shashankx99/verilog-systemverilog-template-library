module mod_n_counter #(
    parameter integer N = 10,
    parameter integer WIDTH = (N > 1) ? $clog2(N) : 1
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (count == N - 1)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end

endmodule