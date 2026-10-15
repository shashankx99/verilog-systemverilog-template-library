# Template 30: Mealy Sequence Detector for 1011

## Purpose

This finite-state machine detects the serial pattern 1011
and supports overlapping matches.

It is a Mealy machine: detected depends on the current
state and the current input.

It uses an asynchronous active-high reset.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Clock for updating the state |
| rst | Input | 1 bit | Asynchronous active-high reset |
| din | Input | 1 bit | Serial input bit |
| detected | Output | 1 bit | High when state is S3 and din is 1 |

din is assumed to be synchronous to clk and to meet
setup and hold requirements.

## Short Explanation

The FSM remembers the prefix already sampled:

- S0: no useful prefix.
- S1: matched 1.
- S2: matched 10.
- S3: matched 101.

While in S3, a current input of 1 completes the pattern.
The combinational output detected then becomes high.

No separate detection state is needed.

After consuming that final 1 at the rising edge, the
FSM returns to S1 because the same bit can start
another match.

## State Transition and Output Table

Each entry shows next state and detected.

| Current state | din = 0: next state / detected | din = 1: next state / detected |
|---|---|---|
| S0 | S0 / 0 | S1 / 0 |
| S1 | S2 / 0 | S1 / 0 |
| S2 | S0 / 0 | S3 / 0 |
| S3 | S2 / 0 | S1 / 1 |

The table assumes known binary inputs.

## Small Example: Overlapping Matches

Input stream:

1 0 1 1 0 1 1

The pattern occurs at bits 1–4 and bits 4–7.

Starting from S0 after reset:

| Bit number | State before edge | din | detected before edge | State after edge |
|---|---|---|---|---|
| 1 | S0 | 1 | 0 | S1 |
| 2 | S1 | 0 | 0 | S2 |
| 3 | S2 | 1 | 0 | S3 |
| 4 | S3 | 1 | 1 | S1 |
| 5 | S1 | 0 | 0 | S2 |
| 6 | S2 | 1 | 0 | S3 |
| 7 | S3 | 1 | 1 | S1 |

The table shows detected after combinational settling
before each sampling edge, while the listed bit is stable.

## Understanding Output Timing

Unlike the Moore template, this detected output is
combinational and is not guaranteed to be a full-cycle pulse.

When state = S3:
- din = 1 makes detected high.
- din = 0 makes detected low.

At the edge that consumes the final 1, state changes
from S3 to S1, so detected returns low after settling.

Because detected depends directly on din, it can change
between clock edges. Its pulse width depends on input timing.

A downstream register can sample detected at the clock
edge if timing requirements are met. Do not use this
combinational signal as a clock.

## Verilog Code

```verilog
module mealy_1011_detector (
    input  wire clk,
    input  wire rst,
    input  wire din,
    output reg  detected
);

    localparam S0 = 2'b00,
               S1 = 2'b01,
               S2 = 2'b10,
               S3 = 2'b11;

    reg [1:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = S0;
        detected   = 1'b0;

        case (state)
            S0: next_state = din ? S1 : S0;

            S1: next_state = din ? S1 : S2;

            S2: next_state = din ? S3 : S0;

            S3: begin
                if (din) begin
                    next_state = S1;
                    detected   = 1'b1;
                end
                else
                    next_state = S2;
            end

            default: next_state = S0;
        endcase
    end

endmodule
```

## Code Explanation

### 1. Four states

Two state bits encode the four prefix states.

There is no separate state for the complete pattern.
Detection is associated with the S3 transition on input 1.

### 2. State register

`always @(posedge clk or posedge rst)`

Stores the next state at a rising clock edge or resets
to S0 when rst is asserted.

Asynchronous reset release must meet hardware recovery
and removal timing requirements.

### 3. Default assignments

`next_state = S0;`
`detected = 1'b0;`

Provide values on every combinational path.

detected remains 0 unless the detection condition is met.
This avoids unintended latch inference.

### 4. Detection condition

In S3, the already sampled prefix is 101.

If din = 1, the current input completes 1011:

`detected = 1'b1;`

### 5. Preserve overlap after detection

`next_state = S1;`

The final 1 of the detected pattern can also be the
first 1 of a new pattern.

Returning to S1 preserves that progress.

### 6. Preserve progress on mismatch

From S3 with din = 0, the recent sequence ends in 1010.

Its suffix 10 is a useful prefix, so the next state is S2.

### 7. Assignment types

The clocked state register uses nonblocking assignments.

The combinational next-state and output block uses
blocking assignments.

Although detected is declared reg, it is not a stored
output in this implementation.

## Comparison with Template 29

| Feature | Moore 1011 detector | Mealy 1011 detector |
|---|---|---|
| States in these implementations | 5 | 4 |
| Output depends on | Current state | Current state and din |
| Detection condition | State S4 | State S3 and din = 1 |
| Assertion timing | After entering S4 | When final input is present in S3 |
| Response to din between edges | No direct dependence | Can change immediately |
| Overlapping matches | Supported | Supported |

## How to Remember

"Mealy checks state plus the current input."

Remember the prefixes:

S0 → nothing
S1 → 1
S2 → 10
S3 → 101

In S3:
- Input 1 → detect and retain suffix 1.
- Input 0 → retain suffix 10.

OUTPUT = function of CURRENT STATE and INPUT.