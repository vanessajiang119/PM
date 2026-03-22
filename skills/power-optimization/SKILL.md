---
name: power-optimization
description: 功耗优化技术 - invoke with $power-optimization
---

# 功耗优化专家

你是芯片功耗优化专家，专注于降低芯片的动态功耗和静态功耗。

## 功耗类型

```
总功耗 = 动态功耗 + 静态功耗

动态功耗:
- 开关功耗: P_sw = 0.5 * V^2 * f * C_load * activity
- 短路功耗: P_sc = V * I_sc * f

静态功耗:
- 泄漏功耗: P_leak = V * I_leak
  - 亚阈值泄漏
  - 结泄漏
  - 栅极泄漏
```

## 功耗优化技术

### 1. 动态功耗优化

```tcl
# ============================================
# 时钟门控
# ============================================

# 自动插入门控时钟
set_clock_gating_style -sequential_cell latch
insert_clock_gating

# 手动门控
set_clock_gating_signal -gate_clock [get_pins u_module/clk_gate]

# ============================================
# 多电压设计
# ============================================

# 定义电压域
create_power_domain -name CORE -domain default
create_power_domain -name MEM -elements {u_mem}

# 设置电压
set_voltage -domain CORE -voltage 1.0
set_voltage -domain MEM -voltage 0.9

# ============================================
# 频率调节
# ============================================

# DVFS设置
set_dynamic_power_options -enable_dvfs
```

### 2. 静态功耗优化

```tcl
# ============================================
# 功率门控
# ============================================

# 定义断电逻辑
create_power_switch -domain PD1 \
    -external_off_pin u_pgctrl/off \
    -output_pin u_pgctrl/pg_out

# ============================================
# 阈值电压优化
# ============================================

# 使用多重阈值单元
set_library_attribute -library stdcell_lvt \
    -attribute default_threshold_cell_voltage 0.7

set_library_attribute -library stdcell_hvt \
    -attribute default_threshold_cell_voltage 1.0

# 关键路径用LVT
set_cost_priority -delay
```

### 3. RTL级功耗优化

```systemverilog
// 减少开关活动
module power_opt (
    input  logic clk, rst_n,
    input  logic [7:0] data,
    input  logic       enable,
    output logic [7:0] out
);

    // ❌ 不推荐: enable直接控制数据
    // assign out = enable ? data : 8'h00;

    // ✅ 推荐: 使用门控时钟
    logic gated_clk;
    assign gated_clk = clk & enable;

    always_ff @(posedge gated_clk or negedge rst_n) begin
        if (!rst_n)
            out <= '0;
        else
            out <= data;
    end
endmodule
```

### 4. 功耗分析

```tcl
# 功耗报告
report_power -analysis_effort high -hierarchical

# 模式分析
report_power -mode active
report_power -mode standby

# 功耗分解
report_power -format {core logic:%.2f, memory:%.2f, io:%.2f}
```

## 功耗优化检查清单

- [ ] 时钟门控覆盖率 > 90%
- [ ] 多电压域设计
- [ ] 使用高阈值单元
- [ ] 减少不必要的开关活动
- [ ] 断电不使用模块
- [ ] 功耗签收

Remember: 功耗优化需要在设计早期就开始考虑，并在整个设计流程中持续优化。
