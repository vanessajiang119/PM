// =============================================================================
// Project: sram_ctrl - SRAM Controller IP
// Module:  APB Interface Module
// Version: 1.0.0
// =============================================================================

module sram_ctrl_apb (
    // =========================================================================
    // Clock and Reset
    // =========================================================================
    input  wire        pclk,
    input  wire        prst_n,
    input  wire        pgate,

    // =========================================================================
    // APB Interface
    // =========================================================================
    input  wire [11:0] paddr,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [63:0] pwdata,
    output wire        pready,
    output wire [63:0] prdata,
    output wire        pslverr,

    // =========================================================================
    // Control/Status Outputs
    // =========================================================================
    output reg         ecc_enable,
    output reg         ecc_bypass,
    output reg         irq_ecc_single,
    output reg         irq_ecc_double,
    output reg         cgate_en
);

    // =========================================================================
    // Internal Registers
    // =========================================================================
    reg  [31:0] ctrl_reg;
    reg  [31:0] stat_reg;
    reg  [31:0] int_en_reg;
    reg  [31:0] int_stat_reg;
    reg  [31:0] ecc_ctrl_reg;
    reg  [31:0] ecc_err_cnt;
    reg  [31:0] ecc_err_addr;
    reg  [31:0] ecc_err_info;
    reg  [31:0] cg_ctrl_reg;

    // FSM states
    localparam IDLE  = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;

    reg [1:0] state, next_state;

    // =========================================================================
    // APB FSM
    // =========================================================================
    always @(posedge pclk or negedge prst_n) begin
        if (!prst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:   if (psel) next_state = SETUP;
            SETUP:  if (psel && penable) next_state = ACCESS;
            ACCESS: if (!psel) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // =========================================================================
    // Register Read/Write
    // =========================================================================
    always @(posedge pclk or negedge prst_n) begin
        if (!prst_n) begin
            ctrl_reg     <= 32'h0;
            int_en_reg   <= 32'h0;
            int_stat_reg <= 32'h0;
            ecc_ctrl_reg <= 32'h0;
            cg_ctrl_reg  <= 32'h10; // Default idle count = 10
            ecc_err_cnt  <= 32'h0;
            ecc_err_addr <= 32'hFFFFFFFF;
            ecc_err_info <= 32'h0;
        end else if (psel && pwrite && (state == SETUP) && penable) begin
            case (paddr[9:2])
                8'h00: ctrl_reg     <= pwdata[31:0];
                8'h02: int_en_reg   <= pwdata[31:0];
                8'h03: int_stat_reg <= pwdata[31:0]; // Write 1 to clear
                8'h04: ecc_ctrl_reg <= pwdata[31:0];
                8'h08: cg_ctrl_reg  <= pwdata[31:0];
                default: ;
            endcase
        end else begin
            // Clear interrupt status on write 1
            if (psel && pwrite && (state == SETUP) && penable && (paddr[9:2] == 8'h03)) begin
                int_stat_reg <= int_stat_reg & ~pwdata[31:0];
            end

            // ECC error counter and address are read-only but can be cleared
            if (psel && pwrite && (state == SETUP) && penable && (paddr[9:2] == 8'h00) && pwdata[0]) begin
                ecc_err_cnt  <= 32'h0;
                ecc_err_addr <= 32'hFFFFFFFF;
                ecc_err_info <= 32'h0;
            end
        end
    end

    // =========================================================================
    // Register Outputs
    // =========================================================================
    always @(posedge pclk or negedge prst_n) begin
        if (!prst_n) begin
            ecc_enable      <= 1'b1;
            ecc_bypass      <= 1'b0;
            irq_ecc_single  <= 1'b0;
            irq_ecc_double  <= 1'b0;
            cgate_en        <= 1'b1;
        end else begin
            ecc_enable <= ecc_ctrl_reg[0];
            ecc_bypass <= ecc_ctrl_reg[1];
            cgate_en   <= cg_ctrl_reg[0];
        end
    end

    // =========================================================================
    // Read Data Multiplexer
    // =========================================================================
    reg [63:0] prdata_mux;

    always @(*) begin
        case (paddr[9:2])
            8'h00: prdata_mux = {32'h0, ctrl_reg};
            8'h01: prdata_mux = {32'h0, stat_reg};
            8'h02: prdata_mux = {32'h0, int_en_reg};
            8'h03: prdata_mux = {32'h0, int_stat_reg};
            8'h04: prdata_mux = {32'h0, ecc_ctrl_reg};
            8'h05: prdata_mux = {32'h0, ecc_err_cnt};
            8'h06: prdata_mux = {32'h0, ecc_err_addr};
            8'h07: prdata_mux = {32'h0, ecc_err_info};
            8'h08: prdata_mux = {32'h0, cg_ctrl_reg};
            default: prdata_mux = 64'h0;
        endcase
    end

    assign prdata = prdata_mux;

    // =========================================================================
    // Status Register
    // =========================================================================
    assign stat_reg = {
        27'h0,           // Reserved
        cgate_en,        // Clock gating enabled
        ecc_bypass,      // ECC bypass mode
        ecc_enable,      // ECC enabled
        1'b0,
        irq_ecc_double,  // Double-bit error interrupt
        irq_ecc_single   // Single-bit error interrupt
    };

    // =========================================================================
    // APB Response
    // =========================================================================
    assign pready   = (state == ACCESS);
    assign pslverr  = 1'b0;

    // =========================================================================
    // Interrupt Generation (from external ECC signals - can be connected)
    // =========================================================================
    // Note: These would be connected to ECC module errors
    // wire ext_ecc_single;
    // wire ext_ecc_double;
    // always @(posedge pclk or negedge prst_n) begin
    //     if (!prst_n) begin
    //         irq_ecc_single <= 1'b0;
    //         irq_ecc_double <= 1'b0;
    //     end else begin
    //         if (ext_ecc_single && int_en_reg[0])
    //             irq_ecc_single <= 1'b1;
    //         if (ext_ecc_double && int_en_reg[1])
    //             irq_ecc_double <= 1'b1;
    //     end
    // end

endmodule
