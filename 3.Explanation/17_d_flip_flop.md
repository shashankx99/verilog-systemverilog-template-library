# Template 17: D Flip-Flop

## Purpose

A D flip-flop stores one bit and normally captures its
data input at the rising edge of a clock.

This template includes two independent modules:

1. dff_sync_reset: synchronous active-high reset.
2. dff_async_reset: asynchronous active-high reset.

Both resets clear q to 0.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Clock; data is captured on its rising edge |
| rst | Input | 1 bit | Active-high reset |
| d | Input | 1 bit | Data to capture |
| q | Output | 1 bit | Stored output |

## Short Explanation

A rising-edge D flip-flop captures d when clk changes
from 0 to 1.

Between rising edges, q holds its value, except when
an asynchronous reset is asserted.

The two variants differ in when reset takes effect:

- Synchronous reset: clears q only at a rising clock edge.
- Asynchronous reset: clears q when rst rises, without
  waiting for a clock edge.

## Reset Comparison

| Feature | Synchronous reset | Asynchronous reset |
|---|---|---|
| Reset active level | High | High |
| Reset assertion takes effect | At a rising clock edge | Without waiting for a clock edge |
| Event control | posedge clk | posedge clk or posedge rst |
| Can clear q with a stopped clock? | No | Yes |
| Reset release alone captures d? | No | No |

In hardware, asynchronous reset release must meet recovery
and removal timing. Reset release is commonly synchronized
to the destination clock; this basic template does not
include a reset synchronizer.

## Behavior Tables

### Synchronous Reset

| Event | rst | Next q |
|---|---|---|
| Rising clock edge | 1 | 0 |
| Rising clock edge | 0 | d |
| No rising clock edge | Either binary value | Previous q |

### Asynchronous Reset

| Condition or event | Next q |
|---|---|
| rst asserted high | 0, without waiting for the clock |
| rst remains high | Held at 0 |
| Rising clock edge with rst = 0 | d |
| rst falls, with no clock edge | Holds 0 after reset |
| No clock edge and rst remains low | Previous q |

These tables describe known binary control values.

## Small Example

Assume both outputs have previously captured 1.

| Step | Event | rst | d | Synchronous q | Asynchronous q |
|---|---|---|---|---|---|
| 1 | rst rises between clock edges | 1 | 1 | 1 | 0 |
| 2 | Next rising clock edge | 1 | 1 | 0 | 0 |
| 3 | rst falls between clock edges | 0 | 1 | 0 | 0 |
| 4 | Next rising clock edge | 0 | 1 | 1 | 1 |
| 5 | d changes without a clock edge | 0 | 0 | 1 | 1 |
| 6 | Next rising clock edge | 0 | 0 | 0 | 0 |

The key difference appears in step 1:
only asynchronous reset clears q before the next clock edge.

## Verilog Code

```verilog
// Synchronous active-high reset
module dff_sync_reset (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule


// Asynchronous active-high reset
module dff_async_reset (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule
```

## Code Explanation

### 1. Rising-edge clock

`posedge clk`

Triggers the block on the clock's rising edge during
normal binary operation.

Unlike a latch, the flip-flop does not follow d throughout
the high level of the clock.

### 2. Synchronous reset event control

`always @(posedge clk)`

Only clock edges trigger this block.

Changing rst between clock edges does not immediately
update q. The reset value is checked at the next rising edge.

### 3. Asynchronous reset event control

`always @(posedge clk or posedge rst)`

A rising clock edge or reset assertion triggers this block.

The word or lists triggering events. It does not describe
an OR gate combining clk and rst.

### 4. Reset priority

`if (rst) q <= 1'b0;`

Checks reset before capturing data, so reset has priority.

For the asynchronous variant, clock edges while rst is
high also keep q at 0.

### 5. Capture data

`else q <= d;`

Captures d on a rising clock edge when reset is inactive.

### 6. Nonblocking assignments

`<=`

Models updates to stored state.

In simulation, the right-hand value is evaluated when
the statement executes, and the update is scheduled
for the nonblocking-assignment region of that time step.

### 7. Independent modules

The source file contains two modules with different names.
Choose the module matching the required reset behavior.

## How to Remember

"D is captured on the clock edge."

For reset:

- Synchronous → reset waits for the clock.
- Asynchronous → reset can act without the clock.

Remember the event controls:

Synchronous:
always @(posedge clk)

Asynchronous:
always @(posedge clk or posedge rst)

In both versions:
if reset, clear; otherwise, capture D.