# Template 01: Basic Logic Gates

## Purpose

This template implements seven basic logic gates:

AND, OR, NOT, NAND, NOR, XOR, and XNOR.

Logic gates are the building blocks of digital circuits.
Their outputs depend on the current input values.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | 1 bit | First input |
| b | Input | 1 bit | Second input |
| y_and | Output | 1 bit | AND result |
| y_or | Output | 1 bit | OR result |
| y_not | Output | 1 bit | Inverted a |
| y_nand | Output | 1 bit | NAND result |
| y_nor | Output | 1 bit | NOR result |
| y_xor | Output | 1 bit | XOR result |
| y_xnor | Output | 1 bit | XNOR result |

The NOT gate uses only a. All other gates use both a and b.

## Short Explanation

| Gate | Output is 1 when... |
|---|---|
| AND | Both inputs are 1 |
| OR | At least one input is 1 |
| NOT | Input a is 0 |
| NAND | The inputs are not both 1 |
| NOR | Both inputs are 0 |
| XOR | The two inputs differ |
| XNOR | The two inputs are equal |

These are combinational circuits.
No clock or reset is required.

## Truth Table

| a | b | AND | OR | NOT a | NAND | NOR | XOR | XNOR |
|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 1 |
| 0 | 1 | 0 | 1 | 1 | 1 | 0 | 1 | 0 |
| 1 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 0 |
| 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 |

This table assumes binary inputs.

Verilog also supports x (unknown) and z (high impedance).
Gate expressions can produce unknown results for such inputs.

## Small Example

Let a = 1 and b = 0.

| Output | Value | Reason |
|---|---|---|
| y_and | 0 | Both inputs are not 1 |
| y_or | 1 | At least one input is 1 |
| y_not | 0 | Inverting a = 1 gives 0 |
| y_nand | 1 | Inverse of AND = 0 |
| y_nor | 0 | Inverse of OR = 1 |
| y_xor | 1 | Inputs differ |
| y_xnor | 0 | Inputs are not equal |

## Verilog Code

```verilog
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
```

## Code Explanation

### 1. Module declaration

`module basic_gates (...)`

Defines a hardware module named basic_gates and lists
its input and output ports.

`endmodule` ends the definition.

### 2. Input and output wires

`input wire a`

Declares a one-bit input connection.

`output wire y_and`

Declares a one-bit output driven by a continuous assignment.

### 3. Continuous assignment

`assign y_and = a & b;`

Continuously drives y_and from the expression a & b.

All seven assignments operate concurrently.
Their order in the file does not create sequential execution.

### 4. Bitwise operators

| Operator | Operation | Example |
|---|---|---|
| & | AND | a & b |
| \| | OR | a \| b |
| ~ | NOT | ~a |
| ^ | XOR | a ^ b |

These operators act on individual bits.

For multi-bit operands, binary bitwise operators act
on corresponding bit positions.

### 5. Inverted gates

NAND is AND followed by inversion:

`~(a & b)`

NOR is OR followed by inversion:

`~(a | b)`

XNOR is XOR followed by inversion:

`~(a ^ b)`

The parentheses ensure that the complete gate result
is inverted.

For example, ~(a & b) is different from ~a & b.

## How to Remember

| Gate | Memory tip |
|---|---|
| AND | ALL inputs must be 1 |
| OR | ANY input can be 1 |
| NOT | Flip the input |
| NAND | AND, then flip |
| NOR | OR, then flip |
| XOR | Different inputs give 1 |
| XNOR | Equal inputs give 1 |

For two-input XOR and XNOR:

XOR → DIFFERENT
XNOR → SAME

Start with AND, OR, and XOR.
Add inversion to obtain NAND, NOR, and XNOR.