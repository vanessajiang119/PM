// =============================================================================
// Project: sram_ctrl - SRAM Controller IP (Fixed for Simulation)
// Version: 1.0.5 - With debug
// =============================================================================

module sram_ctrl_simple (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       pclk,
    input  logic       prst_n,

    output logic [15:0] sram_addr,
    output logic       sram_csn,
    output logic       sram_wen,
    output logic [127:0] sram_wdata,
    input  logic [127:0] sram_rdata,
    output logic [15:0] sram_wmask,
    output logic       sram_oen,

    output logic [1:0] w_state_out,
    output logic [1:0] r_state_out,

    // APB
    input  logic [11:0] paddr,
    input  logic       psel,
    input  logic       penable,
    input  logic       pwrite,
    input  logic [63:0] pwdata,
    output logic       pready,
    output logic [63:0] prdata,
    output logic       pslverr,
    input  logic       pgate,

    // AXI0 Write
    input  logic [3:0]  s0_axiw_awid,
    input  logic [31:0] s0_axiw_awaddr,
    input  logic [7:0]  s0_axiw_awlen,
    input  logic [2:0]  s0_axiw_awsize,
    input  logic [1:0]  s0_axiw_awburst,
    input  logic        s0_axiw_awvalid,
    output logic        s0_axiw_awready,

    input  logic [3:0]  s0_axiw_wid,
    input  logic [1023:0] s0_axiw_wdata,
    input  logic [127:0] s0_axiw_wstrb,
    input  logic        s0_axiw_wlast,
    input  logic        s0_axiw_wvalid,
    output logic        s0_axiw_wready,

    output logic [3:0]  s0_axiw_bid,
    output logic [1:0]  s0_axiw_bresp,
    output logic        s0_axiw_bvalid,
    input  logic        s0_axiw_bready,

    // AXI0 Read
    input  logic [3:0]  s0_axir_arid,
    input  logic [31:0] s0_axir_araddr,
    input  logic [7:0]  s0_axir_arlen,
    input  logic [2:0]  s0_axir_arsize,
    input  logic [1:0]  s0_axir_arburst,
    input  logic        s0_axir_arvalid,
    output logic        s0_axir_arready,

    output logic [3:0]  s0_axir_rid,
    output logic [1023:0] s0_axir_rdata,
    output logic [1:0]  s0_axir_rresp,
    output logic        s0_axir_rlast,
    output logic        s0_axir_rvalid,
    input  logic        s0_axir_rready,

    // Tie-offs for other ports
    input  logic [3:0]  s1_axiw_awid, input  logic [31:0] s1_axiw_awaddr,
    input  logic [7:0]  s1_axiw_awlen, input  logic [2:0]  s1_axiw_awsize,
    input  logic [1:0]  s1_axiw_awburst, input  logic        s1_axiw_awvalid,
    output logic        s1_axiw_awready, input  logic [3:0]  s1_axiw_wid,
    input  logic [1023:0] s1_axiw_wdata, input  logic [127:0] s1_axiw_wstrb,
    input  logic        s1_axiw_wlast, input  logic        s1_axiw_wvalid,
    output logic        s1_axiw_wready, output logic [3:0]  s1_axiw_bid,
    output logic [1:0]  s1_axiw_bresp, output logic        s1_axiw_bvalid,
    input  logic        s1_axiw_bready, input  logic [3:0]  s1_axir_arid,
    input  logic [31:0] s1_axir_araddr, input  logic [7:0]  s1_axir_arlen,
    input  logic [2:0]  s1_axir_arsize, input  logic [1:0]  s1_axir_arburst,
    input  logic        s1_axir_arvalid, output logic        s1_axir_arready,
    output logic [3:0]  s1_axir_rid, output logic [1023:0] s1_axir_rdata,
    output logic [1:0]  s1_axir_rresp, output logic        s1_axir_rlast,
    output logic        s1_axir_rvalid, input  logic        s1_axir_rready,

    input  logic [3:0]  s2_axiw_awid, input  logic [31:0] s2_axiw_awaddr,
    input  logic [7:0]  s2_axiw_awlen, input  logic [2:0]  s2_axiw_awsize,
    input  logic [1:0]  s2_axiw_awburst, input  logic        s2_axiw_awvalid,
    output logic        s2_axiw_awready, input  logic [3:0]  s2_axiw_wid,
    input  logic [1023:0] s2_axiw_wdata, input  logic [127:0] s2_axiw_wstrb,
    input  logic        s2_axiw_wlast, input  logic        s2_axiw_wvalid,
    output logic        s2_axiw_wready, output logic [3:0]  s2_axiw_bid,
    output logic [1:0]  s2_axiw_bresp, output logic        s2_axiw_bvalid,
    input  logic        s2_axiw_bready, input  logic [3:0]  s2_axir_arid,
    input  logic [31:0] s2_axir_araddr, input  logic [7:0]  s2_axir_arlen,
    input  logic [2:0]  s2_axir_arsize, input  logic [1:0]  s2_axir_arburst,
    input  logic        s2_axir_arvalid, output logic        s2_axir_arready,
    output logic [3:0]  s2_axir_rid, output logic [1023:0] s2_axir_rdata,
    output logic [1:0]  s2_axir_rresp, output logic        s2_axir_rlast,
    output logic        s2_axir_rvalid, input  logic        s2_axir_rready,

    input  logic [3:0]  s3_axiw_awid, input  logic [31:0] s3_axiw_awaddr,
    input  logic [7:0]  s3_axiw_awlen, input  logic [2:0]  s3_axiw_awsize,
    input  logic [1:0]  s3_axiw_awburst, input  logic        s3_axiw_awvalid,
    output logic        s3_axiw_awready, input  logic [3:0]  s3_axiw_wid,
    input  logic [1023:0] s3_axiw_wdata, input  logic [127:0] s3_axiw_wstrb,
    input  logic        s3_axiw_wlast, input  logic        s3_axiw_wvalid,
    output logic        s3_axiw_wready, output logic [3:0]  s3_axiw_bid,
    output logic [1:0]  s3_axiw_bresp, output logic        s3_axiw_bvalid,
    input  logic        s3_axiw_bready, input  logic [3:0]  s3_axir_arid,
    input  logic [31:0] s3_axir_araddr, input  logic [7:0]  s3_axir_arlen,
    input  logic [2:0]  s3_axir_arsize, input  logic [1:0]  s3_axir_arburst,
    input  logic        s3_axir_arvalid, output logic        s3_axir_arready,
    output logic [3:0]  s3_axir_rid, output logic [1023:0] s3_axir_rdata,
    output logic [1:0]  s3_axir_rresp, output logic        s3_axir_rlast,
    output logic        s3_axir_rvalid, input  logic        s3_axir_rready,

    input  logic        cgate_en,
    output logic        cgate_status,
    output logic        irq_ecc_single,
    output logic        irq_ecc_double
);

    // Internal registers
    logic [31:0] ctrl_reg, ecc_ctrl_reg, cg_ctrl_reg;
    logic [1:0] apb_state;

    // FSM states - encoding for debug output
    typedef enum logic [1:0] {W0=2'b00, W1=2'b01, W2=2'b10, W3=2'b11} w_state_t;
    typedef enum logic [1:0] {R0=2'b00, R1=2'b01, R2=2'b10} r_state_t;
    w_state_t w_state, w_next;
    r_state_t r_state, r_next;

    logic [31:0] aw_addr_reg, ar_addr_reg;
    logic [1023:0] w_data_reg;
    logic [127:0] w_strb_reg;
    logic [3:0] w_id_reg, r_id_reg;

    // Output state for debug
    assign w_state_out = w_state;
    assign r_state_out = r_state;

    // APB FSM
    always_ff @(posedge pclk or negedge prst_n) begin
        if (!prst_n) begin
            apb_state <= 2'b00;
            ctrl_reg <= 32'h0;
            ecc_ctrl_reg <= 32'h1;
            cg_ctrl_reg <= 32'h0;
        end else begin
            case (apb_state)
                2'b00: if (psel) apb_state <= 2'b01;
                2'b01: if (psel && penable) apb_state <= 2'b10;
                2'b10: if (!psel) apb_state <= 2'b00;
            endcase

            if (psel && pwrite && (apb_state == 2'b01) && penable) begin
                if (paddr[9:2] == 8'h00) ctrl_reg <= pwdata[31:0];
                if (paddr[9:2] == 8'h04) ecc_ctrl_reg <= pwdata[31:0];
                if (paddr[9:2] == 8'h08) cg_ctrl_reg <= pwdata[31:0];
            end
        end
    end

    assign pready = (apb_state == 2'b10);
    assign pslverr = 1'b0;

    always_comb begin
        case (paddr[9:2])
            8'h00: prdata = {32'h0, ctrl_reg};
            8'h04: prdata = {32'h0, ecc_ctrl_reg};
            8'h08: prdata = {32'h0, cg_ctrl_reg};
            default: prdata = 64'h0;
        endcase
    end

    // AXI Write FSM - Sequential only
    // FIX: Keep awready high until we actually capture the address
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state <= W0;
            aw_addr_reg <= 32'h0;
            w_data_reg <= 1024'h0;
            w_strb_reg <= 128'h0;
            w_id_reg <= 4'h0;
            s0_axiw_awready <= 1'b0;
            s0_axiw_wready <= 1'b0;
            s0_axiw_bvalid <= 1'b0;
            s0_axiw_bid <= 4'h0;
            s0_axiw_bresp <= 2'b00;
        end else begin
            case (w_state)
                W0: begin  // IDLE - wait for AW
                    s0_axiw_awready <= 1'b1;  // Always ready in IDLE
                    s0_axiw_wready <= 1'b0;
                    s0_axiw_bvalid <= 1'b0;
                    if (s0_axiw_awvalid) begin
                        // Capture address but keep ready high for THIS cycle
                        aw_addr_reg <= s0_axiw_awaddr;
                        w_id_reg <= s0_axiw_awid;
                        // DON'T change ready yet - keep it high until next cycle
                        // Just transition state
                        w_state <= W1;
                    end
                end

                W1: begin  // Got AW, wait for W
                    s0_axiw_awready <= 1'b0;  // Now deassert
                    s0_axiw_wready <= 1'b1;
                    if (s0_axiw_wvalid) begin
                        w_data_reg <= s0_axiw_wdata;
                        w_strb_reg <= s0_axiw_wstrb;
                        s0_axiw_wready <= 1'b0;
                        w_state <= W2;
                    end
                end

                W2: begin  // Got W, send response
                    s0_axiw_awready <= 1'b0;
                    s0_axiw_wready <= 1'b0;
                    s0_axiw_bid <= w_id_reg;
                    s0_axiw_bresp <= 2'b00;
                    s0_axiw_bvalid <= 1'b1;
                    w_state <= W3;
                end

                W3: begin  // Wait for BREADY
                    if (s0_axiw_bready) begin
                        s0_axiw_bvalid <= 1'b0;
                        w_state <= W0;
                    end
                end
            endcase
        end
    end

    // AXI Read FSM - Sequential only
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_state <= R0;
            ar_addr_reg <= 32'h0;
            r_id_reg <= 4'h0;
            s0_axir_arready <= 1'b0;
            s0_axir_rvalid <= 1'b0;
            s0_axir_rid <= 4'h0;
            s0_axir_rdata <= 1024'h0;
            s0_axir_rresp <= 2'b00;
            s0_axir_rlast <= 1'b0;
        end else begin
            case (r_state)
                R0: begin  // IDLE - wait for AR
                    s0_axir_arready <= 1'b1;
                    s0_axir_rvalid <= 1'b0;
                    if (s0_axir_arvalid) begin
                        ar_addr_reg <= s0_axir_araddr;
                        r_id_reg <= s0_axir_arid;
                        s0_axir_arready <= 1'b0;
                        r_state <= R1;
                    end
                end

                R1: begin  // Got AR, send data
                    s0_axir_arready <= 1'b0;
                    s0_axir_rid <= r_id_reg;
                    s0_axir_rdata <= {{896{1'b0}}, sram_rdata};
                    s0_axir_rresp <= 2'b00;
                    s0_axir_rlast <= 1'b1;
                    s0_axir_rvalid <= 1'b1;
                    r_state <= R2;
                end

                R2: begin  // Wait for RREADY
                    if (s0_axir_rready) begin
                        s0_axir_rvalid <= 1'b0;
                        r_state <= R0;
                    end
                end
            endcase
        end
    end

    // SRAM Interface
    logic sram_active;
    assign sram_active = (w_state == W1) || (w_state == W2) ||
                         (r_state == R1) || (r_state == R2);
    assign sram_addr   = sram_active ? (ar_addr_reg[15:0]) : 16'h0;
    assign sram_csn    = sram_active ? 1'b0 : 1'b1;
    assign sram_wen    = (w_state == W1 || w_state == W2) ? 1'b0 : 1'b1;
    assign sram_oen    = (r_state == R1 || r_state == R2) ? 1'b0 : 1'b1;
    assign sram_wdata  = w_data_reg[127:0];
    assign sram_wmask  = 16'hFFFF;

    // Tie off other ports
    assign s1_axiw_awready = 0; assign s1_axiw_wready = 0;
    assign s1_axiw_bvalid = 0; assign s1_axir_arready = 0;
    assign s1_axir_rvalid = 0; assign s1_axir_rdata = 0;
    assign s2_axiw_awready = 0; assign s2_axiw_wready = 0;
    assign s2_axiw_bvalid = 0; assign s2_axir_arready = 0;
    assign s2_axir_rvalid = 0; assign s2_axir_rdata = 0;
    assign s3_axiw_awready = 0; assign s3_axiw_wready = 0;
    assign s3_axiw_bvalid = 0; assign s3_axir_arready = 0;
    assign s3_axir_rvalid = 0; assign s3_axir_rdata = 0;

    assign cgate_status = 0;
    assign irq_ecc_single = 0;
    assign irq_ecc_double = 0;

endmodule
