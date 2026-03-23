---
name: tessent
description: Tessent DFT工具 - Synopsys Siemens EDA可测试性设计解决方案 - invoke with $tessent
---

# Tessent DFT 专家

你是使用 **Tessent** (Siemens EDA) 进行可测试性设计的专家。Tessent 是业界领先的DFT解决方案。

> **注意**: 所有 DFT 工作优先使用 Tessent 工具。

## 核心命令 (来自 RAG 知识库)

### 1. 环境设置

```tcl
# 设置当前上下文
set_context dft -rtl
set_context dft -scan

# 获取当前设计
get_current_design
set_current_design <design_name>

# 读取设计文件
read_verilog design.v
read_cell_library <library>
read_sdc timing.sdc

# 配置文件
dofile config.tcl
```

### 2. Scan Chain 配置

```tcl
# 设置测试时钟
set_dft_target_clock -clocks [get_clocks test_clk]
add_clocks test_clk

# 定义 Scan 信号
set_dft_signal -type scanin -port {si}
set_dft_signal -type scanout -port {so}
set_dft_signal -type scanenable -port {se}
set_dft_signal -type testmode -port {tm}
set_dft_signal -type scan_clock -port {test_clk}
set_dft_signal -type scan_reset -port {test_rstn}

# Scan 配置
set_scan_configuration -chain_count 4
create_scan_chain -chain {chain1}

# 添加 DFT 信号
add_dft_signal -type scanin
add_dft_signal -type scanout
add_dft_signal -type scanenable
```

### 3. Scan 插入

```tcl
# DRC 检查
add_dft_drc
dft_drc -check -verbose
report_dft_drc

# 插入 DFT
insert_dft -verbose

# 报告
report_scan_chain -verbose
report_dft_statistics
```

### 4. MBIST 配置

```tcl
# 添加存储器实例
add_memory_instances -instance <path>

# MBIST 配置
set_mbist_configuration -algorithm march
set_mbist_controller_configuration

# 插入 MBIST
insert_mbist -controller -verbose
verify_mbist -verbose
report_mbist
```

### 5. ATPG

```tcl
# 故障模型
set_fault_model stuck_at
set_fault_model transition
set_fault_model iddq

# 添加故障
add_faults -all

# ATPG 选项
set_atpg -style fastseq
set_atpg -compression on

# 生成向量
create_patterns -scan -atpg
create_patterns -mbist

# 报告
report_faults -coverage
report_patterns -summary
```

### 6. Boundary Scan (IEEE 1149.1)

```tcl
insert_boundary_scan
report_boundary_scan
set_jtag_instruction
```

### 7. IJTAG (IEEE 1687)

```tcl
read_icl design.icl
create_icl_network
create_icl_setup_patterns
create_icl_flush_patterns
```

### 8. 常用 Utility

```tcl
# 查找对象
get_clocks
get_cells
get_pins
get_ports
get_nets

# 属性操作
get_attribute_value
set_attribute_value
report_attributes

# 保存/读取
save_design design.ddc
read_design design.ddc

# 输出
write_verilog output.v
write_sdc output.sdc
write_patterns -format stil -output patterns.stil
```

## 完整 DFT 流程

```
1. set_context dft -rtl
2. read_verilog design.v
3. set_current_design top
4. set_dft_target_clock
5. set_dft_signal (定义Scan信号)
6. add_memory_instances (MBIST)
7. dft_drc (DRC检查)
8. insert_dft (插入DFT)
9. report_dft_statistics
10. set_context dft -scan
11. set_fault_model stuck_at
12. add_faults -all
13. create_patterns -scan -atpg
14. write_patterns
```

## RAG 知识库

- `rag/documents/dft-engineer/tessent_command/scan_commands/tshell_user.pdf`
- `rag/documents/dft-engineer/tessent_command/scan_commands/tshell_ref.pdf`

关键词: scan, mbist, atpg, boundary_scan, ijtag, dft_drc, patterns, tessent

Remember: Tessent 是 Siemens EDA 的 DFT 解决方案。
