`timescale 1ns/1ps

module tb_vending;
    import vending_pkg::*;

    // ==========================================
    // Sinais do Testbench
    // =========================================
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

    int erros_detetados = 0;
    int wait_ticks = 0;

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

    initial begin
        $fsdbDumpfile("waves.fsdb");
        $fsdbDumpvars(0, tb_vending, "+all");
    end
    
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
        #10000 begin
            $display("\n[FALHA FATAL] Timeout atingido! A FSM travou.");
            $finish;
        end
    end

    // ==========================================
    // Tasks para simular o Utilizador
    // ==========================================
    task wait_cycles(input int cycles);
        for (int i = 0; i < cycles; i++) begin
            @(posedge clk) wait_ticks++;
        end
    endtask

    task apply_reset();
        rst = 1;
        coin_in = COIN_NONE;
        sel_item = ITEM_CAFE;
        confirm = 0;
        cancel = 0;
        wait_cycles(2);
        rst = 0;
        wait_cycles(1);
    endtask

    task insert_coin(input logic [1:0] coin_type);
        coin_in = coin_type;
        wait_cycles(1);
        coin_in = COIN_NONE;
        wait_cycles(1);
    endtask

    task press_confirm();
        confirm = 1;
        wait_cycles(1);
        confirm = 0;
        wait_cycles(4);
    endtask

    task press_cancel();
        cancel = 1;
        wait_cycles(1);
        cancel = 0;
        wait_cycles(1);
    endtask

    // ==========================================
    // Bloco Principal de Testes (Cenários)
    // ==========================================
    initial begin
        $display("==================================================");
        $display("   INICIO DA SIMULACAO - VENDING MACHINE FSM      ");
        $display("==================================================");

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
            $display("  [PASS] Cenario 1: Troco correto (25 centavos).");
        end else begin
            $display("  [FAIL] Cenario 1: Troco incorreto! Obtido: %0d", change_out);
            erros_detetados++;
        end

        wait_cycles(2);

        // -----------------------------------------------------------
        // CENÁRIO 2: Erro por crédito insuficiente
        // O utilizador insere R$ 0.25 e tenta comprar Snack (R$ 1.00).
        // Deve ativar o sinal de erro.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 2: Credito Insuficiente ---");
        insert_coin(COIN_25);
        sel_item = ITEM_SNACK;

        confirm = 1;
        wait_cycles(1);
        confirm = 0;
        wait_cycles(1);
        wait_cycles(1);

        if (error == 1'b1) begin
            $display("  [PASS] Cenario 2: Erro detetado corretamente.");
        end else begin
            $display("  [FAIL] Cenario 2: Sinal de erro nao ativou!");
            erros_detetados++;
        end

        press_cancel();

        // -----------------------------------------------------------
        // CENÁRIO 3: Cancelamento da operação com devolução
        // O utilizador insere R$ 0.50 e cancela antes de comprar.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 3: Cancelamento da Operacao ---");
        insert_coin(COIN_50);
        press_cancel();

        if (change_out == 8'd50 && state_out == IDLE) begin
            $display("  [PASS] Cenario 3: Dinheiro devolvido e regressou ao IDLE.");
        end else begin
            $display("  [FAIL] Cenario 3: Falha no cancelamento! Troco obtido: %0d", change_out);
            erros_detetados++;
        end

        wait_cycles(2);

        // -----------------------------------------------------------
        // CENÁRIO 4: Esgotamento de stock
        // A memória começou com 5 cafés. Vamos comprar 5 cafés com sucesso.
        // A 6ª tentativa deve dar erro por falta de stock.
        // -----------------------------------------------------------
        $display("\n--- Iniciando Cenario 4: Esgotamento de Stock ---");
        sel_item = ITEM_CAFE;

        for (int i = 0; i < 5; i++) begin
            insert_coin(COIN_25);
            press_confirm();
        end
        $display("  [INFO] 5 cafes comprados (Stock de cafe deve ser 0 agora).");

        insert_coin(COIN_25);
        confirm = 1;
        wait_cycles(1);
        confirm = 0;
        wait_cycles(1);
        wait_cycles(1);

        if (error == 1'b1) begin
            $display("  [PASS] Cenario 4: Venda bloqueada por falta de stock.");
        end else begin
            $display("  [FAIL] Cenario 4: Vendeu item sem stock!");
            erros_detetados++;
        end
        press_cancel();

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

    initial begin
        $vcdpluson;
    end

endmodule
