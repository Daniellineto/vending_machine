`timescale 1ns/1ps
import vending_pkg::*;

module tb_vending;

    // ==========================================
    // Sinais do Testbench
    // ==========================================
    logic clk;
    logic rst;
    logic [1:0] coin_in;
    logic [1:0] sel_item;
    logic confirm;
    logic cancel;
    
    logic dispense;
    logic error;
    logic [7:0] change_out;
    logic [7:0] display;
    logic [2:0] state_out;

    int erros_detetados = 0; // Contador para o sistema self-checking

    // ==========================================
    // Instanciação do DUT (Device Under Test)
    // ==========================================
    vending_top dut (
        .clk(clk),
        .rst(rst),
        .coin_in(coin_in),
        .sel_item(sel_item),
        .confirm(confirm),
        .cancel(cancel),
        .dispense(dispense),
        .error(error),
        .change_out(change_out),
        .display(display),
        .state_out(state_out)
    );

    // ==========================================
    // Geração do Relógio (Clock) - 50 MHz (20ns)
    // ==========================================
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // ==========================================
    // Timeout de Segurança (Exigência do projeto)
    // ==========================================
    initial begin
        #10000; // Se a simulação durar mais que 10.000 ns, algo correu mal (loop infinito)
        $display("\n[FALHA FATAL] Timeout atingido! A FSM travou.");
        $finish;
    end

    // ==========================================
    // Tarefas (Tasks) para simular o Utilizador
    // ==========================================
    task apply_reset();
        rst = 1;
        coin_in = COIN_NONE;
        sel_item = ITEM_CAFE;
        confirm = 0;
        cancel = 0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
    endtask

    task insert_coin(input logic [1:0] coin_type);
        coin_in = coin_type;
        @(posedge clk);
        coin_in = COIN_NONE;
        @(posedge clk);
    endtask

    task press_confirm();
        confirm = 1;
        @(posedge clk);
        confirm = 0;
        // Espera a FSM processar CHECK, DISPENSE e CHANGE (uns 4 ciclos)
        repeat(4) @(posedge clk); 
    endtask

    task press_cancel();
        cancel = 1;
        @(posedge clk);
        cancel = 0;
        @(posedge clk);
    endtask

    // ==========================================
    // Bloco Principal de Testes (Cenários)
    // ==========================================
    initial begin
        $display("==================================================");
        $display("   INICIO DA SIMULACAO - VENDING MACHINE FSM      ");
        $display("==================================================");
        
        // 0. Inicialização
        apply_reset();
        $display("[INFO] Sistema reiniciado.");

        // -----------------------------------------------------------
        // CENÁRIO 1: Compra bem-sucedida com troco
        // O utilizador insere R$ 1.00 e compra um Suco (R$ 0.75).
        // Troco esperado: 25 cêntimos.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 1: Compra com Troco ---");
        insert_coin(COIN_100);
        sel_item = ITEM_SUCO;
        press_confirm();
        
        if (change_out == 8'd25) begin
            $display("  [PASS] Cenario 1: Troco correto (25 centimos).");
        end else begin
            $display("  [FAIL] Cenario 1: Troco incorreto! Obtido: %0d", change_out);
            erros_detetados++;
        end

        // Aguarda voltar ao IDLE
        repeat(2) @(posedge clk);

        // -----------------------------------------------------------
        // CENÁRIO 2: Erro por crédito insuficiente
        // O utilizador insere R$ 0.25 e tenta comprar Água (R$ 0.50).
        // Deve ativar o sinal de erro.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 2: Credito Insuficiente ---");
        insert_coin(COIN_25);
        sel_item = ITEM_AGUA;
        
        confirm = 1;
        @(posedge clk);
        confirm = 0;
        @(posedge clk); // Estado CHECK
        @(posedge clk); // Vai para estado ERROR
        
        if (error == 1'b1) begin
            $display("  [PASS] Cenario 2: Erro detetado corretamente.");
        end else begin
            $display("  [FAIL] Cenario 2: Sinal de erro nao ativou!");
            erros_detetados++;
        end
        
        // Pressionar cancel para sair do erro e reaver o dinheiro
        press_cancel();

        // -----------------------------------------------------------
        // CENÁRIO 3: Cancelamento da operação com devolução
        // O utilizador insere R$ 0.50 e cancela antes de comprar.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 3: Cancelamento da Operacao ---");
        insert_coin(COIN_50);
        press_cancel();
        
        // No ciclo em que o cancelamento ocorre, o troco deve devolver o crédito (50)
        if (change_out == 8'd50 && state_out == IDLE) begin
            $display("  [PASS] Cenario 3: Dinheiro devolvido e regressou ao IDLE.");
        end else begin
            $display("  [FAIL] Cenario 3: Falha no cancelamento! Troco obtido: %0d", change_out);
            erros_detetados++;
        end
        
        repeat(2) @(posedge clk);

        // -----------------------------------------------------------
        // CENÁRIO 4: Esgotamento de stock
        // A memória começou com 5 cafés. Vamos comprar 5 cafés com sucesso.
        // A 6ª tentativa deve dar erro por falta de stock.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 4: Esgotamento de Stock ---");
        sel_item = ITEM_CAFE;
        
        // Comprar os 5 cafés iniciais
        for (int i = 0; i < 5; i++) begin
            insert_coin(COIN_25);
            press_confirm();
        end
        $display("  [INFO] 5 cafes comprados (Stock de cafe deve ser 0 agora).");
        
        // Tentar comprar o 6º café (com dinheiro suficiente)
        insert_coin(COIN_25);
        confirm = 1;
        @(posedge clk);
        confirm = 0;
        @(posedge clk); // CHECK
        @(posedge clk); // Deve ir para ERROR
        
        if (error == 1'b1) begin
            $display("  [PASS] Cenario 4: Venda bloqueada por falta de stock.");
        end else begin
            $display("  [FAIL] Cenario 4: Vendeu item sem stock!");
            erros_detetados++;
        end
        press_cancel(); // Limpar a máquina

        // ==========================================
        // Veredicto Final (Self-Checking)
        // ==========================================
        $display("\n==================================================");
        if (erros_detetados == 0) begin
            $display("  RESULTADO FINAL: >>> PASS <<<");
            $display("  Todos os requisitos do testbench foram cumpridos!");
        end else begin
            $display("  RESULTADO FINAL: >>> FAIL <<<");
            $display("  Foram encontrados %0d erros.", erros_detetados);
        end
        $display("==================================================\n");
        
        $finish;
    end

    // ==========================================
    // Gerar ficheiro para o Verdi/DVE
    // ==========================================
    initial begin
        $vcdpluson; // Comando VCS para gerar waveform
        // Se usar um simulador padrão Verilog, substitua por:
        // $dumpfile("vending.vcd");
        // $dumpvars(0, tb_vending);
    end

endmodule