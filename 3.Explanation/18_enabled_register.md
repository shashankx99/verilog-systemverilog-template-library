# Template 18: Parameterized Enabled Register

## Purpose

An enabled register stores a multi-bit value.

At each rising clock edge:
- Reset clears the stored value.
- Otherwise, enable allows new data to be loaded.
- Otherwise, the register holds its previous value.

WIDTH defaults to 8 and must be a positive integer.
The reset is synchronous and active-high.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| en | Input | 1 bit | Load enable |
| d | Input | WIDTH bits | Data to load |
| q | Output | WIDTH bits | Stored data |

## Short Explanation

The register behaves like WIDTH D flip-flops sharing
the same clock, reset, and enable.

When en = 1, d is captured at the next rising clock edge.
When en = 0, q retains its value.

Reset has priority over enable. If rst and en are both 1
at a rising edge, q is cleared rather than loaded.

Between rising clock edges, q does not change.

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

Assume WIDTH = 4. Values shown for q are after each event.

| Step | Event | rst | en | d | q | Explanation |
|---|---|---|---|---|---|---|
| 1 | Rising edge | 1 | 0 | 1010 | 0000 | Reset clears q |
| 2 | Rising edge | 0 | 1 | 1010 | 1010 | Load data |
| 3 | Rising edge | 0 | 0 | 0011 | 1010 | Enable low: hold |
| 4 | No clock edge | 0 | 1 | 1111 | 1010 | Wait for rising edge |
| 5 | Rising edge | 0 | 1 | 1111 | 1111 | Load new data |
| 6 | Rising edge | 1 | 1 | 0101 | 0000 | Reset overrides enable |

## Verilog Code

```verilog
module enabled_register #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else if (en)
            q <= d;
    end

endmodule
```

## Code Explanation

### 1. Parameterized storage width

`parameter WIDTH = 8`

Sets the default storage size to eight bits.

For a four-bit instance, override the parameter with:

`enabled_register #(.WIDTH(4))`

### 2. Clocked operation

`always @(posedge clk)`

Updates the register only at a rising clock edge.

Because rst is checked inside this clock-only block,
reset is synchronous.

### 3. Clear all bits

`q <= {WIDTH{1'b0}};`

The replication operator repeats 1'b0 WIDTH times.

For WIDTH = 8, it produces 8'b00000000.

### 4. Reset priority

`if (rst)`

Checks reset first. A high reset clears q at the rising
edge regardless of en or d.

### 5. Conditional loading

`else if (en) q <= d;`

Loads d only when reset is inactive and enable is high.

All WIDTH bits are captured at the same clock edge.

### 6. Holding the value

There is no final else assignment.

In this edge-triggered block, leaving q unassigned when
en = 0 means the flip-flops retain their stored values.

An explicit `q <= q;` is unnecessary.

Unlike the incomplete level-sensitive block in the D-latch
template, this block describes edge-triggered storage.

### 7. Nonblocking assignments

`<=`

Models updates to the stored register value.

### 8. Initialization

There is no guaranteed initial hardware value before
reset or a valid load.

To initialize this synchronous-reset register, rst must
be high at a rising clock edge.

## How to Remember

"Reset, Load, Hold."

At every rising edge:

1. Reset high → clear.
2. Otherwise, enable high → load.
3. Otherwise → hold.

The priority is:

RESET > ENABLE > HOLD

Enable decides whether to capture data.
The clock edge decides when capture can happen.