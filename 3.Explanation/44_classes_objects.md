# Template 44: Classes and Objects

## Purpose

A class groups data and operations into one type.

- Properties store data.
- Methods operate on that data.
- A constructor initializes a new object.
- A handle refers to an object.

Classes are widely used in SystemVerilog verification.
This is a simulation-only programming example.

## Class Components

| Component | Example | Purpose |
|---|---|---|
| Class | student | Defines the object type |
| Property | name, marks | Stores object data |
| Constructor | function new(...) | Initializes a new object |
| Method | set_marks(), display() | Performs an operation |
| Handle | s1 | Refers to an object |

## Short Explanation

The class defines the structure and behavior of a student.

Each separately constructed object has its own name and marks.

Declaring a class variable creates a handle, not an object:

```systemverilog
student s1;
```

Initially, s1 is null.

Construct an object and assign its handle using:

```systemverilog
s1 = new("Shashank", 90);
```

Now s1 can access that object's properties and methods.

## Small Example

Create two objects:

s1 → student with name Shashank and marks 90
s2 → student with name Riya and marks 95

Then assign:

```systemverilog
alias_handle = s1;
```

s1 and alias_handle now refer to the same object.

Updating through alias_handle:

```systemverilog
alias_handle.set_marks(98);
```

also changes the marks observed through s1.

The separate object referenced by s2 remains unchanged.

## SystemVerilog Code

```systemverilog
class student;

    string name;
    int marks;

    function new(string student_name, int student_marks);
        name  = student_name;
        marks = student_marks;
    endfunction

    function void set_marks(int new_marks);
        marks = new_marks;
    endfunction

    function void display();
        $display("Name: %s, Marks: %0d", name, marks);
    endfunction

endclass


module classes_objects_example;

    student s1;
    student s2;
    student alias_handle;

    initial begin
        s1 = new("Shashank", 90);
        s2 = new("Riya", 95);

        s1.display();
        s2.display();

        alias_handle = s1;
        alias_handle.set_marks(98);

        $display("After updating through alias_handle:");
        s1.display();
        s2.display();

        alias_handle = null;

        $display("s1 still refers to its object:");
        s1.display();
    end

endmodule
```

## Expected Results

```text
Name: Shashank, Marks: 90
Name: Riya, Marks: 95
After updating through alias_handle:
Name: Shashank, Marks: 98
Name: Riya, Marks: 95
s1 still refers to its object:
Name: Shashank, Marks: 98
```

## Code Explanation

### 1. Class definition

`class student; ... endclass`

Defines a class type named student.

It describes what each object contains and what
operations it supports.

### 2. Properties

```systemverilog
string name;
int marks;
```

These are instance properties: each independently
created object has its own copies.

They are public by default in this example.

### 3. Constructor

```systemverilog
function new(string student_name, int student_marks);
```

new is the special constructor name.

A constructor has no declared return type, not even void.

It executes when a new object is created and initializes
the object's properties.

### 4. Creating objects

```systemverilog
s1 = new("Shashank", 90);
s2 = new("Riya", 95);
```

Each new call constructs a separate object.

Changing one object's properties does not change
the other object's properties.

### 5. Void methods

`function void set_marks(...)`

Declares a function method that does not return a value.

It changes the marks property of the object on which
it is called.

`function void display()`

Prints that object's properties.

These methods contain no timing controls.

### 6. Dot notation

```systemverilog
s1.display();
s1.set_marks(98);
```

The dot selects a method belonging to the object.

Public properties can also be accessed directly:

```systemverilog
s1.marks = 98;
```

Using a method can make an update clearer and provides
a place to add validation later.

### 7. Handle assignment

`alias_handle = s1;`

Copies the reference to the object, not the object itself.

Both handles refer to the same name and marks properties.

Therefore:

alias_handle.set_marks(98);

changes the value seen by s1.marks.

### 8. null

`alias_handle = null;`

Removes the reference held by alias_handle.

It does not clear the object's properties or invalidate
s1, which still refers to that object.

Do not access properties or instance methods through
a null handle.

### 9. Method lifetime

Class methods are automatic by default.

Their arguments and ordinary local variables have
separate storage for each call. The object's properties
remain part of the object between calls.

## Handle Versus Object

| Statement | Effect |
|---|---|
| student s1; | Declare a handle, initially null |
| s1 = new("Aman", 80); | Create an object and store its handle |
| s2 = s1; | Make s2 refer to the same object |
| s2 = new("Riya", 95); | Make s2 refer to a newly created object |
| s2 = null; | Remove the reference held by s2 |

## How to Remember

"Class defines; new creates; handle refers; dot accesses."

CLASS → definition
OBJECT → actual instance
HANDLE → reference to the instance
PROPERTY → stored data
METHOD → operation
CONSTRUCTOR → initialization

Remember:

s2 = s1;

copies a handle. It does not create an independent object.