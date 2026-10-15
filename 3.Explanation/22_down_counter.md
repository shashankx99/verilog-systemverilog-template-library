# Template 22: Parameterized Down Counter

## Purpose

A down counter decreases its stored value by one at each
rising clock edge when enabled.

WIDTH defaults to 4 and must be a positive integer.
This template uses a synchronous active-high reset
that clears the count to zero.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| en | Input | 1 bit | Enables counting |
| count | Output | WIDTH bits | Current unsigned count |

## Short Explanation

At each rising clock edge:

1. If rst = 1, clear count to zero.
2. Otherwise, if en = 1, decrement count by one.
3. Otherwise, hold the previous count.

A WIDTH-bit counter stores values from 0 to 2^WIDTH - 1.

Decrementing zero wraps to the maximum value.

For WIDTH = 4, starting after reset:

0 → 15 → 14 → 13 → ... → 1 → 0 → 15

This counter wraps; it does not stop at zero.

## Behavior Table

| Event | rst | en | Next count |
|---|---|---|---|
| Rising clock edge | 1 | - | 0 |
| Rising clock edge | 0 | 1 | Previous count - 1, modulo 2^WIDTH |
| Rising clock edge | 0 | 0 | Previous count |
| No rising clock edge | - | - | Previous count |

The symbol - means either binary value.
Reset has priority over enable.

## Small Example

Assume WIDTH = 3, so the count range is 0 through 7.

Each row shows count after a rising clock edge.

| Edge | rst | en | count | Decimal | Explanation |
|---|---|---|---|---|---|
| 1 | 1 | 0 | 000 | 0 | Reset |
| 2 | 0 | 1 | 111 | 7 | Wrap from zero to maximum |
| 3 | 0 | 1 | 110 | 6 | Decrement |
| 4 | 0 | 0 | 110 | 6 | Hold |
| 5 | 0 | 1 | 101 | 5 | Decrement |
| 6 | 0 | 1 | 100 | 4 | Decrement |
| 7 | 0 | 1 | 011 | 3 | Decrement |
| 8 | 0 | 1 | 010 | 2 | Decrement |
| 9 | 0 | 1 | 001 | 1 | Decrement |
| 10 | 0 | 1 | 000 | 0 | Reach zero |
| 11 | 0 | 1 | 111 | 7 | Wrap again |

## Why Wraparound Happens

The counter uses fixed-width arithmetic.

For WIDTH = 3:

0 - 1 modulo 8 = 7

The stored three-bit result is 111.

In general:

0 - 1 modulo 2^WIDTH = 2^WIDTH - 1

No explicit zero check is needed for this wrapping behavior.

## Verilog Code

```verilog
module down_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en)
            count <= count - 1'b1;
    end

endmodule
```

## Code Explanation

### 1. Counter width

`parameter WIDTH = 4`

Sets the number of stored bits.

For WIDTH = 4, the unsigned count range is 0 through 15.

### 2. Clocked operation

`always @(posedge clk)`

Updates count only at rising clock edges.

### 3. Synchronous reset

`count <= {WIDTH{1'b0}};`

Clears every bit when rst is high at a rising edge.

Reset assertion between clock edges does not immediately
change count.

### 4. Decrement

`count <= count - 1'b1;`

Subtracts one from the current count and stores the
WIDTH-bit result.

The right-hand side uses the count before the update.

### 5. Hold behavior

When rst = 0 and en = 0, no assignment is made.
The flip-flops retain the previous count.

### 6. Nonblocking assignment

`<=`

Models the update to stored state at the clock edge.

### 7. Initialization

Apply reset at a rising clock edge to establish a known count.

Subtracting one from an unknown count does not initialize it.

## How to Remember

"Down means subtract one."

RESET → 0
ENABLE → count - 1
OTHERWISE → hold

Compare the two counter templates:

Up counter:   count <= count + 1'b1;
Down counter: count <= count - 1'b1;

At zero, a wrapping down counter returns to its maximum.