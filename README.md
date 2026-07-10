# Vending Machine

Projeto em SystemVerilog de uma maquina de vendas simples, com FSM de controle, acumulador de credito, memoria de estoque/preco, comparador, subtrator de troco e modulo top-level.

## Estrutura

- `rtl/`: modulos sintetizaveis do projeto.
- `sim/`: testbench self-checking da vending machine.
- `synth/`: script TCL e constraints para sintese.
- `Makefile`: comandos para sintaxe, simulacao, sintese e limpeza.

## Funcionalidades

A maquina aceita moedas de 25, 50 e 100 centimos, permite selecionar um item, confirma a compra, verifica credito e estoque, libera o produto e calcula o troco. Tambem possui cancelamento com devolucao do credito e tratamento de erro para credito insuficiente ou falta de estoque.

## Comandos Principais

Verificar sintaxe com VCS:

```sh
make syntax
```

Compilar e simular:

```sh
make run
```

Abrir waveform no Verdi:

```sh
make wave
```

Executar sintese com Design Compiler:

```sh
make synth
```

Limpar arquivos gerados:

```sh
make clean
```

## Saidas Esperadas

A simulacao gera mensagens de `PASS` ou `FAIL` no terminal. A sintese gera relatorios em `synth/reports/` e arquivos sintetizados em `synth/`.
