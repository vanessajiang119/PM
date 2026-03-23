# =============================================================================
# Tessent MBIST Script for sram_ctrl
# =============================================================================
# Description: Memory BIST insertion for sram_ctrl
# Target: SRAM controller with external memory interface
# Author: DFT Engineer
# Date: 2026-03-23
# =============================================================================

# ============================================
# Step 1: Environment Setup
# ============================================

# Set DFT context for MBIST
set_context dft -rtl

# Read design files
read_verilog -library work ../rtl/sram_ctrl.v
read_verilog -library work ../rtl/sram_ctrl_core.v
read_verilog -library work ../rtl/sram_ctrl_apb.v
read_verilog -library work ../rtl/sram_ctrl_axi.v
read_verilog -library work ../rtl/sram_ctrl_cg.v

# Set current design
set_current_design sram_ctrl

# ============================================
# Step 2: Memory Configuration
# ============================================

# Define external SRAM memory for MBIST
# Note: sram_ctrl connects to external SRAM, so we create MBIST
# to test the SRAM interface

# Memory instance definitions for external SRAM
# Format: add_memory_instances -instance <path> -memory <type>
add_memory_instances -instance u_core/* -memory sram_sp_hs

# Alternative: If using internal FIFO/buffers, add them
add_memory_instances -instance u_core/fifo_inst -depth 64 -width 128

# ============================================
# Step 3: MBIST Configuration
# ============================================

# Set MBIST algorithm
set_mbist_configuration \
    -algorithm march \
    -repair_mode column \
    -benchmark_mode on

# Configure MBIST controller
set_mbist_controller_configuration \
    -controller_name mbist_ctrl \
    -algorithm MATRIX \
    -num_parallel_tests 4

# ============================================
# Step 4: Add Memory Ports for MBIST
# ============================================

# Add MBIST test ports
add_mbist_ports -instance u_core/* -scan

# Configure MBIST chain
create_mbist_scan_chain -controller mbist_controller

# ============================================
# Step 5: MBIST Insertion
# ============================================

# Insert MBIST controllers
insert_mbist -controller -verbose

# ============================================
# Step 6: Verify MBIST
# ============================================

# Run MBIST verification
verify_mbist -verbose

# ============================================
# Step 7: ATPG for Memory Test
# ============================================

# Set fault model for memory
set_fault_model memory_stuck_at

# Add memory faults
add_faults -memory -all

# Generate memory test patterns
create_patterns -mbist

# ============================================
# Step 8: Report and Save
# ============================================

# Report MBIST statistics
report_mbist -verbose

# Save design
save_design sram_ctrl_mbist.ddc

# Write output
write_verilog -output sram_ctrl_mbist.v

puts "MBIST insertion completed successfully!"
