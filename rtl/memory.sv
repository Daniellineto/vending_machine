import vending_pkg::*;

module memory (
    input  logic clk,
    input  logic rst,
    input  logic mem_read,
    input  logic mem_write,
    input  logic [1:0] sel_item,
    output logic [7:0] price,
    output logic [7:0] stock
);

    // Array de memória para guardar o stock de 4 itens
    logic [7:0] stock_mem [0:3];

    // Leitura e Escrita síncronas
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Inicializa o stock com os respectivos valores de cada item
            stock_mem[ITEM_CAFE]  <= 8'd5;
            stock_mem[ITEM_AGUA]  <= 8'd5;
            stock_mem[ITEM_SUCO]  <= 8'd3;
            stock_mem[ITEM_SNACK] <= 8'd2;
            
            price <= 8'd0;
            stock <= 8'd0;
        end else begin
            
            // Escrita: Decrementa o stock se a FSM mandar gravar (estado DISPENSE)
            if (mem_write) begin
                if (stock_mem[sel_item] > 8'd0) begin
                    stock_mem[sel_item] <= stock_mem[sel_item] - 8'd1;
                end
            end
            
            // Leitura: Atualiza os fios de saída (estado CHECK)
            if (mem_read) begin
                stock <= stock_mem[sel_item];
                
                // Associa o endereço ao preço correspondente definido no package
                case (sel_item)
                    ITEM_CAFE:  price <= PRICE_CAFE;
                    ITEM_AGUA:  price <= PRICE_AGUA;
                    ITEM_SUCO:  price <= PRICE_SUCO;
                    ITEM_SNACK: price <= PRICE_SNACK;
                    default:    price <= 8'd0;
                endcase
            end
        end
    end

endmodule