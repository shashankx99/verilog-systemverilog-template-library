interface data_if;

    logic [7:0] data;
    logic       valid;
    logic       ready;

    modport source (
        output data, valid,
        input  ready
    );

    modport sink (
        input  data, valid,
        output ready
    );

endinterface


module interface_source (
    input  logic [7:0] data_in,
    input  logic       valid_in,
    output logic       ready_out,
    data_if.source     link
);

    assign link.data  = data_in;
    assign link.valid = valid_in;
    assign ready_out = link.ready;

endmodule


module interface_sink (
    input  logic       clk,
    input  logic       rst,
    input  logic       accept,
    output logic [7:0] received_data,
    output logic       received_valid,
    data_if.sink       link
);

    assign link.ready = accept && !rst;

    always_ff @(posedge clk) begin
        if (rst) begin
            received_data  <= '0;
            received_valid <= 1'b0;
        end
        else begin
            received_valid <= link.valid && link.ready;

            if (link.valid && link.ready)
                received_data <= link.data;
        end
    end

endmodule


module interfaces_modports_example (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] data_in,
    input  logic       valid_in,
    input  logic       accept,
    output logic       ready_out,
    output logic [7:0] received_data,
    output logic       received_valid
);

    data_if link();

    interface_source source_inst (
        .data_in   (data_in),
        .valid_in  (valid_in),
        .ready_out (ready_out),
        .link      (link)
    );

    interface_sink sink_inst (
        .clk            (clk),
        .rst            (rst),
        .accept         (accept),
        .received_data  (received_data),
        .received_valid (received_valid),
        .link           (link)
    );

endmodule