# Template 36: Packed Arrays

## Purpose

A packed array groups bits into a single contiguous
bit vector in the language's data representation.

Packed arrays support:
- Accessing individual bits.
- Selecting groups of bits.
- Whole-vector assignment.
- Arithmetic and bitwise operations.
- Multiple packed dimensions.

This template demonstrates these operations using
a 16-bit input.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| data | Input | 16 bits | Original packed vector |
| upper_byte | Output | 8 bits | Bits 15 through 8 |
| lower_byte | Output | 8 bits | Bits 7 through 0 |
| bit_5 | Output | 1 bit | Bit at index 5 |
| middle_bits | Output | 4 bits | Bits 7 through 4 |
| bytes_view | Output | 16 bits | Two packed groups of eight bits |
| swapped | Output | 16 bits | Input with its two bytes exchanged |

This is combinational wiring. No clock or reset is needed.

## Short Explanation

Packed dimensions appear before the variable name.

Example:

logic [15:0] data;

This declares one 16-bit packed vector.

A multidimensional packed declaration can organize
the same number of bits into groups:

logic [1:0][7:0] bytes_view;

This declares 2 × 8 = 16 packed bits.

- bytes_view[1] selects the upper eight-bit group.
- bytes_view[0] selects the lower eight-bit group.
- bytes_view[1][7] selects one bit within the upper group.

These mappings follow the descending ranges used here.

## Access Table

| Expression | Meaning | Width |
|---|---|---|
| data | Entire vector | 16 bits |
| data[5] | Single bit at index 5 | 1 bit |
| data[15:8] | Upper byte | 8 bits |
| data[7:0] | Lower byte | 8 bits |
| data[7:4] | Four-bit slice | 4 bits |
| bytes_view[1] | Upper packed byte | 8 bits |
| bytes_view[0] | Lower packed byte | 8 bits |
| bytes_view[1][7] | Most significant bit of the upper byte | 1 bit |

For a descending range [high:low]:

Width = high - low + 1

Therefore, data[15:8] contains 15 - 8 + 1 = 8 bits.

## Small Example

Let:

data = 16'hABCD

In binary:

data = 16'b1010_1011_1100_1101

The outputs are:

| Output | Value |
|---|---|
| upper_byte | 8'hAB |
| lower_byte | 8'hCD |
| bit_5 | 1'b0 |
| middle_bits | 4'hC |
| bytes_view[1] | 8'hAB |
| bytes_view[0] | 8'hCD |
| swapped | 16'hCDAB |

To find bit_5, examine the lower byte:

Index: 7 6 5 4 3 2 1 0
Value: 1 1 0 0 1 1 0 1

Bit 5 is 0.

## SystemVerilog Code

```systemverilog
module packed_arrays (
    input  logic [15:0]     data,
    output logic [7:0]      upper_byte,
    output logic [7:0]      lower_byte,
    output logic           bit_5,
    output logic [3:0]      middle_bits,
    output logic [1:0][7:0] bytes_view,
    output logic [15:0]     swapped
);

    assign upper_byte  = data[15:8];
    assign lower_byte  = data[7:0];
    assign bit_5       = data[5];
    assign middle_bits = data[7:4];

    assign bytes_view = data;

    assign swapped = {data[7:0], data[15:8]};

endmodule
```

## Code Explanation

### 1. One-dimensional packed vector

`logic [15:0] data`

The range appears before the name, making it packed.

The vector contains 16 four-state bits. Each bit can
represent 0, 1, x, or z.

### 2. Bit-select

`data[5]`

Selects one bit.

Index 5 means the sixth bit when counting from index 0.

### 3. Part-select

`data[15:8]`

Selects a contiguous group of bits.

For this descending declaration, the conventional
part-select also uses descending indices.

### 4. Multidimensional packed array

`logic [1:0][7:0] bytes_view`

Both dimensions appear before the name.

The left dimension selects one of two groups.
The right dimension selects one of eight bits in a group.

The complete value is still a 16-bit packed quantity.

### 5. Whole-vector assignment

`assign bytes_view = data;`

Assigns the 16-bit input to the 16-bit packed output.

For these declarations:

bytes_view[1] = data[15:8]
bytes_view[0] = data[7:0]

The assignment changes how the bits are grouped for
access; it does not reverse their order.

### 6. Concatenation

`{data[7:0], data[15:8]}`

Places the original lower byte in the upper position
and the original upper byte in the lower position.

The leftmost concatenation item becomes the most
significant part of the result.

### 7. Indexed part-select syntax

SystemVerilog also supports a base index and a
constant selection width.

For this descending vector:

data[4 +: 4] is equivalent to data[7:4].
data[7 -: 4] is equivalent to data[7:4].

- +: selects toward increasing indices from the base.
- -: selects toward decreasing indices from the base.

The base may be variable, but the selected width
must be constant.

## Packed Versus Unpacked Declaration

| Declaration | Meaning |
|---|---|
| logic [7:0] value; | One packed eight-bit vector |
| logic [1:0][7:0] value; | One 16-bit quantity with two packed dimensions |
| logic [7:0] value [0:1]; | An unpacked array containing two eight-bit vectors |

Dimensions before the name are packed.
Dimensions after the name are unpacked.

The next template covers unpacked arrays.

## How to Remember

"Packed dimensions go before the name."

logic [15:0] data;
      PACKED  NAME

For access:

[index] → select one element of that dimension.
[high:low] → select a range.

For two packed dimensions:

bytes_view[byte_index][bit_index]

Think of the value as one bit vector that can also
be accessed in smaller groups.