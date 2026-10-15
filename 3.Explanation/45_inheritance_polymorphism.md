# Template 45: Inheritance and Polymorphism

## Purpose

Inheritance allows a new class to reuse and extend
an existing class.

Polymorphism allows a base-class handle to call the
appropriate overridden method for the actual object.

This example uses:
- A base_packet class with an address.
- A data_packet class that adds data.
- A virtual display method.
- A base-class handle that refers to either object.

This is a simulation-only programming example.

## Main Concepts

| Concept | Keyword or syntax | Meaning |
|---|---|---|
| Inheritance | extends | Derive a class from another class |
| Base-class access | super | Access the parent implementation |
| Current object | this | Refer to the current object's members |
| Virtual method | virtual function | Enable dynamic method dispatch |
| Method overriding | Same method signature in derived class | Provide a specialized implementation |
| Polymorphism | Base handle referring to derived object | Use the actual object's virtual method |

## Short Explanation

base_packet defines:
- An address property.
- A constructor.
- A virtual display method.

data_packet extends base_packet:
- It inherits address.
- It adds a data property.
- It initializes the base portion using super.new().
- It overrides display().

A base_packet handle can refer to a data_packet object.

Because display() is virtual, calling it through that
handle executes the derived implementation when the
actual object is a data_packet.

## Class Relationship

| Class | Properties | display() behavior |
|---|---|---|
| base_packet | address | Prints the address |
| data_packet | Inherited address, plus data | Prints the address and data |

## Small Example

Create:

base_obj → base_packet(address = 16)
derived_obj → data_packet(address = 32, data = 99)

First:

```systemverilog
handle = base_obj;
handle.display();
```

The actual object is a base_packet, so the base
display method runs.

Next:

```systemverilog
handle = derived_obj;
handle.display();
```

The actual object is a data_packet, so the overridden
display method runs.

The handle's declared type stays base_packet.

## SystemVerilog Code

```systemverilog
class base_packet;

    int address;

    function new(int addr);
        this.address = addr;
    endfunction

    virtual function void display();
        $display("Base packet: address=%0d", address);
    endfunction

endclass


class data_packet extends base_packet;

    int data;

    function new(int addr, int data);
        super.new(addr);
        this.data = data;
    endfunction

    virtual function void display();
        $display("Data packet: address=%0d, data=%0d",
                 address, data);
    endfunction

endclass


module inheritance_polymorphism_example;

    base_packet base_obj;
    data_packet derived_obj;
    base_packet handle;

    initial begin
        base_obj    = new(16);
        derived_obj = new(32, 99);

        handle = base_obj;
        handle.display();

        handle = derived_obj;
        handle.display();

        base_obj.display();
    end

endmodule
```

## Expected Results

```text
Base packet: address=16
Data packet: address=32, data=99
Base packet: address=16
```

## Code Explanation

### 1. Inheritance

`class data_packet extends base_packet;`

Declares data_packet as a derived class.

Its objects contain the inherited address property
and the added data property.

### 2. Base constructor

```systemverilog
function new(int addr);
    this.address = addr;
endfunction
```

Initializes the address portion of an object.

The constructor has no declared return type.

### 3. Calling the parent constructor

`super.new(addr);`

Invokes the base-class constructor.

It is the first statement in the derived constructor
and supplies the address required by the base constructor.

### 4. Resolving a name conflict with this

```systemverilog
function new(int addr, int data);
    super.new(addr);
    this.data = data;
endfunction
```

Here, the argument and property share the name data.

- this.data means the object's property.
- data means the constructor argument.

Without the qualifier, data = data would assign the
argument to itself rather than initialize the property.

### 5. Virtual method

`virtual function void display();`

Enables dispatch according to the actual object type.

The derived method uses the same signature as the
base method.

Once a method is virtual in the base class, overriding
versions remain virtual. Repeating virtual in the
derived class makes the intent explicit.

### 6. Base handle assignment

`handle = derived_obj;`

Makes a base-class handle refer to a derived-class object.

This is an upcast and needs no explicit cast.

It does not create a new object or remove the derived
object's additional properties.

### 7. Polymorphic call

`handle.display();`

Calls the implementation belonging to the actual object.

- Base object → base display.
- Derived object → derived display.

### 8. Declared type still controls member access

Although handle may refer to a data_packet object,
its declared type is base_packet.

It can access inherited members such as address, but
cannot directly access the derived-only data property.

Use derived_obj.data to access that property through
the derived handle.

### 9. Accessing the base implementation

Inside an overriding method, this statement can call
the parent's implementation:

```systemverilog
super.display();
```

This is useful when the derived method should extend
the parent's behavior rather than replace it completely.

## With and Without virtual

For a base handle referring to a derived object:

| Base method declaration | Method selected through base handle |
|---|---|
| Nonvirtual | Base implementation |
| Virtual | Override for the actual derived object |

This distinction is why the base display method is
declared virtual.

## How to Remember

"extends reuses; super reaches the parent; this means me."

For polymorphism:

"Base handle, derived object, virtual method."

Remember the three steps:

1. Declare the base method virtual.
2. Override it in the derived class.
3. Call through a base handle referring to the derived object.