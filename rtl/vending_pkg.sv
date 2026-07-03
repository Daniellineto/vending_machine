package vending_pkg;

    // Codificação dos Estados da FSM (Moore)
    typedef enum logic [2:0] {
        IDLE     = 3'b000,
        COLLECT  = 3'b001,
        CHECK    = 3'b010,
        DISPENSE = 3'b011,
        CHANGE   = 3'b100,
        ERROR    = 3'b101
    } state_t;

    // Preços dos Itens em centavos (8 bits unsigned)
    parameter logic [7:0] PRICE_CAFE  = 8'd25;
    parameter logic [7:0] PRICE_AGUA  = 8'd50;
    parameter logic [7:0] PRICE_SUCO  = 8'd75;
    parameter logic [7:0] PRICE_SNACK = 8'd100;

    // Codificação das Entradas (coin_in)
    parameter logic [1:0] COIN_NONE = 2'b00; // R$ 0,00
    parameter logic [1:0] COIN_25   = 2'b01; // R$ 0,25
    parameter logic [1:0] COIN_50   = 2'b10; // R$ 0,50
    parameter logic [1:0] COIN_100  = 2'b11; // R$ 1,00

    // Valores reais das moedas para soma (8 bits)
    parameter logic [7:0] VAL_COIN_25  = 8'd25;
    parameter logic [7:0] VAL_COIN_50  = 8'd50;
    parameter logic [7:0] VAL_COIN_100 = 8'd100;

    // Codificação dos Itens (sel_item)
    parameter logic [1:0] ITEM_CAFE  = 2'b00;
    parameter logic [1:0] ITEM_AGUA  = 2'b01;
    parameter logic [1:0] ITEM_SUCO  = 2'b10;
    parameter logic [1:0] ITEM_SNACK = 2'b11;

endpackage : vending_pkg