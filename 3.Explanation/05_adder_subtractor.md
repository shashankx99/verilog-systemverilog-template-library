# Template 05: Parameterized Adder–Subtractor

## Purpose

This circuit adds or subtracts two WIDTH-bit numbers using
the same adder hardware.

- sub = 0: result = a + b
- sub = 1: result = a - b

WIDTH defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | WIDTH bits | First operand |
| b | Input | WIDTH bits | Second operand |
| sub | Input | 1 bit | 0 selects addition; 1 selects subtraction |
| result | Output | WIDTH bits | Lower WIDTH bits of the answer |
| cout | Output | 1 bit | Carry-out from the internal adder |
| borrow | Output | 1 bit | Unsigned subtraction borrow; 0 during addition |

The result wraps modulo 2^WIDTH when the mathematical answer
does not fit in WIDTH unsigned bits.

For addition, {cout, result} is the complete unsigned sum.

For subtraction, cout = 1 means no unsigned borrow, while
cout = 0 means an unsigned borrow occurred. Do not interpret
{cout, result} as the complete subtraction answer.

## Short Explanation

Two's-complement subtraction uses this identity:

a - b = a + (~b) + 1

The same adder can therefore perform both operations:

- Addition:    a + b + 0
- Subtraction: a + (~b) + 1

We use sub to control both the inversion of b and the
adder's carry input.

## Operation Table

| sub | Modified b | Carry input | Operation |
|---|---|---|---|
| 0 | b | 0 | a + b |
| 1 | ~b | 1 | a - b |

## Why XOR Is Used

| b bit | sub | b bit XOR sub |
|---|---|---|
| 0 | 0 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 1 | 0 |

XOR with 0 preserves a bit.
XOR with 1 inverts a bit.

Therefore, XOR lets sub control whether b is inverted.

## Small Examples

Assume WIDTH = 4.

### Example 1: Addition

a = 4'b0101 = 5
b = 4'b0011 = 3
sub = 0

b remains 0011, and the carry input is 0.

0101 + 0011 + 0 = 01000

- result = 1000 = 8 unsigned
- cout = 0
- borrow = 0

### Example 2: Subtraction Without Borrow

a = 4'b0101 = 5
b = 4'b0011 = 3
sub = 1

Invert b: ~0011 = 1100
Set the carry input to 1.

0101 + 1100 + 1 = 10010

- result = 0010 = 2
- cout = 1
- borrow = 0

The final carry is discarded from the subtraction result.

### Example 3: Subtraction With Borrow

a = 4'b0011 = 3
b = 4'b0101 = 5
sub = 1

Invert b: ~0101 = 1010
Set the carry input to 1.

0011 + 1010 + 1 = 01110

- result = 1110
- cout = 0
- borrow = 1

The mathematical answer is -2.

The stored bit pattern 1110 represents 14 when interpreted
as unsigned, or -2 when interpreted as four-bit two's complement.

The ports in this module are unsigned. Signed interpretation
is an explanation of the bit pattern, not a change to the
declared port types.

## Verilog Code

```verilog
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

    assign borrow = sub & ~cout;

endmodule
```

## Code Explanation

### 1. Replicate the control bit

`{WIDTH{sub}}` repeats sub WIDTH times.

For WIDTH = 4:

- sub = 0 produces 0000.
- sub = 1 produces 1111.

This is called the replication operator.

### 2. Conditionally invert b

`b ^ {WIDTH{sub}}`

XOR applies independently to each bit.

- XOR with 0000 keeps b unchanged.
- XOR with 1111 inverts every bit of b.

### 3. Instantiate the ripple-carry adder

`ripple_carry_adder #(.WIDTH(WIDTH))`

Creates an adder with the same operand width as this module.

It adds a, b_modified, and sub.

### 4. Use sub as the carry input

`.cin(sub)`

For addition, this supplies 0.

For subtraction, this supplies the +1 needed to complete
the two's complement of b.

### 5. Generate unsigned borrow

`assign borrow = sub & ~cout;`

During subtraction, borrow is the inverse of cout.
During addition, sub forces borrow to 0.

Carry-out and borrow are unsigned arithmetic flags.
This template does not generate a signed-overflow flag.

### 6. Source dependencies

Include these three files when using this design:

- 03_full_adder.v
- 04_ripple_carry_adder.v
- 05_adder_subtractor.v

No clock or reset is required because the circuit is
combinational.

## How to Remember

"Subtract: flip B and add one."

Use the same control bit twice:

1. XOR b with sub to control inversion.
2. Connect sub to the adder's carry input.

Remember the main expression:

result = a + (b XOR repeated sub) + sub