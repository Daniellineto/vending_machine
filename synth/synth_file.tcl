# ============================================================
# Script de Síntese - Vending Machine
# ============================================================

# ------------------------------------------------------------
# Carregar configuração 
# ------------------------------------------------------------
set search_path [list . libs]
set target_library "saed32rvt_tt1v25c.db"
set link_library "* $target_library"

# ------------------------------------------------------------
# Ler RTL
# ------------------------------------------------------------
analyze -format sverilog rtl/vending_pkg.sv
analyze -format sverilog rtl/credit_reg.sv
analyze -format sverilog rtl/memory.sv
analyze -format sverilog rtl/comparator.sv
analyze -format sverilog rtl/subtractor.sv
analyze -format sverilog rtl/unit_control.sv
analyze -format sverilog rtl/vending_top.sv

# ------------------------------------------------------------
# Elaborar
# ------------------------------------------------------------
elaborate vending_top

link

# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------
read_sdc synth/vending.sdc

# ------------------------------------------------------------
# Verificação do design
# ------------------------------------------------------------
puts "\n=================================================="
puts "CHECK DESIGN"
puts "=================================================="

redirect synth/reports/check_design.rpt {
    check_design
}

# ------------------------------------------------------------
# Relatórios pré-síntese
# ------------------------------------------------------------

redirect synth/reports/area_pre.rpt {
    report_area -hierarchy
}

redirect synth/reports/timing_pre.rpt {
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

redirect synth/reports/report_area.rpt {
    report_area
}

redirect synth/reports/report_timing.rpt {
    report_timing
}

redirect synth/reports/report_power.rpt {
    report_power
}

redirect synth/reports/report_constraint.rpt {
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
puts "Arquivos gerados na pasta synth/reports/ :"
puts "  synth/reports/check_design.rpt"
puts "  synth/reports/area_pre.rpt"
puts "  synth/reports/timing_pre.rpt"
puts "  synth/reports/report_area.rpt"
puts "  synth/reports/report_timing.rpt"
puts "  synth/reports/report_power.rpt"
puts "  synth/reports/report_constraint.rpt"
puts "Arquivos gerados na pasta synth/ :"
puts "  synth/vending_top_syn.v"
puts "  synth/vending_top_syn.ddc"
puts "  synth/vending_top.ddc"
puts "=================================================="
