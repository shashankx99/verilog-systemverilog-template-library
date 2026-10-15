# Template 32: Sequential RTL Using always_ff

## Purpose

This template demonstrates SystemVerilog's always_ff
construct for describing edge-triggered storage.

The example is a parameterized register with:
- Rising-edge clock.
- Synchronous active-high reset.
- Load enable.
- Hold behavior when disabled.

WIDTH defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| en | Input | 1 bit | Enables data capture |
| d | Input | WIDTH bits | Data to capture |
| q | Output | WIDTH bits | Stored output |

## Short Explanation

At each rising clock edge:

1. If rst = 1, clear q.
2. Otherwise, if en = 1, capture d.
3. Otherwise, retain the stored value.

Between rising edges, q holds its value even if d,
en, or rst changes.

Reset has priority over enable.

## Behavior Table

| Event | rst | en | Next q |
|---|---|---|---|
| Rising clock edge | 1 | - | All zeros |
| Rising clock edge | 0 | 1 | d |
| Rising clock edge | 0 | 0 | Previous q |
| No rising clock edge | - | - | Previous q |

The symbol - means either binary value.
The table assumes known binary control inputs.

## Small Example

Assume WIDTH = 4.

Each row shows q after the event has settled.

| Step | Event | rst | en | d | q | Explanation |
|---|---|---|---|---|---|---|
| 1 | Rising edge | 1 | 0 | 1010 | 0000 | Reset |
| 2 | Rising edge | 0 | 1 | 1010 | 1010 | Capture data |
| 3 | d changes; no rising edge | 0 | 1 | 0101 | 1010 | Hold until edge |
| 4 | Rising edge | 0 | 1 | 0101 | 0101 | Capture new data |
| 5 | Rising edge | 0 | 0 | 1111 | 0101 | Disabled: hold |
| 6 | Rising edge | 1 | 1 | 1111 | 0000 | Reset overrides load |

## SystemVerilog Code

```systemverilog
module always_ff_example #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk) begin
        if (rst)
            q <= '0;
        else if (en)
            q <= d;
    end

endmodule
```

## Code Explanation

### 1. logic data type

`output logic [WIDTH-1:0] q`

Declares a four-state output variable.

Its use in this clocked block describes stored data.
The logic type alone does not imply a flip-flop.

### 2. always_ff

`always_ff @(posedge clk)`

Expresses the intent to model edge-triggered storage.

The block executes when the specified event occurs;
unlike always_comb, it does not automatically execute
once at simulation startup.

Variables written by this always_ff process must not
also be written by another process.

### 3. Synchronous reset

`if (rst) q <= '0;`

Checks reset at a rising clock edge.

The literal '0 fills every bit of q with zero.

Because rst is not an event in the sensitivity control,
asserting reset between clock edges does not immediately
clear q.

### 4. Load enable

`else if (en) q <= d;`

Captures d when reset is inactive and enable is high.

### 5. Hold behavior

There is no final else assignment.

When reset and enable are both low, q retains its value.
An explicit q <= q is unnecessary.

### 6. Nonblocking assignment

`<=`

Evaluates the right-hand value when the statement executes,
then schedules the stored output update for the
nonblocking-assignment region of that simulation time step.

This helps model registers updating together at an edge.

### 7. Initialization

Apply reset at a rising clock edge, or perform a known
enabled load, before relying on q.

always_ff does not automatically initialize storage.

## Why Nonblocking Assignments Matter

Consider two registers in one clocked block:

```systemverilog
always_ff @(posedge clk) begin
    stage1 <= d;
    stage2 <= stage1;
end
```

At each rising edge:

- stage1 receives the current d.
- stage2 receives the old stage1.

The two assignments describe two pipeline stages.
stage2 does not receive the newly updated stage1
during that same edge.

## Comparison with always_comb

| Feature | always_comb | always_ff |
|---|---|---|
| Intended hardware | Combinational logic | Edge-triggered storage |
| Trigger | Inferred input sensitivity; also runs at startup | Explicit event control |
| Assignment style used | Blocking = | Nonblocking <= |
| Missing assignment on a path | Can imply unintended storage | Holds stored value |
| Typical use | MUX, decoder, next-state logic | Register, counter, state register |

## How to Remember

"COMB calculates; FF remembers."

For clocked storage:

always_ff @(posedge clk)

Inside the block:

RESET → clear
ENABLE → load
OTHERWISE → hold

Use <= for updates to stored state.