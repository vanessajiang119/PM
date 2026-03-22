// =============================================================================
// Project: sram_ctrl - SRAM Controller IP (Simplified for Simulation)
// Version: 1.0.2
// =============================================================================

module sram_ctrl_simple (
    // Clock and Reset
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pclk,
    input  wire        prst_n,

    // SRAM Interface
    output wire [15:0] sram_addr,
    output wire        sram_csn,
    output wire        sram_wen,
    output wire [127:0] sram_wdata,
    input  wire [127:0] sram_rdata,
    output wire [15:0] sram_wmask,
    output wire        sram_oen,

    // APB Interface
    input  wire [11:0] paddr,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [63:0] pwdata,
    output wire        pready,
    output wire [63:0] prdata,
    output wire        pslverr,
    input  wire        pgate,

    // AXI4 Slave Port 0 - Write Address
    input  wire [3:0]  s0_axiw_awid,
    input  wire [31:0] s0_axiw_awaddr,
    input  wire [7:0]  s0_axiw_awlen,
    input  wire [2:0]  s0_axiw_awsize,
    input  wire [1:0]  s0_axiw_awburst,
    input  wire        s0_axiw_awvalid,
    output wire        s0_axiw_awready,

    // AXI4 Slave Port 0 - Write Data
    input  wire [3:0]  s0_axiw_wid,
    input  wire [1023:0] s0_axiw_wdata,
    input  wire [127:0] s0_axiw_wstrb,
    input  wire        s0_axiw_wlast,
    input  wire        s0_axiw_wvalid,
    output wire        s0_axiw_wready,

    // AXI4 Slave Port 0 - Write Response
    output wire [3:0]  s0_axiw_bid,
    output wire [1:0]  s0_axiw_bresp,
    output wire        s0_axiw_bvalid,
    input  wire        s0_axiw_bready,

    // AXI4 Slave Port 0 - Read Address
    input  wire [3:0]  s0_axir_arid,
    input  wire [31:0] s0_axir_araddr,
    input  wire [7:0]  s0_axir_arlen,
    input  wire [2:0]  s0_axir_arsize,
    input  wire [1:0]  s0_axir_arburst,
    input  wire        s0_axir_arvalid,
    output wire        s0_axir_arready,

    // AXI4 Slave Port 0 - Read Data
    output wire [3:0]  s0_axir_rid,
    output wire [1023:0] s0_axir_rdata,
    output wire [1:0]  s0_axir_rresp,
    output wire        s0_axir_rlast,
    output wire        s0_axir_rvalid,
    input  wire        s0_axir_rready,

    // Other AXI ports (tied off)
    input  wire [3:0]  s1_axiw_awid, input  wire [31:0] s1_axiw_awaddr,
    input  wire [7:0]  s1_axiw_awlen, input  wire [2:0]  s1_axiw_awsize,
    input  wire [1:0]  s1_axiw_awburst, input  wire        s1_axiw_awvalid,
    output wire        s1_axiw_awready, input  wire [3:0]  s1_axiw_wid,
    input  wire [1023:0] s1_axiw_wdata, input  wire [127:0] s1_axiw_wstrb,
    input  wire        s1_axiw_wlast, input  wire        s1_axiw_wvalid,
    output wire        s1_axiw_wready, output wire [3:0]  s1_axiw_bid,
    output wire [1:0]  s1_axiw_bresp, output wire        s1_axiw_bvalid,
    input  wire        s1_axiw_bready, input  wire [3:0]  s1_axir_arid,
    input  wire [31:0] s1_axir_araddr, input  wire [7:0]  s1_axir_arlen,
    input  wire [2:0]  s1_axir_arsize, input  wire [1:0]  s1_axir_arburst,
    input  wire        s1_axir_arvalid, output wire        s1_axir_arready,
    output wire [3:0]  s1_axir_rid, output wire [1023:0] s1_axir_rdata,
    output wire [1:0]  s1_axir_rresp, output wire        s1_axir_rlast,
    output wire        s1_axir_rvalid, input  wire        s1_axir_rready,

    input  wire [3:0]  s2_axiw_awid, input  wire [31:0] s2_axiw_awaddr,
    input  wire [7:0]  s2_axiw_awlen, input  wire [2:0]  s2_axiw_awsize,
    input  wire [1:0]  s2_axiw_awburst, input  wire        s2_axiw_awvalid,
    output wire        s2_axiw_awready, input  wire [3:0]  s2_axiw_wid,
    input  wire [1023:0] s2_axiw_wdata, input  wire [127:0] s2_axiw_wstrb,
    input  wire        s2_axiw_wlast, input  wire        s2_axiw_wvalid,
    output wire        s2_axiw_wready, output wire [3:0]  s2_axiw_bid,
    output wire [1:0]  s2_axiw_bresp, output wire        s2_axiw_bvalid,
    input  wire        s2_axiw_bready, input  wire [3:0]  s2_axir_arid,
    input  wire [31:0] s2_axir_araddr, input  wire [7:0]  s2_axir_arlen,
    input  wire [2:0]  s2_axir_arsize, input  wire [1:0]  s2_axir_arburst,
    input  wire        s2_axir_arvalid, output wire        s2_axir_arready,
    output wire [3:0]  s2_axir_rid, output wire [1023:0] s2_axir_rdata,
    output wire [1:0]  s2_axir_rresp, output wire        s2_axir_rlast,
    output wire        s2_axir_rvalid, input  wire        s2_axir_rready,

    input  wire [3:0]  s3_axiw_awid, input  wire [31:0] s3_axiw_awaddr,
    input  wire [7:0]  s3_axiw_awlen, input  wire [2:0]  s3_axiw_awsize,
    input  wire [1:0]  s3_axiw_awburst, input  wire        s3_axiw_awvalid,
    output wire        s3_axiw_awready, input  wire [3:0]  s3_axiw_wid,
    input  wire [1023:0] s3_axiw_wdata, input  wire [127:0] s3_axiw_wstrb,
    input  wire        s3_axiw_wlast, input  wire        s3_axiw_wvalid,
    output wire        s3_axiw_wready, output wire [3:0]  s3_axiw_bid,
    output wire [1:0]  s3_axiw_bresp, output wire        s3_axiw_bvalid,
    input  wire        s3_axiw_bready, input  wire [3:0]  s3_axir_arid,
    input  wire [31:0] s3_axir_araddr, input  wire [7:0]  s3_axir_arlen,
    input  wire [2:0]  s3_axir_arsize, input  wire [1:0]  s3_axir_arburst,
    input  wire        s3_axir_arvalid, output wire        s3_axir_arready,
    output wire [3:0]  s3_axir_rid, output wire [1023:0] s3_axir_rdata,
    output wire [1:0]  s3_axir_rresp, output wire        s3_axir_rlast,
    output wire        s3_axir_rvalid, input  wire        s3_axir_rready,

    input  wire        cgate_en,
    output wire        cgate_status,
    output wire        irq_ecc_single,
    output wire        irq_ecc_double
);

    // Internal signals
    reg [31:0] ctrl_reg;
    reg [31:0] ecc_ctrl_reg;
    reg [31:0] cg_ctrl_reg;

    // APB FSM
    reg [1:0] apb_state;
    localparam APB_IDLE  = 2'b00;
    localparam APB_SETUP = 2'b01;
    localparam APB_ACCESS = 2'b10;

    always @(posedge pclk or negedge prst_n) begin
        if (!prst_n) begin
            apb_state <= APB_IDLE;
            ctrl_reg  <= 32'h0;
            ecc_ctrl_reg <= 32'h1;
            cg_ctrl_reg  <= 32'h0;
        end else begin
            case (apb_state)
                APB_IDLE:   if (psel) apb_state <= APB_SETUP;
                APB_SETUP:  if (psel && penable) apb_state <= APB_ACCESS;
                APB_ACCESS: if (!psel) apb_state <= APB_IDLE;
                default:    apb_state <= APB_IDLE;
            endcase

            if (psel && pwrite && (apb_state == APB_SETUP) && penable) begin
                if (paddr[9:2] == 8'h00) ctrl_reg <= pwdata[31:0];
                if (paddr[9:2] == 8'h04) ecc_ctrl_reg <= pwdata[31:0];
                if (paddr[9:2] == 8'h08) cg_ctrl_reg <= pwdata[31:0];
            end
        end
    end

    assign pready = (apb_state == APB_ACCESS);
    assign pslverr = 1'b0;

    // APB read mux
    reg [63:0] prdata_mux;
    always @(*) begin
        case (paddr[9:2])
            8'h00: prdata_mux = {32'h0, ctrl_reg};
            8'h01: prdata_mux = 64'h0;
            8'h04: prdata_mux = {32'h0, ecc_ctrl_reg};
            8'h08: prdata_mux = {32'h0, cg_ctrl_reg};
            default: prdata_mux = 64'h0;
        endcase
    end
    assign prdata = prdata_mux;

    // AXI4 Write State Machine (Simplified)
    reg [1:0] w_state;
    localparam W_IDLE = 2'b00;
    localparam W_ADDR = 2'b01;
    localparam W_DATA = 2'b10;
    localparam W_RESP = 2'b11;

    reg [31:0] aw_addr_reg;
    reg [7:0] aw_len_reg;
    reg [1023:0] w_data_reg;
    reg [127:0] w_strb_reg;
    reg [3:0] w_id_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state <= W_IDLE;
            s0_axiw_awready <= 1'b0;
            s0_axiw_wready <= 1'b0;
            s0_axiw_bvalid <= 1'b0;
            s0_axiw_bid <= 4'h0;
            s0_axiw_bresp <= 2'b00;
        end else begin
            case (w_state)
                W_IDLE: begin
                    if (s0_axiw_awvalid) begin
                        aw_addr_reg <= s0_axiw_awaddr;
                        aw_len_reg  <= s0_axiw_awlen;
                        w_id_reg    <= s0_axiw_awid;
                        s0_axiw_awready <= 1'b1;
                        w_state <= W_ADDR;
                    end else begin
                        s0_axiw_awready <= 1'b0;
                    end
                end

                W_ADDR: begin
                    s0_axiw_awready <= 1'b0;
                    if (s0_axiw_wvalid) begin
                        w_data_reg <= s0_axiw_wdata;
                        w_strb_reg <= s0_axiw_wstrb;
                        s0_axiw_wready <= 1'b1;
                        w_state <= W_DATA;
                    end
                end

                W_DATA: begin
                    s0_axiw_wready <= 1'b0;
                    // SRAM write
                    s0_axiw_bid    <= w_id_reg;
                    s0_axiw_bresp  <= 2'b00; // OKAY
                    s0_axiw_bvalid <= 1'b1;
                    w_state <= W_RESP;
                end

                W_RESP: begin
                    if (s0_axiw_bready) begin
                        s0_axiw_bvalid <= 1'b0;
                        w_state <= W_IDLE;
                    end
                end
            endcase
        end
    end

    // AXI4 Read State Machine (Simplified)
    reg [1:0] r_state;
    localparam R_IDLE = 2'b00;
    localparam R_ADDR = 2'b01;
    localparam R_DATA = 2'b10;

    reg [31:0] ar_addr_reg;
    reg [7:0] ar_len_reg;
    reg [3:0] r_id_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_state <= R_IDLE;
            s0_axir_arready <= 1'b0;
            s0_axir_rvalid <= 1'b0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    if (s0_axir_arvalid) begin
                        ar_addr_reg <= s0_axir_araddr;
                        ar_len_reg  <= s0_axir_arlen;
                        r_id_reg    <= s0_axir_arid;
                        s0_axir_arready <= 1'b1;
                        r_state <= R_ADDR;
                    end else begin
                        s0_axir_arready <= 1'b0;
                    end
                end

                R_ADDR: begin
                    s0_axir_arready <= 1'b0;
                    s0_axir_rid    <= r_id_reg;
                    s0_axir_rdata  <= {{896{1'b0}}, sram_rdata};
                    s0_axir_rresp  <= 2'b00;
                    s0_axir_rlast  <= 1'b1;
                    s0_axir_rvalid <= 1'b1;
                    r_state <= R_DATA;
                end

                R_DATA: begin
                    if (s0_axir_rready) begin
                        s0_axir_rvalid <= 1'b0;
                        r_state <= R_IDLE;
                    end
                end
            endcase
        end
    end

    // SRAM Interface (simplified - direct mapping)
    assign sram_addr  = (w_state == W_DATA) ? aw_addr_reg[15:0] :
                       (r_state == R_DATA) ? ar_addr_reg[15:0] : 16'h0;
    assign sram_csn   = ((w_state != W_DATA) && (r_state != R_DATA));
    assign sram_wen   = (w_state == W_DATA) ? 1'b0 : 1'b1;
    assign sram_oen   = (r_state == R_DATA) ? 1'b0 : 1'b1;

    // Extract 128-bit from 1024-bit based on address offset
    wire [2:0] addr_offset = aw_addr_reg[5:3];  // 128-bit beat select

    always @(*) begin
        case (addr_offset)
            3'd0: sram_wdata = w_data_reg[127:0];
            3'd1: sram_wdata = w_data_reg[255:128];
            3'd2: sram_wdata = w_data_reg[383:256];
            3'd3: sram_wdata = w_data_reg[511:384];
            3'd4: sram_wdata = w_data_reg[639:512];
            3'd5: sram_wdata = w_data_reg[767:640];
            3'd6: sram_wdata = w_data_reg[895:768];
            3'd7: sram_wdata = w_data_reg[1023:896];
            default: sram_wdata = w_data_reg[127:0];
        endcase
    end

    always @(*) begin
        case (addr_offset)
            3'd0: sram_wmask = {16{w_strb_reg[15:0]}};
            3'd1: sram_wmask = {16{w_strb_reg[31:16]}};
            3'd2: sram_wmask = {16{w_strb_reg[47:32]}};
            3'd3: sram_wmask = {16{w_strb_reg[63:48]}};
            3'd4: sram_wmask = {16{w_strb_reg[79:64]}};
            3'd5: sram_wmask = {16{w_strb_reg[95:80]}};
            3'd6: sram_wmask = {16{w_strb_reg[111:96]}};
            3'd7: sram_wmask = {16{w_strb_reg[127:112]}};
            default: sram_wmask = 16'hFFFF;
        endcase
    end

    // Other AXI ports - tie off
    assign s1_axiw_awready = 1'b0;
    assign s1_axiw_wready = 1'b0;
    assign s1_axiw_bid = 4'h0;
    assign s1_axiw_bresp = 2'b00;
    assign s1_axiw_bvalid = 1'b0;
    assign s1_axir_arready = 1'b0;
    assign s1_axir_rid = 4'h0;
    assign s1_axir_rdata = 1024'h0;
    assign s1_axir_rresp = 2'b00;
    assign s1_axir_rlast = 1'b0;
    assign s1_axir_rvalid = 1'b0;

    assign s2_axiw_awready = 1'b0;
    assign s2_axiw_wready = 1'b0;
    assign s2_axiw_bid = 4'h0;
    assign s2_axiw_bresp = 2'b00;
    assign s2_axiw_bvalid = 1'b0;
    assign s2_axir_arready = 1'b0;
    assign s2_axir_rid = 4'h0;
    assign s2_axir_rdata = 1024'h0;
    assign s2_axir_rresp = 2'b00;
    assign s2_axir_rlast = 1'b0;
    assign s2_axir_rvalid = 1'b0;

    assign s3_axiw_awready = 1'b0;
    assign s3_axiw_wready = 1'b0;
    assign s3_axiw_bid = 4'h0;
    assign s3_axiw_bresp = 2'b00;
    assign s3_axiw_bvalid = 1'b0;
    assign s3_axir_arready = 1'b0;
    assign s3_axir_rid = 4'h0;
    assign s3_axir_rdata = 1024'h0;
    assign s3_axir_rresp = 2'b00;
    assign s3_axir_rlast = 1'b0;
    assign s3_axir_rvalid = 1'b0;

    assign cgate_status = 1'b0;
    assign irq_ecc_single = 1'b0;
    assign irq_ecc_double = 1'b0;

endmodule
