# Template 47: Mailboxes

## Purpose

A mailbox transfers messages between concurrent processes.

It stores messages in FIFO order:
the first message inserted is the first message removed.

This example uses:
- A producer that sends three integers.
- A consumer that receives three integers.
- A bounded mailbox with capacity for two messages.

Mailboxes are simulation constructs, not synthesizable RTL.

## Declaration and Construction

```systemverilog
mailbox #(int) mbx;
```

Declares a handle to a mailbox that stores integers.

The handle initially has no mailbox object.
Construct it before use:

```systemverilog
mbx = new(2);
```

The argument 2 sets the capacity to two messages.

For an unbounded mailbox:

```systemverilog
mbx = new();
```

An unbounded mailbox has no specified message-count limit,
though available runtime memory is still finite.

## Methods Table

| Method | Operation | Waiting behavior |
|---|---|---|
| put(value) | Add a message | Waits if a bounded mailbox is full |
| get(value) | Remove the oldest message | Waits if empty |
| peek(value) | Read the oldest message without removing it | Waits if empty |
| try_put(value) | Attempt to add a message | Returns immediately |
| try_get(value) | Attempt to remove a message | Returns immediately |
| try_peek(value) | Attempt to inspect a message | Returns immediately |
| num() | Return the current message count | Returns immediately |

For compatible types in this typed mailbox, try methods
return 1 on success and 0 when the operation cannot
currently proceed.

## Short Explanation

The producer sends:

10, 20, 30

The consumer receives:

10, 20, 30

If the consumer reaches an empty mailbox, get() waits
until a message becomes available.

If the producer reaches a full mailbox, put() waits
until another process removes a message.

This allows the processes to coordinate without
manually checking a shared queue.

## Small Example

One possible execution order is:

| Step | Operation | Mailbox contents afterward |
|---|---|---|
| 1 | Producer puts 10 | 10 |
| 2 | Producer puts 20 | 10, 20 |
| 3 | Producer attempts to put 30 | Full: producer waits |
| 4 | Consumer gets 10 | Space becomes available |
| 5 | Pending put of 30 completes | 20, 30 |
| 6 | Consumer gets 20 | 30 |
| 7 | Consumer gets 30 | Empty |

The precise process interleaving can differ.
The received order remains 10, 20, 30 in this example.

## SystemVerilog Code

```systemverilog
module mailboxes_example;

    mailbox #(int) mbx;

    task automatic producer();
        for (int i = 1; i <= 3; i++) begin
            mbx.put(i * 10);
        end
    endtask

    task automatic consumer();
        int value;

        repeat (3) begin
            mbx.get(value);
            $display("Received: %0d", value);
        end
    endtask

    initial begin
        mbx = new(2);

        fork
            producer();
            consumer();
        join

        $display("Messages remaining: %0d", mbx.num());
    end

endmodule
```

## Expected Results

```text
Received: 10
Received: 20
Received: 30
Messages remaining: 0
```

There are no explicit time delays in this example.
Processes may block and resume within the same simulation
time as messages and space become available.

## Code Explanation

### 1. Typed mailbox

`mailbox #(int) mbx;`

Specifies the message type as int.

This makes the intended data type explicit and enables
type checking for mailbox operations.

### 2. Capacity

`mbx = new(2);`

Creates an empty mailbox that can hold two messages.

The value 2 is the capacity, not the initial number
of messages.

### 3. Producer

`mbx.put(i * 10);`

Sends 10, then 20, then 30.

A blocking put returns only after the message has
been inserted.

### 4. Consumer

`mbx.get(value);`

Waits for a message if necessary, removes the oldest
message, and stores it in value.

The following display executes after the get completes.

### 5. Concurrent execution

```systemverilog
fork
    producer();
    consumer();
join
```

Starts the producer and consumer as concurrent processes.

join waits until both finish before executing the
final message-count display.

Calling producer() first as a sequential call would
block on its third put because the mailbox capacity
is only two and no consumer would yet be running.

### 6. Blocking methods belong in tasks

put(), get(), and peek() may suspend the calling process.

They are used inside tasks here. They cannot be called
as ordinary blocking operations from a function that
must complete without suspending.

### 7. Message count

`mbx.num()`

Returns the number of messages currently stored.

After both processes finish, all three messages have
been removed, so the count is zero.

In concurrent code, num() is only a snapshot.
Another process can change the mailbox before a later
operation. Use try_get() for an immediate receive attempt
rather than relying on a separate count check.

## Nonblocking Receive Example

```systemverilog
int value;

if (mbx.try_get(value))
    $display("Received: %0d", value);
else
    $display("No message available");
```

try_get() does not wait for a future message.

Here, nonblocking means the method returns immediately.
It is unrelated to the nonblocking assignment operator <=.

## Queue Versus Mailbox

| Feature | Queue | Mailbox |
|---|---|---|
| Main purpose | Store and manipulate ordered elements | Transfer messages between processes |
| Direct indexed access | Yes | No |
| Wait automatically when empty | No | get() and peek() can wait |
| Wait automatically when full | No | Bounded put() can wait |
| Access style | Queue methods and indices | Mailbox methods |

## How to Remember

"PUT sends; GET receives; PEEK looks."

PUT → insert a message
GET → remove the oldest message
PEEK → inspect without removing

No message:
get() waits.
try_get() returns immediately.

Use fork...join when producer and consumer must
make progress concurrently.