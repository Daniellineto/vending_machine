module memory (
    input  logic clk,
    input  logic rst,
    input  logic mem_read,
    input  logic mem_write,
    input  logic [1:0] sel_item,
    output logic [7:0] price,
    output logic [7:0] stock
);

    import vending_pkg::*;

    logic [7:0] stock_mem [0:3];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            stock_mem[ITEM_CAFE]  <= 8'd5;
            stock_mem[ITEM_AGUA]  <= 8'd5;
            stock_mem[ITEM_SUCO]  <= 8'd3;
            stock_mem[ITEM_SNACK] <= 8'd2;
        end else if (mem_write && (stock_mem[sel_item] > 8'd0)) begin
            stock_mem[sel_item] <= stock_mem[sel_item] - 8'd1;
        end
    end

    always_comb begin
        stock = mem_read ? stock_mem[sel_item] : 8'd0;

        case (sel_item)
            ITEM_CAFE:  price = PRICE_CAFE;
            ITEM_AGUA:  price = PRICE_AGUA;
            ITEM_SUCO:  price = PRICE_SUCO;
            ITEM_SNACK: price = PRICE_SNACK;
            default:    price = 8'd0;
        endcase
    end

endmodule
