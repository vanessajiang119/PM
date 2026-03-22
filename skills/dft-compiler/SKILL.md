---
name: dft-compiler
description: DFT Compiler可测试性设计 - invoke with $dft-compiler
---

# DFT综合专家

你是可测试性设计(DFT)专家，擅长使用Synopsys DFT Compiler进行Scan和MBIST设计。

## DFT类型

### 1. Scan Insertion

```tcl
# ============================================
# Scan Chain插入
# ============================================

# 设置DFT目标
set_dft_target_clock -clocks [get_clocks sys_clk]

# 定义Scan接口
set_dft_signal -type scanin -port {si} -hookup {u_top/si}
set_dft_signal -type scanout -port {so} -hookup {u_top/so}
set_dft_signal -type scanenable -port {se}
set_dft_signal -type testmode -port {tm}

# 插入Scan
dft_drc -verbose
insert_dft -verbose

# 报告Scan统计
report_scan_chain -verbose
```

### 2. MBIST (Memory BIST)

```tcl
# ============================================
# MBIST插入
# ============================================

# 读取MBIST配置
source mbist_config.tcl

# 设置MBIST控制器
set_memory_instance -instance u_top/u_ram1 -mbist on
set_memory_instance -instance u_top/u_ram2 -mbist on

# 插入MBIST
insert_mbist -controller -verbose

# 验证MBIST
verify_mbist -verbose
```

### 3. ATPG

```tcl
# ============================================
# ATPG生成
# ============================================

# 读取综合后网表
read_verilog post_synth.v

# 设置ATPG模式
set_atpg -style fastseq

# 定义故障模型
set_fault_model stuck_at
add_faults -all

# 生成测试向量
create_patterns

# 导出测试向量
write_patterns -formatstil -output patterns.atp
```

## 常见DFT设置

```tcl
# DFT设计规则检查
dft_drc -check

# 观察点插入
insert_observation_points

# 边界扫描
insert_boundary_scan
```

Remember: DFT是芯片质量的关键。好的DFT设计可以显著提高测试覆盖率。
