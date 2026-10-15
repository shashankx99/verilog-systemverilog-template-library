# Template 24: Mod-N Counter

## Purpose

A Mod-N counter cycles through N values:

0 → 1 → 2 → ... → N-1 → 0

Unlike a normal binary up counter, its counting range
does not have to be a power of two.

The default N is 10, giving the sequence 0 through 9.

This template uses a synchronous active-high reset
and a count enable.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| en | Input | 1 bit | Enables counting |
| count | Output | WIDTH bits | Current count |

## Parameters

| Parameter | Default | Meaning |
|---|---|---|
| N | 10 | Number of values in the counting cycle |
| WIDTH | Automatically calculated | Number of storage bits |

N must be a positive integer.

Normally, override only N and allow WIDTH to be calculated.
If WIDTH is overridden, it must be at least 1 and large
enough to represent N-1.

## Short Explanation

At each rising clock edge:

1. If rst = 1, clear count to zero.
2. Otherwise, if en = 0, hold.
3. Otherwise, if count = N-1, return to zero.
4. Otherwise, increment count by one.

The terminal count is N-1 because counting starts at zero.

For N = 10:

0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 0

## Behavior Table

| Event | rst | en | Current count | Next count |
|---|---|---|---|---|
| Rising edge | 1 | - | Any | 0 |
| Rising edge | 0 | 0 | Any | Previous count |
| Rising edge | 0 | 1 | N-1 | 0 |
| Rising edge | 0 | 1 | Below N-1 | Previous count + 1 |
| No rising edge | - | - | Any | Previous count |

The symbol - means either binary value.
The normal sequence assumes the counter has been reset.

## Small Example

Let N = 6. The automatically calculated WIDTH is 3.

The six legal count values are:

000 → 001 → 010 → 011 → 100 → 101 → 000

Each row shows count after a rising clock edge.

| Edge | rst | en | count | Decimal | Explanation |
|---|---|---|---|---|---|
| 1 | 1 | 0 | 000 | 0 | Reset |
| 2 | 0 | 1 | 001 | 1 | Increment |
| 3 | 0 | 1 | 010 | 2 | Increment |
| 4 | 0 | 0 | 010 | 2 | Hold |
| 5 | 0 | 1 | 011 | 3 | Increment |
| 6 | 0 | 1 | 100 | 4 | Increment |
| 7 | 0 | 1 | 101 | 5 | Reach N-1 |
| 8 | 0 | 1 | 000 | 0 | Wrap to zero |

Although three bits can represent 0 through 7, this
counter normally uses only 0 through 5.

## Verilog Code

```verilog
module mod_n_counter #(
    parameter integer N = 10,
    parameter integer WIDTH = (N > 1) ? $clog2(N) : 1
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (count == N - 1)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end

endmodule
```

## Code Explanation

### 1. Modulus parameter

`parameter integer N = 10`

Defines the number of count values.

N is chosen during elaboration; it is not an input
that changes while the circuit operates.

### 2. Automatic width calculation

`$clog2(N)`

Calculates the ceiling of log base 2 of N, giving the
bits needed to represent values from 0 through N-1.

Examples:

| N | Count range | WIDTH |
|---|---|---|
| 2 | 0 to 1 | 1 |
| 6 | 0 to 5 | 3 |
| 8 | 0 to 7 | 3 |
| 10 | 0 to 9 | 4 |
| 16 | 0 to 15 | 4 |

$clog2 requires Verilog-2005 or a later language mode.

### 3. Handle N = 1

`(N > 1) ? $clog2(N) : 1`

Ensures WIDTH is at least one bit.

For N = 1, the only legal count is zero.
Every enabled edge keeps the initialized count at zero.

The width expression does not make N = 0 or a negative
N valid; those parameter values are unsupported.

### 4. Terminal-count check

`if (count == N - 1)`

Detects the final legal count.

The comparison uses the current value before the
clocked update.

### 5. Explicit wraparound

`count <= {WIDTH{1'b0}};`

Returns to zero after the terminal count.

For N = 10, this prevents the normal sequence from
continuing to 10, 11, and higher binary values.

### 6. Enable and reset priority

Reset is checked first, then enable, then terminal count.

If en = 0 at the terminal count, the counter stays there
until an enabled edge occurs.

### 7. Initialization and unused states

Apply reset at a rising edge to start the legal sequence.

This basic template checks equality with N-1. It does not
immediately reset every out-of-range value that might
result from a fault or forced state.

## How to Remember

"Count N values: zero through N minus one."

RESET → zero
DISABLED → hold
AT N-1 → zero
OTHERWISE → add one

The main difference from the ordinary up counter is:

if (count == N - 1)
    count <= 0;
else
    count <= count + 1;