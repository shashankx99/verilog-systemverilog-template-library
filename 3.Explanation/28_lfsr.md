# Template 28: 4-bit Linear-Feedback Shift Register

## Purpose

A Linear-Feedback Shift Register (LFSR) generates a
deterministic sequence of bit patterns using a shift
register and XOR feedback.

LFSRs are used for pseudorandom test patterns and
sequence generation. They are not suitable for
cryptographic randomness.

This implementation uses:
- Four stored bits.
- Left shifting through concatenation.
- XOR feedback from out[3] and out[2].
- Asynchronous active-high reset.
- A nonzero seed of 0001.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Asynchronous active-high reset |
| out | Output | 4 bits | Current LFSR state |

There is no enable input. With reset inactive, the
LFSR advances on every rising clock edge.

## Short Explanation

The feedback bit is:

feedback = out[3] XOR out[2]

At each rising clock edge:

1. Calculate feedback from the current state.
2. Move the lower three bits toward higher indices.
3. Insert feedback into bit 0.

The next-state expression is:

{out[2:0], feedback}

For this exact shift direction and feedback equation,
the sequence visits all 15 nonzero four-bit states
before repeating.

## Behavior Table

| Condition or event | Next out |
|---|---|
| rst asserted high | 0001, without waiting for the clock |
| rst remains high | Held at 0001 |
| Rising clock edge with rst = 0 | {out[2:0], out[3] ^ out[2]} |
| rst falls without a clock edge | Hold the seed |
| No clock edge, with rst = 0 | Previous out |

## State Sequence

Starting from the reset seed:

| State index | Current out | Feedback | Next out |
|---|---|---|---|
| 0 | 0001 | 0 | 0010 |
| 1 | 0010 | 0 | 0100 |
| 2 | 0100 | 1 | 1001 |
| 3 | 1001 | 1 | 0011 |
| 4 | 0011 | 0 | 0110 |
| 5 | 0110 | 1 | 1101 |
| 6 | 1101 | 0 | 1010 |
| 7 | 1010 | 1 | 0101 |
| 8 | 0101 | 1 | 1011 |
| 9 | 1011 | 1 | 0111 |
| 10 | 0111 | 1 | 1111 |
| 11 | 1111 | 0 | 1110 |
| 12 | 1110 | 0 | 1100 |
| 13 | 1100 | 0 | 1000 |
| 14 | 1000 | 1 | 0001 |

After 15 rising clock edges, the initialized sequence
returns to 0001.

## Small Example

Suppose out = 4'b0100.

Step 1: Calculate feedback.

out[3] = 0
out[2] = 1

feedback = 0 XOR 1 = 1

Step 2: Select the lower three bits.

out[2:0] = 100

Step 3: Concatenate.

{100, 1} = 1001

Therefore, the next rising clock edge changes out
from 0100 to 1001.

## Verilog Code

```verilog
module lfsr_4bit (
    input  wire       clk,
    input  wire       rst,
    output reg  [3:0] out
);

    wire feedback;

    assign feedback = out[3] ^ out[2];

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 4'b0001;
        else
            out <= {out[2:0], feedback};
    end

endmodule
```

## Code Explanation

### 1. Feedback wire

`wire feedback;`

Declares the one-bit signal inserted into the register.

### 2. XOR taps

`assign feedback = out[3] ^ out[2];`

The selected state bits are called taps.

XOR produces 1 when these two bits differ and 0
when they are equal.

### 3. Asynchronous reset

`always @(posedge clk or posedge rst)`

Responds to a rising clock edge or reset assertion.

`out <= 4'b0001;`

Loads the nonzero starting state.

In hardware, asynchronous reset release must meet
recovery and removal timing requirements.

### 4. Concatenation and shift

`{out[2:0], feedback}`

Creates the next state:

Next out[3] = old out[2]
Next out[2] = old out[1]
Next out[1] = old out[0]
Next out[0] = old out[3] XOR old out[2]

The original out[3] is shifted out, but it contributes
to the feedback calculation.

### 5. Nonblocking assignment

`out <= {out[2:0], feedback};`

Captures the next state using the current state and
its corresponding feedback.

### 6. Why the seed must be nonzero

For out = 0000:

feedback = 0 XOR 0 = 0
Next out = 0000

The all-zero state therefore locks this XOR-feedback
LFSR at zero. Reset loads 0001 to avoid that state.

### 7. Sequence length

A four-bit register has 16 possible states.

This tap configuration cycles through all 15 nonzero
states, giving the maximum nonzero period:

2^4 - 1 = 15

Other widths or arbitrary tap choices do not automatically
give a maximum-length sequence.

The sequence is repeatable: the same seed produces
the same state order.

## How to Remember

"XOR the taps, shift, insert feedback."

For this four-bit version:

1. XOR bits 3 and 2.
2. Keep bits 2 down to 0.
3. Append the XOR result on the right.

feedback = out[3] ^ out[2];
out <= {out[2:0], feedback};

Always start this XOR-feedback LFSR with a nonzero seed.