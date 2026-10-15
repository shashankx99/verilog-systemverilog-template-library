# Template 12: Binary-to-Gray Converter

## Purpose

This circuit converts an unsigned binary number into
binary-reflected Gray code.

Consecutive values in the Gray-code sequence differ
by exactly one bit.

WIDTH sets the number of bits.
It defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| binary | Input | WIDTH bits | Binary number to convert |
| gray | Output | WIDTH bits | Corresponding Gray-code value |

## Short Explanation

To convert binary to Gray code:

1. Keep the most significant bit unchanged.
2. Generate each remaining Gray bit by XORing the
   corresponding binary bit with the binary bit above it.

For a four-bit input:

gray[3] = binary[3]
gray[2] = binary[3] ^ binary[2]
gray[1] = binary[2] ^ binary[1]
gray[0] = binary[1] ^ binary[0]

All these operations can be written in one expression:

gray = binary ^ (binary >> 1)

No clock or reset is required because this is combinational logic.

## Conversion Table

For WIDTH = 3:

| Decimal input | Binary | Gray |
|---|---|---|
| 0 | 000 | 000 |
| 1 | 001 | 001 |
| 2 | 010 | 011 |
| 3 | 011 | 010 |
| 4 | 100 | 110 |
| 5 | 101 | 111 |
| 6 | 110 | 101 |
| 7 | 111 | 100 |

Moving between adjacent rows changes exactly one Gray bit.

This property applies to consecutive binary values.
An arbitrary jump between binary values can change
multiple Gray bits.

## Small Example

Let WIDTH = 4 and binary = 4'b1011.

Step 1: Shift binary right by one bit.

binary      = 1011
binary >> 1 = 0101

Step 2: XOR the two values.

  1011
^ 0101
------
  1110

Therefore, gray = 4'b1110.

Bit-by-bit calculation:

- gray[3] = 1
- gray[2] = 1 XOR 0 = 1
- gray[1] = 0 XOR 1 = 1
- gray[0] = 1 XOR 1 = 0


## How to Remember

"Shift right, then XOR."

gray = binary ^ (binary >> 1)

For manual conversion:

"Keep the top bit; XOR neighboring binary bits."

Always use the original binary bits when calculating
each Gray bit.