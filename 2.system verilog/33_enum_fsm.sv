module enum_fsm (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic work_done,
    output logic busy,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RUN  = 2'b01,
        DONE = 2'b10
    } state_t;

    state_t state, next_state;

    // State register: synchronous active-high reset
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = RUN;
            end

            RUN: begin
                if (work_done)
                    next_state = DONE;
            end

            DONE: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    // Moore output logic
    always_comb begin
        busy = 1'b0;
        done = 1'b0;

        case (state)
            RUN:     busy = 1'b1;
            DONE:    done = 1'b1;
            default: begin
                busy = 1'b0;
                done = 1'b0;
            end
        endcase
    end

endmodule