module universal_shift_register #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [1:0]       mode,
    input  wire             serial_right,
    input  wire             serial_left,
    input  wire [WIDTH-1:0] parallel_in,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else begin
            case (mode)
                2'b00: q <= q;

                2'b01: q <= {serial_right, q[WIDTH-1:1]};

                2'b10: q <= {q[WIDTH-2:0], serial_left};

                2'b11: q <= parallel_in;

                default: q <= q;
            endcase
        end
    end

endmodule