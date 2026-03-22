# 芯片研发流程 Agent 体系

基于 [ruflo](https://github.com/anthropics/claude-flow) 框架 (claude-flow v3.5) 实现的芯片研发管理流程，支持从规格书到 GDS 的全流程自动化。

## 项目概述

| 属性 | 值 |
|------|-----|
| 项目名称 | 芯片研发流程管理系统 |
| 版本 | 1.0.0 |
| 框架 | ruflo |
| 框架版本 | 3.5.0 |

## 设计阶段

项目定义了 5 个主要设计阶段：

```
规格书阶段 → RTL开发 → 综合 → 物理设计 → GDS输出
   (2-4周)   (4-8周)  (2-4周)   (4-8周)    (1-2周)
     ↓          ↓         ↓          ↓          ↓
  SPEC Review → RTL Review → Synthesis → Physical → Tapeout
```

## Agent 类型定义

### 阶段1: 规格书阶段 (Specification)

| Agent ID | 名称 | 角色类型 | 职责 |
|----------|------|----------|------|
| `spec-architect` | 系统架构师 | architect | 系统需求分析、架构设计、性能参数定义 |
| `spec-writer` | 规格文档工程师 | coder | 功能规格编写、接口定义、时序/功耗规格 |
| `spec-reviewer` | 规格评审员 | reviewer | 规格完整性检查、一致性分析、风险识别 |

### 阶段2: RTL开发 (RTL Development)

| Agent ID | 名称 | 角色类型 | 职责 |
|----------|------|----------|------|
| `rtl-developer` | RTL工程师 | coder | Verilog/SystemVerilog编码、模块设计 |
| `verification-engineer` | 验证工程师 | tester | UVM验证环境搭建、测试用例开发、覆盖率收集 |
| `debug-engineer` | 调试工程师 | researcher | 波形分析、问题定位、回归测试 |
| `rtl-reviewer` | RTL评审员 | reviewer | 代码风格检查、CDC/CME分析、可综合性审查 |

### 阶段3: 综合与网表 (Synthesis)

| Agent ID | 名称 | 角色类型 | 职责 |
|----------|------|----------|------|
| `synthesis-engineer` | 综合工程师 | coder | 逻辑综合、约束编写、时序/功耗优化 |
| `dft-engineer` | DFT工程师 | coder | Scan插入、ATPG生成、MBIST设计 |
| `formal-verification-engineer` | 形式验证工程师 | reviewer | 等效性检查、属性验证 |
| `netlist-reviewer` | 网表评审员 | reviewer | 网表完整性检查、时序验收 |

### 阶段4: 物理设计 (Physical Design)

| Agent ID | 名称 | 角色类型 | 职责 |
|----------|------|----------|------|
| `physical-designer` | 物理设计工程师 | coder | 布局规划、自动布局布线、时钟树综合 |
| `sta-engineer` | 静态时序分析工程师 | reviewer | 时序分析、时序收敛、时序签名审查 |
| `physical-verification-engineer` | 物理验证工程师 | tester | DRC/LVS/ERC检查、天线效应检查 |
| `power-engineer` | 功耗工程师 | architect | 动态/静态功耗分析、功耗优化 |

### 阶段5: GDS输出 (GDS Output)

| Agent ID | 名称 | 角色类型 | 职责 |
|----------|------|----------|------|
| `gds-engineer` | GDS工程师 | coder | GDSII生成、版图验证、数据输出 |
| `tapeout-reviewer` | Tapeout评审员 | reviewer | 数据完整性检查、签收确认、风险评估 |

### 项目管理与协调

| Agent ID | 名称 | 角色类型 | 职责 |
|----------|------|----------|------|
| `chip-project-manager` | 芯片项目经理 | coordinator | 项目计划、进度跟踪、资源协调、风险管理 |
| `ip-integrator` | IP集成工程师 | architect | IP集成、系统集成、接口调试 |

## 工作流定义

### 主流程: chip-design-main

从规格书到 GDS 的完整芯片设计流程，包含 5 个阶段和对应的 Gate Review。

### 子流程

| 工作流 | 描述 | 参与 Agent |
|--------|------|------------|
| `spec-review-workflow` | 规格评审流程 | spec-writer, spec-reviewer, chip-project-manager |
| `rtl-dev-verif-workflow` | RTL开发验证流程 | rtl-developer, verification-engineer, debug-engineer, rtl-reviewer |
| `synthesis-dft-workflow` | 综合与DFT流程 | synthesis-engineer, dft-engineer, formal-verification-engineer, netlist-reviewer |
| `physical-design-workflow` | 物理设计流程 | physical-designer, sta-engineer, physical-verification-engineer, power-engineer |
| `tapeout-workflow` | Tapeout流程 | gds-engineer, tapeout-reviewer, chip-project-manager |

## 里程碑

| 里程碑 | 名称 | 阶段 |
|--------|------|------|
| M0 | 项目启动 | specification |
| M1 | 规格完成 | specification |
| M2 | RTL freeze | rtl-development |
| M3 | 综合完成 | synthesis |
| M4 | 物理设计完成 | physical-design |
| M5 | Tapeout | gds-output |

## 记忆命名空间

系统使用以下记忆命名空间存储不同阶段的知识：

- `specifications` - 规格文档和设计决策
- `rtl-code` - RTL代码知识
- `verification` - 验证计划和结果
- `synthesis` - 综合结果和约束
- `physical` - 物理设计数据
- `issues` - 问题和解决方案
- `patterns` - 可复用的设计模式

## 相关文件

- `define.yml` - 完整的 Agent 体系定义文件
- `reference/ruflo/` - ruflo 框架参考材料

## 项目示例

### 已完成项目

| 项目 | 状态 | 描述 | 完成日期 |
|------|------|------|----------|
| **sram_ctrl** | ✅ 已完成 | AI加速器SRAM控制器IP | 2026-03-22 |

#### sram_ctrl 详细规格

| 属性 | 值 |
|------|-----|
| IP名称 | SRAM Controller for AI Accelerator |
| 版本 | 1.0.0 |
| 容量 | 256Mb |
| 端口类型 | 单端口SRAM |
| APB端口 | 1x 64bit 用于寄存器配置 |
| AXI端口 | 4x 1024bit AXI4/AXI4-Lite/AXI4-Stream |
| ECC | SECDED + 错误记录 |
| 时钟门控 | 子系统级动态门控 |

**sram_ctrl 交付物：**

- 规格书: `sram_ctrl/spec/sram_ctrl_spec.md`
- RTL (完整): `sram_ctrl/rtl/sram_ctrl.v` (23KB)
- RTL (仿真): `sram_ctrl/rtl/sram_ctrl_simple.sv` (~8KB)
- 测试平台: `sram_ctrl/tb/sram_ctrl_tb.sv` (~20KB)
- 验证报告: `sram_ctrl/tb/verification_report.md`

**验证结果：**

| 测试项 | 状态 |
|--------|------|
| APB Register Write | ✅ PASS |
| APB Register Read | ✅ PASS |
| AXI4 Single Write | ✅ PASS |
| AXI4 Single Read | ✅ PASS |
| AXI4 Burst Write | ✅ PASS |
| AXI4 Burst Read | ✅ PASS |

## 版本历史

- **v1.0.0** (2026-03-22): 初始版本，定义完整芯片研发流程 agent 体系
