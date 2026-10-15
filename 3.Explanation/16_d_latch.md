# Template 16: D Latch

## Purpose

A D latch stores one bit of data.

It is level-sensitive:
- When en = 1, q follows d.
- When en = 0, q holds its previously stored value.

The enabled condition is called the transparent state.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| d | Input | 1 bit | Data to store |
| en | Input | 1 bit | Active-high enable |
| q | Output | 1 bit | Stored output |

This template has no reset input.

## Short Explanation

While en is high, changes in d propagate to q.
The latch remains transparent for the entire high level.

When en becomes low, the latch closes and retains
the last value that passed through.

Unlike a rising-edge D flip-flop, a D latch does not
wait for a clock edge to update its output.

## Behavior Table

| en | d | Next q |
|---|---|---|
| 0 | - | Previous q |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

The symbol - means either binary value.
When disabled, d does not change the stored output.

## Small Example

Read these steps in order. Each row describes the
settled output after the input change.

| Step | en | d | q | Explanation |
|---|---|---|---|---|
| 1 | 1 | 0 | 0 | Enabled: q follows d |
| 2 | 1 | 1 | 1 | Still enabled: q changes with d |
| 3 | 0 | 1 | 1 | Disabled: store the last value |
| 4 | 0 | 0 | 1 | d changes, but q holds |
| 5 | 1 | 0 | 0 | Enabled again: q follows d |

Because there is no reset, q has no guaranteed initial
hardware value. In a typical RTL simulation, q begins
as x until a known value is loaded while enabled.

## Verilog Code

```verilog
module d_latch (
    input  wire d,
    input  wire en,
    output reg  q
);

    always @(*) begin
        if (en)
            q <= d;
    end

endmodule
```

## Code Explanation

### 1. Stored output

`output reg q`

Allows q to be assigned inside an always block.

Here, storage is inferred because q must retain its value
when en is low, not simply because q is declared reg.

### 2. Sensitivity list

`always @(*)`

Reevaluates the block when an input read by it changes.

Using always @(*) does not by itself guarantee
combinational hardware. The assignments inside the block
determine whether storage is needed.

### 3. Enable condition

`if (en)`

Updates q while en is high.

There is no posedge or negedge event control, so the
latch responds to an enable level rather than an edge.

### 4. Nonblocking assignment

`q <= d;`

Uses a nonblocking assignment, appropriate for modeling
stored state.

It schedules q to receive d; it does not add a clock cycle.

### 5. Intentional missing else

When en = 0, no assignment is made to q.
Therefore, q retains its previous value.

This incomplete assignment intentionally describes a latch.

Do not add a default assignment of q = 0 or an else
that clears q: that would remove the required hold behavior.

An explicit self-assignment is unnecessary.

## How to Remember

"Enable high: follow. Enable low: hold."

Think of the enable as a door:

- Door open → data passes through.
- Door closed → the last value stays inside.

Coding pattern:

if (en)
    q <= d;

The missing else is intentional because the latch must remember.