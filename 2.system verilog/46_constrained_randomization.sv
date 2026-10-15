class constrained_packet;

    rand bit [7:0] addr;
    rand bit [7:0] data;
    rand bit       write;
    rand int unsigned length;

    constraint c_addr {
        addr inside {[8'h10:8'h3F]};
        addr[1:0] == 2'b00;
    }

    constraint c_length {
        length inside {[1:8]};
    }

    constraint c_data {
        if (write)
            data != 8'h00;
        else
            data == 8'h00;
    }

    function void display();
        $display("addr=%02h data=%02h write=%0b length=%0d",
                 addr, data, write, length);
    endfunction

endclass


module constrained_randomization_example;

    constrained_packet pkt;

    initial begin
        pkt = new();

        repeat (5) begin
            if (!pkt.randomize())
                $fatal(1, "Packet randomization failed");

            pkt.display();
        end

        // Add requirements for this call only
        if (!pkt.randomize() with {
            write  == 1'b1;
            length == 4;
        })
            $fatal(1, "Inline randomization failed");

        $display("Packet with inline constraints:");
        pkt.display();
    end

endmodule