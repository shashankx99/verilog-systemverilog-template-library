# Template 46: Constrained Randomization

## Purpose

Constrained randomization generates values that satisfy
specified rules.

It is useful for creating varied, legal stimulus in
verification environments.

This example generates packet fields with:
- A limited address range.
- Four-byte address alignment.
- A length between 1 and 8.
- Data rules depending on whether the packet is a write.

This is a simulation-only verification example.

## Randomized Properties

| Property | Type | Rule |
|---|---|---|
| addr | Eight-bit unsigned value | 0x10 through 0x3F, aligned to four bytes |
| data | Eight-bit unsigned value | Nonzero for writes; zero otherwise |
| write | One bit | 0 or 1 |
| length | Unsigned integer | 1 through 8 |

## Short Explanation

Declaring a property rand makes it eligible for
class randomization.

Calling randomize() asks the constraint solver to
choose values satisfying all active constraints.

Constraints describe relationships, not a sequence
of procedural assignments.

The randomize() method returns:
- 1 when successful.
- 0 when it cannot satisfy the constraints.

Always check this return value before using the results.

## Rules Table

| Constraint | Meaning |
|---|---|
| addr inside {[8'h10:8'h3F]} | Address is within the inclusive range |
| addr[1:0] == 2'b00 | Address is a multiple of four |
| length inside {[1:8]} | Length is from 1 through 8 |
| write = 1 implies data != 0 | Write packets contain nonzero data |
| write = 0 implies data == 0 | Non-write packets contain zero data |

The allowed addresses are:

10, 14, 18, 1C, 20, 24, 28, 2C, 30, 34, 38, 3C

These addresses are written in hexadecimal.

## Small Example

These are examples of legal generated values:

| addr, hex | data, hex | write | length |
|---|---|---|---|
| 10 | 00 | 0 | 3 |
| 2C | A5 | 1 | 8 |
| 38 | 01 | 1 | 1 |

Examples that violate the constraints:

| Example | Reason |
|---|---|
| addr = 12 hex | Not aligned to four bytes |
| addr = 40 hex | Outside the allowed range |
| length = 0 | Below the minimum |
| write = 1, data = 00 | Write data must be nonzero |

These are illustrative values, not a predicted random sequence.

## SystemVerilog Code

```systemverilog
class constrained_packet;

    rand bit [7:0] addr;
    rand bit [7:0] data;
    rand bit       write;
    rand int unsigned length;

    constraint c_addr {
        addr inside {[8'h10:8'h3F]};
        addr[1:0] == 2'b00;
    }

    constraint c_length {
        length inside {[1:8]};
    }

    constraint c_data {
        if (write)
            data != 8'h00;
        else
            data == 8'h00;
    }

    function void display();
        $display("addr=%02h data=%02h write=%0b length=%0d",
                 addr, data, write, length);
    endfunction

endclass


module constrained_randomization_example;

    constrained_packet pkt;

    initial begin
        pkt = new();

        repeat (5) begin
            if (!pkt.randomize())
                $fatal(1, "Packet randomization failed");

            pkt.display();
        end

        if (!pkt.randomize() with {
            write  == 1'b1;
            length == 4;
        })
            $fatal(1, "Inline randomization failed");

        $display("Packet with inline constraints:");
        pkt.display();
    end

endmodule
```

## Expected Behavior

The first five successful calls each produce a packet
satisfying all class constraints.

Values can repeat. Five calls do not guarantee that
every address, length, or operation is exercised.

The final call additionally requires:
- write = 1.
- length = 4.

Its address must still be aligned and within range.
Its data must still be nonzero.

Exact values depend on the random seed, tool, and
randomization context.

## Code Explanation

### 1. rand properties

`rand bit [7:0] addr;`

Declares a property whose value can be selected by
randomize().

rand does not automatically change the property:
a randomization call is required.

### 2. Named constraint blocks

`constraint c_addr { ... }`

Groups related requirements under a name.

All enabled constraint blocks apply together.

### 3. inside operator

`length inside {[1:8]};`

Requires length to belong to the inclusive range 1 to 8.

The square brackets express the range within the set braces.

### 4. Alignment constraint

`addr[1:0] == 2'b00;`

Requires the two least significant bits to be zero.

This makes the address divisible by four.

### 5. Conditional constraint

```systemverilog
if (write)
    data != 8'h00;
else
    data == 8'h00;
```

Describes a relationship between write and data.

It does not mean the solver first chooses write and
then procedurally assigns data.

### 6. Creating the object

`pkt = new();`

Constructs the packet object.

There is no explicit constructor, so the class uses
its implicit constructor.

### 7. Checking success

```systemverilog
if (!pkt.randomize())
    $fatal(1, "Packet randomization failed");
```

Stops the example if randomization fails, preventing
the code from reporting a failed result as a valid packet.

### 8. Inline constraints

```systemverilog
pkt.randomize() with {
    write  == 1'b1;
    length == 4;
}
```

Adds constraints for that call only.

Inline constraints do not automatically override the
class constraints; they must be compatible with them.

For example, forcing length == 10 would conflict with
the class range 1 through 8 and cause failure.

### 9. Distribution

Legal values are constrained, but this example does not
request an equal balance of reads and writes.

Relationships between randomized variables can affect
their distributions. Do not assume write will be 0
and 1 equally often.

## How to Remember

"rand marks the fields; constraints set the rules;
randomize chooses the values."

1. Declare rand properties.
2. Write legal-value constraints.
3. Construct the object.
4. Call randomize().
5. Check success.
6. Use the generated values.

Inside constraints:

== means require equality.
It is not an assignment.