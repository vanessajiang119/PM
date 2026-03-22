# SRAM Controller IP Specification

## Document Information

| Item | Value |
|------|-------|
| **Document Title** | SRAM Controller IP Specification |
| **IP Name** | sram_ctrl |
| **Version** | 1.0.0 |
| **Date** | 2026-03-22 |
| **Author** | Chip Design Agent System |
| **Status** | Draft |

---

## 1. Overview

### 1.1 Purpose and Scope

This document defines the functional and performance specifications for the **sram_ctrl** (SRAM Controller) IP. This IP provides a high-performance interface between internal SRAM memory macros and external bus protocols, optimized for AI accelerator applications.

### 1.2 Target Application

- **Primary**: AI Accelerator (High-performance computing)
- **Secondary**: CPU Cache / System Memory Interface

### 1.3 Key Features

- 256Mb single-port SRAM support
- 4x AXI4/AXI4-Lite/AXI4-Stream slave interfaces (1024-bit each)
- 1x APB slave interface (64-bit) for control and status registers
- Subsystem-level dynamic clock gating
- SECDED ECC with error logging and interrupt reporting

---

## 2. Memory Interface Specifications

### 2.1 SRAM Configuration

| Parameter | Value |
|-----------|-------|
| **Total Capacity** | 256 Mb (256 Megabits) |
| **SRAM Type** | Single-port SRAM |
| **Data Organization** | Configurable (x64, x128, x256, x512, x1024) |
| **Technology Node** | To be determined by integration |

### 2.2 Memory Map

```
+------------------------+ 0x0000_0000
|                        |
|   SRAM Data Region     |
|   (256Mb - ECC area)   |
|                        |
+------------------------+ 0x0FFF_FFFF
|                        |
|   ECC Checkbits        |
|   (overlaid)           |
|                        |
+------------------------+ 0x1000_0000
```

### 2.3 SRAM Timing Parameters

| Parameter | Min | Typ | Max | Unit |
|-----------|-----|-----|-----|------|
| Clock Frequency | - | - | 800 | MHz |
| Read Latency | 1 | 2 | 3 | cycles |
| Write Latency | 1 | 1 | 2 | cycles |
| Access Time | - | 2.5 | - | ns |

---

## 3. Interface Specifications

### 3.1 APB Slave Interface (Control Port)

| Parameter | Specification |
|-----------|---------------|
| **Protocol** | APB (AMBA Peripheral Bus) |
| **Data Width** | 64-bit |
| **Address Width** | 12-bit (4KB register space) |
| **Clock Domain** | clk (system clock) |
| **Reset Domain** | prstn (active low) |
| **Transfer Type** | Single transfers only |
| **Clock Gating** | Supported (per-interface) |

#### 3.1.1 APB Signal List

| Signal | Direction | Description |
|--------|-----------|-------------|
| pclk | Input | APB clock |
| prstn | Input | APB reset (active low) |
| paddr[11:0] | Input | Address bus |
| psel | Input | Select |
| penable | Input | Enable |
| pwrite | Input | Write enable |
| pwdata[63:0] | Input | Write data |
| pready | Output | Ready |
| prdata[63:0] | Output | Read data |
| pslverr | Output | Error response |
| pgate | Input | Clock gate control |

#### 3.1.2 APB Register Map

| Offset | Register Name | Access | Description |
|--------|---------------|--------|-------------|
| 0x000 | CTRL | RW | Control register |
| 0x004 | STAT | RO | Status register |
| 0x008 | INT_EN | RW | Interrupt enable |
| 0x00C | INT_STAT | RW1C | Interrupt status |
| 0x010 | ECC_CTRL | RW | ECC control |
| 0x014 | ECC_ERR_CNT | RO | ECC error counter |
| 0x018 | ECC_ERR_ADDR | RO | Last ECC error address |
| 0x01C | ECC_ERR_INFO | RO | ECC error info |
| 0x020 | CG_CTRL | RW | Clock gating control |
| 0x100-0x3FF | Reserved | - | Reserved |

### 3.2 AXI Slave Interfaces (Data Ports)

| Parameter | Specification |
|-----------|---------------|
| **Protocol** | AXI4, AXI4-Lite, AXI4-Stream |
| **Quantity** | 4 ports |
| **Data Width** | 1024-bit |
| **Address Width** | 32-bit |
| **ID Width** | 4-bit |
| **Clock Domain** | clk (system clock) |
| **Reset Domain** | arstn (active low) |
| **Burst Support** | Yes (INCR, FIXED, WRAP) |
| **Max Burst Length** | 256 beats |
| **Clock Gating** | Supported (subsystem-level) |

#### 3.2.1 AXI4 Signal List (per port)

**Write Address Channel**
| Signal | Direction | Description |
|--------|-----------|-------------|
| s_axiw_awid[3:0] | Input | Write address ID |
| s_axiw_awaddr[31:0] | Input | Write address |
| s_axiw_awlen[7:0] | Input | Burst length |
| s_axiw_awsize[2:0] | Input | Burst size |
| s_axiw_awburst[1:0] | Input | Burst type |
| s_axiw_awvalid | Input | Address valid |
| s_axiw_awready | Output | Address ready |

**Write Data Channel**
| Signal | Direction | Description |
|--------|-----------|-------------|
| s_axiw_wid[3:0] | Input | Write data ID |
| s_axiw_wdata[1023:0] | Input | Write data |
| s_axiw_wstrb[127:0] | Write strobes |
| s_axiw_wlast | Input | Last beat |
| s_axiw_wvalid | Input | Data valid |
| s_axiw_wready | Output | Data ready |

**Write Response Channel**
| Signal | Direction | Description |
|--------|-----------|-------------|
| s_axiw_bid[3:0] | Output | Response ID |
| s_axiw_bresp[1:0] | Output | Response |
| s_axiw_bvalid | Output | Response valid |
| s_axiw_bready | Input | Response ready |

**Read Address Channel**
| Signal | Direction | Description |
|--------|-----------|-------------|
| s_axir_arid[3:0] | Input | Read address ID |
| s_axir_araddr[31:0] | Input | Read address |
| s_axir_arlen[7:0] | Input | Burst length |
| s_axir_arsize[2:0] | Input | Burst size |
| s_axir_arburst[1:0] | Input | Burst type |
| s_axir_arvalid | Input | Address valid |
| s_axir_arready | Output | Address ready |

**Read Data Channel**
| Signal | Direction | Description |
|--------|-----------|-------------|
| s_axir_rid[3:0] | Output | Read data ID |
| s_axir_rdata[1023:0] | Output | Read data |
| s_axir_rresp[1:0] | Output | Response |
| s_axir_rlast | Output | Last beat |
| s_axir_rvalid | Output | Data valid |
| s_axir_rready | Input | Data ready |

**Clock Gating**
| Signal | Direction | Description |
|--------|-----------|-------------|
| cgate_en | Input | Clock gate enable |
| cgate_status | Output | Clock gate status |

#### 3.2.2 AXI4-Lite Support

All 4 ports support AXI4-Lite protocol for register access:
- AWLEN/ARLEN ignored (single beat)
- AWSIZE/ARSIZE ignored (full data width)
- No burst transactions
- ID signals ignored

#### 3.2.3 AXI4-Stream Support

All 4 ports support AXI4-Stream protocol:
- No address channel
- TDEST used for port routing
- TSTRB used for data valid mask
- TLAST indicates packet end

---

## 4. Functional Specifications

### 4.1 Core Features

#### 4.1.1 Address Routing

The controller routes requests from 4 AXI ports to internal SRAM based on:
- Address bits [31:28]: Port selection (4 ports)
- Address bits [27:0]: Offset within selected port's address space

#### 4.1.2 Arbitration

When multiple AXI ports request access to the same SRAM port:
- Round-robin arbitration (default)
- Priority arbitration (configurable)
- Maximum pending transactions: 4 per port

#### 4.1.3 Data Path

```
AXI Write:  AXI_WDATA -> ECC_ENC -> SRAM_WRITE -> SRAM
AXI Read:   SRAM_READ -> SRAM -> ECC_DEC -> ECC_CHK -> AXI_RDATA
```

### 4.2 ECC Functionality

#### 4.2.1 ECC Algorithm

- **Scheme**: SECDED (Single Error Correction, Double Error Detection)
- **Code Length**: 1024-bit data + 22-bit checkbits
- **Generator Matrix**: Modified Hamming code

#### 4.2.2 ECC Operations

| Operation | Description |
|-----------|-------------|
| Encode | Generate checkbits from 1024-bit data |
| Decode | Detect and correct single-bit errors |
| Bypass | Pass-through mode (ECC disabled) |

#### 4.2.3 Error Handling

| Error Type | Action |
|------------|--------|
| Single-bit error | Correct data, log error, optionally interrupt |
| Double-bit error | Log error, assert error flag, optionally interrupt |
| Multi-bit error | Log error, assert fatal error flag |

#### 4.2.4 Error Logging Registers

- **ECC_ERR_CNT**: Cumulative error count (saturating at 0xFFFF)
- **ECC_ERR_ADDR**: Address of last error (0xFFFFFFFF if none)
- **ECC_ERR_INFO**: Error type and bit position

### 4.3 Clock Gating

#### 4.3.1 Subsystem-Level Dynamic Clock Gating

The controller implements intelligent clock gating based on activity:

| Condition | Clock State |
|-----------|-------------|
| All ports idle > 10 cycles | Gated |
| Any port active | Enabled |
| Error condition | Enabled |
| Debug mode | Enabled |

#### 4.3.2 Clock Gating Control Register

| Bit | Name | Description |
|-----|------|-------------|
| [0] | CG_EN | Global clock gating enable |
| [1] | CG_MODE | 0: Auto, 1: Manual |
| [2] | CG_FORCE | Force clock on (when manual mode) |
| [7:4] | CG_IDLE_CNT | Idle cycle count threshold (default: 10) |

---

## 5. Timing Specifications

### 5.1 Clock Domains

| Domain | Frequency | Description |
|--------|-----------|-------------|
| clk | Up to 800 MHz | Main system clock |
| pclk | Up to 200 MHz | APB interface clock |
| sram_clk | 1:1 or 2:1 of clk | SRAM interface clock |

### 5.2 Timing Constraints

| Path | Constraint |
|------|------------|
| APB to register | Setup: 1ns, Hold: 0.5ns |
| AXI address to ready | 2 cycles max |
| AXI data to output | 2 cycles max |
| SRAM read data | 1 cycle latency |

---

## 6. Power Specifications

### 6.1 Power Domains

| Domain | Description |
|--------|-------------|
| PD_CORE | Core logic (always on) |
| PD_ECC | ECC engine (clock gated) |
| PD_AXI4 | AXI interface (clock gated) |
| PD_APB | APB interface (clock gated) |

### 6.2 Power Modes

| Mode | Description | Exit Latency |
|------|-------------|--------------|
| Active | Full operation | 0 cycles |
| Idle | Clock gated | 1 cycle |
| Retention | Reduced leakage | 100 cycles |

---

## 7. Physical Specifications

### 7.1 Area Estimate

| Module | Gate Count (K) |
|--------|----------------|
| APB Interface | 5K |
| AXI4 x 4 | 80K |
| SRAM Controller | 30K |
| ECC Encoder/Decoder | 25K |
| Clock Gating | 5K |
| **Total** | **~145K** |

### 7.2 Pin Count

| Category | Count |
|----------|-------|
| APB Signals | 14 |
| AXI4 x 4 Signals | 160 |
| Clock/Reset | 4 |
| Configuration | 8 |
| **Total** | **~186** |

---

## 8. Verification Strategy

### 8.1 Functional Verification

- [ ] APB register read/write
- [ ] AXI4 basic read/write
- [ ] AXI4 burst transactions
- [ ] AXI4-Lite protocol
- [ ] AXI4-Stream protocol
- [ ] ECC encode/decode
- [ ] ECC error injection
- [ ] Clock gating transitions
- [ ] Arbitration correctness

### 8.2 Performance Verification

- [ ] Maximum frequency可达800MHz
- [ ] Bandwidth: 4 x 1024-bit x 800MHz = 409.6 GB/s
- [ ] Latency: < 5 cycles end-to-end

---

## 9. Deliverables

| Item | Description |
|------|-------------|
| RTL Source | Verilog/SystemVerilog RTL code |
| Specification | This document |
| Verification Plan | Verification plan document |
| Synthesis Scripts | Design synthesis scripts |
| Integration Guide | IP integration manual |

---

## 10. Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0.0 | 2026-03-22 | Chip Design Agent | Initial specification |

---

## Appendix A: Signal Naming Convention

```
s_axiw_  - AXI Write (slave)
s_axir_  - AXI Read (slave)
s_axis_  - AXI Stream (slave)
p_       - APB
cgate_   - Clock gating
ecc_     - ECC related
srams_   - SRAM signals
```
