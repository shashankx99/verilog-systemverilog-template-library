# Template 25: Universal Shift Register

## Purpose

A universal shift register stores a multi-bit value
and supports four operations:

1. Hold.
2. Shift right.
3. Shift left.
4. Parallel load.

WIDTH defaults to 4 and must be at least 2 for this implementation.

The reset is synchronous and active-high.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| mode | Input | 2 bits | Selects the register operation |
| serial_right | Input | 1 bit | Bit entering the MSB during a right shift |
| serial_left | Input | 1 bit | Bit entering the LSB during a left shift |
| parallel_in | Input | WIDTH bits | Complete word to load |
| q | Output | WIDTH bits | Stored value |

MSB means most significant bit.
LSB means least significant bit.

The serial input names refer to the selected shift direction,
not the physical side where the bit enters.

## Short Explanation

At each rising clock edge, reset is checked first.

If reset is inactive, mode selects the operation:

- Hold: retain q.
- Shift right: move bits toward lower indices.
- Shift left: move bits toward higher indices.
- Parallel load: replace all stored bits at once.

During a shift, one old bit is discarded and one serial
input bit enters the register.

Between rising edges, q holds its value.

## Operation Table

With rst = 0:

| mode | Operation | Next q |
|---|---|---|
| 00 | Hold | Previous q |
| 01 | Shift right | {serial_right, q[WIDTH-1:1]} |
| 10 | Shift left | {q[WIDTH-2:0], serial_left} |
| 11 | Parallel load | parallel_in |

If rst = 1 at a rising edge, q becomes zero regardless of mode.

## Understanding the Shift Directions

For a four-bit register:

### Shift Right

Next q[3] = serial_right
Next q[2] = old q[3]
Next q[1] = old q[2]
Next q[0] = old q[1]

Old q[0] is discarded.

Example:

Old q = 1011
serial_right = 0
New q = 0101

### Shift Left

Next q[3] = old q[2]
Next q[2] = old q[1]
Next q[1] = old q[0]
Next q[0] = serial_left

Old q[3] is discarded.

Example:

Old q = 1011
serial_left = 0
New q = 0110

These operations are not rotations: the incoming bit
comes from a serial input rather than automatically
reusing the discarded bit.

## Small Example

Assume WIDTH = 4.

Each row shows q after a rising clock edge.

| Edge | rst | mode | serial_right | serial_left | parallel_in | q | Operation |
|---|---|---|---|---|---|---|---|
| 1 | 1 | 00 | 0 | 0 | 0000 | 0000 | Reset |
| 2 | 0 | 11 | 0 | 0 | 1011 | 1011 | Parallel load |
| 3 | 0 | 01 | 0 | 0 | 0000 | 0101 | Shift right, insert 0 |
| 4 | 0 | 10 | 0 | 1 | 0000 | 1011 | Shift left, insert 1 |
| 5 | 0 | 00 | 1 | 0 | 1111 | 1011 | Hold |
| 6 | 0 | 01 | 1 | 0 | 0000 | 1101 | Shift right, insert 1 |
| 7 | 1 | 11 | 0 | 0 | 1111 | 0000 | Reset overrides load |

Only the inputs relevant to the selected mode affect
the update.

## Verilog Code

```verilog
module universal_shift_register #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [1:0]       mode,
    input  wire             serial_right,
    input  wire             serial_left,
    input  wire [WIDTH-1:0] parallel_in,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else begin
            case (mode)
                2'b00: q <= q;

                2'b01: q <= {serial_right, q[WIDTH-1:1]};

                2'b10: q <= {q[WIDTH-2:0], serial_left};

                2'b11: q <= parallel_in;

                default: q <= q;
            endcase
        end
    end

endmodule
```

## Code Explanation

### 1. Parameterized storage

`parameter WIDTH = 4`

Defines the number of stored bits.

WIDTH must be at least 2 because the code selects
q[WIDTH-1:1] and q[WIDTH-2:0].

### 2. Clock and reset

`always @(posedge clk)`

Updates storage only at a rising clock edge.

Reset is synchronous because only clk appears in
the event control.

### 3. Hold

`q <= q;`

Explicitly retains the current value.

An empty hold branch would also retain q in this
edge-triggered block.

### 4. Right shift

`{serial_right, q[WIDTH-1:1]}`

Concatenates the new serial bit with the upper WIDTH-1
bits of the old register.

The new serial bit becomes the MSB.
The old LSB is discarded.

### 5. Left shift

`{q[WIDTH-2:0], serial_left}`

Concatenates the lower WIDTH-1 bits of the old register
with the new serial bit.

The new serial bit becomes the LSB.
The old MSB is discarded.

### 6. Parallel load

`q <= parallel_in;`

Captures all input bits together at one rising edge.

### 7. Nonblocking assignments

All right-hand expressions use the old q value.
The selected update is scheduled using <=.

This means a shift moves all stored bits together,
rather than changing them one at a time.

### 8. Default branch

An unknown or high-impedance bit in mode prevents a
match with the listed binary values.

This template then holds q.

### 9. Initialization

Use reset or parallel load at a rising edge to establish
a known complete register value.

## How to Remember

"Hold, Right, Left, Load."

00 → Hold
01 → Right
10 → Left
11 → Load

Remember where the new bit enters:

- Shift RIGHT → insert at the LEFT end, the MSB.
- Shift LEFT → insert at the RIGHT end, the LSB.

In a concatenation, the leftmost item becomes the
most significant part of the result.V