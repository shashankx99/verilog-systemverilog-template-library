# Template 02: Half Adder

## Purpose

A half adder adds two one-bit binary inputs and produces
a sum bit and a carry bit.

It does not accept a carry input.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | 1 bit | First operand |
| b | Input | 1 bit | Second operand |
| sum | Output | 1 bit | Least significant bit of the result |
| carry | Output | 1 bit | Most significant bit of the result |

The complete two-bit answer is {carry, sum}.

## Short Explanation

The sum is 1 when the inputs differ.
The carry is 1 when both inputs are 1.

Therefore:

- XOR generates the sum.
- AND generates the carry.

This is combinational logic.
No clock or reset is required.

## Truth Table

| a | b | sum | carry | Complete result |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 00 |
| 0 | 1 | 1 | 0 | 01 |
| 1 | 0 | 1 | 0 | 01 |
| 1 | 1 | 0 | 1 | 10 |

The complete result is shown in the order {carry, sum}.
This table assumes binary inputs.

## Small Example

Let a = 1 and b = 1.

```text
Decimal: 1 + 1 = 2
Binary:  1 + 1 = 10
```

Therefore:

- sum = 0
- carry = 1
- {carry, sum} = 2'b10

The sum bit alone cannot represent the complete answer
when both inputs are 1.

## Logic Equations

```text
sum   = a XOR b
carry = a AND b
```

For binary inputs, the numeric relationship is:

```text
a + b = 2 × carry + sum
```

## Verilog Code

```verilog
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    assign sum   = a ^ b;  // XOR produces the sum bit
    assign carry = a & b;  // AND produces the carry bit

endmodule
```

## Code Explanation

### 1. Module declaration

`module half_adder (...)`

Defines the half-adder module and its ports.

### 2. Inputs

`input wire a`
`input wire b`

Declare the two one-bit values being added.

### 3. Outputs

`output wire sum`
`output wire carry`

Declare the two result bits.

carry has a numeric weight of 2.
sum has a numeric weight of 1.

### 4. Sum calculation

`assign sum = a ^ b;`

The ^ operator performs bitwise XOR.

For one-bit inputs, XOR produces 1 only when the
inputs differ.

When both inputs are 1, sum is 0.

### 5. Carry calculation

`assign carry = a & b;`

The & operator performs bitwise AND.

A carry occurs only when both inputs are 1.

### 6. Concurrent assignments

Both continuous assignments operate concurrently.

The circuit does not calculate sum first and carry later
because of their order in the source file.

### 7. Half adder versus full adder

A half adder adds two input bits.

A full adder adds three input bits:
a, b, and a carry input.

Simply widening the half-adder ports would perform
independent bitwise operations. It would not create
carry propagation between bit positions.

## How to Remember

"Different gives SUM; both 1 gives CARRY."

SUM → XOR → ^
CARRY → AND → &

Remember the key case:

1 + 1 = binary 10

Therefore:
- Sum must become 0.
- Carry must become 1.