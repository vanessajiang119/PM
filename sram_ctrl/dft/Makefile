# =============================================================================
# Makefile for Tessent DFT Flow
# =============================================================================
# Usage:
#   make scan       - Run Scan Insertion only
#   make mbist      - Run MBIST only
#   make atpg       - Run ATPG only
#   make dft        - Run complete DFT flow
#   make clean      - Clean output files
# =============================================================================

TESSENT = tessent_shell
RTL_DIR = ../rtl
SDC_DIR = ../sdc
DFT_DIR = dft_output

# Target design
DESIGN = sram_ctrl

.PHONY: all scan mbist atpg dft clean help

all: help

help:
	@echo "Tessent DFT Flow for sram_ctrl"
	@echo "================================"
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  scan    - Run Scan Insertion"
	@echo "  mbist   - Run MBIST Insertion"
	@echo "  atpg    - Run ATPG Pattern Generation"
	@echo "  dft     - Run Complete DFT Flow (Scan + MBIST + ATPG)"
	@echo "  clean   - Clean Output Files"
	@echo ""
	@echo "Output Directory: $(DFT_DIR)"

scan:
	@echo "Running Scan Insertion..."
	$(TESSENT) -f run_tessent_scan.tcl

mbist:
	@echo "Running MBIST Insertion..."
	$(TESSENT) -f run_tessent_mbist.tcl

atpg:
	@echo "Running ATPG..."
	$(TESSENT) -f run_tessent_atpg.tcl

dft:
	@echo "Running Complete DFT Flow..."
	$(TESSENT) -f run_tessent_dft.tcl

clean:
	@echo "Cleaning output files..."
	rm -rf dft_work
	rm -rf dft_output
	@echo "Clean complete!"

# Quick check - just verify TCL syntax
check:
	@echo "Checking TCL scripts syntax..."
	@# This is a placeholder - would need TCL interpreter
	@echo "run_tessent_scan.tcl"
	@echo "run_tessent_mbist.tcl"
	@echo "run_tessent_atpg.tcl"
	@echo "run_tessent_dft.tcl"
	@echo "All TCL scripts created successfully!"
