module queues_example;

    int q[$];
    int removed;

    initial begin
        q = {10, 20, 30};
        $display("Initial: %p", q);

        q.push_back(40);
        q.push_front(5);
        $display("After pushes: %p", q);

        removed = q.pop_front();
        $display("Removed from front: %0d", removed);

        removed = q.pop_back();
        $display("Removed from back: %0d", removed);
        $display("After pops: %p", q);

        q.insert(1, 15);
        $display("After insert: %p", q);

        q.delete(2);
        $display("After deleting index 2: %p", q);

        $display("First: %0d, Last: %0d", q[0], q[$]);
        $display("Size: %0d", q.size());

        foreach (q[i])
            $display("q[%0d] = %0d", i, q[i]);

        q.delete();
        $display("Size after delete: %0d", q.size());
    end

endmodule