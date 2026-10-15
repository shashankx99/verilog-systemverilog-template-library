module priority_encoder_4to2 (
    input  wire [3:0] d,
    output reg  [1:0] code,
    output reg        valid
);

    always @(*) begin
        code  = 2'b00;
        valid = 1'b0;

        if (d[3]) begin
            code  = 2'b11;
            valid = 1'b1;
        end
        else if (d[2]) begin
            code  = 2'b10;
            valid = 1'b1;
        end
        else if (d[1]) begin
            code  = 2'b01;
            valid = 1'b1;
        end
        else if (d[0]) begin
            code  = 2'b00;
            valid = 1'b1;
        end
    end

endmodule