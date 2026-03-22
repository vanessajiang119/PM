# sram_ctrl RTL Source Files
# =============================================================================
# Project: sram_ctrl - SRAM Controller IP
# Version: 1.0.0
# =============================================================================

# Core modules
+incdir+../spec
sram_ctrl.v           # Top-level module
sram_ctrl_apb.v       # APB interface
sram_ctrl_axi.v       # AXI4 interface
sram_ctrl_core.v      # SRAM controller core
sram_ctrl_ecc.v       # SECDED ECC encoder/decoder
sram_ctrl_cg.v        # Clock gating control
