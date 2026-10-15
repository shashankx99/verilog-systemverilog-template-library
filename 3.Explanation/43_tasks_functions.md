# Template 43: Tasks and Functions

## Purpose

Tasks and functions group statements into reusable operations.

They help avoid repeating code and give an operation
a meaningful name.

This example uses:
- A function that returns the sum of two integers.
- A task that produces their sum and difference.

The initial block and displays form a programming
demonstration. Tasks and functions can also be used in
synthesizable RTL when their contents and usage are suitable.

## Function Syntax

```systemverilog
function automatic return_type function_name(
    input argument_type argument_name
);
    // Statements
    return result;
endfunction
```

A value-returning function can be called inside an expression.

Example:

```systemverilog
result = add(20, 7);
```

## Task Syntax

```systemverilog
task automatic task_name(
    input  argument_type input_name,
    output argument_type output_name
);
    // Statements
endtask
```

A task is called as a statement.

Example:

```systemverilog
calculate(20, 7, sum_result, difference_result);
```

## Comparison Table

| Feature | Function | Task |
|---|---|---|
| Return type | Declared type, or void | No return type |
| Can supply a value in an expression | Yes, if non-void | No |
| Can use output arguments in SystemVerilog | Yes | Yes |
| May contain blocking time controls | No | Yes |
| Must consume simulation time | No | No |
| Typical purpose | Calculate a value | Perform an operation or sequence |

A task may contain timing controls, but it does not
have to. The task in this template consumes no simulation time.

A function must complete without suspending for time
or waiting for an event.

## Small Example

Inputs:

a = 20
b = 7

The function computes:

20 + 7 = 27

The task computes:

sum        = 20 + 7 = 27
difference = 20 - 7 = 13

| Call | Result |
|---|---|
| add(20, 7) | Returns 27 |
| calculate(20, 7, sum_result, difference_result) | Sets sum_result to 27 and difference_result to 13 |

## SystemVerilog Code

```systemverilog
module tasks_functions_example;

    int function_result;
    int sum_result;
    int difference_result;

    function automatic int add(
        input int a,
        input int b
    );
        return a + b;
    endfunction

    task automatic calculate(
        input  int a,
        input  int b,
        output int sum,
        output int difference
    );
        sum        = a + b;
        difference = a - b;
    endtask

    initial begin
        function_result = add(20, 7);
        $display("Function sum: %0d", function_result);

        calculate(20, 7, sum_result, difference_result);

        $display("Task sum: %0d", sum_result);
        $display("Task difference: %0d", difference_result);
    end

endmodule
```

## Expected Results

```text
Function sum: 27
Task sum: 27
Task difference: 13
```

## Code Explanation

### 1. Function return type

`function automatic int add`

Declares a function named add that returns an int.

An int is a 32-bit signed, two-state integer.
Results outside its representable range can overflow.

### 2. Function arguments

`input int a, b`

The input values are copied into the function when called.

The function uses them to calculate its result.

### 3. Return statement

`return a + b;`

Returns the sum and exits the function.

Another valid style assigns the result to the function name:

```systemverilog
function automatic int add(input int a, input int b);
    add = a + b;
endfunction
```

Use either style consistently.

### 4. Task output arguments

```systemverilog
output int sum,
output int difference
```

Provide two results to the caller.

For ordinary output arguments, values are copied back
to the caller when the task returns.

In this call:

calculate(20, 7, sum_result, difference_result);

the positional mapping is:

| Formal argument | Actual argument |
|---|---|
| a | 20 |
| b | 7 |
| sum | sum_result |
| difference | difference_result |

### 5. Blocking assignments

```systemverilog
sum        = a + b;
difference = a - b;
```

Complete the calculations before the task returns
and its output arguments are copied back.

### 6. automatic lifetime

`automatic`

Gives each call separate storage for its arguments
and non-static local variables.

This is useful for recursive functions and tasks that
can have overlapping calls.

It does not create another thread or make a call run
in parallel by itself.

### 7. Function versus task timing

The function cannot contain delays, event waits, or
other blocking timing controls.

A task may contain such controls when used in
simulation code. This particular task contains none.

## Argument Directions

| Direction | Meaning |
|---|---|
| input | Copy a value into the subroutine |
| output | Copy a result back when the subroutine returns |
| inout | Copy in at entry and copy out at return |
| ref | Access the caller's variable directly |

A ref argument is an alias to the caller's variable,
not a separate copy. Its type must match the formal
argument's requirements.

## How to Remember

"Function gives an expression value; task performs an operation."

Function call:

answer = add(a, b);

Task call:

calculate(a, b, sum, difference);

Timing rule:

Function → cannot wait.
Task → may wait, but does not have to.

automatic → separate local storage for each call.