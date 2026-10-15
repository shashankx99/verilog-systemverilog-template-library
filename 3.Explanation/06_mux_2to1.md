# Template 06: 2:1 Multiplexer

## Purpose

A 2:1 multiplexer selects one of two data inputs and
connects it to a single output.

It is also called a MUX and acts as a digital selector.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| d0 | Input | 1 bit | Data selected when sel = 0 |
| d1 | Input | 1 bit | Data selected when sel = 1 |
| sel | Input | 1 bit | Select control |
| y | Output | 1 bit | Selected data |

## Short Explanation

The select input determines which data input reaches y.

- sel = 0: y follows d0.
- sel = 1: y follows d1.

This is combinational logic, so no clock or reset is required.

## Selection Table

| sel | y |
|---|---|
| 0 | d0 |
| 1 | d1 |

## Truth Table

| sel | d0 | d1 | y |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 1 |

This table assumes binary inputs (0 or 1).

## Small Example

Let d0 = 0 and d1 = 1.

- When sel = 0, y = d0 = 0.
- When sel = 1, y = d1 = 1.

If d0 changes while sel = 1, y still follows d1.
The unselected input does not affect the output for a
known binary select value.

## Logic Equation

y = (~sel & d0) | (sel & d1)

- When sel = 0, the d0 term passes through.
- When sel = 1, the d1 term passes through.

## Verilog Code

```verilog
module mux_2to1 (
    input  wire d0,
    input  wire d1,
    input  wire sel,
    output wire y
);

    assign y = sel ? d1 : d0;

endmodule
```

## Code Explanation

### 1. Data inputs

`d0` and `d1` are the two one-bit data inputs.

### 2. Select input

`sel` chooses which input drives the output.

### 3. Conditional operator

`sel ? d1 : d0`

The conditional operator uses this format:

condition ? value_if_true : value_if_false

For binary sel:

- sel = 1 selects the expression after `?`, which is d1.
- sel = 0 selects the expression after `:`, which is d0.

### 4. Continuous assignment

`assign y = sel ? d1 : d0;`

Continuously drives y with the selected input.
There is no stored state.

## How to Remember

"Select matches the input number."

- Select 0 → d0
- Select 1 → d1

For the code, remember:

sel ? input_1 : input_0

The true choice comes first, so d1 appears before d0.