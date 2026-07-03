import vending_pkg::*;

module vending_top (
    // Sinais de Entrada
    input  logic clk,
    input  logic rst,
    input  logic [1:0] coin_in,
    input  logic [1:0] sel_item,
    input  logic confirm,
    input  logic cancel,
    
    // Sinais de Saída
    output logic dispense,
    output logic error,
    output logic [7:0] change_out,
    output logic [7:0] display,
    output logic [2:0] state_out
);

    // Fios Internos (Sinais de Controlo e Dados)
    logic can_sell, credit_load, mem_read, mem_write, change_en;
    logic [7:0] credit_w, price_w, stock_w, change_w;

    // Instanciação: Unidade de Controlo (FSM)
    unit_control u_control (
        .clk         (clk),
        .rst         (rst),
        .confirm     (confirm),
        .cancel      (cancel),
        .coin_in     (coin_in),
        .can_sell    (can_sell),
        .dispense    (dispense),
        .error       (error),
        .state_out   (state_out),
        .credit_load (credit_load),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .change_en   (change_en)
    );

    // Instanciação: Datapath (Caminho de Dados)

    credit_reg u_credit_reg (
        .clk         (clk),
        .rst         (rst),
        .credit_load (credit_load),
        .coin_in     (coin_in),
        .credit      (credit_w)
    );

    memory u_memory (
        .clk         (clk),
        .rst         (rst),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .sel_item    (sel_item),
        .price       (price_w),
        .stock       (stock_w)
    );

    comparator u_comparator (
        .credit      (credit_w),
        .price       (price_w),
        .stock       (stock_w),
        .can_sell    (can_sell)
    );

    subtractor u_subtractor (
        .credit      (credit_w),
        .price       (price_w),
        .change      (change_w)
    );

    // Registos de Saída (Display e Change_Out)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            change_out <= 8'd0;
            display    <= 8'd0;
        end else begin
            // O display mostra sempre o crédito atual do registo
            display <= credit_w;
            
            // O registo do troco:
            if (cancel) begin
                // Se cancelar (ou estiver em erro e cancelar), devolve o dinheiro todo inserido
                change_out <= credit_w;
            end else if (change_en) begin
                // Se a venda for concluída (estado CHANGE), envia o troco calculado
                change_out <= change_w;
            end else if (state_out == IDLE) begin
                // Limpa o portal de troco quando a máquina voltar ao repouso
                change_out <= 8'd0; 
            end
        end
    end

endmodule