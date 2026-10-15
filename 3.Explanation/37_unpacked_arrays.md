# Template 37: Unpacked and Multidimensional Arrays

## Purpose

An unpacked array groups separate elements under one name.
Each element can itself be a packed vector.

This template demonstrates:
- Declaring an unpacked array of bytes.
- Selecting an element using an index.
- Copying elements using foreach.
- Mapping a one-dimensional array into a two-dimensional array.

The example describes combinational logic and needs
no clock or reset.

## Inputs and Outputs

| Signal | Direction | Organization | Meaning |
|---|---|---|---|
| data | Input | Four eight-bit elements | Source array |
| index | Input | Two bits | Selects element 0 through 3 |
| selected | Output | Eight bits | Selected source element |
| copied | Output | Four eight-bit elements | Copy of data |
| matrix | Output | Two rows × two columns of bytes | Source elements arranged in a grid |

## Short Explanation

Unpacked dimensions appear after the variable name.

Example:

logic [7:0] data [0:3];

- [7:0] before data defines eight packed bits per element.
- [0:3] after data defines four unpacked elements.

Therefore, the array contains four bytes.

For a two-dimensional unpacked array:

logic [7:0] matrix [0:1][0:1];

This contains two rows and two columns, with eight bits
in each element.

Calling the dimensions rows and columns is our convention;
the language defines them as the first and second dimensions.

## Declaration Table

| Declaration | Meaning | Total bits |
|---|---|---|
| logic [7:0] value; | One eight-bit packed vector | 8 |
| logic [7:0] data [0:3]; | Four unpacked byte elements | 32 |
| logic [7:0] matrix [0:1][0:1]; | A 2 × 2 unpacked array of bytes | 32 |

An unpacked array is not automatically treated as one
packed integer.

## Access Table

| Expression | Meaning | Size |
|---|---|---|
| data[0] | First byte | 8 bits |
| data[3] | Fourth byte | 8 bits |
| data[2][7] | Bit 7 of byte 2 | 1 bit |
| data[1][3:0] | Lower nibble of byte 1 | 4 bits |
| matrix[1][0] | Byte at row 1, column 0 | 8 bits |
| matrix[1][0][7] | Bit 7 of that byte | 1 bit |

Unpacked indices select the element first.
Further indexing can select bits within that element.

## Small Example

Suppose the input array contains:

data[0] = 8'h11
data[1] = 8'h22
data[2] = 8'h33
data[3] = 8'h44

If index = 2:

selected = data[2] = 8'h33

The copied array contains the same four values:

| Element | Value |
|---|---|
| copied[0] | 8'h11 |
| copied[1] | 8'h22 |
| copied[2] | 8'h33 |
| copied[3] | 8'h44 |

The matrix is:

| Row | Column 0 | Column 1 |
|---|---|---|
| 0 | 8'h11 | 8'h22 |
| 1 | 8'h33 | 8'h44 |

## Mapping Rule

The source index is:

row * 2 + col

The factor 2 is the number of columns.

| row | col | Source index | Assignment |
|---|---|---|---|
| 0 | 0 | 0 | matrix[0][0] = data[0] |
| 0 | 1 | 1 | matrix[0][1] = data[1] |
| 1 | 0 | 2 | matrix[1][0] = data[2] |
| 1 | 1 | 3 | matrix[1][1] = data[3] |

## SystemVerilog Code

```systemverilog
module unpacked_arrays (
    input  logic [7:0] data [0:3],
    input  logic [1:0] index,
    output logic [7:0] selected,
    output logic [7:0] copied [0:3],
    output logic [7:0] matrix [0:1][0:1]
);

    always_comb begin
        selected = data[index];

        foreach (data[i])
            copied[i] = data[i];

        foreach (matrix[row, col])
            matrix[row][col] = data[row * 2 + col];
    end

endmodule
```

## Code Explanation

### 1. Unpacked array port

`input logic [7:0] data [0:3]`

Declares four input elements, each eight bits wide.

SystemVerilog permits unpacked arrays as module ports.

### 2. Dynamic element selection

`selected = data[index];`

Selects one complete byte using index.

The two-bit index covers all four valid positions.

This selection describes a four-way byte multiplexer.
An index containing x or z does not identify a known
element and produces an unknown value for this logic array.

### 3. foreach loop

`foreach (data[i])`

Visits every element index of data.

For the declared range [0:3], i takes the values:

0, 1, 2, 3

The loop index is implicitly declared for the loop.
A separate declaration of i is unnecessary.

### 4. Copying elements

`copied[i] = data[i];`

Assigns every output element from the matching input.

Because these arrays have identical compatible types,
a whole-array assignment is also possible:

copied = data;

The foreach version makes the element-by-element
operation explicit.

### 5. Multidimensional foreach

`foreach (matrix[row, col])`

Iterates over both unpacked dimensions.

The loop selects each byte with:

matrix[row][col]

It does not iterate over the packed bits of each byte,
because no third loop index is specified.

### 6. Combinational behavior

The loops assign every element of copied and matrix.
selected is also assigned on every execution.

There is no stored state and no incomplete output assignment.

These fixed-size loops describe repeated combinational
logic; they do not require one clock cycle per element.

## Packed Versus Unpacked

| Feature | Packed | Unpacked |
|---|---|---|
| Dimension placement | Before the name | After the name |
| Example | logic [3:0][7:0] p; | logic [7:0] u [0:3]; |
| Whole value | A 32-bit packed quantity | An array of four byte elements |
| Typical purpose | Bit fields and buses | Collections of words or records |

Both examples contain 32 bits, but their types and
whole-value operations differ.

## How to Remember

"Before the name: bits. After the name: elements."

logic [7:0] data [0:3];

- Eight bits per element.
- Four elements.

For a matrix:

matrix[row][column]

For a bit inside a matrix element:

matrix[row][column][bit]

For flattening a row-and-column position:

index = row * number_of_columns + column