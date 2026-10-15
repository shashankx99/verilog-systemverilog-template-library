module always_comb_example #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [1:0]       sel,
    output logic [WIDTH-1:0] y
);

    always_comb begin
        y = '0;

        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = a & b;
            2'b11: y = a | b;
            default: y = '0;
        endcase
    end

endmodule