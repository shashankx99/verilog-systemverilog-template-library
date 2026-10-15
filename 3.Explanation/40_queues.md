# Template 40: Queues

## Purpose

A queue is a variable-size, ordered collection of elements.

It supports adding and removing elements without
explicitly allocating storage using new[].

Queues are useful for storing transactions, expected
results, and other ordered data in verification code.

This is a simulation-only programming example.

## Declaration

```systemverilog
int q[$];
```

- int specifies the element type.
- q is the queue name.
- [$] declares an unbounded queue.

Unbounded means no maximum size is specified in the
declaration. Available runtime memory still limits its size.

The queue initially contains zero elements.

## Short Explanation

A queue has two ends:

- Front: index 0.
- Back: index size()-1, also written as $ when indexing.

Adding or removing an element changes the queue's size.
The remaining elements are indexed consecutively from zero.

## Queue Methods

| Operation | Syntax | Meaning |
|---|---|---|
| Add at back | q.push_back(value); | Append an element |
| Add at front | q.push_front(value); | Prepend an element |
| Remove from front | value = q.pop_front(); | Remove and return the first element |
| Remove from back | value = q.pop_back(); | Remove and return the last element |
| Insert | q.insert(index, value); | Insert at the specified position |
| Delete one | q.delete(index); | Remove the specified element |
| Delete all | q.delete(); | Remove every element |
| Get size | q.size() | Return the number of elements |
| Access first | q[0] | Read the first element |
| Access last | q[$] | Read the last element |

Only access or pop an element when the queue is nonempty.

## Small Example

The main example changes the queue as follows:

| Operation | Queue afterward | Returned value |
|---|---|---|
| Initialize | 10, 20, 30 | — |
| push_back(40) | 10, 20, 30, 40 | — |
| push_front(5) | 5, 10, 20, 30, 40 | — |
| pop_front() | 10, 20, 30, 40 | 5 |
| pop_back() | 10, 20, 30 | 40 |
| insert(1, 15) | 10, 15, 20, 30 | — |
| delete(2) | 10, 15, 30 | — |
| delete() | Empty | — |

insert(1, 15) places 15 before the element previously
at index 1.

delete(2) removes the element at index 2, not an element
whose value equals 2.

## SystemVerilog Code

```systemverilog
module queues_example;

    int q[$];
    int removed;

    initial begin
        q = {10, 20, 30};
        $display("Initial: %p", q);

        q.push_back(40);
        q.push_front(5);
        $display("After pushes: %p", q);

        removed = q.pop_front();
        $display("Removed from front: %0d", removed);

        removed = q.pop_back();
        $display("Removed from back: %0d", removed);
        $display("After pops: %p", q);

        q.insert(1, 15);
        $display("After insert: %p", q);

        q.delete(2);
        $display("After deleting index 2: %p", q);

        $display("First: %0d, Last: %0d", q[0], q[$]);
        $display("Size: %0d", q.size());

        foreach (q[i])
            $display("q[%0d] = %0d", i, q[i]);

        q.delete();
        $display("Size after delete: %0d", q.size());
    end

endmodule
```

## Expected Results

Exact %p formatting may vary between tools.

```text
Initial: '{10, 20, 30}
After pushes: '{5, 10, 20, 30, 40}
Removed from front: 5
Removed from back: 40
After pops: '{10, 20, 30}
After insert: '{10, 15, 20, 30}
After deleting index 2: '{10, 15, 30}
First: 10, Last: 30
Size: 3
q[0] = 10
q[1] = 15
q[2] = 30
Size after delete: 0
```

## Code Explanation

### 1. Queue initialization

`q = {10, 20, 30};`

Assigns three elements using a queue concatenation.

No new[] allocation is required.

### 2. Push operations

`q.push_back(40);`

Adds 40 after the current last element.

`q.push_front(5);`

Adds 5 at index 0 and shifts the existing elements
to higher indices.

### 3. Pop operations

`removed = q.pop_front();`

Removes the first element and returns its value.

`removed = q.pop_back();`

Removes the last element and returns its value.

These calls modify the queue. They do not merely read it.

### 4. Insert

`q.insert(1, 15);`

Inserts 15 at index 1.

The old element at index 1 and subsequent elements
move to higher indices.

For a nonempty queue, inserting at q.size() appends.
For an empty queue, inserting at index 0 creates
the first element.

### 5. Delete by index

`q.delete(2);`

Removes the third element because indexing starts at zero.

Later elements move down to close the gap.

### 6. Last-element index

`q[$]`

Uses $ to refer to the final valid index of this queue.

It does not return the size; use q.size() for that.

### 7. foreach traversal

`foreach (q[i])`

Visits the existing elements from index 0 upward.

This example does not change the queue's size while
traversing it.

### 8. Delete everything

`q.delete();`

Empties the queue.

The variable remains available for future push operations.

## FIFO and Stack Patterns

A queue can support different access patterns.

### FIFO: First-In, First-Out

```systemverilog
q.push_back(10);
q.push_back(20);

if (q.size() > 0)
    removed = q.pop_front();
```

The removed value is 10.

### Stack: Last-In, First-Out

```systemverilog
q.push_back(10);
q.push_back(20);

if (q.size() > 0)
    removed = q.pop_back();
```

Starting with an empty queue, the removed value is 20.

## Dynamic Array Versus Queue

| Feature | Dynamic array | Queue |
|---|---|---|
| Declaration | int a[]; | int q[$]; |
| Explicit allocation | new[size] | Not required |
| Resize while preserving data | new[new_size](a) | Push, pop, insert, or delete |
| Indexed access | Yes | Yes |
| Built-in end operations | No push/pop methods | push_front/back and pop_front/back |

## How to Remember

"Push adds; pop removes and returns."

FRONT → index 0
BACK → index $

FIFO:
push_back + pop_front

STACK:
push_back + pop_back

delete(index) removes one.
delete() removes all.