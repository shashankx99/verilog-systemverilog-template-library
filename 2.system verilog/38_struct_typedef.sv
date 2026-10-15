module struct_typedef_example (
    input  logic [7:0]  addr_in,
    input  logic [15:0] data_in,
    input  logic        write_in,
    output logic [7:0]  addr_out,
    output logic [15:0] data_out,
    output logic        write_out,
    output logic [24:0] packed_out
);

    typedef struct packed {
        logic [7:0]  addr;
        logic [15:0] data;
        logic        write;
    } packet_t;

    packet_t packet;

    always_comb begin
        packet = '{
            addr:  addr_in,
            data:  data_in,
            write: write_in
        };

        addr_out   = packet.addr;
        data_out   = packet.data;
        write_out  = packet.write;
        packed_out = packet;
    end

endmodule