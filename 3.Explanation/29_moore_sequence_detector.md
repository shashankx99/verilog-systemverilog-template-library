# Template 29: Moore Sequence Detector for 1011

## Purpose

This finite-state machine detects the serial bit pattern 1011.

It samples one input bit at each rising clock edge and
supports overlapping matches.

It is a Moore machine: detected depends only on the
current state.

Reset is asynchronous and active-high.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Clock for sampling input bits |
| rst | Input | 1 bit | Asynchronous active-high reset |
| din | Input | 1 bit | Serial input bit |
| detected | Output | 1 bit | High while in the detection state |

din is assumed to meet the clock's setup and hold requirements.

## Short Explanation

The FSM remembers how much of 1011 has been matched.

When an input does not continue the expected pattern,
the FSM keeps the longest suffix that can begin another
match.

When the final 1 is sampled, the FSM enters S4 and
detected becomes high after the state update.

For normal binary operation, S4 is left at the next
rising edge, so detected lasts one clock period.

## State Meanings

| State | Meaning | detected |
|---|---|---|
| S0 | No useful prefix matched |
0 |
| S1 | Matched 1 | 0 |
| S2 | Matched 10 | 0 |
| S3 | Matched 101 | 0 |
| S4 | Matched complete pattern 1011 | 1 |

## State Transition Table

| Current state | din = 0 → Next state | din = 1 → Next state |
|---|---|---|
| S0 | S0 | S1 |
| S1 | S2 | S1 |
| S2 | S0 | S3 |
| S3 | S2 | S4 |
| S4 | S2 | S1 |

## Understanding the Important Transitions

### S1 with input 1 → S1

The sequence ends in 11.

The newest 1 can start a new 1011 match, so keep the
matched-prefix state for 1.

### S3 with input 0 → S2

The sequence ends in 1010.

Its final two bits are 10, which already match the
first two bits of the target. Keep that progress.

### S4 with input 0 → S2

After detecting 1011, the final 1 can start another match.

If the next bit is 0, the useful suffix becomes 10.

### S4 with input 1 → S1

If the next bit is 1, the useful suffix is the latest 1.

## Small Example: Overlapping Matches

Input stream:

1 0 1 1 0 1 1

The target appears at:
- Bits 1 through 4.
- Bits 4 through 7.

Bit 4 is shared by both matches.

Starting from S0 after reset:

| Sampled bit number | din | State after edge | detected after edge |
|---|---|---|---|
| 1 | 1 | S1 | 0 |
| 2 | 0 | S2 | 0 |
| 3 | 1 | S3 | 0 |
| 4 | 1 | S4 | 1 |
| 5 | 0 | S2 | 0 |
| 6 | 1 | S3 | 0 |
| 7 | 1 | S4 | 1 |

## Verilog Code

```verilog
module moore_1011_detector (
    input  wire clk,
    input  wire rst,
    input  wire din,
    output wire detected
);

    localparam S0 = 3'b000,
               S1 = 3'b001,
               S2 = 3'b010,
               S3 = 3'b011,
               S4 = 3'b100;

    reg [2:0] state, next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = S0;

        case (state)
            S0: next_state = din ? S1 : S0;
            S1: next_state = din ? S1 : S2;
            S2: next_state = din ? S3 : S0;
            S3: next_state = din ? S4 : S2;
            S4: next_state = din ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    assign detected = (state == S4);

endmodule
```

## Code Explanation

### 1. State constants

`localparam`

Defines named constants for the five states.

Three bits are enough to encode five states because
two bits encode only four values.

### 2. State and next_state

`state` stores the current FSM state.

`next_state` is the combinational decision about which
state to enter at the next rising clock edge.

### 3. State register

`state <= next_state;`

Updates the current state using a nonblocking assignment.

Reset loads S0 without waiting for a clock edge.
Asynchronous reset release must meet hardware recovery
and removal timing requirements.

### 4. Next-state logic

`always @(*)`

Calculates next_state from state and din.

Blocking assignments are used for this combinational logic.
A default value and default case ensure complete assignment.

An unused binary state encoding selects S0 as the next state.

### 5. Conditional operator

`din ? S1 : S0`

For binary din:
- din = 1 selects S1.
- din = 0 selects S0.

Each expression implements one row of the transition table.

### 6. Moore output

`assign detected = (state == S4);`

The output checks only state, not din.

It becomes high after the clock edge that captures the
final bit of 1011 and updates state to S4. No additional
clock edge is needed to assert it.

This is a combinational state decode, not a separately
registered output; physical decode glitches are possible.

## How to Remember

"Each state records how much of 1011 is matched."

S0 → nothing
S1 → 1
S2 → 10
S3 → 101
S4 → 1011 detected

For a mismatch, ask:

"What is the longest ending part that is also the
beginning of 1011?"

For Moore output, remember:

OUTPUT = function of CURRENT STATE only.