# Template 08: 1:4 Demultiplexer

## Purpose

A 1:4 demultiplexer routes one data input to one of four
outputs, based on a two-bit select input.

The selected output follows din.
All unselected outputs remain 0.

A multiplexer selects an input.
A demultiplexer selects an output.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| din | Input | 1 bit | Data to route |
| sel | Input | 2 bits | Selects the destination output |
| y | Output | 4 bits | Four output lines: y[3] through y[0] |

## Short Explanation

- sel = 00: route din to y[0].
- sel = 01: route din to y[1].
- sel = 10: route din to y[2].
- sel = 11: route din to y[3].

If din = 0, all outputs are 0.
If din = 1, only the selected output is 1.

The circuit is combinational and requires no clock or reset.

## Truth Table

| din | sel | y[3] | y[2] | y[1] | y[0] |
|---|---|---|---|---|---|
| 0 | 00 | 0 | 0 | 0 | 0 |
| 0 | 01 | 0 | 0 | 0 | 0 |
| 0 | 10 | 0 | 0 | 0 | 0 |
| 0 | 11 | 0 | 0 | 0 | 0 |
| 1 | 00 | 0 | 0 | 0 | 1 |
| 1 | 01 | 0 | 0 | 1 | 0 |
| 1 | 10 | 0 | 1 | 0 | 0 |
| 1 | 11 | 1 | 0 | 0 | 0 |

This table assumes binary inputs (0 or 1).
Output vectors are written in the order y[3:0].

## Small Example

Let din = 1 and sel = 2'b10.

Binary 10 represents 2, so din is routed to y[2].

- y[2] = 1
- All other outputs = 0
- y = 4'b0100

If din changes to 0 while sel remains 10, y becomes 0000.

## Logic Equations

y[0] = din & ~sel[1] & ~sel[0]
y[1] = din & ~sel[1] &  sel[0]
y[2] = din &  sel[1] & ~sel[0]
y[3] = din &  sel[1] &  sel[0]

Each output passes din only when its select combination matches.

## Verilog Code

```verilog
module demux_1to4 (
    input  wire       din,
    input  wire [1:0] sel,
    output reg  [3:0] y
);

    always @(*) begin
        y = 4'b0000;

        case (sel)
            2'b00:   y[0] = din;
            2'b01:   y[1] = din;
            2'b10:   y[2] = din;
            2'b11:   y[3] = din;
            default: y = 4'b0000;
        endcase
    end

endmodule
```

## Code Explanation

### 1. Output vector

`output reg [3:0] y`

Groups four one-bit outputs into a single vector.

Because y is assigned inside an always block, it is declared
as reg. This does not automatically imply a hardware register.

### 2. Combinational block

`always @(*)`

Describes logic that responds to changes in the inputs
read by the block.

### 3. Default assignment

`y = 4'b0000;`

Assigns all four outputs before selecting a destination.

This ensures unselected outputs remain 0 and prevents
them from retaining old values, which would infer latches.

### 4. Route the input

`2'b10: y[2] = din;`

When sel is 10, this assignment updates only y[2].
The other bits retain the zero assigned earlier in the block.

Blocking assignments execute in order within this block.
The selected-bit assignment overrides that bit's default.

These statements describe combinational hardware, not
separate clock cycles or a required zero pulse at the outputs.

### 5. Default case

If sel contains x or z, none of the binary branches match,
so this code assigns all outputs to zero.

This defines the code's behavior for an unknown select;
it does not guarantee physical behavior for uncertain signals.

## How to Remember

"One input, selected destination."

- Select 0 → y[0]
- Select 1 → y[1]
- Select 2 → y[2]
- Select 3 → y[3]

Remember the coding pattern:

1. Set every output to zero.
2. Decode sel.
3. Assign din to the selected output.