# Template 10: 4:2 Priority Encoder

## Purpose

A 4:2 priority encoder examines four input bits and produces
the two-bit binary position of the highest-priority active bit.

If multiple inputs are 1, the highest-priority input wins.

Priority order:

d[3] > d[2] > d[1] > d[0]

Priority encoders can be used to select among pending requests.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| d | Input | 4 bits | Active-high input requests |
| code | Output | 2 bits | Position of the highest-priority active input |
| valid | Output | 1 bit | 1 when at least one binary input bit is active |

When valid = 0, code is set to 00 but does not identify
an active input.

## Short Explanation

The circuit checks inputs from highest to lowest priority:

1. If d[3] is 1, output code = 11.
2. Otherwise, if d[2] is 1, output code = 10.
3. Otherwise, if d[1] is 1, output code = 01.
4. Otherwise, if d[0] is 1, output code = 00.
5. If all inputs are 0, output valid = 0 and code = 00.

No clock or reset is required because this is combinational logic.

## Priority Table

| d[3] | d[2] | d[1] | d[0] | code | valid |
|---|---|---|---|---|---|
| 1 | - | - | - | 11 | 1 |
| 0 | 1 | - | - | 10 | 1 |
| 0 | 0 | 1 | - | 01 | 1 |
| 0 | 0 | 0 | 1 | 00 | 1 |
| 0 | 0 | 0 | 0 | 00 | 0 |

The symbol - means either binary value, 0 or 1.
It does not mean an unknown Verilog value.

Lower-priority inputs do not affect the result when a
higher-priority input is active.

## Small Examples

### Example 1: Multiple Active Inputs

d = 4'b1010

Both d[3] and d[1] are 1.

d[3] has higher priority, so:

- code = 2'b11
- valid = 1

### Example 2: Input 2 Wins

d = 4'b0111

Inputs d[2], d[1], and d[0] are active.
The highest-priority active input is d[2].

- code = 2'b10
- valid = 1

### Example 3: Why valid Is Needed

For d = 4'b0001:

- code = 00
- valid = 1

For d = 4'b0000:

- code = 00
- valid = 0

The code is identical, but valid distinguishes an active
input 0 from no active input.

## Verilog Code

```verilog
module priority_encoder_4to2 (
    input  wire [3:0] d,
    output reg  [1:0] code,
    output reg        valid
);

    always @(*) begin
        code  = 2'b00;
        valid = 1'b0;

        if (d[3]) begin
            code  = 2'b11;
            valid = 1'b1;
        end
        else if (d[2]) begin
            code  = 2'b10;
            valid = 1'b1;
        end
        else if (d[1]) begin
            code  = 2'b01;
            valid = 1'b1;
        end
        else if (d[0]) begin
            code  = 2'b00;
            valid = 1'b1;
        end
    end

endmodule
```

## Code Explanation

### 1. Input vector

`input wire [3:0] d`

Groups four request bits into one vector.
Each bit can be independently active.

### 2. Default outputs

`code = 2'b00;`
`valid = 1'b0;`

Define the outputs when no input is active.

Both outputs are assigned on every execution, avoiding
unintended latches.

### 3. Priority through if–else

The first true condition in the if–else chain wins.

Because d[3] is checked first, it has the highest priority.
Lower branches are skipped once a true condition is found.

### 4. Binary position

When d[2] wins, code is assigned 2'b10, which represents 2.

The output encodes the input's position, not the number
of active inputs.

### 5. Valid flag

Every selected branch sets valid to 1.
If no branch is selected, valid remains 0.

### 6. Combinational assignments

The always @(*) block uses blocking assignments.

The reg declarations allow procedural assignment and
do not imply hardware registers in this complete
combinational description.

The priority table assumes binary inputs. An x or z bit
does not satisfy a single-bit if condition, so this code
can skip an unknown higher-priority input. It is not an
unknown-input detector.

## How to Remember

"Check from the top; first 1 wins."

- Bit 3 → code 11
- Bit 2 → code 10
- Bit 1 → code 01
- Bit 0 → code 00

Remember the structure:

1. Default code and valid to zero.
2. Check inputs from highest to lowest priority.
3. Output the winning bit's index.
4. Set valid when a winner exists.