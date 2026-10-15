module mux_2to1 (
    input  wire d0,
    input  wire d1,
    input  wire sel,
    output wire y
);

    assign y = sel ? d1 : d0;

endmodule