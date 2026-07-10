# ==========================================
# Diretórios
# ==========================================
RTL_DIR = rtl
SIM_DIR   = sim
SYNTH_DIR = synth
REP_DIR   = synth/reports

# ===========================================
# Arquivos
# ===========================================
PKG_FILES = $(RTL_DIR)/vending_pkg.sv

RTL_FILES = \
    $(RTL_DIR)/credit_reg.sv \
    $(RTL_DIR)/memory.sv \
    $(RTL_DIR)/comparator.sv \
    $(RTL_DIR)/subtractor.sv \
    $(RTL_DIR)/unit_control.sv \
    $(RTL_DIR)/vending_top.sv

TB_FILES = \
    $(SIM_DIR)/tb_vending.sv

# ==========================================
# Top do testbench
# ==========================================
TOP = tb_vending

# ==========================================
# Flags
# ==========================================
TIMESCALE = 1ns/1ps

VLOGAN_FLAGS = -full64 \
               -sverilog \
               -kdb \
			   -timescale=$(TIMESCALE) \
               +lint=all

VCS_FLAGS = -full64 \
            -timescale=$(TIMESCALE) \
            -debug_access+all \
            -kdb

# ==========================================
# Verificação de sintaxe
# ==========================================
syntax:
	vlogan $(VLOGAN_FLAGS) \
		$(PKG_FILES) \
		$(RTL_FILES) \
		$(TB_FILES)

# ==========================================
# Compilação / Elaboração
# ==========================================
compile: syntax
	vcs $(VCS_FLAGS) -top $(TOP)

# ==========================================
# Simulação
# ==========================================
run: compile
	./simv

# ==========================================
# Abrir waveform
# ==========================================
wave:
	verdi -ssf waves.fsdb &

# ==========================================
# Síntese
# ==========================================
synth:
	dc_shell -f $(SYNTH_DIR)/synth_file.tcl

# ==========================================
# Limpeza da síntese
# ==========================================
clean_synth:
	rm -rf \
		./vending_top.ddc \
		./alib-52 \
		./default.svf \
		./command.log \
		./work* \
		$(REP_DIR)/*.rpt \
		$(SYNTH_DIR)/*.ddc \
		$(SYNTH_DIR)/*.db \
		$(SYNTH_DIR)/*_syn.v

# ==========================================
# Limpeza da simulação
# ==========================================
clean_sim:
	rm -rf \
		csrc \
		simv* \
		*.daidir \
		novas* \
		AN.DB \
		ucli.key \
		verdi* \
		DVEfiles \
		.vlogan* \
		*.fsdb \
		*.log \
		*.vpd \
		*.vcd

# ==========================================
# Limpeza total
# ==========================================
clean: clean_sim clean_synth

.PHONY: syntax compile run wave synth clean clean_sim clean_synth
