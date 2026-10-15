# Template 19: T Flip-Flop

## Purpose

A T flip-flop stores one bit and can toggle its value.

Toggle means:
- 0 becomes 1.
- 1 becomes 0.

At each rising clock edge:
- t = 0: hold the previous value.
- t = 1: toggle the previous value.

This template uses a synchronous active-high reset.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| t | Input | 1 bit | Toggle control |
| q | Output | 1 bit | Stored output |

## Short Explanation

The flip-flop checks reset and t at each rising clock edge.

1. If rst = 1, clear q to 0.
2. Otherwise, if t = 1, invert q.
3. Otherwise, hold q.

Changing t between rising clock edges does not change q.

## Behavior Table

| Event | rst | t | Next q |
|---|---|---|---|
| Rising clock edge | 1 | - | 0 |
| Rising clock edge | 0 | 0 | Previous q |
| Rising clock edge | 0 | 1 | Inverted previous q |
| No rising clock edge | - | - | Previous q |

The symbol - means either binary value.

## State Transition Table

With rst = 0, at a rising clock edge:

| t | Current q | Next q |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

For binary values, the next-state equation is:

Next q = q XOR t

This equation applies when reset is inactive.

## Small Example

Each row shows the output after a rising clock edge.

| Edge | rst | t | q | Explanation |
|---|---|---|---|---|
| 1 | 1 | 0 | 0 | Reset |
| 2 | 0 | 1 | 1 | Toggle from 0 to 1 |
| 3 | 0 | 1 | 0 | Toggle from 1 to 0 |
| 4 | 0 | 0 | 0 | Hold |
| 5 | 0 | 1 | 1 | Toggle from 0 to 1 |
| 6 | 0 | 0 | 1 | Hold |
| 7 | 1 | 1 | 0 | Reset overrides toggle |

## Verilog Code

```verilog
module t_flip_flop (
    input  wire clk,
    input  wire rst,
    input  wire t,
    output reg  q
);

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else if (t)
            q <= ~q;
    end

endmodule
```

## Code Explanation

### 1. Rising-edge operation

`always @(posedge clk)`

Runs the block at each rising clock edge.
The output does not follow t continuously.

### 2. Synchronous reset

`if (rst) q <= 1'b0;`

Clears q when rst is high at a rising edge.
Asserting rst between edges does not immediately clear q.

### 3. Toggle operation

`q <= ~q;`

The bitwise NOT operator inverts the current one-bit value.

- Current q = 0 → next q = 1.
- Current q = 1 → next q = 0.

The right-hand side uses the value before the update.

### 4. Hold operation

There is no final else assignment.

When rst = 0 and t = 0, no update is scheduled, so the
flip-flop holds its stored value.

### 5. Nonblocking assignment

`<=`

Models the update of stored state at the clock edge.

### 6. Initialization

Apply reset at a rising clock edge to establish a known q.

Without initialization, an unknown q stays unknown when
inverted because ~x is still x.

## Continuous Toggle Example

If t stays at 1 after reset, q changes at every rising edge:

0 → 1 → 0 → 1 → 0

A complete output cycle takes two input clock cycles,
so the output frequency is half the clock frequency.

## How to Remember

"T means Toggle."

- T = 0 → stay.
- T = 1 → flip.

Remember the code:

if (rst)
    q <= 1'b0;
else if (t)
    q <= ~q;

Priority:

RESET > TOGGLE > HOLD