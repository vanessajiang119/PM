# Tessent JTAG 命令参考

> 来源: RAG 知识库 - Tessent Shell 用户手册 v2024.2

**提示**: Tessent 是 Siemens EDA 的 DFT 解决方案。所有 DFT 工作优先使用 Tessent 工具。数据来自 `rag/documents/dft-engineer/tessent_command/` 目录下的知识库。

---

## 1. 边界扫描命令 (Boundary Scan - IEEE 1149.1)

| 命令名称 | 用途说明 |
|---------|---------|
| `insert_boundary_scan` | 插入 IEEE 1149.1 边界扫描架构，自动连接 TAP (Test Access Port) 控制器和边界扫描单元 |
| `report_boundary_scan` | 报告边界扫描配置信息，包括扫描链数量、端口状态等 |
| `set_boundary_scan_port_option` | 设置边界扫描端口选项，如输入/输出模式、上拉电阻等 |
| `set_boundary_scan_port_options` | 批量设置多个边界扫描端口的配置参数 |
| `report_boundary_scan_port_options` | 报告当前边界扫描端口的配置状态 |

---

## 2. IJTAG 命令 (IEEE 1687 - 内建自测试)

| 命令名称 | 用途说明 |
|---------|---------|
| `read_icl` | 读取 ICL (Instrument Connectivity Language) 文件，定义 IJTAG 网络的 instruments 和互相连接 |
| `create_icl_network` | 根据 ICL 描述创建完整的 IJTAG 网络拓扑结构 |
| `create_icl_setup_patterns` | 生成 IJTAG 初始化设置模式，用于配置 instruments |
| `create_icl_flush_patterns` | 生成 IJTAG 刷新模式，用于数据刷新操作 |
| `create_icl_verification_patterns` | 生成验证模式，用于验证 IJTAG 网络正确性 |
| `write_icl` | 输出 ICL 网络描述文件 |
| `add_ijtag_logical_connection` | 添加 IJTAG 逻辑连接，定义 instrument 之间的数据路径 |
| `add_ijtag_logical_connections` | 批量添加多个 IJTAG 逻辑连接 |
| `get_ijtag_instances` | 获取设计中所有 IJTAG instrument 实例 |
| `get_ijtag_instance_option` | 获取特定 IJTAG instrument 的选项配置 |
| `set_ijtag_instance_options` | 设置 IJTAG instrument 的选项参数 |
| `report_ijtag_instances` | 报告所有 IJTAG instrument 的信息 |
| `report_ijtag_logical_connections` | 报告 IJTAG 逻辑连接的配置 |
| `get_ijtag_retargeting_options` | 获取 IJTAG 重定向选项（用于跨 die 测试） |
| `set_ijtag_retargeting_options` | 设置 IJTAG 重定向选项参数 |
| `create_ijtag_graybox` | 创建 IJTAG 灰盒模型，用于行为级仿真 |

---

## 3. SSN 同时开关噪声命令

| 命令名称 | 用途说明 |
|---------|---------|
| `add_buffers_on_jtag_signal_sources` | 在 JTAG 信号源上添加缓冲器，减少 SSN 噪声 |
| `add_icl_ssn_datapaths` | 添加 SSN 数据路径用于噪声分析 |
| `get_icl_ssn_datapath_list` | 获取 ICL SSN 数据路径列表 |
| `get_icl_ssn_datapath_ports` | 获取 ICL SSN 数据路径端口 |
| `set_icl_ssn_datapath_ports` | 设置 ICL SSN 数据路径端口 |
| `get_default_ssn_datapath_configuration` | 获取默认 SSN 数据路径配置 |
| `set_default_ssn_datapath_configuration` | 设置默认 SSN 数据路径配置 |
| `get_ssn_datapath_option` | 获取 SSN 数据路径选项 |
| `set_ssn_datapath_options` | 设置 SSN 数据路径选项 |
| `report_default_ssn_datapath_configuration` | 报告默认 SSN 数据路径配置 |

---

## 4. 典型使用流程

```tcl
# 1. 设置上下文
set_context dft -boundary_scan

# 2. 读取 ICL 定义 (IJTAG)
read_icl design.icl

# 3. 创建 IJTAG 网络
create_icl_network

# 4. 插入边界扫描
insert_boundary_scan

# 5. 配置 JTAG 信号
set_dft_signal -type scanin -port TDI
set_dft_signal -type scanout -port TDO
set_dft_signal -type scan_enable -port TMS
set_dft_signal -type scan_clock -port TCK

# 6. 报告结果
report_boundary_scan
report_ijtag_instances
```

---

## 5. 命令分类总结

| 标准 | 说明 | 命令数量 |
|-----|------|---------|
| IEEE 1149.1 | Classic JTAG - 边界扫描链、TAP控制器 | 5 |
| IEEE 1687 | IJTAG - 内建自测试网络、可编程instrument | 16 |
| SSN | 同时开关噪声分析相关命令 | 10 |

---

## 6. 相关标准

- **IEEE 1149.1**: Standard Test Access Port and Boundary-Scan Architecture
- **IEEE 1687**: Embedded Core Test (IJTAG)
- **SSN**: Simultaneous Switching Noise analysis

---

> 数据来源: Tessent Shell Reference Manual, v2024.24
> 存储位置: rag/documents/dft-engineer/tessent_command/
