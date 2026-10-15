module binary_to_gray_4bit (
    input  wire [3:0] bin, // 4-bit Binary input
    output wire [3:0] gray // 4-bit Gray code output
);

    // The Most Significant Bit (MSB) remains identical
    assign gray[3] = bin[3];
    
    // Each subsequent bit is the XOR of adjacent binary bits
    assign gray[2] = bin[3] ^ bin[2];
    assign gray[1] = bin[2] ^ bin[1];
    assign gray[0] = bin[1] ^ bin[0];

endmodule