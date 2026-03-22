// =============================================================================
// Project: sram_ctrl - SRAM Controller IP
// Module:  Clock Gating Control
// Version: 1.0.0
// =============================================================================

module sram_ctrl_cg (
    // =========================================================================
    // Clock and Reset
    // =========================================================================
    input  wire        clk,        // Source clock
    input  wire        rst_n,      // Source reset

    // =========================================================================
    // Control Signals
    // =========================================================================
    input  wire        gate_en,    // Clock gating enable
    input  wire        idle,       // All ports idle signal

    // =========================================================================
    // Output
    // =========================================================================
    output reg         cg_clk,     // Gated clock
    output reg         cg_status   // Clock gating status
);

    // =========================================================================
    // Configuration
    // =========================================================================
    localparam IDLE_THRESHOLD = 10;  // Cycles to wait before gating

    // =========================================================================
    // Internal Signals
    // =========================================================================
    reg [7:0] idle_counter;
    reg       gating_active;
    reg       next_cg_clk;

    // State machine
    localparam CG_IDLE      = 2'b00;
    localparam CG_COUNTING  = 2'b01;
    localparam CG_GATED     = 2'b10;
    localparam CG_WAKING    = 2'b11;

    reg [1:0] cg_state, cg_next;

    // =========================================================================
    // State Machine
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cg_state    <= CG_IDLE;
            idle_counter <= 8'h0;
            gating_active <= 1'b0;
        end else begin
            cg_state <= cg_next;
            case (cg_state)
                CG_IDLE: begin
                    if (gate_en && idle) begin
                        idle_counter <= 8'h0;
                    end
                end
                CG_COUNTING: begin
                    if (idle) begin
                        idle_counter <= idle_counter + 1;
                    end else begin
                        idle_counter <= 8'h0;
                    end
                end
                CG_GATED: begin
                    // Stay gated until activity
                end
                CG_WAKING: begin
                    idle_counter <= 8'h0;
                end
                default: ;
            endcase
        end
    end

    always @(*) begin
        cg_next = cg_state;
        case (cg_state)
            CG_IDLE: begin
                if (gate_en && idle) begin
                    cg_next = CG_COUNTING;
                end
            end
            CG_COUNTING: begin
                if (!idle) begin
                    cg_next = CG_IDLE;
                end else if (idle_counter >= IDLE_THRESHOLD) begin
                    cg_next = CG_GATED;
                end
            end
            CG_GATED: begin
                if (!idle) begin
                    cg_next = CG_WAKING;
                end
            end
            CG_WAKING: begin
                cg_next = CG_IDLE;
            end
            default: cg_next = CG_IDLE;
        endcase
    end

    // =========================================================================
    // Clock Gating Logic
    // =========================================================================
    always @(*) begin
        case (cg_state)
            CG_IDLE, CG_COUNTING, CG_WAKING: begin
                next_cg_clk = clk;
                gating_active = 1'b0;
            end
            CG_GATED: begin
                next_cg_clk = 1'b0;
                gating_active = 1'b1;
            end
            default: begin
                next_cg_clk = clk;
                gating_active = 1'b0;
            end
        endcase
    end

    // Register the gated clock output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cg_clk    <= 1'b0;
            cg_status <= 1'b0;
        end else begin
            cg_clk    <= next_cg_clk;
            cg_status <= gating_active;
        end
    end

endmodule
