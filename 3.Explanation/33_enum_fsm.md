# Template 33: FSM Using enum and typedef

## Purpose

This template demonstrates a SystemVerilog finite-state
machine using named, typed states.

The controller has three states:

IDLE → RUN → DONE → IDLE

It starts an operation when requested, waits for an
external completion signal, then reports completion.

This module controls the sequence only. It does not
perform the underlying operation.

Reset is synchronous and active-high.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| start | Input | 1 bit | Request accepted while IDLE |
| work_done | Input | 1 bit | Completion indication checked while RUN |
| busy | Output | 1 bit | High while in RUN |
| done | Output | 1 bit | High while in DONE |

Control inputs are assumed to be synchronous to clk.

## Short Explanation

### IDLE

The controller waits for start.

When start = 1 at a rising edge, it enters RUN.

### RUN

busy is high.

The controller stays here until work_done = 1 at a
rising edge, then enters DONE.

### DONE

done is high.

The controller returns to IDLE at the next rising edge,
so done lasts one clock period during normal operation.

Outputs depend only on the current state, making this
a Moore FSM.

## State Transition Table

Assuming reset is inactive:

| Current state | Condition | Next state |
|---|---|---|
| IDLE | start = 0 | IDLE |
| IDLE | start = 1 | RUN |
| RUN | work_done = 0 | RUN |
| RUN | work_done = 1 | DONE |
| DONE | Any input values | IDLE |

start is ignored in RUN and DONE.
work_done is ignored in IDLE and DONE.

If start and work_done are both high in IDLE, the
controller enters RUN. Completion is checked only
after it is in RUN.

## Output Table

| State | busy | done |
|---|---|---|
| IDLE | 0 | 0 |
| RUN | 1 | 0 |
| DONE | 0 | 1 |

## Small Example

Outputs are shown after each rising edge has settled.

| Edge | rst | start | work_done | State after edge | busy | done |
|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | IDLE | 0 | 0 |
| 2 | 0 | 1 | 0 | RUN | 1 | 0 |
| 3 | 0 | 0 | 0 | RUN | 1 | 0 |
| 4 | 0 | 0 | 1 | DONE | 0 | 1 |
| 5 | 0 | 0 | 0 | IDLE | 0 | 0 |
| 6 | 0 | 1 | 0 | RUN | 1 | 0 |

A request asserted only while busy is not stored.

If start remains high when the FSM returns to IDLE,
it starts another operation at the following rising edge.

## SystemVerilog Code

```systemverilog
module enum_fsm (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic work_done,
    output logic busy,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RUN  = 2'b01,
        DONE = 2'b10
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = RUN;
            end

            RUN: begin
                if (work_done)
                    next_state = DONE;
            end

            DONE: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    always_comb begin
        busy = 1'b0;
        done = 1'b0;

        case (state)
            RUN:     busy = 1'b1;
            DONE:    done = 1'b1;
            default: begin
                busy = 1'b0;
                done = 1'b0;
            end
        endcase
    end

endmodule
```

## Code Explanation

### 1. enum

`enum logic [1:0]`

Defines named values represented using two bits.

Instead of scattering raw binary values through the
FSM, we use IDLE, RUN, and DONE.

### 2. typedef

`typedef ... state_t;`

Gives the enumeration a reusable type name: state_t.

The _t suffix is a naming convention, not a language rule.

### 3. State variables

`state_t state, next_state;`

Declares both variables using the same enumeration type.

Enum typing helps tools catch accidental assignments
of unrelated values to state variables.

### 4. State storage

`always_ff @(posedge clk)`

Stores the current state.

Reset loads IDLE at a rising edge. Otherwise, state
receives next_state.

The stored state uses nonblocking assignments.

### 5. Default next state

`next_state = state;`

Defaults the next state to the current state.

This means "stay here unless a transition condition
selects another state."

It does not infer a latch: next_state is assigned on
every execution from the stored state.

### 6. Conditional transitions

In IDLE, start selects RUN.
In RUN, work_done selects DONE.
DONE always selects IDLE.

### 7. Default case

`default: next_state = IDLE;`

For an unrecognized state value in this RTL description,
the next-state logic selects IDLE.

Physical illegal-state recovery also depends on how
synthesis implements the state machine.

### 8. Moore outputs

busy and done are decoded only from state.

Their default assignments ensure both outputs are
assigned on every path.

These are combinational state decodes, not separately
registered outputs.

## How to Remember

"Name, Store, Decide, Decode."

1. NAME the states with typedef enum.
2. STORE the current state using always_ff.
3. DECIDE the next state using always_comb.
4. DECODE outputs from the current state.

Remember the control sequence:

IDLE waits for START.
RUN waits for WORK_DONE.
DONE reports completion for one cycle.