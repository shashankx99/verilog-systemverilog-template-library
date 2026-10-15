module dynamic_arrays_example;

    int data[];
    int copied[];

    initial begin
        // Allocate four elements
        data = new[4];

        // Initialize: 10, 20, 30, 40
        foreach (data[i])
            data[i] = (i + 1) * 10;

        $display("Initial: %p", data);
        $display("Size: %0d", data.size());

        // Grow while preserving existing elements
        data = new[6](data);
        data[4] = 50;
        data[5] = 60;

        $display("After growing: %p", data);

        // Create an independent copy
        copied = data;
        copied[0] = 99;

        $display("Original: %p", data);
        $display("Copy: %p", copied);

        // Shrink, keeping the first three elements
        data = new[3](data);

        $display("After shrinking: %p", data);

        // Remove all elements
        data.delete();

        $display("Size after delete: %0d", data.size());
        $display("Copy remains: %p", copied);
    end

endmodule