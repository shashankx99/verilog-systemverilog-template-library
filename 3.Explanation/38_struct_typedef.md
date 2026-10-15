# Template 38: Structures and typedef

## Purpose

A structure groups related fields into one object.

Each field has a name and a data type, making related
information easier to organize and access.

typedef gives the structure type a reusable name.

This example groups a packet's address, data, and
write flag into a packed structure.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| addr_in | Input | 8 bits | Incoming address |
| data_in | Input | 16 bits | Incoming data |
| write_in | Input | 1 bit | Incoming write flag |
| addr_out | Output | 8 bits | Address extracted from the structure |
| data_out | Output | 16 bits | Data extracted from the structure |
| write_out | Output | 1 bit | Write flag extracted from the structure |
| packed_out | Output | 25 bits | Complete structure as a packed vector |

This template is combinational and needs no clock or reset.

## Short Explanation

The structure contains three fields:

- addr: 8 bits.
- data: 16 bits.
- write: 1 bit.

Total width:

8 + 16 + 1 = 25 bits

Because the structure is packed, its fields form one
contiguous packed value.

The first declared field occupies the most significant bits.

## Structure Definition

```systemverilog
typedef struct packed {
    logic [7:0]  addr;
    logic [15:0] data;
    logic        write;
} packet_t;
```

packet_t is the type name.

To declare a variable of that type:

```systemverilog
packet_t packet;
```

packet is the variable containing the fields.

## Field Mapping

| Field | Width | Position in packed_out |
|---|---|---|
| packet.addr | 8 bits | [24:17] |
| packet.data | 16 bits | [16:1] |
| packet.write | 1 bit | [0] |

The complete packed representation is equivalent to:

{packet.addr, packet.data, packet.write}

## Small Example

Let:

addr_in  = 8'h12
data_in  = 16'hABCD
write_in = 1'b1

The structure contains:

packet.addr  = 8'h12
packet.data  = 16'hABCD
packet.write = 1'b1

The outputs are:

| Output | Value |
|---|---|
| addr_out | 8'h12 |
| data_out | 16'hABCD |
| write_out | 1'b1 |
| packed_out | {8'h12, 16'hABCD, 1'b1} |

The packed output is 25 bits, not 24 bits, because
the write flag adds one more bit.

## SystemVerilog Code

```systemverilog
module struct_typedef_example (
    input  logic [7:0]  addr_in,
    input  logic [15:0] data_in,
    input  logic        write_in,
    output logic [7:0]  addr_out,
    output logic [15:0] data_out,
    output logic        write_out,
    output logic [24:0] packed_out
);

    typedef struct packed {
        logic [7:0]  addr;
        logic [15:0] data;
        logic        write;
    } packet_t;

    packet_t packet;

    always_comb begin
        packet = '{
            addr:  addr_in,
            data:  data_in,
            write: write_in
        };

        addr_out   = packet.addr;
        data_out   = packet.data;
        write_out  = packet.write;
        packed_out = packet;
    end

endmodule
```

## Code Explanation

### 1. struct

`struct`

Groups multiple named fields into one type.

The fields can have different widths.

### 2. packed

`struct packed`

Makes the structure behave as one packed bit vector
as well as a collection of named fields.

Packed structures require members that are permitted
packed data types. Dynamic arrays and strings cannot
be placed inside a packed structure.

### 3. typedef

`typedef ... packet_t;`

Defines the type name packet_t.

It does not create a packet variable by itself.

`packet_t packet;`

Creates the variable using that type.

The _t suffix is a naming convention, not a requirement.

### 4. Named assignment pattern

```systemverilog
packet = '{
    addr:  addr_in,
    data:  data_in,
    write: write_in
};
```

The apostrophe followed by braces introduces an
assignment pattern.

Each field is assigned by its name, so the intended
mapping is explicit.

This differs from ordinary concatenation:

- '{ ... } is an assignment pattern.
- { ... } is a concatenation.

### 5. Dot operator

`packet.addr`

Accesses a field by name.

Other examples:

packet.data
packet.write

Individual bits within a field can also be selected:

packet.data[7:0]

This selects the lower byte of the data field.

### 6. Whole-structure assignment

`packed_out = packet;`

Copies the packed structure into an equally wide vector.

The field order determines the bit layout.

### 7. Combinational ordering

The block assigns packet before reading its fields.

Blocking assignments ensure the following statements
use the newly assigned field values within this execution.

Every field and output is assigned on every path.

## Packed and Unpacked Structures

| Feature | struct packed | struct |
|---|---|---|
| Field access with dot notation | Yes | Yes |
| Defined contiguous packed bit layout | Yes | No |
| Direct treatment as a packed vector | Yes | No |
| Can contain fields such as strings | No | Yes |

For example, a student record with a string name would
use an unpacked structure:

```systemverilog
typedef struct {
    string name;
    int    marks;
} student_t;
```

A structure containing a string is suited to
verification or programming examples, not ordinary
synthesizable RTL.

## How to Remember

"struct groups; typedef names; dot accesses."

1. Group the fields using struct.
2. Name the type using typedef.
3. Declare a variable using the type.
4. Access fields with variable.field.

For this example:

TYPE     → packet_t
VARIABLE → packet
FIELD    → packet.addr

For a packed structure:

First declared field → most significant bits.