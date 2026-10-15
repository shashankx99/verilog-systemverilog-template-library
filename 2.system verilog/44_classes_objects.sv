class student;

    string name;
    int marks;

    // Constructor
    function new(string student_name, int student_marks);
        name  = student_name;
        marks = student_marks;
    endfunction

    // Method to update a property
    function void set_marks(int new_marks);
        marks = new_marks;
    endfunction

    // Method to display properties
    function void display();
        $display("Name: %s, Marks: %0d", name, marks);
    endfunction

endclass


module classes_objects_example;

    student s1;
    student s2;
    student alias_handle;

    initial begin
        // Create two separate objects
        s1 = new("Shashank", 90);
        s2 = new("Riya", 95);

        s1.display();
        s2.display();

        // Copy the handle, not the object
        alias_handle = s1;
        alias_handle.set_marks(98);

        $display("After updating through alias_handle:");
        s1.display();
        s2.display();

        // Remove this handle's reference
        alias_handle = null;

        $display("s1 still refers to its object:");
        s1.display();
    end

endmodule