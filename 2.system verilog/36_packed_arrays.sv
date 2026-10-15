module packed_arrays (
    input  logic [15:0]     data,
    output logic [7:0]      upper_byte,
    output logic [7:0]      lower_byte,
    output logic           bit_5,
    output logic [3:0]      middle_bits,
    output logic [1:0][7:0] bytes_view,
    output logic [15:0]     swapped
);

    assign upper_byte  = data[15:8];
    assign lower_byte  = data[7:0];
    assign bit_5       = data[5];
    assign middle_bits = data[7:4];

    // Same 16 bits, organized as two packed bytes
    assign bytes_view = data;

    // Exchange the upper and lower bytes
    assign swapped = {data[7:0], data[15:8]};

endmodule