module up_down_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    input  wire             up,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (up)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

endmodule