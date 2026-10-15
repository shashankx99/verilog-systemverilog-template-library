# Template 39: Dynamic Arrays

## Purpose

A dynamic array is an unpacked array whose size can
be chosen and changed during execution.

This example demonstrates:
- Declaration.
- Allocation.
- Element initialization.
- Resizing while preserving data.
- Independent copying of integer elements.
- Deletion.

It is a simulation-only programming example, not
synthesizable RTL.

## Declaration

```systemverilog
int data[];
```

The empty brackets after the name declare a dynamic array.

- int is the element type.
- data is the array name.
- [] means its size is determined during execution.

Before allocation, the array has zero elements.

## Operations Table

| Operation | Syntax | Meaning |
|---|---|---|
| Allocate | data = new[4]; | Create four elements |
| Read element | data[2] | Access element at index 2 |
| Write element | data[2] = 30; | Update one element |
| Get size | data.size() | Return the number of elements |
| Grow and preserve | data = new[6](data); | Resize to six and copy old values |
| Copy | copied = data; | Copy the integer array |
| Shrink and preserve | data = new[3](data); | Keep the first three elements |
| Delete | data.delete(); | Remove all elements |

After allocation, valid indices run from 0 through
data.size() - 1.

## Short Explanation

A dynamic array's length does not automatically increase
when an out-of-range index is accessed.

Use new[size] to allocate or resize it.

There are two important allocation forms:

```systemverilog
data = new[6];
```

Creates six fresh elements without preserving the
old array contents.

```systemverilog
data = new[6](data);
```

Creates six elements and copies the existing array
contents into the new array.

The number of copied elements is the smaller of the
old and new sizes.

## Small Example

Start with:

data = [10, 20, 30, 40]

After:

```systemverilog
data = new[6](data);
```

The array contains:

[10, 20, 30, 40, 0, 0]

The additional elements are initialized to the default
value of int, which is 0.

After assigning the new elements:

data[4] = 50
data[5] = 60

The array becomes:

[10, 20, 30, 40, 50, 60]

After:

```systemverilog
data = new[3](data);
```

The array contains:

[10, 20, 30]

The remaining elements are discarded.

## SystemVerilog Code

```systemverilog
module dynamic_arrays_example;

    int data[];
    int copied[];

    initial begin
        data = new[4];

        foreach (data[i])
            data[i] = (i + 1) * 10;

        $display("Initial: %p", data);
        $display("Size: %0d", data.size());

        data = new[6](data);
        data[4] = 50;
        data[5] = 60;

        $display("After growing: %p", data);

        copied = data;
        copied[0] = 99;

        $display("Original: %p", data);
        $display("Copy: %p", copied);

        data = new[3](data);

        $display("After shrinking: %p", data);

        data.delete();

        $display("Size after delete: %0d", data.size());
        $display("Copy remains: %p", copied);
    end

endmodule
```

## Expected Results

The values should appear as follows; exact %p spacing
and formatting may vary between tools.

```text
Initial: '{10, 20, 30, 40}
Size: 4
After growing: '{10, 20, 30, 40, 50, 60}
Original: '{10, 20, 30, 40, 50, 60}
Copy: '{99, 20, 30, 40, 50, 60}
After shrinking: '{10, 20, 30}
Size after delete: 0
Copy remains: '{99, 20, 30, 40, 50, 60}
```

## Code Explanation

### 1. Element type

`int`

Is a 32-bit signed, two-state integer type.

New int elements default to zero.
Default initialization depends on the element type;
four-state logic elements normally default to x.

### 2. initial block

`initial begin ... end`

Executes once at simulation startup.

It is used here to demonstrate a sequence of programming
operations, not to describe a clocked hardware block.

### 3. Allocation

`data = new[4];`

Creates four elements with indices 0, 1, 2, and 3.

### 4. Initialization with foreach

```systemverilog
foreach (data[i])
    data[i] = (i + 1) * 10;
```

Visits all valid indices and assigns:

- Index 0 → 10
- Index 1 → 20
- Index 2 → 30
- Index 3 → 40

### 5. Preserving data while resizing

`data = new[6](data);`

Uses the old array as the initializer for the new array.

When growing, existing values are copied and additional
elements receive their type's default value.

When shrinking, only the initial elements that fit
are copied.

### 6. Copying the array

`copied = data;`

Automatically sizes copied to match data and copies
the integer element values.

Changing copied[0] therefore does not change data[0].

For arrays of class handles, copying the array copies
the handles, not the objects they refer to. This example
uses integers, so that distinction does not arise.

### 7. Display formats

`%p` displays an aggregate such as an array.
`%0d` displays a decimal value without minimum-width padding.

### 8. Deleting elements

`data.delete();`

Removes all elements and makes data.size() return zero.

The variable still exists and can be allocated again.

Deleting data does not delete the separate copied array.

## How to Remember

"Declare empty, allocate, use, resize, delete."

Declaration:
int data[];

Allocate:
data = new[N];

Preserve while resizing:
data = new[new_size](data);

Count elements:
data.size();

Remove elements:
data.delete();

The parentheses after new[size] supply the contents
to preserve.