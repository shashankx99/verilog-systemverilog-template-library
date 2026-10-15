# Template 04: Parameterized Ripple-Carry Adder

## Purpose

A ripple-carry adder adds two multi-bit unsigned numbers
and an optional carry input.

It connects one full adder per bit. Each stage passes its
carry-out to the next higher-bit stage.

The WIDTH parameter controls the number of bits.
Its default value is 4, and it must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | WIDTH bits | First unsigned number |
| b | Input | WIDTH bits | Second unsigned number |
| cin | Input | 1 bit | Initial carry input |
| sum | Output | WIDTH bits | Lower bits of the result |
| cout | Output | 1 bit | Final carry output |

The complete result is {cout, sum}, which contains WIDTH + 1 bits.

## Short Explanation

For WIDTH = 4, the circuit contains four full adders.

- Stage 0 adds a[0], b[0], and cin.
- Stage 1 adds a[1], b[1], and the carry from stage 0.
- Stage 2 adds a[2], b[2], and the carry from stage 1.
- Stage 3 adds a[3], b[3], and the carry from stage 2.

Each sum bit comes from its corresponding stage.
The last stage produces cout.

It is called a ripple-carry adder because a carry can
propagate through successive stages before the result settles.
This propagation is combinational; it does not take one clock
cycle per stage.

## Small Example

Let WIDTH = 4:

- a = 4'b1011 = 11
- b = 4'b0110 = 6
- cin = 0

Expected addition:

11 + 6 + 0 = 17 = 5'b10001

Therefore:

- sum = 4'b0001
- cout = 1
- {cout, sum} = 5'b10001

## Stage-by-Stage Calculation

Work from bit 0, the least significant bit, toward bit 3.

| Stage | a[i] | b[i] | Carry in | sum[i] | Carry out |
|---|---|---|---|---|---|
| 0 | 1 | 0 | 0 | 1 | 0 |
| 1 | 1 | 1 | 0 | 0 | 1 |
| 2 | 0 | 1 | 1 | 0 | 1 |
| 3 | 1 | 0 | 1 | 0 | 1 |

Read sum from bit 3 down to bit 0: 0001.
The final carry is 1, giving the complete result 10001.

Each stage follows the full-adder truth table from Template 03.

## Verilog Code

```verilog
module ripple_carry_adder #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    wire [WIDTH:0] carry;

    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_adder
            full_adder fa (
                .a    (a[i]),
                .b    (b[i]),
                .cin  (carry[i]),
                .sum  (sum[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[WIDTH];

endmodule
```

## Code Explanation

### 1. Parameter

`parameter WIDTH = 4`

Sets the default operand width to four bits.
For an eight-bit instance, override it with `#(.WIDTH(8))`.

### 2. Multi-bit ports

`[WIDTH-1:0]`

Declares WIDTH bits. For WIDTH = 4, this becomes [3:0].

### 3. Carry connections

`wire [WIDTH:0] carry;`

Declares WIDTH + 1 carry connections:
one initial carry and one outgoing carry per stage.

For WIDTH = 4, these are carry[0] through carry[4].

### 4. Initial carry

`assign carry[0] = cin;`

Connects the external carry input to the first stage.

### 5. Generate loop

`genvar i` declares a variable for generating hardware.

The generate-for loop creates WIDTH full-adder instances
during elaboration, before simulation or synthesis.

It describes repeated hardware, not a loop that executes
one addition per clock cycle.

`begin : gen_adder` names each generated block.

### 6. Full-adder instance

`full_adder fa (...)`

Instantiates the module defined in 03_full_adder.v.

Named connections use this format:

.port_name(signal_name)

For example, `.a(a[i])` connects bit i of this module's
input a to the full adder's input port a.

Each stage receives carry[i] and produces carry[i+1].

### 7. Final carry

`assign cout = carry[WIDTH];`

Connects the last stage's carry to the external output.

Include both 03_full_adder.v and 04_ripple_carry_adder.v
when using this design in a tool.

## How to Remember

"One full adder per bit; carry connects the stages."

Remember these three steps:

1. START: carry[0] = cin
2. CHAIN: stage i takes carry[i] and produces carry[i+1]
3. FINISH: cout = carry[WIDTH]

For every stage, a[i], b[i], and sum[i] use the same index.
Only the outgoing carry advances to i + 1.