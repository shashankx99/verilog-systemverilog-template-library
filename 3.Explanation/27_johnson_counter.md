# Template 27: Johnson Counter Using Concatenation

## Purpose

A Johnson counter is a shift register that feeds the
inverted outgoing bit back into the opposite end.

It is also called a twisted-ring counter.

This four-bit implementation shifts right and produces
eight states in its reset-initialized cycle.

It uses an asynchronous active-high reset.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Asynchronous active-high reset |
| out | Output | 4 bits | Current counter state |

There is no enable input. With reset inactive, the
counter advances at every rising clock edge.

## Short Explanation

Reset initializes out to 0000.

At each rising clock edge with reset inactive:

1. Invert the old least significant bit, out[0].
2. Insert that inverted bit into the most significant position.
3. Shift the old upper three bits to the right.

The sequence is:

0000 → 1000 → 1100 → 1110 → 1111
     → 0111 → 0011 → 0001 → 0000

The register fills with 1s and then fills with 0s.

## Behavior Table

| Condition or event | Next out |
|---|---|
| rst asserted high | 0000, without waiting for the clock |
| rst remains high | Held at 0000 |
| Rising clock edge with rst = 0 | {~out[0], out[3:1]} |
| rst falls without a clock edge | Hold the reset value |
| No clock edge, with rst = 0 | Previous out |

## State Transition Table

With reset inactive, at each rising clock edge:

| Current out | Inverted out[0] | Next out |
|---|---|---|
| 0000 | 1 | 1000 |
| 1000 | 1 | 1100 |
| 1100 | 1 | 1110 |
| 1110 | 1 | 1111 |
| 1111 | 0 | 0111 |
| 0111 | 0 | 0011 |
| 0011 | 0 | 0001 |
| 0001 | 0 | 0000 |

This table shows the eight-state cycle established by reset.

## Small Example

Suppose out = 4'b1110.

Step 1: Read the outgoing bit.

out[0] = 0

Step 2: Invert it.

~out[0] = 1

Step 3: Select the upper three bits.

out[3:1] = 111

Step 4: Concatenate.

{1, 111} = 1111

At the next rising edge:

out becomes 1111.

On the following rising edge:

- ~out[0] = 0
- out[3:1] = 111
- New out = {0, 111} = 0111

## Verilog Code

```verilog
module johnson_counter_concat (
    input  wire       clk,
    input  wire       rst,
    output reg  [3:0] out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 4'b0000;
        else
            out <= {~out[0], out[3:1]};
    end

endmodule
```

## Code Explanation

### 1. Four-bit storage

`output reg [3:0] out`

Declares four stored bits.

### 2. Asynchronous reset

`always @(posedge clk or posedge rst)`

Triggers on a rising clock edge or reset assertion.

`if (rst) out <= 4'b0000;`

Clears the counter without waiting for a clock edge.

Reset release alone does not advance the counter.
In hardware, asynchronous reset release must meet
recovery and removal timing requirements.

### 3. Inverted feedback

`~out[0]`

Inverts the outgoing least significant bit.

- Outgoing 0 → incoming 1.
- Outgoing 1 → incoming 0.

This inversion distinguishes a Johnson counter from
the ring counter in Template 26.

### 4. Concatenation

`{~out[0], out[3:1]}`

Builds the next state with this mapping:

Next out[3] = NOT old out[0]
Next out[2] = old out[3]
Next out[1] = old out[2]
Next out[0] = old out[1]

The expression has four bits:
one feedback bit plus three shifted bits.

### 5. Nonblocking assignment

`out <= {~out[0], out[3:1]};`

Uses the old state to calculate the complete next state.

All four stored bits update together at the clock edge.

### 6. Number of states

An N-bit Johnson counter has 2N states in its standard
reset-initialized cycle.

For four bits:

2 × 4 = 8 states

The four-bit register can represent 16 patterns, but only
eight belong to this cycle. Other starting patterns can
remain in a different cycle, so reset establishes the
intended sequence.

## Comparison with the Ring Counter

| Feature | Ring counter from Template 26 | Johnson counter |
|---|---|---|
| Reset pattern | 1000 | 0000 |
| Feedback | out[0] | ~out[0] |
| Update | {out[0], out[3:1]} | {~out[0], out[3:1]} |
| States in the intended four-bit cycle | 4 | 8 |
| Output pattern | One-hot | Fills with 1s, then with 0s |

## How to Remember

"Johnson: invert the bit before feeding it back."

Ring:
out <= {out[0], out[3:1]};

Johnson:
out <= {~out[0], out[3:1]};

The key difference is the ~ operator.

Remember the pattern:

Start empty → fill with 1s → fill with 0s → repeat.