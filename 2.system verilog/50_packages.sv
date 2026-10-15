package template_pkg;

    localparam int DATA_WIDTH = 8;

    typedef logic [DATA_WIDTH-1:0] data_t;

    typedef struct packed {
        logic [7:0] addr;
        data_t      data;
        logic       write;
    } transaction_t;

    function automatic logic even_parity(input data_t value);
        return ^value;
    endfunction

endpackage


module packages_example (
    input  logic [7:0]             addr_in,
    input  template_pkg::data_t    data_in,
    input  logic                   write_in,
    output template_pkg::data_t    data_out,
    output logic                  parity_out,
    output logic [16:0]            packed_out
);

    import template_pkg::*;

    transaction_t transaction;

    always_comb begin
        transaction = '{
            addr:  addr_in,
            data:  data_in,
            write: write_in
        };

        data_out   = transaction.data;
        parity_out = even_parity(transaction.data);
        packed_out = transaction;
    end

endmodule