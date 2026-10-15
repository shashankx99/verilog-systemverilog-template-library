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
        // Capacity: two integer messages
        mbx = new(2);

        fork
            producer();
            consumer();
        join

        $display("Messages remaining: %0d", mbx.num());
    end

endmodule