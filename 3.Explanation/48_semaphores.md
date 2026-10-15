# Template 48: Semaphores

## Purpose

A semaphore coordinates access to a shared resource
using a pool of keys.

A process acquires keys before entering a protected
section and returns them when finished.

This example uses one key to provide mutual exclusion:
only one participating process can use the resource
at a time.

Semaphores are simulation constructs, not synthesizable RTL.

## Declaration and Construction

```systemverilog
semaphore resource_lock;
```

Declares a semaphore handle.

```systemverilog
resource_lock = new(1);
```

Creates the semaphore with one available key.

The handle must refer to a constructed semaphore
before its methods are called.

## Methods Table

| Method | Purpose | Behavior |
|---|---|---|
| new(N) | Construct with N keys | Establishes the initial key count |
| get(N) | Acquire N keys | Waits until enough keys are available |
| put(N) | Return N keys | Adds keys back to the pool |
| try_get(N) | Attempt to acquire N keys | Returns immediately: 1 on success, 0 on failure |

Calling get(), put(), or try_get() without an argument
uses one key by default.

## Short Explanation

Two processes request access to the same resource.

With one available key:

1. One process obtains the key.
2. The other waits in get(1).
3. The first process finishes its protected work.
4. It returns the key using put(1).
5. The waiting process can proceed.

The semaphore protects only code that follows this
acquire-and-release convention. It does not automatically
prevent other code from modifying shared_count.

## Small Example

One possible execution order is:

| Step | Process 1 | Process 2 | Available keys |
|---|---|---|---|
| 1 | Acquires key | Not yet acquired | 0 |
| 2 | Uses resource | Waits in get(1) | 0 |
| 3 | Increments count to 1 and returns key | Can acquire released key | 1 before acquisition |
| 4 | Finished | Acquires key and uses resource | 0 |
| 5 | Finished | Increments count to 2 and returns key | 1 |

Process 2 may acquire the key first instead.
Either way, the protected sections do not overlap.

## SystemVerilog Code

```systemverilog
module semaphores_example;

    timeunit 1ns;
    timeprecision 1ps;

    semaphore resource_lock;
    int shared_count;

    task automatic use_resource(input int id);
        resource_lock.get(1);

        $display("Process %0d entered", id);

        #5ns;
        shared_count = shared_count + 1;

        $display("Process %0d leaving, count=%0d",
                 id, shared_count);

        resource_lock.put(1);
    endtask

    initial begin
        resource_lock = new(1);
        shared_count = 0;

        fork
            use_resource(1);
            use_resource(2);
        join

        $display("Final count: %0d", shared_count);
    end

endmodule
```

## Expected Results

One possible output order is:

```text
Process 1 entered
Process 1 leaving, count=1
Process 2 entered
Process 2 leaving, count=2
Final count: 2
```

Process 2 can run first instead.

The important properties are:
- One process leaves before the other enters.
- The first update produces count = 1.
- The second update produces count = 2.
- Final count is 2.

The two protected five-nanosecond intervals execute
sequentially, taking ten nanoseconds in total.

## Code Explanation

### 1. Time declarations

```systemverilog
timeunit 1ns;
timeprecision 1ps;
```

Define the module's simulation time unit and precision.

The explicit #5ns delay represents five nanoseconds
spent using the shared resource. It is not hardware logic.

### 2. One-key semaphore

`resource_lock = new(1);`

Provides a single permission token.

Only one process can hold that key at a time when
all processes acquire and return it correctly.

### 3. Acquire

`resource_lock.get(1);`

Acquires one key.

If no key is available, the task suspends here.
Statements after get() execute only after acquisition.

### 4. Protected section

The code between get(1) and put(1) is the critical section.

It includes the delay and the shared_count update.

Even while the process is suspended in the delay,
it retains the key, so the other process cannot enter.

### 5. Release

`resource_lock.put(1);`

Returns the key after the shared work is complete.

Every successful acquisition should have a matching
release along the intended execution path.

### 6. Concurrent tasks

fork...join starts both calls concurrently and waits
for both to complete.

The automatic task gives each call its own id argument.
The semaphore and shared_count are shared module variables.

### 7. Key accounting

A semaphore does not enforce ownership of keys.

It also does not cap the key count at the initial value:
extra put() calls can increase the number of available keys.

Correct acquire-and-release accounting is therefore
part of the design.

For this example, each process gets one key and
returns exactly one key.

## Nonblocking Acquisition Example

```systemverilog
if (resource_lock.try_get(1)) begin
    // Access the shared resource
    shared_count++;
    resource_lock.put(1);
end
else begin
    $display("Resource currently busy");
end
```

try_get() returns immediately.

Return a key only if acquisition succeeded.

## Mailbox Versus Semaphore

| Feature | Mailbox | Semaphore |
|---|---|---|
| Main purpose | Transfer messages | Control resource access |
| Stored content | Data messages | Available keys |
| get() | Receives a message | Acquires keys |
| put() | Sends a message | Returns keys |
| Typical use | Producer-consumer communication | Mutual exclusion or resource limits |

## How to Remember

"Get the key, use the resource, return the key."

GET → acquire
WORK → protected section
PUT → release

One key → one participating process at a time.

The lock works only when every resource user follows
the same locking rule.