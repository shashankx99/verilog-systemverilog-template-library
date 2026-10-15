# Template 26: Ring Counter

## Purpose

A ring counter rotates a stored bit pattern.

This four-bit version rotates a single 1 to the right
at every rising clock edge.

It uses an asynchronous active-high reset and has no
enable input.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Asynchronous active-high reset |
| out | Output | 4 bits | Current one-hot pattern |

One-hot means exactly one output bit is 1.

## Short Explanation

When reset is asserted, out becomes 1000 without waiting
for a clock edge.

With reset inactive, each rising clock edge rotates
the pattern right by one position:

1000 → 0100 → 0010 → 0001 → 1000

The old least significant bit returns to the most
significant position.

The sequence repeats after four rising clock edges.

## Behavior Table

| Condition or event | Next out |
|---|---|
| rst asserted high | 1000, without waiting for the clock |
| rst remains high | Held at 1000 |
| Rising clock edge with rst = 0 | Rotate right by one |
| rst falls without a clock edge | Hold the reset value |
| No clock edge, with rst = 0 | Previous out |

## State Transition Table

With reset inactive, at each rising clock edge:

| Current out | Next out |
|---|---|
| 1000 | 0100 |
| 0100 | 0010 |
| 0010 | 0001 |
| 0001 | 1000 |

This table shows the one-hot cycle established by reset.

## Small Example

| Step | Event | rst | out after event | Explanation |
|---|---|---|---|---|
| 1 | Reset asserted | 1 | 1000 | Initialize immediately |
| 2 | Reset released between edges | 0 | 1000 | Hold until a rising edge |
| 3 | Rising clock edge | 0 | 0100 | Rotate right |
| 4 | Rising clock edge | 0 | 0010 | Rotate right |
| 5 | Rising clock edge | 0 | 0001 | Rotate right |
| 6 | Rising clock edge | 0 | 1000 | Wrap the 1 to the MSB |

## Verilog Code

```verilog
module ring_counter_concat (
    input  wire       clk,  // Clock signal
    input  wire       rst,  // Asynchronous active-high reset
    output reg  [3:0] out   // 4-bit counter output
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize the counter to the starting state (1000)
            out <= 4'b1000;
        end else begin
            // Concatenation operator performs a circular right-shift:
            // Takes the last bit (out[0]) and puts it at the front,
            // then slides the other three bits (out[3:1]) to the right.
            out <= {out[0], out[3:1]};
        end
    end

endmodule
```

## Code Explanation

### 1. Four-bit output

`output reg [3:0] out`

Declares four stored bits.

out[3] is the most significant bit.
out[0] is the least significant bit.

### 2. Clock and asynchronous reset

`always @(posedge clk or posedge rst)`

Triggers on either a rising clock edge or reset assertion.

Because rst is included in the event control, reset
does not need to wait for a clock edge.

Reset release does not itself rotate the counter.
In hardware, asynchronous reset release must meet
recovery and removal timing requirements.

### 3. Starting pattern

`out <= 4'b1000;`

Initializes exactly one bit to 1.

Starting at 0000 would cause the counter to remain
at 0000 because rotation cannot create a 1.

### 4. Concatenation

`{out[0], out[3:1]}`

Joins the old least significant bit with the old upper
three bits to form the next four-bit value.

The bit mapping is:

Next out[3] = old out[0]
Next out[2] = old out[3]
Next out[1] = old out[2]
Next out[0] = old out[1]

For out = 1000:

- out[0] = 0
- out[3:1] = 100
- Concatenation = {0, 100} = 0100

For out = 0001:

- out[0] = 1
- out[3:1] = 000
- Concatenation = {1, 000} = 1000

### 5. Rotation versus logical shift

Rotation feeds the outgoing bit back into the register.

A logical right shift inserts 0 at the MSB instead.
That would eventually remove the single 1.

### 6. Nonblocking assignment

`<=`

Calculates the next pattern using the old output value,
then schedules the stored value to update.

### 7. Initialization matters

Rotation preserves the number of 1s in the pattern.

An invalid pattern with zero or multiple 1s does not
automatically become one-hot. Reset restores the intended
starting state.

## How to Remember

"Take the rightmost bit and put it at the left."

Right rotation:

out <= {out[0], out[3:1]};

Remember the sequence:

1000 → 0100 → 0010 → 0001 → repeat