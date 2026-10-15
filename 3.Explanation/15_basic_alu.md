# Template 15: Basic ALU

## Purpose

An Arithmetic Logic Unit (ALU) performs arithmetic and
logical operations on data.

This ALU supports eight operations selected by a
three-bit opcode.

WIDTH controls the operand and result size.
It defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | WIDTH bits | First unsigned operand |
| b | Input | WIDTH bits | Second unsigned operand |
| opcode | Input | 3 bits | Selects the operation |
| result | Output | WIDTH bits | Selected operation's result |
| zero | Output | 1 bit | 1 when result is all zeros |

NOT and shift operations use only a; b is ignored.

## Short Explanation

The opcode selects which operation drives result.

A case statement describes this selection. For known
binary inputs, zero becomes 1 if the selected result is 0.

This ALU is combinational and requires no clock or reset.

## Operation Table

| opcode | Operation | Expression |
|---|---|---|
| 000 | Addition | a + b |
| 001 | Subtraction | a - b |
| 010 | Bitwise AND | a & b |
| 011 | Bitwise OR | a \| b |
| 100 | Bitwise XOR | a ^ b |
| 101 | Bitwise NOT of a | ~a |
| 110 | Logical left shift of a by one | a << 1 |
| 111 | Logical right shift of a by one | a >> 1 |

Three opcode bits provide 2^3 = 8 operation selections.

## Small Example

Let WIDTH = 4:

a = 4'b1010 = 10 unsigned
b = 4'b0011 = 3 unsigned

| opcode | Operation | result | zero |
|---|---|---|---|
| 000 | 10 + 3 | 1101 | 0 |
| 001 | 10 - 3 | 0111 | 0 |
| 010 | 1010 AND 0011 | 0010 | 0 |
| 011 | 1010 OR 0011 | 1011 | 0 |
| 100 | 1010 XOR 0011 | 1001 | 0 |
| 101 | NOT 1010 | 0101 | 0 |
| 110 | 1010 shifted left by one | 0100 | 0 |
| 111 | 1010 shifted right by one | 0101 | 0 |

For a zero-result example:

a = 0101
b = 0101
opcode = 001

The ALU subtracts 5 - 5:

result = 0000
zero = 1

## Result Width

Only the lower WIDTH bits are stored in result.

For WIDTH = 4:

1111 + 0001 = 10000 mathematically.

The stored result is 0000 because the fifth bit is discarded.
Therefore, zero = 1 even though the full mathematical sum is 16.

Likewise:

0011 - 0101 = -2 mathematically.

The stored four-bit result is 1110, which is 14 unsigned
or -2 when interpreted as four-bit two's complement.

This template does not provide carry, borrow, or
signed-overflow flags.

## Verilog Code

```verilog
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
```

## Code Explanation

### 1. Parameterized operands

`parameter WIDTH = 4`

Sets the default operand and result width to four bits.

The ports are unsigned because they are not declared signed.

### 2. Operation selection

`case (opcode)`

Selects the expression assigned to result.

The opcode mapping is a design choice; this template
defines the mapping shown in the operation table.

### 3. Arithmetic operators

`a + b` performs addition.
`a - b` performs subtraction.

The WIDTH-bit result retains only the lower WIDTH bits.

### 4. Bitwise operators

`&`, `|`, and `^` operate on corresponding bits of a and b.
`~a` inverts every bit of a.

### 5. Shift operators

`a << 1` shifts left by one, inserting 0 at the right.
The bit shifted beyond the result width is discarded.

`a >> 1` shifts right by one, inserting 0 at the left.
The original least significant bit is discarded.

These are fixed one-bit logical shifts, not rotations.

### 6. Complete output assignment

Every case branch assigns result, including default.
This prevents unintended latch inference.

The reg declaration permits assignment inside the always
block; it does not imply a hardware register here.

### 7. Zero flag

`assign zero = (result == {WIDTH{1'b0}});`

`{WIDTH{1'b0}}` creates a WIDTH-bit vector of zeros.

The comparison produces 1 when result is zero and 0
when it is a known nonzero value.

An unknown result can produce an unknown zero flag.

### 8. Default branch

If opcode contains x or z, it matches none of the listed
binary values. This description then assigns result = 0.

The default is a code behavior, not an additional operation
or a guarantee about physically uncertain control signals.

## How to Remember

"An ALU is a collection of operations plus a selector."

Remember the opcode groups:

- 000, 001: arithmetic — ADD, SUB.
- 010, 011, 100: two-input logic — AND, OR, XOR.
- 101: invert a — NOT.
- 110, 111: move bits — LEFT, RIGHT.

Coding pattern:

1. Declare operands and opcode.
2. Use case to choose the operation.
3. Assign result on every path.
4. Compare result with zero to generate the zero flag.