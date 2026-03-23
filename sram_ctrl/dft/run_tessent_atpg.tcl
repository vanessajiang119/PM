# =============================================================================
# Tessent ATPG Script for sram_ctrl
# =============================================================================
# Description: ATPG pattern generation for sram_ctrl
# Target: sram_ctrl with Scan + MBIST
# Author: DFT Engineer
# Date: 2026-03-23
# =============================================================================

# ============================================
# Step 1: Load Design with DFT
# ============================================

# Read the DFT-inserted design
set_context dft -scan

read_verilog sram_ctrl_dft.v
read_sdc sram_ctrl_dft.sdc

# Set current design
set_current_design sram_ctrl

# ============================================
# Step 2: ATPG Configuration
# ============================================

# Set ATPG style
set_atpg -style fastseq
set_atpg -compression on
set_atpg -pattern_count 500

# ============================================
# Step 3: Fault Model Setup
# ============================================

# Primary fault model: stuck-at
set_fault_model stuck_at

# Add all faults
add_faults -all

# ============================================
# Step 4: Clock and Reset Setup
# ============================================

# Define ATPG clock
set_atpg_clock -clock clk

# Define scan enable
set_atpg_scan_enable -scan_enable test_se

# ============================================
# Step 5: Pattern Generation
# ============================================

# Generate scan test patterns
create_patterns -scan -atpg

# Generate additional patterns for coverage
create_patterns -scan -atpg -additional

# ============================================
# Step 6: Memory BIST Patterns
# ============================================

# Generate MBIST patterns (if MBIST is inserted)
if {[info exists mbist_controller]} {
    create_patterns -mbist
}

# ============================================
# Step 7: Coverage Report
# ============================================

# Report fault coverage
report_faults -coverage
report_faults -detailed

# Report pattern statistics
report_patterns -summary

# ============================================
# Step 8: Export Patterns
# ============================================

# Export in STIL format
write_patterns -format stil -output patterns/sram_ctrl_atpg.stil

# Export in WGL format
write_patterns -format wgl -output patterns/sram_ctrl_atpg.wgl

# Export in Verilog format
write_patterns -format verilog -output patterns/sram_ctrl_atpg.v

# Export in VCD format (for simulation)
write_patterns -format vcd -output patterns/sram_ctrl_atpg.vcd

puts "ATPG pattern generation completed!"
puts "Fault coverage: [report_faults -coverage]"
