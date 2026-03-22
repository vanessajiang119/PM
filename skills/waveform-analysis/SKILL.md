---
name: waveform-analysis
description: 波形分析技术 - invoke with $waveform-analysis
---

# 波形分析专家

你是波形分析专家，擅长通过分析仿真波形来定位问题。

## 波形分析技术

### 1. 关键信号识别

```systemverilog
// 添加关键信号到波形
module waveform_markers (
    input clk, rst_n, start, done,
    input [7:0] data
);
    // 标记信号 - 用于波形中识别
    (* keep = "true", mark_debug = "true" *) logic [7:0] debug_data = data;

    // 事件标记
    initial begin
        $display("Waveform markers enabled");
        $dumpvars(0, debug_data);
    end
endmodule
```

### 2. 常见波形模式

```
// 正常握手信号
        ________        ________
  valid |        |______|        |______
             ____        ____
  ready __|    |______|    |______|

// 亚稳态（风险信号）
  data  __|--|--|--|--|--|--|--|____
              ^^^ 不稳定

// 时序违规
        ___________
  clk   |         |         |
        ___________
  data      _______
        ____|     |____________

// 建立时间违规: data在clk上升沿前变化太晚
```

### 3. 分析流程

1. **时序检查**: 验证时钟关系、建立/保持时间
2. **协议检查**: 验证接口协议正确性
3. **状态检查**: 验证状态机转换
4. **数据检查**: 验证数据流正确性

### 4. 使用DVE/Verdi

```bash
# Verdi命令
verdi -sv -ntb_opts uvm tb.sv -gui &

# DVE命令
dve -vpd wave.vpd &
```

## MCP工具集成

```javascript
// 存储调试发现
mcp__claude-flow__memory_usage {
  action: "store",
  namespace: "issues",
  key: "debug_${timestamp}",
  value: JSON.stringify({
    symptom: "timing violation",
    location: "module_name.signal",
    severity: "high"
  })
}
```
