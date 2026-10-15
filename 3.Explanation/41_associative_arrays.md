# Template 41: Associative Arrays

## Purpose

An associative array stores values indexed by keys.

Unlike a dynamic array or queue, its entries do not
need consecutive integer indices.

This example uses student names as keys and integer
marks as values.

Associative arrays are useful for lookup tables,
scoreboards, and sparse memory models in verification.

This is a simulation-only programming example.

## Declaration

```systemverilog
int marks[string];
```

- int is the stored value type.
- marks is the array name.
- string is the key type.

Example:

marks["Shashank"] = 90;

This stores the value 90 under the key "Shashank".

No new[] allocation is required.
Initially, the array has no entries.

## Methods Table

| Operation | Syntax | Meaning |
|---|---|---|
| Add or update | marks["Aman"] = 85; | Store a value under a key |
| Read | marks["Aman"] | Retrieve the value |
| Check existence | marks.exists("Aman") | Return 1 if the key exists |
| Count entries | marks.num() | Return the number of stored entries |
| First key | marks.first(key) | Put the first key into key |
| Next key | marks.next(key) | Advance key to the next existing key |
| Last key | marks.last(key) | Put the last key into key |
| Previous key | marks.prev(key) | Move key to the previous existing key |
| Delete one | marks.delete("Aman"); | Remove that entry |
| Delete all | marks.delete(); | Remove every entry |

The traversal methods return 1 on success and 0 when
no applicable entry exists.

## Short Explanation

Writing to a new key creates an entry.

Writing to an existing key replaces its value without
increasing the number of entries.

Keys are unique and case-sensitive:

"Aman" and "aman" are different string keys.

String-indexed entries are traversed in lexicographic
key order, not insertion order.

## Small Example

After these assignments:

```systemverilog
marks["Aman"]     = 85;
marks["Riya"]     = 92;
marks["Shashank"] = 90;
```

The array contains:

| Key | Value |
|---|---|
| Aman | 85 |
| Riya | 92 |
| Shashank | 90 |

marks.num() returns 3.

After:

```systemverilog
marks["Aman"] = 88;
```

Aman's value changes to 88, but the entry count stays 3.

After:

```systemverilog
marks.delete("Riya");
```

Only Aman and Shashank remain, so marks.num() returns 2.

## SystemVerilog Code

```systemverilog
module associative_arrays_example;

    int marks[string];
    string key;

    initial begin
        marks["Aman"]     = 85;
        marks["Riya"]     = 92;
        marks["Shashank"] = 90;

        $display("Entries: %0d", marks.num());

        if (marks.exists("Shashank"))
            $display("Shashank: %0d", marks["Shashank"]);

        if (!marks.exists("Neha"))
            $display("Neha is not present");

        foreach (marks[name])
            $display("%s: %0d", name, marks[name]);

        marks["Aman"] = 88;

        if (marks.first(key)) begin
            do begin
                $display("Walk %s: %0d", key, marks[key]);
            end while (marks.next(key));
        end

        marks.delete("Riya");
        $display("After deleting Riya: %0d", marks.num());

        marks.delete();
        $display("After deleting all: %0d", marks.num());
    end

endmodule
```

## Expected Results

```text
Entries: 3
Shashank: 90
Neha is not present
Aman: 85
Riya: 92
Shashank: 90
Walk Aman: 88
Walk Riya: 92
Walk Shashank: 90
After deleting Riya: 2
After deleting all: 0
```

## Code Explanation

### 1. String keys

`int marks[string];`

Allows access through names instead of consecutive numbers.

The stored values are 32-bit signed, two-state integers.

### 2. Creating entries

`marks["Aman"] = 85;`

Creates the key if it does not exist.

If it already exists, only its value is updated.

### 3. Checking before reading

`marks.exists("Shashank")`

Checks whether the entry is actually present.

Do not infer existence from the stored value:
zero could be a valid value.

Reading a missing key does not create an entry.
Without a user-defined default, a missing int element
returns the type's default value, zero; a tool may
also issue a warning.

### 4. foreach traversal

```systemverilog
foreach (marks[name])
    $display("%s: %0d", name, marks[name]);
```

The loop variable name is implicitly declared with the
array's key type, which is string here.

It visits existing keys only.

For these names, the order is:

Aman → Riya → Shashank

### 5. Finding the first key

`marks.first(key)`

Updates key with the first existing key and returns 1.

If the array is empty, it returns 0 and the loop body
is skipped.

### 6. Advancing to the next key

`marks.next(key)`

Updates key to the next existing key and returns 1.

After the last key, it returns 0, ending the loop.

The do-while structure processes the first key before
asking for the next one.

### 7. Deletion

`marks.delete("Riya");`

Deletes one key-value entry.

`marks.delete();`

Removes all entries, leaving the array empty.

The variable remains available for future assignments.

## Integer-Key Example

Associative arrays can also use integer keys:

```systemverilog
int memory[int];

initial begin
    memory[4]    = 100;
    memory[1000] = 200;
end
```

This creates two entries, not 1001 entries.

The missing integer keys do not need to be populated.

## Comparison with Other Arrays

| Type | Declaration | Indexing | Storage creation |
|---|---|---|---|
| Dynamic array | int a[]; | Consecutive integers from 0 | new[size] |
| Queue | int q[$]; | Consecutive integers from 0 | Assignment or queue methods |
| Associative array | int a[string]; | Existing string keys | Write to a key |

## How to Remember

"Associative means key → value."

Declaration:
value_type array_name[key_type];

Check:
exists(key)

Count:
num()

Traverse:
first(key), then next(key)

Delete one:
delete(key)

Delete all:
delete()