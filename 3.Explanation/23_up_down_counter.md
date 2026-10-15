# Template 23: Parameterized Up/Down Counter

## Purpose

An up/down counter can increase or decrease its stored
value by one at each rising clock edge.

The direction input selects the operation:
- up = 1: increment.
- up = 0: decrement.

WIDTH defaults to 4 and must be a positive integer.
The reset is synchronous and active-high.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| en | Input | 1 bit | Enables counting |
| up | Input | 1 bit | 1 selects up; 0 selects down |
| count | Output | WIDTH bits | Current unsigned count |

## Short Explanation

At each rising clock edge:

1. If rst = 1, clear count to zero.
2. Otherwise, if en = 0, hold the previous count.
3. Otherwise, use up to select increment or decrement.

Changing direction does not reset the counter.
Counting continues from the current stored value.

The count range is 0 through 2^WIDTH - 1.

## Behavior Table

| Event | rst | en | up | Next count |
|---|---|---|---|---|
| Rising clock edge | 1 | - | - | 0 |
| Rising clock edge | 0 | 0 | - | Previous count |
| Rising clock edge | 0 | 1 | 1 | Previous count + 1 |
| Rising clock edge | 0 | 1 | 0 | Previous count - 1 |
| No rising clock edge | - | - | - | Previous count |

The symbol - means either binary value.
Arithmetic wraps modulo 2^WIDTH.
The table assumes known binary control inputs.

## Small Example

Assume WIDTH = 3, giving a count range of 0 through 7.

Each row shows count after a rising clock edge.

| Edge | rst | en | up | count | Decimal | Explanation |
|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 000 | 0 | Reset |
| 2 | 0 | 1 | 1 | 001 | 1 | Count up |
| 3 | 0 | 1 | 1 | 010 | 2 | Count up |
| 4 | 0 | 0 | 0 | 010 | 2 | Hold |
| 5 | 0 | 1 | 0 | 001 | 1 | Count down |
| 6 | 0 | 1 | 0 | 000 | 0 | Count down |
| 7 | 0 | 1 | 0 | 111 | 7 | Wrap downward |
| 8 | 0 | 1 | 1 | 000 | 0 | Wrap upward |
| 9 | 1 | 1 | 1 | 000 | 0 | Reset overrides counting |

## Boundary Behavior

For WIDTH = 4:

- Counting up from 15 produces 0.
- Counting down from 0 produces 15.

Only WIDTH bits are stored, so wraparound occurs naturally.

This counter does not stop at either boundary.

## Verilog Code

```verilog
module up_down_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    input  wire             up,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (up)
                count <= count + 1'b1;
            else
                count <= count - 1'b1;
        end
    end

endmodule
```

## Code Explanation

### 1. Width parameter

`parameter WIDTH = 4`

Sets the number of storage bits.
The default counter has 16 possible values, from 0 to 15.

### 2. Rising-edge operation

`always @(posedge clk)`

Samples the controls and updates count at a rising edge.

Changes to en or up between clock edges do not immediately
change count.

### 3. Reset priority

`if (rst)`

Checks reset before enable or direction.

`count <= {WIDTH{1'b0}};`

Clears all bits at the clock edge.

### 4. Enable condition

`else if (en)`

Allows counting only when reset is inactive and en is high.

Without a final else assignment, count holds when en is low.

### 5. Direction selection

`if (up)`

Selects addition when up = 1.

The else branch selects subtraction when up = 0,
assuming known binary controls.

### 6. Nonblocking assignments

`count <= count + 1'b1;`
`count <= count - 1'b1;`

Both expressions use the stored count before the update.

Only the selected branch schedules an update at that edge.

### 7. Initialization

Apply reset at a rising clock edge before relying on count.

Neither incrementing nor decrementing an unknown value
establishes a known count.

## How to Remember

"Enable decides whether; direction decides which way."

RESET → clear
ENABLE = 0 → hold
ENABLE = 1:
    UP = 1 → add one
    UP = 0 → subtract one

Remember the control order:

RESET → ENABLE → DIRECTION