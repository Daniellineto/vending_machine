# ==========================================================================
# Constraints de Timing e Ambiente (SDC)
# ==========================================================================

# Criação do clock de 20ns (50 MHz)
create_clock -name clk -period 20.0 [get_ports clk]

# Incerteza do clock (jitter e skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# Atrasos de entrada (3 ns)
# Aplica a todas as entradas, exceto ao próprio pino de clock
set_input_delay 3.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

# trasos de saída (3 ns)
set_output_delay 3.0 -clock clk [all_outputs]

# Ambiente físico (Carga e Célula Excitadora)
set_load 0.05 [all_outputs]
set_driving_cell -lib_cell INVX1 [all_inputs]