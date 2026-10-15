# Template 31: Combinational RTL Using always_comb

## Purpose

This template demonstrates SystemVerilog's always_comb
construct for describing combinational logic.

A two-bit select input chooses one of four operations:

- Pass a.
- Pass b.
- Bitwise AND.
- Bitwise OR.

WIDTH defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | WIDTH bits | First operand |
| b | Input | WIDTH bits | Second operand |
| sel | Input | 2 bits | Operation selector |
| y | Output | WIDTH bits | Combinational result |

## Short Explanation

Combinational logic calculates its output from current
inputs without storing a previous result.

always_comb expresses this design intent and automatically
determines the relevant sensitivity.

Each output must receive a value on every execution path
to avoid unintended storage.

No clock or reset is needed.

## Operation Table

| sel | Operation | y |
|---|---|---|
| 00 | Pass a | a |
| 01 | Pass b | b |
| 10 | Bitwise AND | a & b |
| 11 | Bitwise OR | a \| b |

## Small Example

Let:

a = 4'b1010
b = 4'b1100

| sel | Calculation | y |
|---|---|---|
| 00 | Pass a | 1010 |
| 01 | Pass b | 1100 |
| 10 | 1010 AND 1100 | 1000 |
| 11 | 1010 OR 1100 | 1110 |

Changing sel selects a different result without waiting
for a clock edge.

## SystemVerilog Code

```systemverilog
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
```

## Code Explanation

### 1. SystemVerilog file extension

Save the source as .sv and use SystemVerilog language mode
when opening it in an HDL tool.

### 2. Typed parameter

`parameter int WIDTH = 4`

Declares an integer parameter controlling the operand width.

### 3. logic data type

`logic [WIDTH-1:0]`

Declares a four-state packed vector whose bits can represent
0, 1, x, or z.

The logic type does not itself determine whether hardware
is combinational or sequential. That depends on how the
signal is assigned.

### 4. always_comb

`always_comb begin ... end`

Describes a process intended for combinational logic.

It runs once at the start of simulation and then responds
to changes in its inferred sensitivity.

Signals written by an always_comb process must not also
be written by another process.

### 5. Default output

`y = '0;`

Fills the entire destination with zeros, regardless of WIDTH.

For WIDTH = 4, this assigns 0000.
For WIDTH = 8, this assigns 00000000.

The initial default demonstrates the default-then-override
coding pattern.

### 6. Operation selection

The case statement overrides y for each binary sel value.

The default case also assigns zero when sel contains x or z.

Because this case already assigns y in every branch,
including default, the initial y = '0 is redundant here.
It is included to demonstrate a useful combinational
coding pattern.

### 7. Blocking assignments

`=`

Use blocking assignments for this combinational calculation.

Assignments execute in order within the block, so a
selected branch can override the initial default.

### 8. Complete assignment

always_comb does not automatically fill in missing
assignments or prevent a latch by itself.

The code must assign outputs on every path.
Tools can diagnose unintended storage in an always_comb block.

## Comparison with Verilog always @(*)

| Feature | always @(*) | always_comb |
|---|---|---|
| Language | Verilog and SystemVerilog | SystemVerilog |
| Automatic sensitivity | Yes | Yes, with additional function-body sensitivity rules |
| Guaranteed initial execution | No | Yes |
| Restricts other processes from writing its variables | No equivalent restriction | Yes |
| Expresses combinational intent | General procedural construct | Explicit combinational construct |

## How to Remember

"always_comb: calculate completely."

1. Use logic for procedural signals.
2. Give outputs a default value where useful.
3. Override them according to the inputs.
4. Use blocking assignments.
5. Assign every output on every path.

The output should depend on current inputs, not on
a value left over from an earlier execution.