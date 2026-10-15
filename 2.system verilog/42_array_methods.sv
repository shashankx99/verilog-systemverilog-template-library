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

        // Find matching values and their indices
        matches = data.find() with (item > 15);
        indices = data.find_index() with (item == 10);

        $display("Values greater than 15: %p", matches);
        $display("Indices containing 10: %p", indices);

        // Minimum and maximum methods return queues
        minimum = data.min();
        maximum = data.max();

        $display("Minimum: %p", minimum);
        $display("Maximum: %p", maximum);

        // Reduce all elements to one value
        total = data.sum();
        $display("Sum: %0d", total);

        // Ordering methods modify the original array
        data.sort();
        $display("Ascending: %p", data);

        data.rsort();
        $display("Descending: %p", data);

        data.reverse();
        $display("Reversed: %p", data);
    end

endmodule