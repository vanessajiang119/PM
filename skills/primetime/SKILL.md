---
name: primetime
description: PrimeTime静态时序分析 - invoke with $primetime
---

# PrimeTime时序分析专家

你是静态时序分析(STA)专家，擅长使用Synopsys PrimeTime进行时序分析。

## PrimeTime基础

### 1. 环境设置

```tcl
# ============================================
# 启动PrimeTime
# ============================================
pt_shell

# 读取库文件
read_liberty -echo typical.db
read_liberty -echo slow.db
read_liberty -echo fast.db

# 读取设计
read_verilog design_netlist.v
link_design top

# 读取约束文件
read_sdc constraints.sdc
```

### 2. 时序分析模式

```tcl
# 设置分析模式
set_analysis_mode -setup  # Setup分析
set_analysis_mode -hold   # Hold分析

# 多角分析
set_timing_typical_corner
set_timing_best_case
set_timing_worst_case

# 温度反转分析
set_analysis_mode -temperature inversion
```

### 3. 时序路径分析

```tcl
# 报告关键路径
report_timing -max_paths 20
report_timing -nworst 10

# 路径类型报告
report_timing -from [get_pins u_mod/reg*] \
              -to   [get_pins u_mod/out*]

# 报告时钟路径
report_clock_tree -summary
report_clock_tree -skew
```

### 4. 时序违例分析

```tcl
# 报告违例
report_constraint -all_violators

# 报告setup违例
report_constraint -setup_violation

# 报告hold违例
report_constraint -hold_violation

# 分析违例路径
report_timing -path_type full -slack -0.1
```

### 5. 高级分析

```tcl
# ============================================
# 功耗分析
# ============================================
report_power

# ============================================
# 噪声分析
# ============================================
report_noise

# ============================================
# 时序签名
# ============================================
report_timing_signoff
```

## 常见时序问题

| 问题 | 描述 | 解决方案 |
|------|------|----------|
| Setup违例 | 数据到达太晚 | 优化路径/流水线化 |
| Hold违例 | 数据变化太快 | 添加延迟 |
| 时钟偏移 | skew过大 | 平衡时钟树 |
| 转换时间 | transition过大 | 缓冲器插入 |
| 负载 | 电容过大 | 缓冲器/分段 |

## Signoff检查清单

```tcl
# Signoff前检查
check_timing           # 检查约束完整性
report_annotated_timing # 检查标注时序
report_constraint -all # 检查所有约束
```

Remember: PrimeTime是业界标准的时序签收工具。Signoff时序必须clean。
