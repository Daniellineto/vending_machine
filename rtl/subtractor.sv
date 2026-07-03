import vending_pkg::*;

module subtractor (
    input  logic [7:0] credit,
    input  logic [7:0] price,
    output logic [7:0] change
);

    // Calcula a diferença em cêntimos
    assign change = credit - price;

endmodule