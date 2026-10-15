# Template 11: Parameterized Magnitude Comparator

## Purpose

A magnitude comparator compares two unsigned binary numbers
and indicates their relationship:

- gt: a is greater than b.
- eq: a is equal to b.
- lt: a is less than b.

The WIDTH parameter sets the operand size.
It defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | WIDTH bits | First unsigned number |
| b | Input | WIDTH bits | Second unsigned number |
| gt | Output | 1 bit | 1 when a > b |
| eq | Output | 1 bit | 1 when a == b |
| lt | Output | 1 bit | 1 when a < b |

For inputs containing only 0 and 1, exactly one output is 1.

## Short Explanation

Unsigned binary numbers can be compared from the most
significant bit toward the least significant bit.

The first position where the bits differ determines
which number is greater:

- a has 1 and b has 0 → a is greater.
- a has 0 and b has 1 → a is smaller.
- If every bit matches → the numbers are equal.

Verilog comparison operators describe this behavior directly.

No clock or reset is required because this is combinational logic.

## Comparison Table

| Relationship | gt | eq | lt |
|---|---|---|---|
| a > b | 1 | 0 | 0 |
| a == b | 0 | 1 | 0 |
| a < b | 0 | 0 | 1 |

## One-Bit Truth Table

For WIDTH = 1:

| a | b | gt | eq | lt |
|---|---|---|---|---|
| 0 | 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 | 0 |
| 1 | 1 | 0 | 1 | 0 |

For larger widths, the circuit compares the complete
unsigned values rather than each bit independently.

## Small Examples

Assume WIDTH = 4.

| a | b | Unsigned comparison | gt | eq | lt |
|---|---|---|---|---|---|
| 1010 | 0110 | 10 > 6 | 1 | 0 | 0 |
| 0101 | 0101 | 5 == 5 | 0 | 1 | 0 |
| 0011 | 1000 | 3 < 8 | 0 | 0 | 1 |

Consider a = 1010 and b = 1001:

1. Bit 3 matches: both are 1.
2. Bit 2 matches: both are 0.
3. Bit 1 differs: a has 1 and b has 0.
4. Therefore, a > b, regardless of bit 0.

## Verilog Code

```verilog
module magnitude_comparator #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire             gt,
    output wire             eq,
    output wire             lt
);

    assign gt = (a > b);
    assign eq = (a == b);
    assign lt = (a < b);

endmodule
```

## Code Explanation

### 1. Parameterized width

`parameter WIDTH = 4`

Sets the default operand width to four bits.

For an eight-bit instance, use:

`magnitude_comparator #(.WIDTH(8))`

### 2. Unsigned operands

`input wire [WIDTH-1:0] a`

Declares an unsigned vector because the signed keyword
is not present.

For WIDTH = 4, the unsigned range is 0 through 15.

For example, 4'b1111 is interpreted as 15 in this module,
not as -1.

### 3. Greater-than comparison

`assign gt = (a > b);`

Produces 1 when the unsigned value of a exceeds b,
and 0 otherwise for known binary inputs.

### 4. Equality comparison

`assign eq = (a == b);`

Checks whether the operand values are equal.

`==` compares values.
`=` assigns a value.

### 5. Less-than comparison

`assign lt = (a < b);`

Produces 1 when the unsigned value of a is smaller than b,
and 0 otherwise for known binary inputs.

### 6. Concurrent operation

All three continuous assignments operate concurrently.
Each comparison produces a one-bit result.

Inputs containing x or z can cause unknown comparison
results. The exactly-one-output-high property assumes
inputs containing only 0 and 1.

## How to Remember

"Greater, Equal, Less → >, ==, <"

Each output directly matches its operator:

- gt → a > b
- eq → a == b
- lt → a < b

To compare manually, start from the most significant bit.
The first differing bit decides; all matching bits mean equal.