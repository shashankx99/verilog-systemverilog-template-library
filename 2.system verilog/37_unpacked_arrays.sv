module unpacked_arrays (
    input  logic [7:0] data [0:3],
    input  logic [1:0] index,
    output logic [7:0] selected,
    output logic [7:0] copied [0:3],
    output logic [7:0] matrix [0:1][0:1]
);

    always_comb begin
        // Select one complete byte
        selected = data[index];

        // Copy each array element
        foreach (data[i])
            copied[i] = data[i];

        // Arrange four bytes into two rows and two columns
        foreach (matrix[row, col])
            matrix[row][col] = data[row * 2 + col];
    end

endmodule