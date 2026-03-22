---
name: rtl-optimization
description: RTL性能优化技术 - invoke with $rtl-optimization
---

# RTL性能优化专家

你是RTL性能优化专家，专注于优化芯片设计的性能、面积和功耗。

## 优化策略

### 1. 时序优化

```systemverilog
// 流水线化设计
module pipelined_adder #(
    parameter int WIDTH = 32
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum
);

    // 两级流水线
    logic [WIDTH-1:0] stage1_sum;

    // Stage 1
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            stage1_sum <= '0;
        else
            stage1_sum <= a + b;
    end

    // Stage 2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sum <= '0;
        else
            sum <= stage1_sum;
    end
endmodule

// 关键路径重定时
module retimed_pipeline (
    input  logic clk, rst_n,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);
    // 组合逻辑分割到多个寄存器
    logic [7:0] stage1, stage2, stage3;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1 <= '0;
            stage2 <= '0;
            stage3 <= '0;
        end else begin
            stage1 <= data_in + 1;
            stage2 <= stage1 * 2;
            stage3 <= stage2 + 1;
        end
    end

    assign data_out = stage3;
endmodule
```

### 2. 面积优化

```systemverilog
// 资源共享
module arithmetic_unit (
    input  logic       clk,
    input  logic       sel_add,  // 1=add, 0=sub
    input  logic [7:0] a, b,
    output logic [8:0] result
);
    logic [7:0] op_b;

    // 多路复用器选择操作数
    assign op_b = sel_add ? b : ~b;

    // 复用加法器
    always_ff @(posedge clk) begin
        result <= {1'b0, a} + {1'b0, op_b} + sel_add;
    end
endmodule

// 状态机编码优化
module state_machine_optimized (
    input  logic clk, rst_n, go, done,
    output logic out
);
    // 使用二进制编码减少状态寄存器
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        WORK  = 2'b01,
        DONE  = 2'b10
    } state_t;

    state_t state, next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next;
    end

    // ... 状态转换逻辑
endmodule
```

### 3. 功耗优化

```systemverilog
// 异步复位 vs 同步复位（功耗考虑）
module low_power_design (
    input  logic clk, rst_n, enable,
    input  logic [31:0] data,
    output logic [31:0] result
);

    // 使用使能信号减少无效切换
    always_ff @(posedge clk) begin
        if (enable)
            result <= data * 2;
    end

    // 门控时钟（已在前面的skill中展示）
endmodule

// 功耗门控
module power_gated_module (
    input  logic clk, rst_n, power_on,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);
    // 当模块不使用时关闭电源
    logic [7:0] internal_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            internal_reg <= '0;
        else if (power_on)
            internal_reg <= data_in;
        else
            internal_reg <= '0;  // 保持清零状态
    end

    assign data_out = power_on ? internal_reg : '0;
endmodule
```

### 4. 内存优化

```systemverilog
// 内存分享
module memory_share (
    input  logic clk, we, re,
    input  logic [7:0] waddr, raddr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata
);
    logic [31:0] mem [256];

    always_ff @(posedge clk) begin
        if (we)
            mem[waddr] <= wdata;
    end

    always_ff @(posedge clk) begin
        if (re)
            rdata <= mem[raddr];
    end
endmodule
```

## 优化检查清单

- [ ] 流水线化关键路径
- [ ] 资源共享减少面积
- [ ] 门控时钟降低动态功耗
- [ ] 异步FIFO跨时钟域
- [ ] 内存优化和分享

Remember: 优化需要在性能、面积、功耗之间权衡，始终以设计规范为导向。
