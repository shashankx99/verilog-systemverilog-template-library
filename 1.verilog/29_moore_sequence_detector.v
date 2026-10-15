module moore_1011_detector (
    input  wire clk,
    input  wire rst,
    input  wire din,
    output wire detected
);

    localparam S0 = 3'b000,
               S1 = 3'b001,
               S2 = 3'b010,
               S3 = 3'b011,
               S4 = 3'b100;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = S0;

        case (state)
            S0: next_state = din ? S1 : S0;
            S1: next_state = din ? S1 : S2;
            S2: next_state = din ? S3 : S0;
            S3: next_state = din ? S4 : S2;
            S4: next_state = din ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    // Moore output: depends only on the current state
    assign detected = (state == S4);

endmodule