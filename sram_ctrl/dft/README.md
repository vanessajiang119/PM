# sram_ctrl DFT Scripts

本目录包含用于 sram_ctrl IP 的 Tessent DFT 脚本。

## 目录结构

```
dft/
├── run_tessent_scan.tcl      # Scan 插入脚本
├── run_tessent_mbist.tcl     # MBIST 插入脚本
├── run_tessent_atpg.tcl      # ATPG 向量生成脚本
├── run_tessent_dft.tcl       # 完整 DFT 流程
├── Makefile                  # 构建脚本
└── README.md                 # 本文件
```

## 使用方法

### 前提条件

1. 安装 Tessent Shell (Siemens EDA)
2. 设置环境变量

```bash
export TESSENT_HOME=/path/to/tessent
export PATH=$TESSENT_HOME/bin:$PATH
```

### 运行 DFT 流程

#### 方法1: 使用 Makefile

```bash
cd dft

# 完整 DFT 流程
make dft

# 或分步执行
make scan      # Scan 插入
make mbist     # MBIST 插入
make atpg      # ATPG 向量生成
```

#### 方法2: 直接运行 TCL 脚本

```bash
cd dft
tessent_shell -f run_tessent_dft.tcl
```

## 输出文件

运行后将生成以下文件：

```
dft_output/
├── sram_ctrl_dft.v           # DFT 插入后的 Verilog 网表
├── sram_ctrl_dft.sdc         # DFT 时序约束
├── dft_statistics.rpt        # DFT 统计报告
├── scan_chains.rpt           # Scan 链报告
├── mbist_report.rpt          # MBIST 报告
├── coverage.rpt              # 覆盖率报告
└── patterns/
    ├── sram_ctrl.stil        # STIL 格式测试向量
    └── sram_ctrl.vcd         # VCD 格式测试向量
```

## 脚本说明

### 1. run_tessent_scan.tcl

- 读取 RTL 设计
- 配置 Scan 链（4条链）
- 执行 Scan 插入
- 报告 Scan 统计

### 2. run_tessent_mbist.tcl

- 配置外部 SRAM MBIST
- 插入 MBIST 控制器
- 验证 MBIST 电路

### 3. run_tessent_atpg.tcl

- 加载 DFT 设计
- 设置故障模型 (stuck-at)
- 生成测试向量
- 导出多种格式

### 4. run_tessent_dft.tcl

完整的端到端 DFT 流程：
1. 读取设计
2. Scan 配置
3. MBIST 配置
4. DRC 检查
5. DFT 插入
6. 报告生成
7. ATPG 向量生成

## 设计信息

- **模块**: sram_ctrl
- **接口**: APB + AXI4 + SRAM
- **Scan 链数**: 4
- **故障模型**: stuck-at
- **ATPG 风格**: fastseq

## 注意事项

1. 需要有效的 Tessent 许可证
2. 确保 RTL 路径正确
3. SDC 约束文件需要包含测试时钟定义
