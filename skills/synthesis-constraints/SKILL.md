---
name: synthesis-constraints
description: 综合约束编写指南 - invoke with $synthesis-constraints
---

# 综合约束专家

你是逻辑综合专家，擅长编写高质量的SDC约束文件。

## 约束类型

### 1. 时序约束

```tcl
# ============================================
# 时钟定义
# ============================================

# 主时钟
create_clock -name sys_clk -period 10.0 -waveform {0 5.0} [get_ports clk]

# 生成时钟
create_generated_clock -name core_clk -source [get_ports pll_ref] -divide_by 2 [get_pins core/pll/out]

# 时钟延迟
set_clock_latency -source 2.0 [get_clocks sys_clk]
set_clock_latency -network 1.0 [get_clocks sys_clk]

# 时钟过渡（uncertainty）
set_clock_transition 0.5 [get_clocks sys_clk]

# 时钟不确定性
set_clock_uncertainty -setup 0.8 [get_clocks sys_clk]
set_clock_uncertainty -hold 0.3 [get_clocks sys_clk]

# ============================================
# 输入延迟
# ============================================
set_input_delay -clock sys_clk -max 3.0 [get_ports data_in[*]]
set_input_delay -clock sys_clk -min 1.0 [get_ports data_in[*]]
set_input_delay -clock sys_clk -max 3.0 -add_delay [get_ports valid_in]

# ============================================
# 输出延迟
# ============================================
set_output_delay -clock sys_clk -max 4.0 [get_ports data_out[*]]
set_output_delay -clock sys_clk -min 1.5 [get_ports data_out[*]]

# ============================================
# 多时钟域
# ============================================
set_clock_groups -asynchronous \
    -group [get_clocks sys_clk] \
    -group [get_clocks mem_clk] \
    -group [get_clocks usb_clk]
```

### 2. 时序例外

```tcl
# 假路径（不存在的路径）
set_false_path -from [get_clocks fast_clk] -to [get_clocks slow_clk]

# 多周期路径
set_multicycle_path -setup 2 -from [get_pins uart/*] -to [get_pins uart/*]
set_multicycle_path -hold 1 -from [get_pins uart/*] -to [get_pins uart/*]

# 最大延迟
set_max_delay 5.0 -from [get_pins reg_a[*]] -to [get_pins reg_b[*]]
```

### 3. 设计约束

```tcl
# 面积约束
set_max_area 100000

# 功耗约束
set_power_optimization -cell_leakage_high -threshold 0.1

# 缓冲插入
set_buffer_insertion -effort high

# 层次化综合
setCompile -top_level_buffer_ports false

# 保持时间约束（可选）
set_min_delay 0.5 -from [get_pins latches/*] -to [get_pins latches/*]
```

### 4. 端口约束

```tcl
# 输入驱动强度
set_input_transition 0.5 [get_ports rst_n]
set_driver [get_ports {data_in[*]}] 8

# 输出负载
set_load 0.5 [get_ports {data_out[*]}]

# 最大电容
set_max_capacitance 0.2 [get_ports *]
```

## 综合流程

```tcl
# 读取设计
read_verilog top.v
read_liberty typical.db

# 约束应用
source constraints.sdc

# 综合
compile_ultra -gate_clock -no_autoungroup

# 输出报告
report_timing -max_paths 10
report_area
report_power
report_qor
```

## 约束检查

```tcl
# 检查约束完整性
check_timing

# 验证约束
validate_constraints

# 报告违例
report_constraint -all_violators
```

Remember: 约束是综合成功的关键。好的约束让综合工具能够正确优化设计。
