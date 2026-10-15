module adder_subtractor #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             sub,
    output wire [WIDTH-1:0] result,
    output wire             cout,
    output wire             borrow
);

    wire [WIDTH-1:0] b_modified;

    // sub = 0: keep b unchanged
    // sub = 1: invert every bit of b
    assign b_modified = b ^ {WIDTH{sub}};

    ripple_carry_adder #(
        .WIDTH(WIDTH)
    ) adder (
        .a    (a),
        .b    (b_modified),
        .cin  (sub),
        .sum  (result),
        .cout (cout)
    );

    // For unsigned subtraction, no carry-out means a borrow
    assign borrow = sub & ~cout;

endmodule