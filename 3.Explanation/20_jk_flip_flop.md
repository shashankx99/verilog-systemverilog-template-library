# Template 20: JK Flip-Flop

## Purpose

A JK flip-flop stores one bit and supports four operations:

- Hold the stored value.
- Clear it to 0.
- Set it to 1.
- Toggle it.

Inputs j and k select the operation performed at each
rising clock edge.

This template uses a synchronous active-high reset.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| j | Input | 1 bit | JK control input |
| k | Input | 1 bit | JK control input |
| q | Output | 1 bit | Stored output |

## Short Explanation

At each rising clock edge, reset is checked first.

If rst = 1, q becomes 0 regardless of j and k.

Otherwise:

- j = 0, k = 0: hold.
- j = 0, k = 1: clear.
- j = 1, k = 0: set.
- j = 1, k = 1: toggle.

Between rising clock edges, q holds its value.

## Operation Table

With rst = 0, at a rising clock edge:

| j | k | Operation | Next q |
|---|---|---|---|
| 0 | 0 | Hold | Previous q |
| 0 | 1 | Clear | 0 |
| 1 | 0 | Set | 1 |
| 1 | 1 | Toggle | Inverted previous q |

## State Transition Table

With reset inactive:

| j | k | Current q | Next q |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 |

For binary inputs, the next-state equation is:

Next q = (j & ~q) | (~k & q)

This equation applies when reset is inactive.

## Small Example

Each row shows q after a rising clock edge.

| Edge | rst | j | k | q | Explanation |
|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 0 | Reset |
| 2 | 0 | 1 | 0 | 1 | Set |
| 3 | 0 | 0 | 0 | 1 | Hold |
| 4 | 0 | 1 | 1 | 0 | Toggle |
| 5 | 0 | 1 | 1 | 1 | Toggle again |
| 6 | 0 | 0 | 1 | 0 | Clear |
| 7 | 1 | 1 | 0 | 0 | Reset overrides set |

## Verilog Code

```verilog
module jk_flip_flop (
    input  wire clk,
    input  wire rst,
    input  wire j,
    input  wire k,
    output reg  q
);

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else begin
            case ({j, k})
                2'b00:   q <= q;
                2'b01:   q <= 1'b0;
                2'b10:   q <= 1'b1;
                2'b11:   q <= ~q;
                default: q <= q;
            endcase
        end
    end

endmodule
```

## Code Explanation

### 1. Edge-triggered storage

`always @(posedge clk)`

Updates q only at a rising clock edge.

When j and k are both 1, q toggles once per rising edge,
not repeatedly while the clock is high.

### 2. Reset priority

`if (rst) q <= 1'b0;`

Clears the output when reset is high at the clock edge.

The JK selection is evaluated only when reset is inactive.

### 3. Concatenation

`{j, k}`

Combines two one-bit inputs into a two-bit value.

j is the most significant bit.
k is the least significant bit.

For example, j = 1 and k = 0 produce 2'b10.

### 4. Case statement

`case ({j, k})`

Selects one of the four operations directly from the
combined control bits.

### 5. Explicit hold

`q <= q;`

Keeps the current value.

This assignment is included to make the hold operation
visible. It is optional in an edge-triggered block:
leaving q unassigned on that path would also hold it.

### 6. Toggle

`q <= ~q;`

Schedules the inverse of the current stored bit.

### 7. Default branch

If j or k contains x or z, the ordinary case statement
does not match a listed binary value.

This template then holds q. It does not detect or propagate
every unknown-control condition.

### 8. Initialization

A reset, set, or clear operation at a rising edge can
establish a known output.

Holding or toggling an unknown q does not establish
a known value.

## How to Remember

"00 holds, 01 clears, 10 sets, 11 toggles."

Read the combinations in binary order:

00 → HOLD
01 → ZERO
10 → ONE
11 → FLIP

Connection to the T flip-flop:

If j and k are both connected to t:
- t = 0 gives JK = 00 → hold.
- t = 1 gives JK = 11 → toggle.

The JK flip-flop then behaves like a T flip-flop.