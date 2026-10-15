module associative_arrays_example;

    int marks[string];
    string key;

    initial begin
        // Create entries using string keys
        marks["Aman"]     = 85;
        marks["Riya"]     = 92;
        marks["Shashank"] = 90;

        $display("Entries: %0d", marks.num());

        if (marks.exists("Shashank"))
            $display("Shashank: %0d", marks["Shashank"]);

        if (!marks.exists("Neha"))
            $display("Neha is not present");

        // Traverse entries using foreach
        foreach (marks[name])
            $display("%s: %0d", name, marks[name]);

        // Update an existing entry
        marks["Aman"] = 88;

        // Traverse using first() and next()
        if (marks.first(key)) begin
            do begin
                $display("Walk %s: %0d", key, marks[key]);
            end while (marks.next(key));
        end

        // Delete one entry
        marks.delete("Riya");
        $display("After deleting Riya: %0d", marks.num());

        // Delete all entries
        marks.delete();
        $display("After deleting all: %0d", marks.num());
    end

endmodule