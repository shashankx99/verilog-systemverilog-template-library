# Template 50: Packages

## Purpose

A package groups declarations that can be shared across
multiple modules, interfaces, classes, or other scopes.

This example shares:
- A data-width constant.
- An eight-bit data type.
- A packed transaction type.
- An even-parity function.

The example module uses these declarations to assemble
a transaction and calculate its parity bit.

It describes combinational logic and needs no clock or reset.

## Package Contents

| Declaration | Name | Purpose |
|---|---|---|
| Constant | DATA_WIDTH | Defines the data width as 8 |
| Type alias | data_t | Names an eight-bit logic vector type |
| Packed structure | transaction_t | Groups address, data, and write flag |
| Function | even_parity() | Generates an even-parity bit |

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| addr_in | Input | 8 bits | Transaction address |
| data_in | Input | 8 bits | Transaction data |
| write_in | Input | 1 bit | Write flag |
| data_out | Output | 8 bits | Data extracted from the transaction |
| parity_out | Output | 1 bit | Even-parity bit for the data |
| packed_out | Output | 17 bits | Complete packed transaction |

## Short Explanation

The package defines reusable names once.

The module accesses them in two ways:

1. Explicit qualification:

template_pkg::data_t

2. Import followed by an unqualified name:

import template_pkg::*;
transaction_t transaction;

A package is not instantiated like a module.
It supplies declarations rather than a hardware instance.

## Packed Transaction Layout

The structure contains:

8 address bits + 8 data bits + 1 write bit = 17 bits

| Field | Position in packed_out |
|---|---|
| transaction.addr | [16:9] |
| transaction.data | [8:1] |
| transaction.write | [0] |

The first declared field occupies the most significant bits.

## Small Example

Let:

addr_in  = 8'h12
data_in  = 8'hA5
write_in = 1'b1

The transaction contains:

transaction.addr  = 8'h12
transaction.data  = 8'hA5
transaction.write = 1'b1

Outputs:

| Output | Value |
|---|---|
| data_out | 8'hA5 |
| parity_out | 1'b0 |
| packed_out | {8'h12, 8'hA5, 1'b1} |

A5 in binary is 10100101, which contains four 1s.
Because that count is already even, the even-parity bit is 0.

## SystemVerilog Code

```systemverilog
package template_pkg;

    localparam int DATA_WIDTH = 8;

    typedef logic [DATA_WIDTH-1:0] data_t;

    typedef struct packed {
        logic [7:0] addr;
        data_t      data;
        logic       write;
    } transaction_t;

    function automatic logic even_parity(input data_t value);
        return ^value;
    endfunction

endpackage


module packages_example (
    input  logic [7:0]             addr_in,
    input  template_pkg::data_t    data_in,
    input  logic                   write_in,
    output template_pkg::data_t    data_out,
    output logic                  parity_out,
    output logic [16:0]            packed_out
);

    import template_pkg::*;

    transaction_t transaction;

    always_comb begin
        transaction = '{
            addr:  addr_in,
            data:  data_in,
            write: write_in
        };

        data_out   = transaction.data;
        parity_out = even_parity(transaction.data);
        packed_out = transaction;
    end

endmodule
```

## Code Explanation

### 1. Package definition

`package template_pkg; ... endpackage`

Creates a named scope containing shared declarations.

This package is placed before the module that uses it.

### 2. Shared constant

`localparam int DATA_WIDTH = 8;`

Defines the data width used by data_t.

A package is not parameterized through module-style
instance overrides such as #(.DATA_WIDTH(...)).

In this template, packed_out is explicitly 17 bits.
If the package's data width is changed, that output
width and its documented mapping must also be updated.

### 3. Shared type

`typedef logic [DATA_WIDTH-1:0] data_t;`

Defines a reusable vector type.

Using the same package type helps keep declarations
consistent across modules.

### 4. Shared structure

`transaction_t`

Groups the address, data, and write flag into one
packed type.

Modules can declare their own variables of this type.
Those variables are separate objects of the same type.

### 5. Shared function

```systemverilog
function automatic logic even_parity(input data_t value);
    return ^value;
endfunction
```

Returns the reduction XOR of the data bits.

The result is the parity bit needed to make the
combined data-and-parity count of 1s even.

### 6. Scope resolution

`template_pkg::data_t`

Uses the :: scope-resolution operator to identify
the type inside template_pkg.

This explicit form is used in the module port list
because the import inside the module body does not
apply to preceding port declarations.

### 7. Wildcard import

`import template_pkg::*;`

Makes package names available for unqualified lookup
in the importing scope.

It does not copy the declarations or instantiate hardware.

After importing, the module can write:

transaction_t transaction;
even_parity(transaction.data);

### 8. Selective import

Instead of a wildcard import, specific names can be imported:

```systemverilog
import template_pkg::transaction_t;
import template_pkg::even_parity;
```

Selective imports or explicit qualification help avoid
ambiguity when packages contain identical names.

### 9. Compilation order

The package must be available before code that references it.

This single file places the package first.

If separated into files, compile the package file before
the module files that use it.

Do not define the same package repeatedly by including
its source in every module.

## Package Versus Module

| Feature | Package | Module |
|---|---|---|
| Main purpose | Share declarations | Describe a design component |
| Instantiated | No | Yes |
| Hardware ports | No | Yes |
| Typical contents | Types, constants, functions, classes | Ports, signals, logic, instances |
| Access | import or package_name::member | Instance connections |

## How to Remember

"Package once, use in many places."

DEFINE:
package template_pkg;

ACCESS EXPLICITLY:
template_pkg::data_t

OR IMPORT:
import template_pkg::*;

A package shares definitions.
Each module can use those definitions for its own signals.