# =============================================================================
# Tessent Complete DFT Flow for sram_ctrl
# =============================================================================
# Description: Complete DFT flow combining Scan + MBIST + ATPG
# Target: sram_ctrl IP
# Author: DFT Engineer
# Date: 2026-03-23
# =============================================================================

# ============================================
# Variables Setup
# ============================================
set DESIGN_NAME "sram_ctrl"
set WORK_DIR "dft_work"
set OUTPUT_DIR "dft_output"

# Create output directories
file mkdir $WORK_DIR
file mkdir $OUTPUT_DIR
file mkdir $OUTPUT_DIR/patterns

puts "=========================================="
puts "Tessent DFT Flow for $DESIGN_NAME"
puts "=========================================="

# ============================================
# Phase 1: Design Read
# ============================================
puts "\n[Phase 1] Reading design..."

set_context dft -rtl

read_verilog -library work ../rtl/sram_ctrl.v
read_verilog -library work ../rtl/sram_ctrl_core.v
read_verilog -library work ../rtl/sram_ctrl_apb.v
read_verilog -library work ../rtl/sram_ctrl_axi.v
read_verilog -library work ../rtl/sram_ctrl_cg.v
read_verilog -library work ../rtl/sram_ctrl_ecc.v

read_sdc ../sdc/sram_ctrl.sdc

set_current_design $DESIGN_NAME

# ============================================
# Phase 2: Scan Configuration
# ============================================
puts "\n[Phase 2] Configuring Scan..."

# Test clock
set_dft_target_clock -clocks [get_clocks clk]

# Scan signals
set_dft_signal -type scanin        -port {test_si}
set_dft_signal -type scanout       -port {test_so}
set_dft_signal -type scanenable    -port {test_se}
set_dft_signal -type testmode      -port {test_mode}

# Test clock/reset
set_dft_signal -type scan_clock    -port {clk}
set_dft_signal -type scan_reset    -port {rst_n}

# Scan configuration
set_scan_configuration -chain_count 4 -scan_compression on

# ============================================
# Phase 3: MBIST Configuration (External SRAM)
# ============================================
puts "\n[Phase 3] Configuring MBIST..."

# Add memory instances for external SRAM interface
# The sram_ctrl connects to external SRAM
add_memory_instances -instance u_core/* -memory sram_1r1w

# Configure MBIST
set_mbist_configuration -algorithm march_x -repair_mode row

# ============================================
# Phase 4: DRC Check
# ============================================
puts "\n[Phase 4] Running DRC..."

dft_drc -verbose
dft_drc -check

# ============================================
# Phase 5: DFT Insertion
# ============================================
puts "\n[Phase 5] Inserting DFT..."

# Insert Scan
insert_dft -verbose

# Insert MBIST
insert_mbist -controller -verbose

# ============================================
# Phase 6: Reports
# ============================================
puts "\n[Phase 6] Generating Reports..."

report_dft_statistics > $OUTPUT_DIR/dft_statistics.rpt
report_scan_chain -verbose > $OUTPUT_DIR/scan_chains.rpt
report_mbist -verbose > $OUTPUT_DIR/mbist_report.rpt

# ============================================
# Phase 7: Save Design
# ============================================
puts "\n[Phase 7] Saving Design..."

save_design $WORK_DIR/${DESIGN_NAME}_dft.ddc
write_verilog $OUTPUT_DIR/${DESIGN_NAME}_dft.v
write_sdc $OUTPUT_DIR/${DESIGN_NAME}_dft.sdc

# ============================================
# Phase 8: ATPG
# ============================================
puts "\n[Phase 8] Generating ATPG..."

set_context dft -scan

read_verilog $OUTPUT_DIR/${DESIGN_NAME}_dft.v
read_sdc $OUTPUT_DIR/${DESIGN_NAME}_dft.sdc
set_current_design $DESIGN_NAME

# ATPG configuration
set_atpg -style fastseq -compression on

# Fault model
set_fault_model stuck_at
add_faults -all

# Generate patterns
create_patterns -scan -atpg

# Coverage report
report_faults -coverage > $OUTPUT_DIR/coverage.rpt

# Export patterns
write_patterns -format stil -output $OUTPUT_DIR/patterns/${DESIGN_NAME}.stil
write_patterns -format vcd -output $OUTPUT_DIR/patterns/${DESIGN_NAME}.vcd

puts "\n=========================================="
puts "DFT Flow Complete!"
puts "Output files in: $OUTPUT_DIR"
puts "=========================================="
