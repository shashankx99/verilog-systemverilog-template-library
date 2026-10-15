# Template 34: Parameterized Synchronous FIFO

## Purpose

A FIFO stores words in First-In, First-Out order.

The first word written is the first word read.

This FIFO supports:
- Configurable data width and depth.
- One shared clock for reading and writing.
- Simultaneous read and write when neither full nor empty.
- Full and empty status flags.
- Registered read output.

Reset is synchronous and active-high.

## Parameters

| Parameter | Default | Meaning |
|---|---|---|
| DATA_WIDTH | 8 | Bits per stored word |
| DEPTH | 4 | Maximum number of stored words |

Both parameters must be positive integers.

The pointers explicitly wrap at DEPTH-1, so DEPTH
does not need to be a power of two.

## Inputs and Outputs

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| clk | Input | 1 bit | Shared rising-edge clock |
| rst | Input | 1 bit | Synchronous active-high reset |
| wr_en | Input | 1 bit | Write request |
| rd_en | Input | 1 bit | Read request |
| din | Input | DATA_WIDTH bits | Word to write |
| dout | Output | DATA_WIDTH bits | Last successfully read word |
| full | Output | 1 bit | No free storage slots |
| empty | Output | 1 bit | No stored words available |

## Short Explanation

The FIFO uses four main components:

1. Memory: stores the data words.
2. Write pointer: identifies the next write location.
3. Read pointer: identifies the oldest stored word.
4. Count: tracks the number of stored words.

A write is accepted only when the FIFO is not full.
A read is accepted only when the FIFO is not empty.

On an accepted read, dout receives the oldest word
after the rising edge.

dout holds its previous value when no read is accepted.
It does not continuously display the next unread word.

## Request Acceptance

write_ok = wr_en AND NOT full
read_ok  = rd_en AND NOT empty

Acceptance uses the FIFO status before the clock edge.

Reset overrides all read and write operations.

## Operation Table

The table assumes reset is inactive.

| FIFO status before edge | wr_en | rd_en | Accepted operation | Count change |
|---|---|---|---|---|
| Neither full nor empty | 0 | 0 | None | No change |
| Neither full nor empty | 1 | 0 | Write | +1 |
| Neither full nor empty | 0 | 1 | Read | -1 |
| Neither full nor empty | 1 | 1 | Write and read | No change |
| Empty | 0 | 1 | None | No change |
| Empty | 1 | 1 | Write only | +1 |
| Full | 1 | 0 | None | No change |
| Full | 1 | 1 | Read only | -1 |

At empty, simultaneous requests do not pass din directly
to dout. The write is accepted, but the read is rejected.

At full, simultaneous requests do not replace the oldest
word in one cycle. The read is accepted, but the write
is rejected and must be retried if still needed.

These are intentional boundary rules for this template.

## Small Example

Assume DATA_WIDTH = 8 and DEPTH = 4.
Data values below are decimal.

Each row shows the result after a rising edge.

| Step | Request | Stored words, oldest first | Count | dout |
|---|---|---|---|---|
| 1 | Reset | None | 0 | 0 |
| 2 | Write 10 | 10 | 1 | 0 |
| 3 | Write 20 | 10, 20 | 2 | 0 |
| 4 | Write 30 | 10, 20, 30 | 3 | 0 |
| 5 | Read | 20, 30 | 2 | 10 |
| 6 | Write 40 and read | 30, 40 | 2 | 20 |
| 7 | Read | 40 | 1 | 30 |
| 8 | Read | None | 0 | 40 |
| 9 | Read while empty | None | 0 | 40 |

At step 8, dout contains the last successfully read word
even though empty becomes 1.

At step 9, the rejected read leaves dout unchanged.

## SystemVerilog Code

```systemverilog
module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 4
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout,
    output logic                  full,
    output logic                  empty
);

    localparam int PTR_WIDTH =
        (DEPTH > 1) ? $clog2(DEPTH) : 1;

    localparam int COUNT_WIDTH = $clog2(DEPTH + 1);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [COUNT_WIDTH-1:0] count;
    logic write_ok, read_ok;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    assign write_ok = wr_en && !full;
    assign read_ok  = rd_en && !empty;

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            dout   <= '0;
        end
        else begin
            if (write_ok) begin
                mem[wr_ptr] <= din;

                if (wr_ptr == DEPTH - 1)
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + 1'b1;
            end

            if (read_ok) begin
                dout <= mem[rd_ptr];

                if (rd_ptr == DEPTH - 1)
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + 1'b1;
            end

            case ({write_ok, read_ok})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule
```

## Code Explanation

### 1. Memory array

`logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];`

Declares DEPTH words, each containing DATA_WIDTH bits.

For the defaults, this is four words of eight bits each.

### 2. Pointer width

`(DEPTH > 1) ? $clog2(DEPTH) : 1`

Allocates enough bits to address the memory.

The special case ensures at least one pointer bit when
DEPTH = 1.

### 3. Count width

`$clog2(DEPTH + 1)`

Provides enough bits to represent occupancy from
zero through DEPTH, inclusive.

For DEPTH = 4:
- Pointers need 2 bits for addresses 0 through 3.
- Count needs 3 bits for occupancy 0 through 4.

### 4. Full and empty flags

`full = (count == DEPTH)`
`empty = (count == 0)`

Occupancy distinguishes full from empty even when
the read and write pointers are equal.

### 5. Accepted write

`mem[wr_ptr] <= din;`

Stores the input word at the next free write location.

The write pointer then advances, wrapping explicitly
from DEPTH-1 to zero.

### 6. Accepted read

`dout <= mem[rd_ptr];`

Captures the oldest stored word into the registered output.

The read pointer then advances with the same wrap rule.

### 7. Simultaneous operations

Read and write use separate if statements, so both can
execute at the same edge when both requests are accepted.

The occupancy update uses the accepted operations,
not the raw request signals.

- Write only → increment.
- Read only → decrement.
- Both or neither → hold.

### 8. Reset behavior

Reset clears the pointers, count, and dout.

The memory array itself is not cleared.
Old contents are treated as invalid because count is zero.

Accepted writes establish valid entries before they can
be read through normal FIFO operation.

Apply reset before using the FIFO.

### 9. Depth of one

DEPTH = 1 is supported.

Under the boundary rules, a one-entry FIFO cannot accept
a read and write together: it is always either empty or full.

## How to Remember

"Write at the tail, read from the head."

Memory → stores words
Write pointer → next write location
Read pointer → oldest word
Count → how many words are valid

Remember occupancy:

WRITE only → +1
READ only → -1
BOTH → unchanged
NEITHER → unchanged

Never write when full.
Never read when empty.