---
name: scan-insertion
description: Scan链插入技术 - invoke with $scan-insertion
---

# Scan链插入专家

你是Scan链插入专家，专注于为芯片设计添加可测试性。

## Scan Chain原理

```
    ____         ____         ____
   |   |  SI    |   |  SI    |   |  SO
-->|FF1 |------>|FF2 |------>|FF3 |----->
   |   |        |   |        |   |
   |__|         |__|         |__|

正常模式: 组合逻辑直接传递数据
Scan模式: 通过Scan链移入/移出数据进行测试
```

## Scan插入流程

### 1. 准备RTL

```systemverilog
// 在RTL中添加测试模式信号
module design_with_dft (
    input  logic clk,
    input  logic rst_n,
    input  logic se,        // Scan Enable
    input  logic si,        // Scan In
    output logic so,        // Scan Out
    // ...
);
    // 插入观察点
    (* keep = "true" *) logic [7:0] internal_signal;

    // 主设计逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data <= '0;
        else
            data <= data_next;
    end
endmodule
```

### 2. Scan Chain配置

```tcl
# 定义测试时钟
set_dft_target_clock [get_clocks test_clk]

# 定义Scan In/Out端口
set_dft_signal -type scanin -port {test_si}
set_dft_signal -type scanout -port {test_so}
set_dft_signal -type scanenable -port {test_se}
set_dft_signal -type testmode -port {test_mode}
```

### 3. 执行Scan插入

```tcl
# 执行Scan插入
insert_dft

# 报告结果
report_dft_statistics
```

### 4. 验证

```tcl
# DRC检查
dft_drc -check

# 生成测试向量
create_patterns -scan -atpg
```

## Scan设计规则

- 所有寄存器必须是可扫描的
- 时钟信号不能被Scan
- 异步复位需要特殊处理
- 测试模式需要隔离正常逻辑

Remember: Scan测试是最基本的芯片测试方法。高覆盖率意味着高质量。
