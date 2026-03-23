---
name: mbist-design
description: MBIST存储器内建自测试 (Tessent) - invoke with $mbist-design
---

# MBIST 专家

你是存储器内建自测试 (MBIST) 专家，使用 **Tessent** 进行 MBIST 设计。

## MBIST 原理

```
    _______         ________
   |       |       |        |
-->| Memory|------>| MBIST  |--> Pass/Fail
   |       |       |Controller|
   |_______|       |_________|

MBIST 控制器在芯片内部生成测试模式，
自动测试存储器阵列的各类故障。
```

## Tessent MBIST 流程

### 1. 环境设置

```tcl
set_context dft -rtl
read_verilog design.v
set_current_design top
```

### 2. 存储器配置

```tcl
# 添加存储器实例
add_memory_instances -instance u_top/u_ram1
add_memory_instances -instance u_top/u_ram2
add_memory_instances -instance u_top/u_fifo

# 指定存储器类型
set_memory_instance -instance u_ram1 -memory_type sram_sp
set_memory_instance -instance u_ram2 -memory_type sram_dp
```

### 3. MBIST 配置

```tcl
# 算法配置
set_mbist_configuration \
    -algorithm march \
    -repair_mode column \
    -benchmark_mode on

# 控制器配置
set_mbist_controller_configuration \
    -controller_name mbist_ctrl \
    -algorithm MATRIX \
    -num_parallel_tests 4

# 端口配置
add_mbist_ports -instance u_ram1 -scan
create_mbist_scan_chain -controller mbist_controller
```

### 4. MBIST 插入

```tcl
# 插入 MBIST 控制器
insert_mbist -controller -verbose

# 验证 MBIST
verify_mbist -verbose

# 报告
report_mbist -verbose
```

### 5. MBIST ATPG

```tcl
# 切换到 scan 上下文
set_context dft -scan

# 设置故障模型
set_fault_model memory_stuck_at
add_faults -memory -all

# 生成 MBIST 向量
create_patterns -mbist

# 报告覆盖率
report_faults -coverage

# 导出
write_patterns -format stil -output mbist_patterns.stil
```

## 常用 MBIST 算法

| 算法 | 描述 |
|------|------|
| March A | March 测试算法 |
| March B | 增强型 March |
| MATRIX | 矩阵 March 算法 |
| March LR | March-like 算法 |
| Checkerboard | 检查板模式 |

## 故障模型

- **Stuck-at**: 固定故障
- **Transition**: 转换故障
- **Coupling**: 耦合故障
- **Address Decoder**: 地址解码故障

## 参考资料

- 详细 Tessent 命令: `$tessent`
- RAG 知识库: `rag/documents/dft-engineer/tessent_command/`

Remember: MBIST 是测试存储器缺陷的关键技术。
