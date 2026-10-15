# Template 09: 2:4 Decoder with Enable

## Purpose

A 2:4 decoder converts a two-bit binary input into four
output lines.

When enabled, exactly one output is 1 for a binary input.
This is called a one-hot output.

When disabled, all outputs are 0.

Decoders are used for address selection and enabling
individual hardware blocks.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| a | Input | 2 bits | Binary value to decode |
| en | Input | 1 bit | Active-high enable |
| y | Output | 4 bits | Decoded output lines |

Active-high enable means en = 1 enables the circuit.

## Short Explanation

When en = 1, the numeric value of a selects which output
bit becomes 1:

- a = 00 → y[0] = 1
- a = 01 → y[1] = 1
- a = 10 → y[2] = 1
- a = 11 → y[3] = 1

All other output bits remain 0.

When en = 0, y = 0000 regardless of a.

No clock or reset is required because this is combinational logic.

## Truth Table

| en | a | y[3:0] |
|---|---|---|
| 0 | -- | 0000 |
| 1 | 00 | 0001 |
| 1 | 01 | 0010 |
| 1 | 10 | 0100 |
| 1 | 11 | 1000 |

Here, -- means any binary input value.
It is table notation, not Verilog syntax.

Output vectors are written from y[3] down to y[0].

## Small Example

Let en = 1 and a = 2'b10.

Binary 10 represents decimal 2, so output bit 2 becomes 1:

y = 4'b0100

Now change en to 0 while keeping a = 10:

y = 4'b0000

The enable input controls whether any output can be active.

## Logic Equations

y[0] = en & ~a[1] & ~a[0]
y[1] = en & ~a[1] &  a[0]
y[2] = en &  a[1] & ~a[0]
y[3] = en &  a[1] &  a[0]

Each output checks one binary input combination.
The enable signal gates every output.

## Verilog Code

```verilog
module decoder_2to4 (
    input  wire [1:0] a,
    input  wire       en,
    output reg  [3:0] y
);

    always @(*) begin
        y = 4'b0000;

        if (en) begin
            case (a)
                2'b00:   y = 4'b0001;
                2'b01:   y = 4'b0010;
                2'b10:   y = 4'b0100;
                2'b11:   y = 4'b1000;
                default: y = 4'b0000;
            endcase
        end
    end

endmodule
```

## Code Explanation

### 1. Binary input

`input wire [1:0] a`

Declares a two-bit input representing values 0 through 3.

### 2. Output vector

`output reg [3:0] y`

Declares four output bits.

The reg type allows procedural assignments inside the
always block. It does not automatically imply stored state.

### 3. Default assignment

`y = 4'b0000;`

Ensures every output is assigned on every execution.

When en = 0, this value remains unchanged, so a separate
else branch is unnecessary. No latch is inferred.

### 4. Enable condition

`if (en)`

Allows decoding when en = 1.

### 5. Decode the input

The case statement maps each binary input to a one-hot value.

For example:

`2'b11: y = 4'b1000;`

Input 11 represents 3, so y[3] becomes 1.

### 6. Unknown inputs

If en = 1 but a contains x or z, the default case sets y to 0.

If en itself is x or z, the if body is not executed, and
the initial zero assignment remains.

These are behaviors of this Verilog description, not
guarantees for physically uncertain input signals.

## Connection to the Demultiplexer

For binary inputs, this decoder has the same output mapping
as Template 08 when:

- The demultiplexer's din is connected to en.
- The demultiplexer's sel is connected to a.

The interpretation differs:

- Demultiplexer: route data to a selected output.
- Decoder: activate the output identified by a binary code.

## How to Remember

"Binary number becomes the position of the 1."

0 → 0001
1 → 0010
2 → 0100
3 → 1000

Remember the coding pattern:

1. Default all outputs to zero.
2. Check enable.
3. Set the output bit matching the input number.

Two input bits produce 2^2 = 4 decoded outputs.