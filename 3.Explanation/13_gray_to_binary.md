# Template 13: Gray-to-Binary Converter

## Purpose

This circuit converts a four-bit binary-reflected Gray code
into its corresponding binary value.

It performs the reverse operation of Template 12.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| gray | Input | 4 bits | Gray-code input |
| binary | Output | 4 bits | Corresponding binary value |

## Short Explanation

The most significant binary bit equals the most significant
Gray bit.

Each remaining binary bit is the XOR of all Gray bits
from the most significant position down to that position.

binary[3] = gray[3]
binary[2] = gray[3] ^ gray[2]
binary[1] = gray[3] ^ gray[2] ^ gray[1]
binary[0] = gray[3] ^ gray[2] ^ gray[1] ^ gray[0]

No clock or reset is required because this is combinational logic.

## Conversion Table

| Gray input | Binary output | Decimal value |
|---|---|---|
| 0000 | 0000 | 0 |
| 0001 | 0001 | 1 |
| 0011 | 0010 | 2 |
| 0010 | 0011 | 3 |
| 0110 | 0100 | 4 |
| 0111 | 0101 | 5 |
| 0101 | 0110 | 6 |
| 0100 | 0111 | 7 |
| 1100 | 1000 | 8 |
| 1101 | 1001 | 9 |
| 1111 | 1010 | 10 |
| 1110 | 1011 | 11 |
| 1010 | 1100 | 12 |
| 1011 | 1101 | 13 |
| 1001 | 1110 | 14 |
| 1000 | 1111 | 15 |

The rows are ordered by the decoded binary value.

## Small Example

Let gray = 4'b1110.

Calculate each binary bit:

- binary[3] = 1
- binary[2] = 1 ^ 1 = 0
- binary[1] = 1 ^ 1 ^ 1 = 1
- binary[0] = 1 ^ 1 ^ 1 ^ 0 = 1

Therefore:

binary = 4'b1011 = decimal 11

This reverses the example in Template 12, where binary
1011 was converted to Gray code 1110.

## Verilog Code

```verilog
module gray_to_binary (
    input  wire [3:0] gray,
    output wire [3:0] binary
);

    assign binary[3] = gray[3];
    assign binary[2] = gray[3] ^ gray[2];
    assign binary[1] = gray[3] ^ gray[2] ^ gray[1];
    assign binary[0] = gray[3] ^ gray[2] ^ gray[1] ^ gray[0];

endmodule
```

## Code Explanation

### 1. Four-bit ports

`input wire [3:0] gray`
`output wire [3:0] binary`

Declare four-bit input and output vectors.
Bit 3 is the most significant bit; bit 0 is the least significant.

### 2. Preserve the top bit

`assign binary[3] = gray[3];`

The most significant bit stays unchanged during conversion.

### 3. XOR progressively more Gray bits

`assign binary[2] = gray[3] ^ gray[2];`

Uses the top two Gray bits.

`assign binary[1] = gray[3] ^ gray[2] ^ gray[1];`

Uses the top three Gray bits.

`assign binary[0] = gray[3] ^ gray[2] ^ gray[1] ^ gray[0];`

Uses all four Gray bits.

### 4. Continuous assignments

All four assign statements operate concurrently.
Their order in the file does not create a sequence of
clocked operations.

## How to Remember

"Keep the top bit, then keep including the next Gray bit."

- First binary bit: one Gray bit.
- Second binary bit: XOR two Gray bits.
- Third binary bit: XOR three Gray bits.
- Fourth binary bit: XOR four Gray bits.

Binary-to-Gray uses neighboring binary bits.
Gray-to-binary uses cumulative XOR from the top Gray bit.