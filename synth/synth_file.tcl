# ============================================================
# Script de Síntese - Vending Machine
# ============================================================

# ------------------------------------------------------------
# Carregar configuração 
# ------------------------------------------------------------

source synth/.synopsys_dc.setup

# ------------------------------------------------------------
# Ler RTL
# ------------------------------------------------------------

analyze -format sverilog sim/vending_pkg.sv
analyze -format sverilog sim/credit_reg.sv
analyze -format sverilog sim/memory.sv
analyze -format sverilog sim/comparator.sv
analyze -format sverilog sim/subtractor.sv
analyze -format sverilog sim/control_unit.sv
analyze -format sverilog sim/vending_top.sv

# ------------------------------------------------------------
# Elaborar
# ------------------------------------------------------------

elaborate vending_top

link

# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------

source synth/vending.sdc

# ------------------------------------------------------------
# Verificação do design
# ------------------------------------------------------------

puts "\n=================================================="
puts "CHECK DESIGN"
puts "=================================================="

# Redirecionado para a pasta reports/
redirect reports/check_design.rpt {
    check_design
}

# ------------------------------------------------------------
# Relatórios pré-síntese
# ------------------------------------------------------------

redirect reports/area_pre.rpt {
    report_area -hierarchy
}

redirect reports/timing_pre.rpt {
    report_timing -max_paths 10
}

# ------------------------------------------------------------
# Síntese
# ------------------------------------------------------------

puts "\n=================================================="
puts "INICIANDO SÍNTESE (COMPILE ULTRA)"
puts "=================================================="

compile_ultra -no_autoungroup

# ------------------------------------------------------------
# Relatórios pós-síntese
# ------------------------------------------------------------

redirect reports/report_area.rpt {
    report_area -hierarchy
}

redirect reports/report_timing.rpt {
    report_timing -max_paths 10
}

redirect reports/report_power.rpt {
    report_power
}

redirect reports/report_constraint.rpt {
    report_constraint -all_violators
}

# ------------------------------------------------------------
# Exportar netlist
# ------------------------------------------------------------

write -format verilog -hierarchy -output synth/vending_top_syn.v

write -format ddc -hierarchy -output synth/vending_top_syn.ddc

# ------------------------------------------------------------
# Salvar sessão do DC
# ------------------------------------------------------------

write_file -format ddc -hierarchy -output synth/vending_top.ddc

puts "\n=================================================="
puts "SÍNTESE CONCLUÍDA"
puts "=================================================="
puts "Arquivos gerados na pasta reports/ :"
puts "  reports/check_design.rpt"
puts "  reports/report_area.rpt"
puts "  reports/report_timing.rpt"
puts "  reports/report_power.rpt"
puts "  reports/report_constraint.rpt"
puts "Arquivos gerados na pasta synth/ :"
puts "  synth/vending_top_syn.v"
puts "  synth/vending_top_syn.ddc"
puts "=================================================="