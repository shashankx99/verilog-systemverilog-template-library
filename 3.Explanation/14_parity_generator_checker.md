# Template 14: Parity Generator and Checker

## Purpose

A parity bit is an extra bit used to help detect data errors.

This template:
- Generates an even-parity bit for the input data.
- Checks the input data against a received parity bit.

WIDTH defaults to 4 and must be a positive integer.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| data | Input | WIDTH bits | Data for generation or checking |
| parity_in | Input | 1 bit | Received parity bit |
| parity_out | Output | 1 bit | Generated even-parity bit |
| parity_error | Output | 1 bit | 1 when the even-parity check fails |

The generator and checker share the data input.
parity_in affects only the checker.

## Short Explanation

Even parity means the total number of 1s in the data
and its parity bit must be even.

- Data contains an even number of 1s → parity bit = 0.
- Data contains an odd number of 1s → parity bit = 1.

The checker XORs the data bits and received parity bit.

- Result 0 → the combination satisfies even parity.
- Result 1 → the combination fails even parity.

This is combinational logic. No clock or reset is required.

## Parity Generation Table

| Number of 1s in data | parity_out |
|---|---|
| Even, including zero | 0 |
| Odd | 1 |

## Parity Checking Table

| XOR of data bits | parity_in | parity_error |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

These tables assume binary inputs.

## Small Example

### Generate Parity

Let data = 4'b1011.

The data contains three 1s, which is odd.

Therefore:

parity_out = 1

The data and parity bit together contain four 1s,
satisfying even parity.

### Check Correct Data

Received data = 1011
Received parity_in = 1

parity_error = (1 ^ 0 ^ 1 ^ 1) ^ 1
             = 1 ^ 1
             = 0

The check passes.

### Detect a Single-Bit Error

Suppose the data changes from 1011 to 1001 during
transfer, while the received parity bit remains 1.

parity_error = (1 ^ 0 ^ 0 ^ 1) ^ 1
             = 0 ^ 1
             = 1

The checker detects an error.

## Verilog Code

```verilog
module parity_generator_checker #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] data,
    input  wire             parity_in,
    output wire             parity_out,
    output wire             parity_error
);

    // Generate even parity
    assign parity_out = ^data;

    // Check data against the received parity bit
    assign parity_error = (^data) ^ parity_in;

endmodule
```

## Code Explanation

### 1. Parameterized data width

`parameter WIDTH = 4`

Sets the default data width to four bits.

For an eight-bit instance, use:

`parity_generator_checker #(.WIDTH(8))`

### 2. Reduction XOR

`^data`

XORs every bit of data into one result bit.

For WIDTH = 4, it is equivalent to:

data[3] ^ data[2] ^ data[1] ^ data[0]

The result is 1 when an odd number of bits are 1.

### 3. Generate even parity

`assign parity_out = ^data;`

When the data contains an odd number of 1s, an extra
1 makes the total even.

When the data already contains an even number of 1s,
the extra bit is 0.

### 4. Check received parity

`assign parity_error = (^data) ^ parity_in;`

The first ^ is a reduction operator acting on the vector.
The second ^ XORs two one-bit values.

parity_in must be the parity bit received with the data.
Recomputing it from potentially corrupted data and feeding
that result back would defeat the error check.

### 5. Continuous operation

Both assign statements operate concurrently.

The outputs respond to input changes without waiting
for a clock edge.

Unknown or high-impedance input bits can cause the
XOR result to become unknown.

### 6. Detection limits

Parity detects any odd number of bit flips across
the data and parity bit.

An even number of bit flips can pass undetected.
Therefore, parity_error = 0 does not prove that the
received data is unchanged.

Parity cannot identify the faulty bit or correct it.

## How to Remember

"Even parity makes the total number of 1s even."

GENERATE → XOR all data bits.
CHECK → XOR all data bits and the received parity bit.

Generator:
parity_out = ^data;

Checker:
parity_error = (^data) ^ parity_in;

For even parity, a checker result of 1 means failure.