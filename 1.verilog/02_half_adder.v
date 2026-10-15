module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    assign sum   = a ^ b;  // XOR produces the sum bit
    assign carry = a & b;  // AND produces the carry bit

endmodule