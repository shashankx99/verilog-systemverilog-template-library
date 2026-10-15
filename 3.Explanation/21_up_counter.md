# Template 21: Parameterized Up Counter

## Purpose

An up counter increases its stored value by one at each
rising clock edge when enabled.

It can be used to count clock cycles or events represented
by an enable signal sampled at the clock edge.

WIDTH defaults to 4 and must be a positive integer.
This template uses a synchronous active-high reset.

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
2. Otherwise, if en = 1, increment count by one.
3. Otherwise, hold the previous count.

A WIDTH-bit counter has 2^WIDTH possible values:

0 through 2^WIDTH - 1

After the maximum value, it wraps back to zero.

For WIDTH = 4:

0 → 1 → 2 → ... → 14 → 15 → 0

## Behavior Table

| Event | rst | en | Next count |
|---|---|---|---|
| Rising clock edge | 1 | - | 0 |
| Rising clock edge | 0 | 1 | Previous count + 1, modulo 2^WIDTH |
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
| 2 | 0 | 1 | 001 | 1 | Increment |
| 3 | 0 | 1 | 010 | 2 | Increment |
| 4 | 0 | 0 | 010 | 2 | Hold |
| 5 | 0 | 1 | 011 | 3 | Increment |
| 6 | 0 | 1 | 100 | 4 | Increment |
| 7 | 0 | 1 | 101 | 5 | Increment |
| 8 | 0 | 1 | 110 | 6 | Increment |
| 9 | 0 | 1 | 111 | 7 | Maximum value |
| 10 | 0 | 1 | 000 | 0 | Wraparound |

## Why Wraparound Happens

For a three-bit counter:

111 + 001 = 1000

The result needs four bits, but count stores only three.
The extra carry bit is discarded, leaving 000.

Therefore, wraparound occurs naturally without an
explicit maximum-value check.

## Verilog Code

```verilog
module up_counter #(
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
            count <= count + 1'b1;
    end

endmodule
```

## Code Explanation

### 1. Counter width

`parameter WIDTH = 4`

Sets the number of storage bits.

Examples:
- WIDTH = 3 → range 0 to 7.
- WIDTH = 4 → range 0 to 15.
- WIDTH = 8 → range 0 to 255.

### 2. Rising-edge operation

`always @(posedge clk)`

Updates count at the rising clock edge.

The counter does not increment continuously while clk
or en is high.

### 3. Reset

`count <= {WIDTH{1'b0}};`

Clears every count bit.

Because reset is checked inside a clock-only event block,
it takes effect only at a rising clock edge.

### 4. Increment

`count <= count + 1'b1;`

Adds one to the current count and stores the lower
WIDTH bits of the result.

The right-hand side uses the value before the update.

### 5. Enable and hold

`else if (en)`

Allows counting only when reset is inactive and en is high.

When en = 0, no assignment is made, so count retains
its value. An explicit self-assignment is unnecessary.

### 6. Nonblocking assignment

`<=`

Models the update to the counter's stored state.

### 7. Initialization

Apply reset at a rising clock edge before relying on
the count value.

An unknown initial count does not become known merely
by repeatedly adding one.

## How to Remember

"Reset to zero, enable to grow."

At every rising edge:

RESET → 0
ENABLE → count + 1
OTHERWISE → hold

For WIDTH bits:

Maximum = 2^WIDTH - 1

After the maximum, the counter wraps to zero.