import vending_pkg::*;

module comparator (
    input  logic [7:0] credit,
    input  logic [7:0] price,
    input  logic [7:0] stock,
    output logic can_sell
);

    // can_sell só é 1 se o crédito for maior ou igual ao preço E houver stock
    assign can_sell = (credit >= price) && (stock > 8'd0);

endmodule