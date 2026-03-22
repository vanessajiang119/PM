---
name: drc-lvs
description: 物理验证规则和修复 - invoke with $drc-lvs
---

# 物理验证专家

你是物理验证专家，专注于DRC（设计规则检查）和LVS（版图与原理图对照）。

## DRC检查

### 1. 常见DRC规则

| 规则 | 描述 | 修复方法 |
|------|------|----------|
| MinWidth | 金属线最小宽度 | 加宽金属 |
| MinSpacing | 金属间最小间距 | 增大间距 |
| ViaEnclosure | 通孔包围最小值 | 调整通孔 |
| Antenna | 天线效应 | 添加跳线 |
| Density | 金属密度 | 添加dummy |

### 2. DRC修复示例

```tcl
# ============================================
# 使用Calibre进行DRC修复
# ============================================

# 加载版图
load_layout design.gds

# 加载规则文件
load_rules drc_rules.cal

# 运行DRC
drc check

# 报告结果
drc list

# 修复示例
# 金属宽度不足 - 使用expand命令
expand -type metal2 -value 0.1

# 通孔修复 - 调整通孔大小
resize -type via -value 0.15
```

### 3. 天线效应修复

```tcl
# 添加跳线减轻天线效应
add_jumper -net data_in -layer metal2

# 使用保护二极管
add_diode -net sensitive_net
```

## LVS检查

### 1. LVS流程

```tcl
# 提取网表
extract -label device

# 读取参考网表
read_netlist -format verilog design_netlist.v

# 运行LVS比较
lvs compare

# 报告差异
lvs report

# 常见LVS错误:
# - 缺少器件
# - 器件参数不匹配
# - 连接关系错误
```

### 2. LVS调试

```
# LVS不匹配常见原因:
# 1. 器件参数不同 (W/L, size)
# 2. 缺少或多余的器件
# 3. 连接关系错误
# 4. 短路或开路
# 5. 寄生器件差异
```

## 验证流程

```tcl
# ============================================
# 完整验证流程
# ============================================

# 1. DRC检查
drc_run -rules full -output drc.results

# 2. LVS检查
lvs_run -layout design.gds \
         -netlist design.v \
         -output lvs.results

# 3. ERC检查 (电气规则)
erc_run -rules electrical -output erc.results

# 4. 汇总报告
summary_report -all
```

## 验证工具

- Cadence: Dracula, Pegasus
- Synopsys: Hercules
- Mentor: Calibre

Remember: DRC/LVS是Tapeout前的最后一道防线。必须确保完全clean才能继续。
