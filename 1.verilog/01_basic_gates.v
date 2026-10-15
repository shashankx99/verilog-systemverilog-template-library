module basic_gates (
    input  wire a,
    input  wire b,

    output wire y_and,
    output wire y_or,
    output wire y_not,
    output wire y_nand,
    output wire y_nor,
    output wire y_xor,
    output wire y_xnor
);

    assign y_and  =  a & b;     // Both inputs are 1
    assign y_or   =  a | b;     // At least one input is 1
    assign y_not  = ~a;         // Invert input a
    assign y_nand = ~(a & b);   // Inverted AND
    assign y_nor  = ~(a | b);   // Inverted OR
    assign y_xor  =  a ^ b;     // Inputs are different
    assign y_xnor = ~(a ^ b);   // Inputs are equal

endmodule