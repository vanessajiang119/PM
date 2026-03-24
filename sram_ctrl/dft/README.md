# sram_ctrl DFT Scripts

严格按照 Tiling Flow v2023.4 参考流程生成的 DFT 执行脚本。

## 参考流程

基于: `rag/documents/dft-engineer/tessent_command/flow_scripts/external_circuits_solutions_tiling_flow_bscan_mbist_mbisr_ssn_v2023.4/workspace/c1/`

## 目录结构

```
dft/
├── Makefile                          # 构建自动化
├── workspace/                        # Tiling Flow 流程脚本
│   ├── 01_sram_ctrl_dft_rtl1         # BSCAN + IJTAG 配置
│   ├── 02_sram_ctrl_dft_rtl2         # MBIST 配置
│   ├── 03_sram_ctrl_dft_rtl3         # 完整 DFT 配置
│   ├── 04_sram_ctrl_synthesis        # 门级综合
│   ├── 05_sram_ctrl_dft_gate         # 门级 DFT 插入
│   ├── 06_sram_ctrl_dft_sim_gate     # 门级仿真
│   ├── 07_sram_ctrl_int_edt_mode_stuck   # 内部 EDT stuck-at
│   ├── 08_sram_ctrl_int_edt_mode_tdf     # 内部 EDT TDF
│   ├── 09_sram_ctrl_ext_edt_mode_stuck   # 外部 EDT stuck-at
│   └── 10_sram_ctrl_ext_edt_mode_tdf     # 外部 EDT TDF
├── library/                          # 单元库
└── README.md
```

## 使用方法

### 前提条件

1. Tessent Shell (Siemens EDA)
2. Design Compiler
3. 单元库文件:
   - `library/cells/adk.tcelllib`
   - `library/cells/adk.lib`
   - `library/cells/adk.v`

### 执行流程

```bash
cd dft

# 完整 DFT 流程
make dft

# 或分步执行
make rtl1    # BSCAN 配置
make rtl2    # MBIST 配置
make rtl3    # 完整 DFT 配置
make synth   # 综合
make gate    # 门级 DFT 插入
make atpg    # ATPG 向量生成
```

### 单独运行某个阶段

```bash
# RTL 阶段
cd workspace
tessent -shell -log 01_sram_ctrl_dft_rtl1.log -replace -dofile 01_sram_ctrl_dft_rtl1

# ATPG 阶段
tessent -shell -log 07_sram_ctrl_int_edt_mode_stuck.log -replace -dofile 07_sram_ctrl_int_edt_mode_stuck
```

## 流程阶段说明

| 阶段 | 脚本 | 描述 | 参考命令 |
|------|------|------|---------|
| RTL1 | 01_*_dft_rtl1 | BSCAN 初始化, IJTAG graybox | `set_context dft -rtl -design_id rtl1` |
| RTL2 | 02_*_dft_rtl2 | MBIST 配置 | `set_context dft -rtl -design_id rtl2` |
| RTL3 | 03_*_dft_rtl3 | 逻辑测试配置, EDT | `set_context dft -rtl -design_id rtl3` |
| 综合 | 04_*_synthesis | DC 综合 | `dc_shell -f *.dc_synth_script` |
| Gate | 05_*_dft_gate | 门级 DFT 插入 | `set_context dft -scan` |
| 仿真 | 06_*_dft_sim_gate | 门级仿真 | `run_testbench_simulations` |
| ATPG | 07-10_* | ATPG 向量生成 | `set_context patterns -scan` |

## ATPG 模式说明

| 脚本 | 模式 | 故障模型 | 描述 |
|------|------|---------|------|
| 07 | Internal EDT | Stuck-at | 内部压缩模式 stuck-at 故障 |
| 08 | Internal EDT | TDF | 内部压缩模式跳变延迟故障 |
| 09 | External EDT | Stuck-at | 外部压缩模式 stuck-at 故障 |
| 10 | External EDT | TDF | 外部压缩模式跳变延迟故障 |

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| TESSENT | tessent | Tessent Shell 路径 |
| DC | dc_shell | Design Compiler 路径 |
| LC | lc_shell | Library Compiler 路径 |
| NO_EXIT | 0 | 设为 1 避免自动退出 |
| SKIP_SIMS | 0 | 设为 1 跳过仿真 |

## 输出文件

运行后在 workspace 目录生成:

```
workspace/
├── *.log              # 运行日志
├── *.ddc              # 设计数据库
├── *.vg               # 门级 Verilog
├── tsdb_outdir/       # TSDB 输出目录
│   └── dft_inserted_designs/
│       └── sram_ctrl_gate.dft_inserted_design/
│           └── sram_ctrl.vg
```

## 注意事项

1. 脚本严格按照参考模板编写，使用相同的命令格式
2. 需要有效的 Tessent 和 Design Compiler 许可证
3. 首次运行需要配置单元库 (`library/cells/adk.*`)
4. RTL 文件路径根据实际情况调整
