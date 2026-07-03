import vending_pkg::*;

module unit_control (
    input  logic clk,
    input  logic rst,
    input  logic confirm,
    input  logic cancel,
    input  logic [1:0] coin_in,
    input  logic can_sell,
    
    // Saídas Externas
    output logic dispense,
    output logic error,
    output logic [2:0] state_out,
    
    // Sinais de Controlo para o Datapath
    output logic credit_load,
    output logic mem_read,
    output logic mem_write,
    output logic change_en
);

    state_t current_state, next_state;

    // 1. Lógica Sequencial (Registo do Estado Atual)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else if (cancel) begin
            // O sinal cancel força o regresso ao IDLE a partir de qualquer estado
            current_state <= IDLE; 
        end else begin
            current_state <= next_state;
        end
    end

    // 2. Lógica Combinacional (Transição para o Próximo Estado)
    always_comb begin
        next_state = current_state; // Por omissão, mantém-se no mesmo estado
        
        case (current_state)
            IDLE: begin
                if (coin_in != COIN_NONE) 
                    next_state = COLLECT;
            end
            COLLECT: begin
                if (confirm) 
                    next_state = CHECK;
            end
            CHECK: begin
                if (can_sell) 
                    next_state = DISPENSE;
                else          
                    next_state = ERROR;
            end
            DISPENSE: begin
                next_state = CHANGE; // Avanço incondicional
            end
            CHANGE: begin
                next_state = IDLE;   // Avanço incondicional
            end
            ERROR: begin
                // Mantém-se no ERROR até que o utilizador prima "cancel".
                // Como o "cancel" já está a forçar o IDLE no bloco always_ff acima, 
                // não precisamos de colocar lógica de transição extra aqui.
            end
            default: next_state = IDLE;
        endcase
    end

    // 3. Lógica Combinacional (Saídas de Moore)
    always_comb begin
        // Valores por omissão (muito importante para evitar latches)
        dispense    = 1'b0;
        error       = 1'b0;
        credit_load = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        change_en   = 1'b0;
        state_out   = current_state; // A saída regista reflete o estado atual

        case (current_state)
            IDLE: begin
                // Nenhuma saída ativa
            end
            COLLECT: begin
                // Ativa a soma se houver inserção de moeda
                if (coin_in != COIN_NONE) 
                    credit_load = 1'b1;
            end
            CHECK: begin
                mem_read = 1'b1; // Lê o preço e o stock
            end
            DISPENSE: begin
                dispense  = 1'b1;
                mem_write = 1'b1; // Decrementa o stock
            end
            CHANGE: begin
                change_en   = 1'b1; // Manda guardar o troco na saída
                credit_load = 1'b1; // Zera o crédito (pois coin_in será 00 nesta fase)
            end
            ERROR: begin
                error = 1'b1;
            end
        endcase
    end

endmodule