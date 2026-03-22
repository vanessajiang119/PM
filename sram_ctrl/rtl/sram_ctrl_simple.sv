// =============================================================================
// Project: sram_ctrl - SRAM Controller IP (Fixed for Simulation)
// Version: 1.0.4
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

    // FSM states
    typedef enum logic [1:0] {W_IDLE, W_GOT_AW, W_GOT_W, W_RESP} w_state_t;
    typedef enum logic [1:0] {R_IDLE, R_GOT_AR, R_SEND} r_state_t;
    w_state_t w_state, w_next;
    r_state_t r_state, r_next;

    // Registered addresses
    logic [31:0] aw_addr_reg, ar_addr_reg;
    logic [1023:0] w_data_reg;
    logic [127:0] w_strb_reg;
    logic [3:0] w_id_reg, r_id_reg;

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

    // AXI Write FSM - COMBINATIONAL ready
    always_comb begin
        // Default outputs
        s0_axiw_awready = 1'b0;
        s0_axiw_wready = 1'b0;
        s0_axiw_bvalid = 1'b0;
        s0_axiw_bid = 4'h0;
        s0_axiw_bresp = 2'b00;

        case (w_state)
            W_IDLE:   s0_axiw_awready = 1'b1;  // Always ready in IDLE
            W_GOT_W:  s0_axiw_wready = 1'b1;
            W_RESP:   begin
                s0_axiw_bvalid = 1'b1;
                s0_axiw_bid = w_id_reg;
                s0_axiw_bresp = 2'b00;
            end
            default: ;
        endcase
    end

    // AXI Write FSM - SEQUENTIAL state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state <= W_IDLE;
            aw_addr_reg <= 32'h0;
            w_data_reg <= 1024'h0;
            w_strb_reg <= 128'h0;
            w_id_reg <= 4'h0;
        end else begin
            case (w_state)
                W_IDLE: begin
                    if (s0_axiw_awvalid) begin
                        aw_addr_reg <= s0_axiw_awaddr;
                        w_id_reg <= s0_axiw_awid;
                        w_state <= W_GOT_AW;
                    end
                end

                W_GOT_AW: begin
                    if (s0_axiw_wvalid) begin
                        w_data_reg <= s0_axiw_wdata;
                        w_strb_reg <= s0_axiw_wstrb;
                        w_state <= W_GOT_W;
                    end
                end

                W_GOT_W: begin
                    // Just stay here one cycle then go to RESP
                    w_state <= W_RESP;
                end

                W_RESP: begin
                    if (s0_axiw_bready) begin
                        w_state <= W_IDLE;
                    end
                end
            endcase
        end
    end

    // AXI Read FSM - COMBINATIONAL ready
    always_comb begin
        s0_axir_arready = 1'b0;
        s0_axir_rvalid = 1'b0;
        s0_axir_rid = 4'h0;
        s0_axir_rdata = 1024'h0;
        s0_axir_rresp = 2'b00;
        s0_axir_rlast = 1'b0;

        case (r_state)
            R_IDLE:   s0_axir_arready = 1'b1;
            R_SEND:   begin
                s0_axir_rvalid = 1'b1;
                s0_axir_rid = r_id_reg;
                s0_axir_rdata = {{896{1'b0}}, sram_rdata};
                s0_axir_rresp = 2'b00;
                s0_axir_rlast = 1'b1;
            end
            default: ;
        endcase
    end

    // AXI Read FSM - SEQUENTIAL state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_state <= R_IDLE;
            ar_addr_reg <= 32'h0;
            r_id_reg <= 4'h0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    if (s0_axir_arvalid) begin
                        ar_addr_reg <= s0_axir_araddr;
                        r_id_reg <= s0_axir_arid;
                        r_state <= R_GOT_AR;
                    end
                end

                R_GOT_AR: begin
                    r_state <= R_SEND;
                end

                R_SEND: begin
                    if (s0_axir_rready) begin
                        r_state <= R_IDLE;
                    end
                end
            endcase
        end
    end

    // SRAM Interface
    logic sram_active;
    assign sram_active = (w_state == W_GOT_W) || (w_state == W_RESP) ||
                         (r_state == R_SEND);
    assign sram_addr   = sram_active ? (ar_addr_reg[15:0]) : 16'h0;
    assign sram_csn    = sram_active ? 1'b0 : 1'b1;
    assign sram_wen    = (w_state == W_GOT_W || w_state == W_RESP) ? 1'b0 : 1'b1;
    assign sram_oen    = (r_state == R_SEND) ? 1'b0 : 1'b1;
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
