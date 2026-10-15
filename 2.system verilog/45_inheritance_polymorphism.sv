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

        // Base handle referring to a base object
        handle = base_obj;
        handle.display();

        // Same base handle referring to a derived object
        handle = derived_obj;
        handle.display();

        // Call the base implementation directly
        base_obj.display();
    end

endmodule