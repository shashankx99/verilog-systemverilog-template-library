# Template 07: 4:1 Multiplexer

## Purpose

A 4:1 multiplexer selects one of four data inputs and
connects it to a single output.

Two select bits provide four possible binary combinations.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| d0 | Input | 1 bit | Data selected when sel = 00 |
| d1 | Input | 1 bit | Data selected when sel = 01 |
| d2 | Input | 1 bit | Data selected when sel = 10 |
| d3 | Input | 1 bit | Data selected when sel = 11 |
| sel | Input | 2 bits | Select control |
| y | Output | 1 bit | Selected data |

## Short Explanation

The binary value of sel identifies the selected input:

- 00 means 0 → select d0.
- 01 means 1 → select d1.
- 10 means 2 → select d2.
- 11 means 3 → select d3.

The circuit is combinational and requires no clock or reset.

## Selection Table

| sel[1] | sel[0] | y |
|---|---|---|
| 0 | 0 | d0 |
| 0 | 1 | d1 |
| 1 | 0 | d2 |
| 1 | 1 | d3 |

This compact table describes the output for every binary
select combination, regardless of the data values.

## Small Example

Let:

- d0 = 1
- d1 = 0
- d2 = 1
- d3 = 0

| sel | Selected input | y |
|---|---|---|
| 00 | d0 | 1 |
| 01 | d1 | 0 |
| 10 | d2 | 1 |
| 11 | d3 | 0 |

For example, sel = 2'b10 selects d2, so y = 1.

## Logic Equation

y = (~sel[1] & ~sel[0] & d0)
  | (~sel[1] &  sel[0] & d1)
  | ( sel[1] & ~sel[0] & d2)
  | ( sel[1] &  sel[0] & d3)

For a binary select value, exactly one selection term is
enabled, allowing its corresponding data input through.

## Verilog Code

```verilog
module mux_4to1 (
    input  wire       d0,
    input  wire       d1,
    input  wire       d2,
    input  wire       d3,
    input  wire [1:0] sel,
    output reg        y
);

    always @(*) begin
        case (sel)
            2'b00:   y = d0;
            2'b01:   y = d1;
            2'b10:   y = d2;
            2'b11:   y = d3;
            default: y = 1'b0;
        endcase
    end

endmodule
```

## Code Explanation

### 1. Two-bit select

`input wire [1:0] sel`

Declares a two-bit input that represents values 0 through 3.

### 2. Output declared as reg

`output reg y`

In Verilog, a signal assigned inside an always block must
use a procedural variable type such as reg.

The word reg does not automatically mean a hardware register.
Here, y is assigned on every path, so the logic is combinational.

### 3. Combinational always block

`always @(*)`

Runs when a signal read by the block changes.
The automatic sensitivity list avoids listing each input manually.

### 4. Case statement

`case (sel)`

Compares sel against the listed values and executes the
matching assignment.

For example:

`2'b10: y = d2;`

means that binary select value 10 connects d2 to y.

### 5. Blocking assignments

`y = d0;`

Blocking assignments are used here for combinational logic.

### 6. Default branch

`default: y = 1'b0;`

All four binary select values are already covered.

If sel contains x or z, an ordinary case statement will
not match these binary branches, so this code assigns 0.

This is a simulation behavior chosen for this template;
it does not guarantee a zero output for an uncertain
physical select signal.

## How to Remember

"Convert select to a number, then choose that input."

00 → 0 → d0
01 → 1 → d1
10 → 2 → d2
11 → 3 → d3

Remember the coding structure:

always @(*)
    case (sel)
        select_value: y = corresponding_input;
        ...
        default: y = 1'b0;
    endcase

Four inputs need two select bits because 2^2 = 4.