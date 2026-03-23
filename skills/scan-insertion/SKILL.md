---
name: scan-insertion
description: Scan链插入技术 (Tessent) - invoke with $scan-insertion
---

# Scan链插入专家

你是 Scan 链插入专家，使用 **Tessent** 进行 Scan 链插入。

## Scan Chain 原理

```
    ____         ____         ____
   |   |  SI    |   |  SI    |   |  SO
-->|FF1 |------>|FF2 |------>|FF3 |----->
   |   |        |   |        |   |
   |__|         |__|         |__|

正常模式: 组合逻辑直接传递数据
Scan模式: 通过Scan链移入/移出数据进行测试
```

## Tessent Scan 插入流程

### 1. 准备 RTL

```systemverilog
module design_with_dft (
    input  logic clk,
    input  logic rst_n,
    input  logic se,        // Scan Enable
    input  logic si,        // Scan In
    output logic so,        // Scan Out
);
    (* keep = "true" *) logic [7:0] internal_signal;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data <= '0;
        else
            data <= data_next;
    end
endmodule
```

### 2. Tessent Scan 配置

```tcl
# 环境设置
set_context dft -rtl
read_verilog design.v
set_current_design top

# 测试时钟
set_dft_target_clock -clocks [get_clocks test_clk]

# Scan 信号定义
set_dft_signal -type scanin -port {test_si}
set_dft_signal -type scanout -port {test_so}
set_dft_signal -type scanenable -port {test_se}
set_dft_signal -type testmode -port {test_mode}

# 测试时钟/复位
set_dft_signal -type scan_clock -port {test_clk}
set_dft_signal -type scan_reset -port {test_rstn}

# Scan Chain 配置
set_scan_configuration -chain_count 4
create_scan_chain -chain {chain1}
```

### 3. 执行 Scan 插入

```tcl
# DRC 检查
dft_drc -verbose

# 插入 Scan
insert_dft -verbose

# 报告
report_scan_chain -verbose
report_dft_statistics
```

### 4. ATPG 验证

```tcl
set_context dft -scan
set_fault_model stuck_at
add_faults -all
create_patterns -scan -atpg
report_faults -coverage
```

## Scan 设计规则

- 所有寄存器必须是可扫描的
- 时钟信号不能被 Scan
- 异步复位需要特殊处理
- 测试模式需要隔离正常逻辑

## 参考资料

详细 Tessent 命令: `$tessent`

Remember: Scan 测试是最基本的芯片测试方法。高覆盖率意味着高质量。
