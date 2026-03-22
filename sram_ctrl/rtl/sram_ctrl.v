// =============================================================================
// Project: sram_ctrl - SRAM Controller IP
// Description: High-performance SRAM controller for AI accelerator
// Version: 1.0.0
// Date: 2026-03-22
// =============================================================================

module sram_ctrl (
    // =========================================================================
    // Clock and Reset
    // =========================================================================
    input  wire        clk,            // Main system clock
    input  wire        rst_n,          // Main reset (active low)
    input  wire        pclk,           // APB clock
    input  wire        prst_n,         // APB reset (active low)

    // =========================================================================
    // SRAM Interface
    // =========================================================================
    output wire [15:0] sram_addr,      // SRAM address
    output wire        sram_csn,       // SRAM chip select (active low)
    output wire        sram_wen,       // SRAM write enable (active low)
    output wire [127:0] sram_wdata,    // SRAM write data
    input  wire [127:0] sram_rdata,    // SRAM read data
    output wire [15:0] sram_wmask,     // SRAM write mask
    output wire        sram_oen,       // SRAM output enable (active low)

    // =========================================================================
    // APB Slave Interface (Control Port)
    // =========================================================================
    input  wire [11:0] paddr,          // APB address
    input  wire        psel,           // APB select
    input  wire        penable,        // APB enable
    input  wire        pwrite,         // APB write enable
    input  wire [63:0] pwdata,         // APB write data
    output wire        pready,         // APB ready
    output wire [63:0] prdata,         // APB read data
    output wire        pslverr,        // APB error response
    input  wire        pgate,          // APB clock gate control

    // =========================================================================
    // AXI4 Slave Interface Port 0
    // =========================================================================
    // Write Address
    input  wire [3:0]  s0_axiw_awid,
    input  wire [31:0] s0_axiw_awaddr,
    input  wire [7:0]  s0_axiw_awlen,
    input  wire [2:0]  s0_axiw_awsize,
    input  wire [1:0]  s0_axiw_awburst,
    input  wire        s0_axiw_awvalid,
    output wire        s0_axiw_awready,
    // Write Data
    input  wire [3:0]  s0_axiw_wid,
    input  wire [1023:0] s0_axiw_wdata,
    input  wire [127:0] s0_axiw_wstrb,
    input  wire        s0_axiw_wlast,
    input  wire        s0_axiw_wvalid,
    output wire        s0_axiw_wready,
    // Write Response
    output wire [3:0]  s0_axiw_bid,
    output wire [1:0]  s0_axiw_bresp,
    output wire        s0_axiw_bvalid,
    input  wire        s0_axiw_bready,
    // Read Address
    input  wire [3:0]  s0_axir_arid,
    input  wire [31:0] s0_axir_araddr,
    input  wire [7:0]  s0_axir_arlen,
    input  wire [2:0]  s0_axir_arsize,
    input  wire [1:0]  s0_axir_arburst,
    input  wire        s0_axir_arvalid,
    output wire        s0_axir_arready,
    // Read Data
    output wire [3:0]  s0_axir_rid,
    output wire [1023:0] s0_axir_rdata,
    output wire [1:0]  s0_axir_rresp,
    output wire        s0_axir_rlast,
    output wire        s0_axir_rvalid,
    input  wire        s0_axir_rready,

    // =========================================================================
    // AXI4 Slave Interface Port 1
    // =========================================================================
    input  wire [3:0]  s1_axiw_awid,
    input  wire [31:0] s1_axiw_awaddr,
    input  wire [7:0]  s1_axiw_awlen,
    input  wire [2:0]  s1_axiw_awsize,
    input  wire [1:0]  s1_axiw_awburst,
    input  wire        s1_axiw_awvalid,
    output wire        s1_axiw_awready,
    input  wire [3:0]  s1_axiw_wid,
    input  wire [1023:0] s1_axiw_wdata,
    input  wire [127:0] s1_axiw_wstrb,
    input  wire        s1_axiw_wlast,
    input  wire        s1_axiw_wvalid,
    output wire        s1_axiw_wready,
    output wire [3:0]  s1_axiw_bid,
    output wire [1:0]  s1_axiw_bresp,
    output wire        s1_axiw_bvalid,
    input  wire        s1_axiw_bready,
    input  wire [3:0]  s1_axir_arid,
    input  wire [31:0] s1_axir_araddr,
    input  wire [7:0]  s1_axir_arlen,
    input  wire [2:0]  s1_axir_arsize,
    input  wire [1:0]  s1_axir_arburst,
    input  wire        s1_axir_arvalid,
    output wire        s1_axir_arready,
    output wire [3:0]  s1_axir_rid,
    output wire [1023:0] s1_axir_rdata,
    output wire [1:0]  s1_axir_rresp,
    output wire        s1_axir_rlast,
    output wire        s1_axir_rvalid,
    input  wire        s1_axir_rready,

    // =========================================================================
    // AXI4 Slave Interface Port 2
    // =========================================================================
    input  wire [3:0]  s2_axiw_awid,
    input  wire [31:0] s2_axiw_awaddr,
    input  wire [7:0]  s2_axiw_awlen,
    input  wire [2:0]  s2_axiw_awsize,
    input  wire [1:0]  s2_axiw_awburst,
    input  wire        s2_axiw_awvalid,
    output wire        s2_axiw_awready,
    input  wire [3:0]  s2_axiw_wid,
    input  wire [1023:0] s2_axiw_wdata,
    input  wire [127:0] s2_axiw_wstrb,
    input  wire        s2_axiw_wlast,
    input  wire        s2_axiw_wvalid,
    output wire        s2_axiw_wready,
    output wire [3:0]  s2_axiw_bid,
    output wire [1:0]  s2_axiw_bresp,
    output wire        s2_axiw_bvalid,
    input  wire        s2_axiw_bready,
    input  wire [3:0]  s2_axir_arid,
    input  wire [31:0] s2_axir_araddr,
    input  wire [7:0]  s2_axir_arlen,
    input  wire [2:0]  s2_axir_arsize,
    input  wire [1:0]  s2_axir_arburst,
    input  wire        s2_axir_arvalid,
    output wire        s2_axir_arready,
    output wire [3:0]  s2_axir_rid,
    output wire [1023:0] s2_axir_rdata,
    output wire [1:0]  s2_axir_rresp,
    output wire        s2_axir_rlast,
    output wire        s2_axir_rvalid,
    input  wire        s2_axir_rready,

    // =========================================================================
    // AXI4 Slave Interface Port 3
    // =========================================================================
    input  wire [3:0]  s3_axiw_awid,
    input  wire [31:0] s3_axiw_awaddr,
    input  wire [7:0]  s3_axiw_awlen,
    input  wire [2:0]  s3_axiw_awsize,
    input  wire [1:0]  s3_axiw_awburst,
    input  wire        s3_axiw_awvalid,
    output wire        s3_axiw_awready,
    input  wire [3:0]  s3_axiw_wid,
    input  wire [1023:0] s3_axiw_wdata,
    input  wire [127:0] s3_axiw_wstrb,
    input  wire        s3_axiw_wlast,
    input  wire        s3_axiw_wvalid,
    output wire        s3_axiw_wready,
    output wire [3:0]  s3_axiw_bid,
    output wire [1:0]  s3_axiw_bresp,
    output wire        s3_axiw_bvalid,
    input  wire        s3_axiw_bready,
    input  wire [3:0]  s3_axir_arid,
    input  wire [31:0] s3_axir_araddr,
    input  wire [7:0]  s3_axir_arlen,
    input  wire [2:0]  s3_axir_arsize,
    input  wire [1:0]  s3_axir_arburst,
    input  wire        s3_axir_arvalid,
    output wire        s3_axir_arready,
    output wire [3:0]  s3_axir_rid,
    output wire [1023:0] s3_axir_rdata,
    output wire [1:0]  s3_axir_rresp,
    output wire        s3_axir_rlast,
    output wire        s3_axir_rvalid,
    input  wire        s3_axir_rready,

    // =========================================================================
    // Clock Gating
    // =========================================================================
    input  wire        cgate_en,       // Clock gate enable
    output wire        cgate_status,   // Clock gate status

    // =========================================================================
    // Interrupt Outputs
    // =========================================================================
    output wire        irq_ecc_single, // Single-bit ECC error interrupt
    output wire        irq_ecc_double  // Double-bit ECC error interrupt
);

    // =========================================================================
    // Internal Signals
    // =========================================================================

    // APB to Core
    wire [11:0]  apb_addr;
    wire         apb_wr;
    wire [63:0]  apb_wdata;
    wire [63:0]  apb_rdata;
    wire         apb_ready;
    wire         apb_error;

    // AXI to Core (port 0)
    wire [31:0]  axi0_waddr;
    wire         axi0_wvalid;
    wire         axi0_wready;
    wire [1023:0] axi0_wdata;
    wire [127:0] axi0_wstrb;
    wire         axi0_wlast;
    wire [31:0]  axi0_raddr;
    wire         axi0_rvalid;
    wire         axi0_rready;
    wire [1023:0] axi0_rdata;
    wire         axi0_rlast;
    wire [1:0]   axi0_rresp;

    // AXI to Core (port 1)
    wire [31:0]  axi1_waddr;
    wire         axi1_wvalid;
    wire         axi1_wready;
    wire [1023:0] axi1_wdata;
    wire [127:0] axi1_wstrb;
    wire         axi1_wlast;
    wire [31:0]  axi1_raddr;
    wire         axi1_rvalid;
    wire         axi1_rready;
    wire [1023:0] axi1_rdata;
    wire         axi1_rlast;
    wire [1:0]   axi1_rresp;

    // AXI to Core (port 2)
    wire [31:0]  axi2_waddr;
    wire         axi2_wvalid;
    wire         axi2_wready;
    wire [1023:0] axi2_wdata;
    wire [127:0] axi2_wstrb;
    wire         axi2_wlast;
    wire [31:0]  axi2_raddr;
    wire         axi2_rvalid;
    wire         axi2_rready;
    wire [1023:0] axi2_rdata;
    wire         axi2_rlast;
    wire [1:0]   axi2_rresp;

    // AXI to Core (port 3)
    wire [31:0]  axi3_waddr;
    wire         axi3_wvalid;
    wire         axi3_wready;
    wire [1023:0] axi3_wdata;
    wire [127:0] axi3_wstrb;
    wire         axi3_wlast;
    wire [31:0]  axi3_raddr;
    wire         axi3_rvalid;
    wire         axi3_rready;
    wire [1023:0] axi3_rdata;
    wire         axi3_rlast;
    wire [1:0]   axi3_rresp;

    // SRAM Interface
    wire [15:0]  core_sram_addr;
    wire         core_sram_csn;
    wire         core_sram_wen;
    wire [127:0] core_sram_wdata;
    wire [127:0] core_sram_rdata;
    wire [15:0]  core_sram_wmask;
    wire         core_sram_oen;

    // ECC signals
    wire         ecc_enable;
    wire         ecc_bypass;
    wire [21:0]  ecc_checkbits;
    wire         ecc_error_single;
    wire         ecc_error_double;
    wire [15:0]  ecc_error_addr;

    // Clock gating
    wire         cg_clk;
    wire         cg_active;

    // =========================================================================
    // Clock Gating Unit
    // =========================================================================
    sram_ctrl_cg u_cg (
        .clk        (clk),
        .rst_n      (rst_n),
        .gate_en    (cgate_en),
        .idle       (cg_active),
        .cg_clk     (cg_clk),
        .cg_status  (cgate_status)
    );

    // =========================================================================
    // APB Interface
    // =========================================================================
    sram_ctrl_apb u_apb (
        .pclk       (pclk),
        .prst_n     (prst_n),
        .pgate      (pgate),
        .paddr      (paddr),
        .psel       (psel),
        .penable    (penable),
        .pwrite     (pwrite),
        .pwdata     (pwdata),
        .pready     (pready),
        .prdata     (prdata),
        .pslverr    (pslverr),
        .ecc_enable (ecc_enable),
        .ecc_bypass (ecc_bypass),
        .irq_ecc_single (irq_ecc_single),
        .irq_ecc_double (irq_ecc_double),
        .cgate_en   (cgate_en)
    );

    // =========================================================================
    // AXI4 Interface Port 0
    // =========================================================================
    sram_ctrl_axi u_axi0 (
        .clk        (cg_clk),
        .rst_n      (rst_n),
        .ecc_enable (ecc_enable),
        // Write Address
        .s_awid     (s0_axiw_awid),
        .s_awaddr   (s0_axiw_awaddr),
        .s_awlen    (s0_axiw_awlen),
        .s_awsize   (s0_axiw_awsize),
        .s_awburst  (s0_axiw_awburst),
        .s_awvalid  (s0_axiw_awvalid),
        .s_awready  (s0_axiw_awready),
        // Write Data
        .s_wid      (s0_axiw_wid),
        .s_wdata    (s0_axiw_wdata),
        .s_wstrb    (s0_axiw_wstrb),
        .s_wlast    (s0_axiw_wlast),
        .s_wvalid   (s0_axiw_wvalid),
        .s_wready   (s0_axiw_wready),
        // Write Response
        .s_bid      (s0_axiw_bid),
        .s_bresp    (s0_axiw_bresp),
        .s_bvalid   (s0_axiw_bvalid),
        .s_bready   (s0_axiw_bready),
        // Read Address
        .s_arid     (s0_axir_arid),
        .s_araddr   (s0_axir_araddr),
        .s_arlen    (s0_axir_arlen),
        .s_arsize   (s0_axir_arsize),
        .s_arburst  (s0_axir_arburst),
        .s_arvalid  (s0_axir_arvalid),
        .s_arready  (s0_axir_arready),
        // Read Data
        .s_rid      (s0_axir_rid),
        .s_rdata    (s0_axir_rdata),
        .s_rresp    (s0_axir_rresp),
        .s_rlast    (s0_axir_rlast),
        .s_rvalid   (s0_axir_rvalid),
        .s_rready   (s0_axir_rready),
        // Internal Interface
        .m_waddr    (axi0_waddr),
        .m_wvalid   (axi0_wvalid),
        .m_wready   (axi0_wready),
        .m_wdata    (axi0_wdata),
        .m_wstrb    (axi0_wstrb),
        .m_wlast    (axi0_wlast),
        .m_raddr    (axi0_raddr),
        .m_rvalid   (axi0_rvalid),
        .m_rready   (axi0_rready),
        .m_rdata    (axi0_rdata),
        .m_rlast    (axi0_rlast),
        .m_rresp    (axi0_rresp),
        .port_active(cg_active)
    );

    // =========================================================================
    // AXI4 Interface Port 1
    // =========================================================================
    sram_ctrl_axi u_axi1 (
        .clk        (cg_clk),
        .rst_n      (rst_n),
        .ecc_enable (ecc_enable),
        .s_awid     (s1_axiw_awid),
        .s_awaddr   (s1_axiw_awaddr),
        .s_awlen    (s1_axiw_awlen),
        .s_awsize   (s1_axiw_awsize),
        .s_awburst  (s1_axiw_awburst),
        .s_awvalid  (s1_axiw_awvalid),
        .s_awready  (s1_axiw_awready),
        .s_wid      (s1_axiw_wid),
        .s_wdata    (s1_axiw_wdata),
        .s_wstrb    (s1_axiw_wstrb),
        .s_wlast    (s1_axiw_wlast),
        .s_wvalid   (s1_axiw_wvalid),
        .s_wready   (s1_axiw_wready),
        .s_bid      (s1_axiw_bid),
        .s_bresp    (s1_axiw_bresp),
        .s_bvalid   (s1_axiw_bvalid),
        .s_bready   (s1_axiw_bready),
        .s_arid     (s1_axir_arid),
        .s_araddr   (s1_axir_araddr),
        .s_arlen    (s1_axir_arlen),
        .s_arsize   (s1_axir_arsize),
        .s_arburst  (s1_axir_arburst),
        .s_arvalid  (s1_axir_arvalid),
        .s_arready  (s1_axir_arready),
        .s_rid      (s1_axir_rid),
        .s_rdata    (s1_axir_rdata),
        .s_rresp    (s1_axir_rresp),
        .s_rlast    (s1_axir_rlast),
        .s_rvalid   (s1_axir_rvalid),
        .s_rready   (s1_axir_rready),
        .m_waddr    (axi1_waddr),
        .m_wvalid   (axi1_wvalid),
        .m_wready   (axi1_wready),
        .m_wdata    (axi1_wdata),
        .m_wstrb    (axi1_wstrb),
        .m_wlast    (axi1_wlast),
        .m_raddr    (axi1_raddr),
        .m_rvalid   (axi1_rvalid),
        .m_rready   (axi1_rready),
        .m_rdata    (axi1_rdata),
        .m_rlast    (axi1_rlast),
        .m_rresp    (axi1_rresp),
        .port_active(cg_active)
    );

    // =========================================================================
    // AXI4 Interface Port 2
    // =========================================================================
    sram_ctrl_axi u_axi2 (
        .clk        (cg_clk),
        .rst_n      (rst_n),
        .ecc_enable (ecc_enable),
        .s_awid     (s2_axiw_awid),
        .s_awaddr   (s2_axiw_awaddr),
        .s_awlen    (s2_axiw_awlen),
        .s_awsize   (s2_axiw_awsize),
        .s_awburst  (s2_axiw_awburst),
        .s_awvalid  (s2_axiw_awvalid),
        .s_awready  (s2_axiw_awready),
        .s_wid      (s2_axiw_wid),
        .s_wdata    (s2_axiw_wdata),
        .s_wstrb    (s2_axiw_wstrb),
        .s_wlast    (s2_axiw_wlast),
        .s_wvalid   (s2_axiw_wvalid),
        .s_wready   (s2_axiw_wready),
        .s_bid      (s2_axiw_bid),
        .s_bresp    (s2_axiw_bresp),
        .s_bvalid   (s2_axiw_bvalid),
        .s_bready   (s2_axiw_bready),
        .s_arid     (s2_axir_arid),
        .s_araddr   (s2_axir_araddr),
        .s_arlen    (s2_axir_arlen),
        .s_arsize   (s2_axir_arsize),
        .s_arburst  (s2_axir_arburst),
        .s_arvalid  (s2_axir_arvalid),
        .s_arready  (s2_axir_arready),
        .s_rid      (s2_axir_rid),
        .s_rdata    (s2_axir_rdata),
        .s_rresp    (s2_axir_rresp),
        .s_rlast    (s2_axir_rlast),
        .s_rvalid   (s2_axir_rvalid),
        .s_rready   (s2_axir_rready),
        .m_waddr    (axi2_waddr),
        .m_wvalid   (axi2_wvalid),
        .m_wready   (axi2_wready),
        .m_wdata    (axi2_wdata),
        .m_wstrb    (axi2_wstrb),
        .m_wlast    (axi2_wlast),
        .m_raddr    (axi2_raddr),
        .m_rvalid   (axi2_rvalid),
        .m_rready   (axi2_rready),
        .m_rdata    (axi2_rdata),
        .m_rlast    (axi2_rlast),
        .m_rresp    (axi2_rresp),
        .port_active(cg_active)
    );

    // =========================================================================
    // AXI4 Interface Port 3
    // =========================================================================
    sram_ctrl_axi u_axi3 (
        .clk        (cg_clk),
        .rst_n      (rst_n),
        .ecc_enable (ecc_enable),
        .s_awid     (s3_axiw_awid),
        .s_awaddr   (s3_axiw_awaddr),
        .s_awlen    (s3_axiw_awlen),
        .s_awsize   (s3_axiw_awsize),
        .s_awburst  (s3_axiw_awburst),
        .s_awvalid  (s3_axiw_awvalid),
        .s_awready  (s3_axiw_awready),
        .s_wid      (s3_axiw_wid),
        .s_wdata    (s3_axiw_wdata),
        .s_wstrb    (s3_axiw_wstrb),
        .s_wlast    (s3_axiw_wlast),
        .s_wvalid   (s3_axiw_wvalid),
        .s_wready   (s3_axiw_wready),
        .s_bid      (s3_axiw_bid),
        .s_bresp    (s3_axiw_bresp),
        .s_bvalid   (s3_axiw_bvalid),
        .s_bready   (s3_axiw_bready),
        .s_arid     (s3_axir_arid),
        .s_araddr   (s3_axir_araddr),
        .s_arlen    (s3_axir_arlen),
        .s_arsize   (s3_axir_arsize),
        .s_arburst  (s3_axir_arburst),
        .s_arvalid  (s3_axir_arvalid),
        .s_arready  (s3_axir_arready),
        .s_rid      (s3_axir_rid),
        .s_rdata    (s3_axir_rdata),
        .s_rresp    (s3_axir_rresp),
        .s_rlast    (s3_axir_rlast),
        .s_rvalid   (s3_axir_rvalid),
        .s_rready   (s3_axir_rready),
        .m_waddr    (axi3_waddr),
        .m_wvalid   (axi3_wvalid),
        .m_wready   (axi3_wready),
        .m_wdata    (axi3_wdata),
        .m_wstrb    (axi3_wstrb),
        .m_wlast    (axi3_wlast),
        .m_raddr    (axi3_raddr),
        .m_rvalid   (axi3_rvalid),
        .m_rready   (axi3_rready),
        .m_rdata    (axi3_rdata),
        .m_rlast    (axi3_rlast),
        .m_rresp    (axi3_rresp),
        .port_active(cg_active)
    );

    // =========================================================================
    // SRAM Controller Core
    // =========================================================================
    sram_ctrl_core u_core (
        .clk        (cg_clk),
        .rst_n      (rst_n),
        // Port 0
        .p0_waddr   (axi0_waddr),
        .p0_wvalid  (axi0_wvalid),
        .p0_wready  (axi0_wready),
        .p0_wdata   (axi0_wdata),
        .p0_wstrb   (axi0_wstrb),
        .p0_wlast   (axi0_wlast),
        .p0_raddr   (axi0_raddr),
        .p0_rvalid  (axi0_rvalid),
        .p0_rready  (axi0_rready),
        .p0_rdata   (axi0_rdata),
        .p0_rlast   (axi0_rlast),
        .p0_rresp   (axi0_rresp),
        // Port 1
        .p1_waddr   (axi1_waddr),
        .p1_wvalid  (axi1_wvalid),
        .p1_wready  (axi1_wready),
        .p1_wdata   (axi1_wdata),
        .p1_wstrb   (axi1_wstrb),
        .p1_wlast   (axi1_wlast),
        .p1_raddr   (axi1_raddr),
        .p1_rvalid  (axi1_rvalid),
        .p1_rready  (axi1_rready),
        .p1_rdata   (axi1_rdata),
        .p1_rlast   (axi1_rlast),
        .p1_rresp   (axi1_rresp),
        // Port 2
        .p2_waddr   (axi2_waddr),
        .p2_wvalid  (axi2_wvalid),
        .p2_wready  (axi2_wready),
        .p2_wdata   (axi2_wdata),
        .p2_wstrb   (axi2_wstrb),
        .p2_wlast   (axi2_wlast),
        .p2_raddr   (axi2_raddr),
        .p2_rvalid  (axi2_rvalid),
        .p2_rready  (axi2_rready),
        .p2_rdata   (axi2_rdata),
        .p2_rlast   (axi2_rlast),
        .p2_rresp   (axi2_rresp),
        // Port 3
        .p3_waddr   (axi3_waddr),
        .p3_wvalid  (axi3_wvalid),
        .p3_wready  (axi3_wready),
        .p3_wdata   (axi3_wdata),
        .p3_wstrb   (axi3_wstrb),
        .p3_wlast   (axi3_wlast),
        .p3_raddr   (axi3_raddr),
        .p3_rvalid  (axi3_rvalid),
        .p3_rready  (axi3_rready),
        .p3_rdata   (axi3_rdata),
        .p3_rlast   (axi3_rlast),
        .p3_rresp   (axi3_rresp),
        // SRAM Interface
        .sram_addr  (core_sram_addr),
        .sram_csn   (core_sram_csn),
        .sram_wen   (core_sram_wen),
        .sram_wdata (core_sram_wdata),
        .sram_rdata (core_sram_rdata),
        .sram_wmask (core_sram_wmask),
        .sram_oen   (core_sram_oen),
        // ECC
        .ecc_enable (ecc_enable),
        .ecc_bypass (ecc_bypass),
        .ecc_error_single (ecc_error_single),
        .ecc_error_double (ecc_error_double),
        .ecc_error_addr   (ecc_error_addr),
        // Activity status for clock gating
        .port_active ({axi3_wvalid | axi3_rvalid,
                       axi2_wvalid | axi2_rvalid,
                       axi1_wvalid | axi1_rvalid,
                       axi0_wvalid | axi0_rvalid})
    );

    // =========================================================================
    // ECC Module
    // =========================================================================
    sram_ctrl_ecc u_ecc (
        .clk        (cg_clk),
        .rst_n      (rst_n),
        .enable     (ecc_enable),
        .bypass     (ecc_bypass),
        // Write path
        .wdata_in   (core_sram_wdata),
        .wdata_out  (sram_wdata),
        .wcheckbits (ecc_checkbits),
        // Read path
        .rdata_in   (sram_rdata),
        .rdata_out  (core_sram_rdata),
        .rcheckbits (ecc_checkbits),
        .error_single (ecc_error_single),
        .error_double (ecc_error_double),
        .error_addr    (ecc_error_addr)
    );

    // =========================================================================
    // Output Assignment
    // =========================================================================
    assign sram_addr  = core_sram_addr;
    assign sram_csn   = core_sram_csn;
    assign sram_wen   = core_sram_wen;
    assign sram_wmask = core_sram_wmask;
    assign sram_oen   = core_sram_oen;

endmodule
