module credit_reg (
    input  logic clk,
    input  logic rst,
    input  logic credit_clear,
    input  logic credit_load,
    input  logic [1:0] coin_in,
    output logic [7:0] credit
);

    import vending_pkg::*;

    logic [7:0] coin_value;

    // Decode the current coin without adding a one-cycle delay.
    always_comb begin
        case (coin_in)
            COIN_25:  coin_value = VAL_COIN_25;
            COIN_50:  coin_value = VAL_COIN_50;
            COIN_100: coin_value = VAL_COIN_100;
            default:  coin_value = 8'd0;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            credit <= 8'd0;
        end else if (credit_clear) begin
            credit <= 8'd0;
        end else if (credit_load) begin
            credit <= credit + coin_value;
        end
    end

endmodule
