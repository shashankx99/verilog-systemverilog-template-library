# Template 35: Single-Port Synchronous RAM

## Purpose

RAM stores data words that can be accessed using an address.

This template implements a single-port synchronous RAM:
- One shared address port.
- Clocked writes.
- Clocked reads with a registered output.
- Enable control.
- Output holds during writes and when disabled.

There is no reset or initialization in this template.

## Parameters

| Parameter | Default | Meaning |
|---|---|---|
| DATA_WIDTH | 8 | Bits per memory word |
| ADDR_WIDTH | 4 | Bits in the address |

The number of memory locations is:

DEPTH = 2^ADDR_WIDTH

With the default parameters:
- 16 locations.
- 8 bits per location.
- 128 bits of total storage.

DATA_WIDTH and ADDR_WIDTH must be positive integers.
Keep ADDR_WIDTH within a practical range; DEPTH is
represented by an int and memory size grows exponentially.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Rising-edge clock |
| en | Input | 1 bit | Enables memory access |
| we | Input | 1 bit | 1 selects write; 0 selects read |
| addr | Input | ADDR_WIDTH bits | Address to access |
| din | Input | DATA_WIDTH bits | Data to write |
| dout | Output | DATA_WIDTH bits | Last successfully read word |

## Short Explanation

At each rising clock edge:

1. If en = 0, perform no access.
2. If en = 1 and we = 1, write din into mem[addr].
3. If en = 1 and we = 0, read mem[addr] into dout.

Changing addr alone does not update dout.
A read requires an enabled rising clock edge.

The read and write branches are mutually exclusive.
This template does not perform both operations at once.

## Operation Table

| Event | en | we | Memory action | dout action |
|---|---|---|---|---|
| Rising edge | 0 | - | No change | Hold |
| Rising edge | 1 | 1 | Write din at addr | Hold |
| Rising edge | 1 | 0 | Read location addr | Capture mem[addr] |
| No rising edge | - | - | No change | Hold |

The symbol - means either binary value.

During a write, dout does not automatically show either
the newly written word or the old word at that address.
It retains the last read result.

## Small Example

Use the default 8-bit data and 4-bit address widths.

Hexadecimal notation is used for data.

| Edge | en | we | addr | din | Action | dout after edge |
|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 3 | 8'hA5 | Write A5 to location 3 | Unknown initially |
| 2 | 1 | 1 | 7 | 8'h3C | Write 3C to location 7 | Still unknown |
| 3 | 1 | 0 | 3 | Unused | Read location 3 | A5 |
| 4 | 0 | 0 | 7 | Unused | Disabled | A5 |
| 5 | 1 | 0 | 7 | Unused | Read location 7 | 3C |
| 6 | 1 | 1 | 7 | 8'hF0 | Replace location 7 with F0 | 3C |
| 7 | 1 | 0 | 7 | Unused | Read location 7 | F0 |

A write updates memory.
A later read updates dout.

## SystemVerilog Code

```systemverilog
module single_port_ram #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 4
)(
    input  logic                  clk,
    input  logic                  en,
    input  logic                  we,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    localparam int DEPTH = 2 ** ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (en) begin
            if (we)
                mem[addr] <= din;
            else
                dout <= mem[addr];
        end
    end

endmodule
```

## Code Explanation

### 1. Memory depth

`localparam int DEPTH = 2 ** ADDR_WIDTH;`

The ** operator means exponentiation.

For ADDR_WIDTH = 4:

DEPTH = 2^4 = 16

Valid binary addresses range from 0 through 15.

### 2. Memory declaration

`logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];`

The packed dimension before mem defines each word's bits.

The unpacked dimension after mem defines the array
of memory locations.

For the default settings, mem[3] is one eight-bit word.

### 3. Synchronous access

`always_ff @(posedge clk)`

Performs accesses at the rising clock edge.

The address and control inputs must meet timing
requirements around that edge.

### 4. Enable

`if (en)`

Allows an access only when en is high.

When en is low, neither memory nor dout is updated.

### 5. Write operation

`mem[addr] <= din;`

Stores the input data at the selected address.

Only that location is changed.

### 6. Read operation

`dout <= mem[addr];`

Captures the addressed word into dout after the
read edge's nonblocking update.

The output then holds until another accepted read.

### 7. Write output behavior

The write branch does not assign dout.

Therefore, writes preserve the previous output value.
This is often described as no-change output behavior
during writes.

### 8. Initialization

Neither memory nor dout is initialized.

In a typical RTL simulation, they begin as unknown.
Write a known value to a location before expecting
a known value from reading it.

Physical power-up contents are device-dependent and
are not specified by this template.

### 9. Hardware mapping

The code describes RAM behavior, but the synthesized
implementation depends on the target device and tool.

It may map to a memory block or other storage resources.
This source alone does not guarantee a specific RAM primitive.

## How to Remember

"Enable, then choose write or read."

EN = 0 → hold
EN = 1 and WE = 1 → memory gets data
EN = 1 and WE = 0 → output gets memory

Write:
mem[addr] <= din;

Read:
dout <= mem[addr];

Both operations happen at the clock edge.