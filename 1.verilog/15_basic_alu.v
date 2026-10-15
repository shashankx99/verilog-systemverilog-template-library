module basic_alu #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       opcode,
    output reg  [WIDTH-1:0] result,
    output wire             zero
);

    always @(*) begin
        case (opcode)
            3'b000:  result = a + b;
            3'b001:  result = a - b;
            3'b010:  result = a & b;
            3'b011:  result = a | b;
            3'b100:  result = a ^ b;
            3'b101:  result = ~a;
            3'b110:  result = a << 1;
            3'b111:  result = a >> 1;
            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero = (result == {WIDTH{1'b0}});

endmodule