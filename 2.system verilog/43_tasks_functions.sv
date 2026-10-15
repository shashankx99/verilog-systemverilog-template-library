module tasks_functions_example;

    int function_result;
    int sum_result;
    int difference_result;

    // Function returns a value
    function automatic int add(
        input int a,
        input int b
    );
        return a + b;
    endfunction

    // Task provides results through output arguments
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