# Verilog and SystemVerilog Template Library

## Live Website

[Explore the Verilog & SystemVerilog Template Library](https://verilog-systemverilog-template-libr.vercel.app/)

Browse 50 templates with searchable code, language filters, explanations,
examples, truth tables where applicable, and memory tips.

Shashank Singh  
M.Tech — VLSI Design  
Thapar Institute of Engineering & Technology

A collection of 50 educational Verilog and SystemVerilog
templates covering digital circuits, RTL design, and
verification programming concepts.

The library combines source code with explanations,
small examples, relevant tables, and memory tips to
help students understand and reconstruct each design.

## Contents

- 30 Verilog source files.
- 20 SystemVerilog source files.
- 50 accompanying Markdown explanations.
- Truth tables and state-transition tables where relevant.
- Examples showing expected behavior.
- Code walkthroughs and tips for remembering the logic.

## Folder Organization

| Folder | Contents |
|---|---|
| `1.verilog` | Verilog source files for Templates 01–30 |
| `2.system verilog` | SystemVerilog source files for Templates 31–50 |
| `3.Explanation` | Explanations for all 50 templates |
| `README.md` | Project introduction and topic index |

## How to Use

1. Choose a topic from the index below.
2. Read its explanation and example.
3. Open the matching source file in the appropriate folder.
4. Check the interface, reset behavior, parameters, and
   dependencies before adapting the code.

These templates are independent learning examples,
not one combined hardware design.

## Template Index

Each link opens the corresponding explanation.

### Verilog — Combinational Circuits

| No. | Template |
|---|---|
| 01 | [Basic Logic Gates](3.Explanation/01_basic_gates.md) |
| 02 | [Half Adder](3.Explanation/02_half_adder.md) |
| 03 | [Full Adder](3.Explanation/03_full_adder.md) |
| 04 | [Parameterized Ripple-Carry Adder](3.Explanation/04_ripple_carry_adder.md) |
| 05 | [Adder–Subtractor](3.Explanation/05_adder_subtractor.md) |
| 06 | [2:1 Multiplexer](3.Explanation/06_mux_2to1.md) |
| 07 | [4:1 Multiplexer](3.Explanation/07_mux_4to1.md) |
| 08 | [1:4 Demultiplexer](3.Explanation/08_demux_1to4.md) |
| 09 | [2:4 Decoder with Enable](3.Explanation/09_decoder_2to4.md) |
| 10 | [4:2 Priority Encoder](3.Explanation/10_priority_encoder_4to2.md) |
| 11 | [Magnitude Comparator](3.Explanation/11_magnitude_comparator.md) |
| 12 | [Binary-to-Gray Converter](3.Explanation/12_binary_to_gray.md) |
| 13 | [Gray-to-Binary Converter](3.Explanation/13_gray_to_binary.md) |
| 14 | [Parity Generator and Checker](3.Explanation/14_parity_generator_checker.md) |
| 15 | [Basic ALU](3.Explanation/15_basic_alu.md) |

### Verilog — Sequential Circuits and FSMs

| No. | Template |
|---|---|
| 16 | [D Latch](3.Explanation/16_d_latch.md) |
| 17 | [D Flip-Flop: Synchronous and Asynchronous Reset](3.Explanation/17_d_flip_flop.md) |
| 18 | [Parameterized Enabled Register](3.Explanation/18_enabled_register.md) |
| 19 | [T Flip-Flop](3.Explanation/19_t_flip_flop.md) |
| 20 | [JK Flip-Flop](3.Explanation/20_jk_flip_flop.md) |
| 21 | [Up Counter](3.Explanation/21_up_counter.md) |
| 22 | [Down Counter](3.Explanation/22_down_counter.md) |
| 23 | [Up/Down Counter](3.Explanation/23_up_down_counter.md) |
| 24 | [Mod-N Counter](3.Explanation/24_mod_n_counter.md) |
| 25 | [Universal Shift Register](3.Explanation/25_universal_shift_register.md) |
| 26 | [Ring Counter Using Concatenation](3.Explanation/26_ring_counter.md) |
| 27 | [Johnson Counter Using Concatenation](3.Explanation/27_johnson_counter.md) |
| 28 | [Linear-Feedback Shift Register](3.Explanation/28_lfsr.md) |
| 29 | [Moore Sequence Detector for 1011](3.Explanation/29_moore_sequence_detector.md) |
| 30 | [Mealy Sequence Detector for 1011](3.Explanation/30_mealy_sequence_detector.md) |

### SystemVerilog — RTL and Data Organization

| No. | Template |
|---|---|
| 31 | [Combinational RTL Using always_comb](3.Explanation/31_always_comb_example.md) |
| 32 | [Sequential RTL Using always_ff](3.Explanation/32_always_ff_example.md) |
| 33 | [FSM Using enum and typedef](3.Explanation/33_enum_fsm.md) |
| 34 | [Parameterized Synchronous FIFO](3.Explanation/34_sync_fifo.md) |
| 35 | [Single-Port Synchronous RAM](3.Explanation/35_single_port_ram.md) |
| 36 | [Packed Arrays](3.Explanation/36_packed_arrays.md) |
| 37 | [Unpacked and Multidimensional Arrays](3.Explanation/37_unpacked_arrays.md) |
| 38 | [Structures and typedef](3.Explanation/38_struct_typedef.md) |

### SystemVerilog — Programming and Verification Concepts

| No. | Template |
|---|---|
| 39 | [Dynamic Arrays](3.Explanation/39_dynamic_arrays.md) |
| 40 | [Queues](3.Explanation/40_queues.md) |
| 41 | [Associative Arrays](3.Explanation/41_associative_arrays.md) |
| 42 | [Array Methods](3.Explanation/42_array_methods.md) |
| 43 | [Tasks and Functions](3.Explanation/43_tasks_functions.md) |
| 44 | [Classes and Objects](3.Explanation/44_classes_objects.md) |
| 45 | [Inheritance and Polymorphism](3.Explanation/45_inheritance_polymorphism.md) |
| 46 | [Constrained Randomization](3.Explanation/46_constrained_randomization.md) |
| 47 | [Mailboxes](3.Explanation/47_mailboxes.md) |
| 48 | [Semaphores](3.Explanation/48_semaphores.md) |

### SystemVerilog — Connectivity and Shared Definitions

| No. | Template |
|---|---|
| 49 | [Interfaces and Modports](3.Explanation/49_interfaces_modports.md) |
| 50 | [Packages](3.Explanation/50_packages.md) |

## Source Dependencies

Most templates are self-contained. The following examples
reuse modules or definitions:

| Template | Required source files |
|---|---|
| 04: Ripple-Carry Adder | Templates 03 and 04 |
| 05: Adder–Subtractor | Templates 03, 04, and 05 |
| 49: Interfaces and Modports | Interface and modules are included in the same file |
| 50: Packages | Package is defined before the example module in the same file |

Compile package definitions before files that reference them
if they are later separated into different source files.

## RTL and Programming Examples

Templates 01–38 primarily demonstrate hardware descriptions
and fixed-size data organization.

Templates 39–48 provide simulation-oriented programming
examples. The supplied demonstrations are not intended
for hardware synthesis. Some individual concepts, such as
tasks and functions, can also be used in synthesizable RTL
when their contents and usage are suitable.

Templates 49–50 demonstrate interfaces, modports, and
packages through hardware-oriented examples.

Tool support and hardware mapping depend on the constructs
used and the target toolchain.

## Language Notes

- `.v` files contain Verilog source.
- `.sv` files require SystemVerilog language support.
- `$clog2` requires Verilog-2005 or a later language mode.
- Advanced features such as classes, constraints, mailboxes,
  and semaphores require suitable simulator support.
- Parameter limits and reset conventions are documented
  in the individual explanations.

## Project Status

All 50 templates have been drafted.

The collection has received an initial manual review.
Compilation, simulation, synthesis, and FPGA validation
have not been performed as part of this project.

Expected results in the explanations are illustrative,
not recorded simulation results.

### Pending Documentation Updates

- Align Template 12's explanation with its fixed four-bit
  source module and `bin` input name.
- Repair the S0 row in Template 29's state-meaning table.

## Planned Website

A browsable website is planned with:

- Topic search and category filters.
- Readable code and copy buttons.
- Explanations, examples, tables, and memory tips.
- Links to the source repository.

The public website link will be added after deployment.

## About the Author

I am Shashank Singh, pursuing an M.Tech in VLSI Design
at Thapar Institute of Engineering & Technology.

I am building this library to strengthen my understanding
of digital design and SystemVerilog and to share an
organized learning reference with other students.
