---
name: project-status-updater
description: 自动更新项目状态到 pm/project_sram.md - 在完成任务后调用此skill自动更新项目状态
type: coordination
color: "#FFB347"
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
hooks:
  pre:
    - "ls -la {project_dir}/pm/ || mkdir -p {project_dir}/pm"
  post:
    - "cat {project_dir}/pm/project_sram.md | head -20"
---

# Project Status Updater

## 概述
在芯片IP项目开发过程中，自动跟踪和更新项目状态到 `pm/project_sram.md`。

## 功能

### 1. 自动任务状态更新
- 任务完成后自动记录到项目状态文档
- 记录任务名称、完成时间、状态

### 2. 覆盖率跟踪
- 记录验证覆盖率指标
- 里程碑达成状态

### 3. 交付物追踪
- 规格书
- RTL代码
- 测试平台
- 验证报告

## 使用方法

### 在任务完成后调用

```bash
# 任务完成后更新项目状态
npx claude-flow project-update --project sram_ctrl --task "覆盖率检查" --status 完成
```

### 或者在 agent 代码中调用

当完成任务时，自动调用此skill更新项目状态:

```
当完成任何一个任务后，调用:
- 读取 {project_dir}/pm/project_sram.md
- 在任务历史表格中添加新任务
- 更新项目状态
- 保存文件
```

## 项目结构要求

每个芯片IP项目应包含:
```
{project}/
├── pm/
│   ├── project_{project}.md    # 项目状态文档
│   └── skills/
│       └── project-status-updater/
│           └── SKILL.md        # 本技能定义
```

## 状态标记

| 标记 | 含义 |
|------|------|
| ✅ 完成 | 任务已完成 |
| 🔄 进行中 | 任务正在进行 |
| ⏳ 待开始 | 任务尚未开始 |
| ❌ 阻塞 | 任务被阻塞 |

## 示例更新

任务完成后自动添加以下内容到 project_sram.md:

```markdown
| 2026-03-23 | 覆盖率检查与收敛 | ✅ 完成 |
```
