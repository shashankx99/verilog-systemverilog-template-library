# Template 49: Interfaces and Modports

## Purpose

An interface groups related signals into one named connection.

Modports define how a connected module accesses those signals.

This example connects:
- A source that presents data and valid.
- A sink that supplies ready and captures accepted data.

The interface uses an eight-bit data path and a
valid/ready handshake.

The receiver uses a synchronous active-high reset.

## Interface Signals

| Signal | Width | Driven by | Meaning |
|---|---|---|---|
| data | 8 bits | Source | Word being offered |
| valid | 1 bit | Source | Source is offering a valid word |
| ready | 1 bit | Sink | Sink can accept a word |

A transfer occurs at a rising clock edge when both
valid and ready are high, with reset inactive.

## Modport Directions

Directions are written from the connected module's perspective.

| Signal | source modport | sink modport |
|---|---|---|
| data | output | input |
| valid | output | input |
| ready | input | output |

The source drives data and valid, but reads ready.

The sink reads data and valid, but drives ready.

## Top-Level Inputs and Outputs

| Signal | Direction | Meaning |
|---|---|---|
| clk | Input | Rising-edge receiver clock |
| rst | Input | Synchronous active-high receiver reset |
| data_in | Input | Word offered by the external source |
| valid_in | Input | Indicates the offered word is valid |
| accept | Input | Allows the sink to accept data |
| ready_out | Output | Indicates acceptance is currently allowed |
| received_data | Output | Most recently captured word |
| received_valid | Output | Indicates a transfer at the preceding edge |

received_valid is updated after each rising edge.
It can stay high across consecutive successful transfers.

## Short Explanation

The source adapter passes data_in and valid_in into
the interface. It returns ready to the external source.

The sink drives:

ready = accept AND NOT rst

At each rising edge, the sink:
- Clears its outputs if reset is high.
- Otherwise captures data if valid and ready are both high.
- Records whether a transfer occurred in received_valid.

When no transfer occurs, received_data holds its value
and received_valid becomes zero.

The source adapter does not buffer data.

## Handshake Table

With reset inactive, at a rising clock edge:

| valid | ready | Transfer? | Receiver action |
|---|---|---|---|
| 0 | 0 | No | Hold data, clear received_valid |
| 0 | 1 | No | Hold data, clear received_valid |
| 1 | 0 | No | Hold data, clear received_valid |
| 1 | 1 | Yes | Capture data, set received_valid |

The external source must hold valid and data stable
while a word is waiting for acceptance.

After a successful transfer, it may present the next
word or deassert valid.

If valid and ready remain high at consecutive edges,
each edge represents a separate transfer.

## Small Example

Values are shown after each rising edge.

| Edge | rst | valid_in | accept | data_in | received_data | received_valid |
|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 00 | 00 | 0 |
| 2 | 0 | 1 | 0 | A5 | 00 | 0 |
| 3 | 0 | 1 | 1 | A5 | A5 | 1 |
| 4 | 0 | 1 | 1 | 3C | 3C | 1 |
| 5 | 0 | 0 | 1 | 00 | 3C | 0 |

Data values are hexadecimal.

At edge 2, the source must keep A5 pending because
the sink is not ready.

At edge 3, the word is accepted.

## SystemVerilog Code

```systemverilog
interface data_if;

    logic [7:0] data;
    logic       valid;
    logic       ready;

    modport source (
        output data, valid,
        input  ready
    );

    modport sink (
        input  data, valid,
        output ready
    );

endinterface


module interface_source (
    input  logic [7:0] data_in,
    input  logic       valid_in,
    output logic       ready_out,
    data_if.source     link
);

    assign link.data  = data_in;
    assign link.valid = valid_in;
    assign ready_out = link.ready;

endmodule


module interface_sink (
    input  logic       clk,
    input  logic       rst,
    input  logic       accept,
    output logic [7:0] received_data,
    output logic       received_valid,
    data_if.sink       link
);

    assign link.ready = accept && !rst;

    always_ff @(posedge clk) begin
        if (rst) begin
            received_data  <= '0;
            received_valid <= 1'b0;
        end
        else begin
            received_valid <= link.valid && link.ready;

            if (link.valid && link.ready)
                received_data <= link.data;
        end
    end

endmodule


module interfaces_modports_example (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] data_in,
    input  logic       valid_in,
    input  logic       accept,
    output logic       ready_out,
    output logic [7:0] received_data,
    output logic       received_valid
);

    data_if link();

    interface_source source_inst (
        .data_in   (data_in),
        .valid_in  (valid_in),
        .ready_out (ready_out),
        .link      (link)
    );

    interface_sink sink_inst (
        .clk            (clk),
        .rst            (rst),
        .accept         (accept),
        .received_data  (received_data),
        .received_valid (received_valid),
        .link           (link)
    );

endmodule
```

## Code Explanation

### 1. Interface definition

`interface data_if; ... endinterface`

Defines a group of related signals.

The definition is a type of connection.
An instance is still needed to connect modules.

### 2. Interface instance

`data_if link();`

Creates one interface instance named link.

Both modules connect to this same instance.

### 3. Modport declaration

```systemverilog
modport source (
    output data, valid,
    input ready
);
```

Defines the source module's access directions.

A modport does not create separate copies of the signals.

### 4. Modport-qualified port

`data_if.source link`

Declares an interface port using the source view.

`data_if.sink link`

Declares a port using the sink view.

### 5. Member access

`link.data`
`link.valid`
`link.ready`

Dot notation accesses the interface signals.

### 6. Source adapter

Continuous assignments forward the offered data and
valid signal, and return the ready signal.

There is no internal queue or register in the source.

### 7. Receiver capture

`if (link.valid && link.ready)`

Allows capture only when both sides agree to transfer.

The registered data remains unchanged otherwise.

### 8. Reset behavior

The stored receiver outputs clear only at a rising
edge with rst high.

ready is separately gated by rst through combinational
logic, so asserting rst lowers ready without waiting
for a clock edge.

### 9. What modports do not provide

Modports specify signal access directions.
They do not enforce handshake timing, synchronize
clock domains, or create storage automatically.

All inputs in this example are assumed to obey the
receiver clock's timing requirements.

## How to Remember

"Interface bundles; modport defines the view."

SOURCE:
Drive DATA and VALID.
Read READY.

SINK:
Read DATA and VALID.
Drive READY.

Transfer rule:

VALID AND READY at the clock edge.