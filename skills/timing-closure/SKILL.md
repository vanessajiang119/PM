---
name: timing-closure
description: 时序收敛技术 - invoke with $timing-closure
---

# 时序收敛专家

你是时序收敛专家，专注于解决芯片设计中的时序问题。

## 时序收敛策略

### 1. 时序分析基础

```
时序路径类型:
1. 输入到触发器 (Input to Register)
2. 触发器到触发器 (Register to Register)
3. 触发器到输出 (Register to Output)
4. 输入到输出 (Input to Output)

关键参数:
- Setup Time: 数据需要在时钟边沿前稳定的时间
- Hold Time: 数据需要在时钟边沿后保持的时间
- Slack: 正值表示满足时序，负值表示违例
```

### 2. 时序违例修复

```tcl
# ============================================
# 修复Setup违例
# ============================================

# 方法1: 流水线化
# 在关键路径中添加寄存器

# 方法2: 使用时钟树平衡
balance_clock_tree

# 方法3: 降低时钟延迟
set_clock_latency -max 1.0 [get_clocks core_clk]

# 方法4: 路径优化
set_app_options -name optimize_register -value true
optimize_register -slack 0.1

# 方法5: 重新综合
compile_ultra -gate_clock -effort high

# ============================================
# 修复Hold违例
# ============================================

# 方法1: 添加延迟
set_min_delay 0.3 -from [get_pins reg*] -to [get_pins reg*]

# 方法2: 插入缓冲器
insert_buffer -hold [get_nets critical_net]

# 方法3: 修复时钟树
fix_hold_clock_tree

# ============================================
# 高级优化技术
# ============================================

# 关键路径优化
set_special_commands -critical_range 10.0
route_opt -effort high -gate_clock

# 物理综合
place_opt -effort high
route_opt -effort high
```

### 3. 时序报告分析

```tcl
# 关键路径报告
report_timing -max_paths 10 -nworst 10

# 时序违例汇总
report_constraint -all_violators

# 时钟网络分析
report_clock_tree -summary
```

### 4. 常见时序问题

| 问题 | 症状 | 解决方案 |
|------|------|----------|
| 长组合逻辑 | 路径延迟大 | 流水线化 |
| 时钟偏移 | skew过大 | 时钟树平衡 |
| 负载过重 | 延迟大 | 缓冲器插入 |
| 互连延迟 | RC延迟大 | 布局优化 |

## 时序收敛流程

```
1. 综合后时序分析
2. 布局规划后时序分析
3. Placement后时序分析
4. Clock Tree前时序分析
5. Clock Tree后时序分析
6. 布线后时序分析 (Signoff)
```

Remember: 时序收敛是物理设计中最具挑战性的任务之一，需要迭代优化。
