# Template 03: Full Adder

## Purpose

A full adder adds three one-bit inputs: a, b, and carry-in (cin).
It produces a sum bit and a carry-out bit (cout).

Unlike a half adder, it accepts a carry from a previous stage.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | 1 bit | First operand bit |
| b | Input | 1 bit | Second operand bit |
| cin | Input | 1 bit | Carry from the previous stage |
| sum | Output | 1 bit | Sum bit |
| cout | Output | 1 bit | Carry to the next stage |

The complete two-bit result is {cout, sum}.

## Truth Table

| a | b | cin | sum | cout |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

This table assumes binary inputs (0 or 1).

## Small Examples

Example 1: a = 1, b = 0, cin = 1

1 + 0 + 1 = 2 in decimal = 10 in binary.

Therefore:
- sum = 0
- cout = 1
- {cout, sum} = 2'b10

Example 2: a = 1, b = 1, cin = 1

1 + 1 + 1 = 3 in decimal = 11 in binary.

Therefore:
- sum = 1
- cout = 1
- {cout, sum} = 2'b11

## Logic

sum  = a XOR b XOR cin
cout = (a AND b) OR (a AND cin) OR (b AND cin)

The sum is 1 when an odd number of inputs are 1.
The carry is 1 when at least two inputs are 1.

## Verilog Code

```verilog
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);

endmodule
```

## Code Explanation

- `a`, `b`, and `cin` are the three one-bit inputs.
- `a ^ b ^ cin` generates the sum using XOR.
- Each AND term checks whether a particular input pair is 1.
- OR combines the three pair checks to generate carry-out.
- `assign` continuously drives the outputs.

Both assignments operate concurrently.
No clock or reset is required because this is combinational logic.

## How to Remember

"SUM checks odd ones; CARRY checks two or more ones."

For sum:
- One input is 1 → sum = 1.
- Three inputs are 1 → sum = 1.
- Otherwise → sum = 0.

For carry:
- Write all pairs: a·b, a·cin, b·cin.
- OR the pairs together.

## Connection to the Half Adder

A full adder can also be constructed using two half adders
and one OR gate:

1. First half adder:
   s1 = a ^ b
   c1 = a & b

2. Second half adder:
   sum = s1 ^ cin
   c2 = s1 & cin

3. Combine the carries:
   cout = c1 | c2

Therefore, an equivalent carry equation is:

cout = (a & b) | ((a ^ b) & cin)



