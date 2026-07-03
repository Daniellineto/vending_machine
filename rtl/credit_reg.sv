import vending_pkg::*;

module credit_reg (
    input  logic clk,
    input  logic rst,
    input  logic credit_load,
    input  logic [1:0] coin_in,
    output logic [7:0] credit
);

    logic [7:0] coin_value;

    // Descodificador combinacional: Transforma a entrada no valor em cêntimos
    always_comb begin
        case (coin_in)
            COIN_25:  coin_value = VAL_COIN_25;
            COIN_50:  coin_value = VAL_COIN_50;
            COIN_100: coin_value = VAL_COIN_100;
            default:  coin_value = 8'd0;
        endcase
    end

    // Registo síncrono para acumular o crédito
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            credit <= 8'd0;
        end else if (credit_load) begin
            if (coin_in == COIN_NONE) begin
                credit <= 8'd0; // Zera o crédito (usado no CHANGE ou ao cancelar)
            end else begin
                credit <= credit + coin_value; // Soma a nova moeda
            end
        end
    end

endmodule