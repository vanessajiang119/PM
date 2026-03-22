# Define.yml Integration Plan

## Summary of Changes

### 1. New Agents to Add (for RTL Verification)

```yaml
# New agent definitions to add after rtl-reviewer

# rtl-editor: Edit RTL based on review feedback
- id: "rtl-editor"
  name: "RTL编辑器"
  type: "coder"
  phase: "rtl-development"
  description: "根据审查反馈修改RTL代码"
  capabilities:
    - "定位并修复设计错误"
    - "优化代码结构和性能"
    - "修复时序问题"
  tools:
    - "memory-store"
    - "task-create"

# simulator: Run RTL simulation
- id: "simulator"
  name: "仿真工程师"
  type: "tester"
  phase: "rtl-development"
  description: "编译并运行RTL仿真"
  capabilities:
    - "使用iverilog编译"
    - "使用verilator仿真"
    - "生成仿真报告"
  tools:
    - "bash"
    - "memory-store"

# sim-reviewer: Review simulation results
- id: "sim-reviewer"
  name: "仿真审查员"
  type: "reviewer"
  phase: "rtl-development"
  description: "分析仿真结果，识别设计错误"
  capabilities:
    - "解析仿真输出"
    - "识别失败原因"
    - "生成问题报告"
  tools:
    - "memory-search"
    - "memory-store"

# sim-judge: Make verification decisions
- id: "sim-judge"
  name: "验证决策员"
  type: "reviewer"
  phase: "rtl-development"
  description: "综合验证结果做出最终判定"
  capabilities:
    - "评估测试通过率"
    - "检查覆盖率"
    - "做出pass/fail判定"
  tools:
    - "memory-search"
    - "task-status"

# coverage-analyzer: Analyze coverage
- id: "coverage-analyzer"
  name: "覆盖率分析员"
  type: "tester"
  phase: "rtl-development"
  description: "分析代码覆盖率和功能覆盖率"
  capabilities:
    - "分析行覆盖率"
    - "分析分支覆盖率"
    - "生成覆盖率报告"
  tools:
    - "bash"
    - "memory-store"
```

### 2. Updated Agents (add eda_agent capabilities)

#### spec-architect (existing agent-1)
- Add skill: spec_enrichment (from spec_enrichment_skill)

#### rtl-developer (existing agent-4)
- Add tool: bash (for running EDA tools)
- Add capability: "遵循SPEC注释规范"

#### rtl-reviewer (existing agent-7)
- Add skill: verilog_code_review
- Add mcp_tools: verilog_syntax_check, verilog_list_modules

#### verification-engineer (existing agent-5)
- Add capability: "生成SystemVerilog测试台"
- Add skill: tb_generator

### 3. New Skills to Add

```yaml
# Add to skills section

- id: "spec_enrichment"
  name: "规格补全"
  description: "根据基本模块规格自动补全完整设计规格"
  type: "skill"
  module: "spec_enrichment_skill"

- id: "verilog_code_review"
  name: "Verilog代码审查"
  description: "审查Verilog代码并验证SPEC合规性"
  type: "skill"
  module: "verilog_code_review_skill"
  compatibility: ["verilog_mcp"]

- id: "verilog_mcp"
  name: "Verilog MCP工具"
  description: "Verilog语法检查和分析的MCP工具"
  type: "mcp"
  tools:
    - verilog_syntax_check
    - verilog_list_modules
    - verilog_analyze_signals
```

### 4. Updated Workflow

Replace the simple "RTL开发验证流程" with the detailed eda_agent flow:

```yaml
- id: "rtl-dev-verif-workflow"
  name: "RTL开发验证流程"
  description: "RTL代码开发和验证的完整流程 (EDA Agent风格)"
  topology: "hierarchical"
  max_agents: 8
  strategy: "specialized"
  agents:
    - "rtl-developer"
    - "rtl-reviewer"
    - "rtl-editor"
    - "verification-engineer"
    - "tb_generator"
    - "simulator"
    - "sim-reviewer"
    - "sim-judge"
  steps:
    - "规格解析 (spec_parser)"
    - "RTL生成 (rtl_generator)"
    - "RTL代码审查 (rtl_code_review)"
    - "生成测试台 (tb_generator)"
    - "运行仿真 (simulator)"
    - "覆盖率分析 (coverage_analyzer)"
    - "仿真审查 (sim_reviewer)"
    - "验证决策 (sim_judge)"
    - "如失败则RTL编辑 (rtl_editor) - 循环回到仿真"
```

### 5. New Configuration Section

Add MCP tools configuration:

```yaml
# =============================================================================
# MCP工具配置
# =============================================================================
mcp_tools:
  verilog_tools:
    - name: "iverilog"
      description: "ICARUS Verilog 编译器"
      version: ">=12.0"
    - name: "verilator"
      description: "Verilog仿真和lint工具"

  mcp_servers:
    - name: "verilog_mcp"
      description: "Verilog代码分析MCP服务器"
      path: "/root/workspace/eda_agent/verilog_mcp"
      tools:
        - verilog_syntax_check
        - verilog_list_modules
        - verilog_analyze_signals
```

## Files to Create

1. `skills/spec_enrichment/` - Copy from eda_agent
2. `skills/verilog_code_review/` - Copy from eda_agent
3. Update `define.yml` with new agents and workflows

## Agent ID Mapping

| Current ID | Agent Name | New ID (if added) | Agent Name |
|------------|------------|-------------------|------------|
| 1 | spec-architect | - | - |
| 2 | spec-writer | - | - |
| 3 | spec-reviewer | - | - |
| 4 | rtl-developer | - | - |
| 5 | verification-engineer | - | - |
| 6 | debug-engineer | - | - |
| 7 | rtl-reviewer | - | - |
| 8 | synthesis-engineer | - | - |
| 9 | dft-engineer | - | - |
| 10 | formal-verification-engineer | - | - |
| 11 | netlist-reviewer | - | - |
| 12 | physical-designer | - | - |
| 13 | sta-engineer | - | - |
| 14 | physical-verification-engineer | - | - |
| 15 | power-engineer | - | - |
| 16 | gds-engineer | - | - |
| 17 | tapeout-reviewer | - | - |
| 18 | chip-project-manager | - | - |
| 19 | ip-integrator | - | - |
| - | - | 20 | rtl-editor |
| - | - | 21 | simulator |
| - | - | 22 | sim-reviewer |
| - | - | 23 | sim-judge |
| - | - | 24 | coverage-analyzer |
