# Template 42: Array Methods

## Purpose

SystemVerilog provides built-in methods for working
with unpacked arrays.

This template demonstrates:

- Searching for values.
- Finding matching indices.
- Finding minimum and maximum values.
- Summing elements.
- Sorting and reversing elements.

This is a simulation-only programming example.

## Declarations

```systemverilog
int data[0:4];
int matches[$];
int indices[$];
int minimum[$];
int maximum[$];
int total;
```

data is a fixed unpacked array containing five integers.

The queues hold results returned by locator methods.
total holds the single value returned by sum().

## Methods Table

| Method | Purpose | Result or effect |
|---|---|---|
| find() with (...) | Find all matching elements | Returns a queue of values |
| find_index() with (...) | Find all matching indices | Returns a queue of indices |
| min() | Find the minimum element | Returns a queue |
| max() | Find the maximum element | Returns a queue |
| sum() | Add all elements | Returns one value |
| sort() | Sort in ascending order | Modifies the array |
| rsort() | Sort in descending order | Modifies the array |
| reverse() | Reverse the current order | Modifies the array |

The search, min/max, and sum operations do not modify
the source array.

## Small Example

Start with:

data = '{40, 10, 30, 20, 10};

| Expression | Result |
|---|---|
| data.find() with (item > 15) | Queue containing 40, 30, 20 |
| data.find_index() with (item == 10) | Queue containing indices 1, 4 |
| data.min() | Queue containing 10 |
| data.max() | Queue containing 40 |
| data.sum() | 110 |

The minimum occurs twice, but min() returns one
minimum element, not every occurrence.

To find every index containing the minimum value,
use find_index() with a comparison to that minimum.

## SystemVerilog Code

```systemverilog
module array_methods_example;

    int data[0:4];
    int matches[$];
    int indices[$];
    int minimum[$];
    int maximum[$];
    int total;

    initial begin
        data = '{40, 10, 30, 20, 10};

        $display("Original: %p", data);

        matches = data.find() with (item > 15);
        indices = data.find_index() with (item == 10);

        $display("Values greater than 15: %p", matches);
        $display("Indices containing 10: %p", indices);

        minimum = data.min();
        maximum = data.max();

        $display("Minimum: %p", minimum);
        $display("Maximum: %p", maximum);

        total = data.sum();
        $display("Sum: %0d", total);

        data.sort();
        $display("Ascending: %p", data);

        data.rsort();
        $display("Descending: %p", data);

        data.reverse();
        $display("Reversed: %p", data);
    end

endmodule
```

## Expected Results

Exact %p formatting may vary between tools.

```text
Original: '{40, 10, 30, 20, 10}
Values greater than 15: '{40, 30, 20}
Indices containing 10: '{1, 4}
Minimum: '{10}
Maximum: '{40}
Sum: 110
Ascending: '{10, 10, 20, 30, 40}
Descending: '{40, 30, 20, 10, 10}
Reversed: '{10, 10, 20, 30, 40}
```

## Code Explanation

### 1. Array initialization

`data = '{40, 10, 30, 20, 10};`

Uses an assignment pattern to assign the five elements.

The apostrophe distinguishes this pattern from an
ordinary packed concatenation.

### 2. Finding values

`data.find() with (item > 15)`

Examines each element and collects those satisfying
the condition.

item represents the current element's value.

The result is a queue because the number of matches
is not fixed.

If nothing matches, the returned queue is empty.

### 3. Finding indices

`data.find_index() with (item == 10)`

Tests each element's value but returns its index.

In the original array, 10 appears at indices 1 and 4.

These indices describe the array at the time of the
search. Sorting afterward does not update the saved indices.

### 4. Minimum and maximum

`minimum = data.min();`
`maximum = data.max();`

For this nonempty integer array, each method returns
a queue containing one element.

For an empty source array, the returned queue is empty.
Check the result's size before accessing element 0
when the source could be empty.

### 5. Sum reduction

`total = data.sum();`

Adds all five elements:

40 + 10 + 30 + 20 + 10 = 110

The result type depends on the element type or the
expression supplied in a with clause.

Assigning to a wider variable afterward does not
automatically widen the method's internal arithmetic.

For narrow unsigned elements, one possible widening
form is:

total = values.sum() with (int'(item));

Choose a suitable type for the required range and signedness.

### 6. Ascending sort

`data.sort();`

Reorders the original array from smallest to largest.

It modifies data directly; it does not return a sorted array.

### 7. Descending sort

`data.rsort();`

Reorders the original array from largest to smallest.

### 8. Reverse

`data.reverse();`

Reverses the current element order without comparing values.

In this example, it follows descending sort, so the
result happens to be ascending.

Reversing an arbitrary array does not necessarily sort it.

## Other Reduction Methods

| Method | Operation |
|---|---|
| sum() | Add all elements |
| product() | Multiply all elements |
| and() | Bitwise AND across elements |
| or() | Bitwise OR across elements |
| xor() | Bitwise XOR across elements |

These array methods reduce multiple elements to one result.

They differ from a packed-vector reduction such as
^data_word, which operates across bits of a packed value.

## How to Remember

"Find returns values; find_index returns positions."

Search → use a condition with item.
Min/max → expect a queue.
Reduction → expect one value.
Sort/reverse → change the original order.

sort() → small to large
rsort() → large to small
reverse() → flip the current order