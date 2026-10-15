module parity_generator_checker #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] data,
    input  wire             parity_in,
    output wire             parity_out,
    output wire             parity_error
);

    // Generate even parity
    assign parity_out = ^data;

    // Check data against the received parity bit
    assign parity_error = (^data) ^ parity_in;

endmodule