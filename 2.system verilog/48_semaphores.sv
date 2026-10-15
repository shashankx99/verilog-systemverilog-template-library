module semaphores_example;

    timeunit 1ns;
    timeprecision 1ps;

    semaphore resource_lock;
    int shared_count;

    task automatic use_resource(input int id);
        // Acquire the only key
        resource_lock.get(1);

        $display("Process %0d entered", id);

        // Represent time spent using the shared resource
        #5ns;
        shared_count = shared_count + 1;

        $display("Process %0d leaving, count=%0d",
                 id, shared_count);

        // Return the key
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