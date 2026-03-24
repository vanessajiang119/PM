# =============================================================================
# sram_ctrl DFT Makefile - Tiling Flow v2023.4
# =============================================================================
# Reference: external_circuits_solutions_tiling_flow_bscan_mbist_mbisr_ssn_v2023.4
# Usage:
#   make rtl1    - Run RTL1 (BSCAN configuration)
#   make rtl2    - Run RTL2 (MBIST configuration)
#   make rtl3    - Run RTL3 (Final DFT configuration)
#   make synth   - Run synthesis
#   make gate    - Run gate-level DFT insertion
#   make sim     - Run gate-level simulation
#   make atpg    - Run all ATPG patterns
#   make all     - Run complete DFT flow
# =============================================================================

TESSENT ?= tessent
DC ?= dc_shell
LC ?= lc_shell
WORKSPACE = workspace

.PHONY: all rtl1 rtl2 rtl3 synth gate sim atpg clean help

all: help

help:
	@echo "sram_ctrl DFT Flow - Tiling Flow v2023.4"
	@echo "=========================================="
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "RTL Phase:"
	@echo "  rtl1    - BSCAN configuration + IJTAG graybox"
	@echo "  rtl2    - MBIST configuration"
	@echo "  rtl3    - Final DFT configuration"
	@echo ""
	@echo "Gate Phase:"
	@echo "  synth   - Design synthesis (Design Compiler)"
	@echo "  gate    - Gate-level DFT insertion"
	@echo "  sim     - Gate-level simulation"
	@echo ""
	@echo "ATPG Phase:"
	@echo "  atpg    - Generate all ATPG patterns"
	@echo "  atpg07  - Internal EDT stuck-at"
	@echo "  atpg08  - Internal EDT transition fault"
	@echo "  atpg09  - External EDT stuck-at"
	@echo "  atpg10  - External EDT transition fault"
	@echo ""
	@echo "Utilities:"
	@echo "  all     - This help message"
	@echo "  clean   - Clean generated files"
	@echo ""

# =============================================================================
# RTL Phase
# =============================================================================

rtl1:
	@echo "Running RTL1: BSCAN Configuration..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 01_sram_ctrl_dft_rtl1.log -replace -dofile 01_sram_ctrl_dft_rtl1

rtl2:
	@echo "Running RTL2: MBIST Configuration..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 02_sram_ctrl_dft_rtl2.log -replace -dofile 02_sram_ctrl_dft_rtl2

rtl3:
	@echo "Running RTL3: Final DFT Configuration..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 03_sram_ctrl_dft_rtl3.log -replace -dofile 03_sram_ctrl_dft_rtl3

# =============================================================================
# Gate Phase
# =============================================================================

synth:
	@echo "Running Synthesis..."
	cd $(WORKSPACE) && sh 04_sram_ctrl_synthesis

gate:
	@echo "Running Gate DFT Insertion..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 05_sram_ctrl_dft_gate.log -replace -dofile 05_sram_ctrl_dft_gate

sim:
	@echo "Running Gate-Level Simulation..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 06_sram_ctrl_dft_sim_gate.log -replace -dofile 06_sram_ctrl_dft_sim_gate

# =============================================================================
# ATPG Phase
# =============================================================================

atpg07:
	@echo "Running ATPG: Internal EDT Stuck-at..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 07_sram_ctrl_int_edt_mode_stuck.log -replace -dofile 07_sram_ctrl_int_edt_mode_stuck

atpg08:
	@echo "Running ATPG: Internal EDT Transition Fault..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 08_sram_ctrl_int_edt_mode_tdf.log -replace -dofile 08_sram_ctrl_int_edt_mode_tdf

atpg09:
	@echo "Running ATPG: External EDT Stuck-at..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 09_sram_ctrl_ext_edt_mode_stuck.log -replace -dofile 09_sram_ctrl_ext_edt_mode_stuck

atpg10:
	@echo "Running ATPG: External EDT Transition Fault..."
	cd $(WORKSPACE) && $(TESSENT) -shell -log 10_sram_ctrl_ext_edt_mode_tdf.log -replace -dofile 10_sram_ctrl_ext_edt_mode_tdf

atpg: atpg07 atpg08 atpg09 atpg10

# =============================================================================
# Complete Flow
# =============================================================================

dft: rtl1 rtl2 rtl3 synth gate atpg
	@echo "Complete DFT flow finished!"

# =============================================================================
# Clean
# =============================================================================

clean:
	@echo "Cleaning generated files..."
	cd $(WORKSPACE) && rm -f *.log *.ddc *.vg *.sdc tsdb_outdir *.wsp
	rm -rf dft_work dft_output
	@echo "Clean complete!"

# =============================================================================
# Check Environment
# =============================================================================

check_env:
	@echo "Environment Check"
	@echo "================="
	@echo "Tessent: $(TESSENT)"
	@which $(TESSENT) > /dev/null 2>&1 || echo "Warning: Tessent not found in PATH"
	@echo "Design Compiler: $(DC)"
	@which $(DC) > /dev/null 2>&1 || echo "Warning: DC not found in PATH"
	@echo "Library Compiler: $(LC)"
	@which $(LC) > /dev/null 2>&1 || echo "Warning: LC not found in PATH"
	@echo ""
	@echo "Workspace files:"
	@ls $(WORKSPACE)/0* 2>/dev/null | head -10
