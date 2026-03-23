# =============================================================================
# Tessent Scan Insertion Script for sram_ctrl
# =============================================================================
# Description: Scan chain insertion for sram_ctrl IP
# Target: sram_ctrl top-level module
# Author: DFT Engineer
# Date: 2026-03-23
# =============================================================================

# ============================================
# Step 1: Environment Setup
# ============================================

# Set DFT context
set_context dft -rtl

# Read design files
read_verilog -library work ../rtl/sram_ctrl.v
read_verilog -library work ../rtl/sram_ctrl_core.v
read_verilog -library work ../rtl/sram_ctrl_apb.v
read_verilog -library work ../rtl/sram_ctrl_axi.v
read_verilog -library work ../rtl/sram_ctrl_cg.v

# Set current design
set_current_design sram_ctrl

# Read timing constraints
read_sdc ../sdc/sram_ctrl.sdc

# ============================================
# Step 2: DFT Configuration
# ============================================

# Define test clock
set_dft_target_clock -clocks [get_clocks clk]

# ============================================
# Step 3: Scan Signal Definition
# ============================================

# Primary inputs for test
set_dft_signal -type scanin        -port {test_si}
set_dft_signal -type scanout       -port {test_so}
set_dft_signal -type scanenable    -port {test_se}
set_dft_signal -type testmode      -port {test_mode}

# Clock and reset for test
set_dft_signal -type scan_clock    -port {clk}
set_dft_signal -type scan_reset    -port {rst_n}

# ============================================
# Step 4: Scan Chain Configuration
# ============================================

# Configure scan chains
set_scan_configuration \
    -chain_count 4 \
    -scan_compression on \
    -max_scan_chain_length 200

# Create named scan chains
create_scan_chain -chain {scan_chain_0} -scan_cells [get_cells -hier * -filter "is_sequential"]
create_scan_chain -chain {scan_chain_1}
create_scan_chain -chain {scan_chain_2}
create_scan_chain -chain {scan_chain_3}

# ============================================
# Step 5: DFT Design Rule Check
# ============================================

# Run DRC before insertion
dft_drc -check -verbose

# ============================================
# Step 6: Scan Insertion
# ============================================

# Insert scan chains
insert_dft -verbose

# ============================================
# Step 7: Verify and Report
# ============================================

# Report scan statistics
report_dft_statistics
report_scan_chain -verbose

# ============================================
# Step 8: Save Design
# ============================================

# Save DFT-inserted design
save_design sram_ctrl_dft.ddc

# Write output files
write_verilog -output sram_ctrl_dft.v
write_sdc -output sram_ctrl_dft.sdc

puts "Scan insertion completed successfully!"
