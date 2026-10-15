module mealy_1011_detector (
    input  wire clk,
    input  wire rst,
    input  wire din,
    output reg  detected
);

    localparam S0 = 2'b00,
               S1 = 2'b01,
               S2 = 2'b10,
               S3 = 2'b11;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state and Mealy output logic
    always @(*) begin
        next_state = S0;
        detected   = 1'b0;

        case (state)
            S0: next_state = din ? S1 : S0;

            S1: next_state = din ? S1 : S2;

            S2: next_state = din ? S3 : S0;

            S3: begin
                if (din) begin
                    next_state = S1;
                    detected   = 1'b1;
                end
                else
                    next_state = S2;
            end

            default: next_state = S0;
        endcase
    end

endmodule