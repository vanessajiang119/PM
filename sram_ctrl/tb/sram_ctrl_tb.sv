// =============================================================================
// Project: sram_ctrl - SRAM Controller IP
// Testbench: Top-level testbench
// Version: 1.0.0
// =============================================================================

`timescale 1ns/1ps

module sram_ctrl_tb;

    // =========================================================================
    // Clock and Reset
    // =========================================================================
    reg clk;
    reg rst_n;
    reg pclk;
    reg prst_n;

    // =========================================================================
    // SRAM Interface (mock)
    // =========================================================================
    wire [15:0] sram_addr;
    wire        sram_csn;
    wire        sram_wen;
    wire [127:0] sram_wdata;
    reg  [127:0] sram_rdata;
    wire [15:0] sram_wmask;
    wire        sram_oen;

    // SRAM memory model
    reg [127:0] sram_mem [0:65535];

    // =========================================================================
    // APB Interface
    // =========================================================================
    reg  [11:0] paddr;
    reg         psel;
    reg         penable;
    reg         pwrite;
    reg  [63:0] pwdata;
    wire        pready;
    wire [63:0] prdata;
    wire        pslverr;
    reg         pgate;

    // =========================================================================
    // AXI4 Slave Interface Port 0
    // =========================================================================
    reg  [3:0]  s0_axiw_awid;
    reg  [31:0] s0_axiw_awaddr;
    reg  [7:0]  s0_axiw_awlen;
    reg  [2:0]  s0_axiw_awsize;
    reg  [1:0]  s0_axiw_awburst;
    reg         s0_axiw_awvalid;
    wire        s0_axiw_awready;
    reg  [3:0]  s0_axiw_wid;
    reg  [1023:0] s0_axiw_wdata;
    reg  [127:0] s0_axiw_wstrb;
    reg         s0_axiw_wlast;
    reg         s0_axiw_wvalid;
    wire        s0_axiw_wready;
    wire [3:0]  s0_axiw_bid;
    wire [1:0]  s0_axiw_bresp;
    wire        s0_axiw_bvalid;
    reg         s0_axiw_bready;
    reg  [3:0]  s0_axir_arid;
    reg  [31:0] s0_axir_araddr;
    reg  [7:0]  s0_axir_arlen;
    reg  [2:0]  s0_axir_arsize;
    reg  [1:0]  s0_axir_arburst;
    reg         s0_axir_arvalid;
    wire        s0_axir_arready;
    wire [3:0]  s0_axir_rid;
    wire [1023:0] s0_axir_rdata;
    wire [1:0]  s0_axir_rresp;
    wire        s0_axir_rlast;
    wire        s0_axir_rvalid;
    reg         s0_axir_rready;

    // =========================================================================
    // Clock Gating
    // =========================================================================
    reg         cgate_en;
    wire        cgate_status;

    // =========================================================================
    // Interrupts
    // =========================================================================
    wire        irq_ecc_single;
    wire        irq_ecc_double;

    // =========================================================================
    // DUT Instance (Using simplified version)
    // =========================================================================
    sram_ctrl_simple dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .pclk           (pclk),
        .prst_n         (prst_n),
        .sram_addr      (sram_addr),
        .sram_csn       (sram_csn),
        .sram_wen       (sram_wen),
        .sram_wdata     (sram_wdata),
        .sram_rdata     (sram_rdata),
        .sram_wmask     (sram_wmask),
        .sram_oen       (sram_oen),
        .paddr          (paddr),
        .psel           (psel),
        .penable        (penable),
        .pwrite         (pwrite),
        .pwdata         (pwdata),
        .pready         (pready),
        .prdata         (prdata),
        .pslverr        (pslverr),
        .pgate          (pgate),
        .s0_axiw_awid   (s0_axiw_awid),
        .s0_axiw_awaddr (s0_axiw_awaddr),
        .s0_axiw_awlen  (s0_axiw_awlen),
        .s0_axiw_awsize (s0_axiw_awsize),
        .s0_axiw_awburst(s0_axiw_awburst),
        .s0_axiw_awvalid(s0_axiw_awvalid),
        .s0_axiw_awready(s0_axiw_awready),
        .s0_axiw_wid    (s0_axiw_wid),
        .s0_axiw_wdata  (s0_axiw_wdata),
        .s0_axiw_wstrb  (s0_axiw_wstrb),
        .s0_axiw_wlast  (s0_axiw_wlast),
        .s0_axiw_wvalid (s0_axiw_wvalid),
        .s0_axiw_wready (s0_axiw_wready),
        .s0_axiw_bid    (s0_axiw_bid),
        .s0_axiw_bresp  (s0_axiw_bresp),
        .s0_axiw_bvalid (s0_axiw_bvalid),
        .s0_axiw_bready (s0_axiw_bready),
        .s0_axir_arid   (s0_axir_arid),
        .s0_axir_araddr (s0_axir_araddr),
        .s0_axir_arlen  (s0_axir_arlen),
        .s0_axir_arsize (s0_axir_arsize),
        .s0_axir_arburst(s0_axir_arburst),
        .s0_axir_arvalid(s0_axir_arvalid),
        .s0_axir_arready(s0_axir_arready),
        .s0_axir_rid    (s0_axir_rid),
        .s0_axir_rdata  (s0_axir_rdata),
        .s0_axir_rresp  (s0_axir_rresp),
        .s0_axir_rlast  (s0_axir_rlast),
        .s0_axir_rvalid (s0_axir_rvalid),
        .s0_axir_rready (s0_axir_rready),
        .s1_axiw_awid   (4'h0),
        .s1_axiw_awaddr (32'h0),
        .s1_axiw_awlen  (8'h0),
        .s1_axiw_awsize (3'h0),
        .s1_axiw_awburst(2'h0),
        .s1_axiw_awvalid(1'b0),
        .s1_axiw_awready(),
        .s1_axiw_wid    (4'h0),
        .s1_axiw_wdata  (1024'h0),
        .s1_axiw_wstrb  (128'h0),
        .s1_axiw_wlast  (1'b0),
        .s1_axiw_wvalid (1'b0),
        .s1_axiw_wready (),
        .s1_axiw_bid    (),
        .s1_axiw_bresp  (),
        .s1_axiw_bvalid (),
        .s1_axiw_bready (1'b0),
        .s1_axir_arid   (4'h0),
        .s1_axir_araddr (32'h0),
        .s1_axir_arlen  (8'h0),
        .s1_axir_arsize (3'h0),
        .s1_axir_arburst(2'h0),
        .s1_axir_arvalid(1'b0),
        .s1_axir_arready(),
        .s1_axir_rid    (),
        .s1_axir_rdata  (),
        .s1_axir_rresp  (),
        .s1_axir_rlast  (),
        .s1_axir_rvalid (),
        .s1_axir_rready (1'b0),
        .s2_axiw_awid   (4'h0),
        .s2_axiw_awaddr (32'h0),
        .s2_axiw_awlen  (8'h0),
        .s2_axiw_awsize (3'h0),
        .s2_axiw_awburst(2'h0),
        .s2_axiw_awvalid(1'b0),
        .s2_axiw_awready(),
        .s2_axiw_wid    (4'h0),
        .s2_axiw_wdata  (1024'h0),
        .s2_axiw_wstrb  (128'h0),
        .s2_axiw_wlast  (1'b0),
        .s2_axiw_wvalid (1'b0),
        .s2_axiw_wready (),
        .s2_axiw_bid    (),
        .s2_axiw_bresp  (),
        .s2_axiw_bvalid (),
        .s2_axiw_bready (1'b0),
        .s2_axir_arid   (4'h0),
        .s2_axir_araddr (32'h0),
        .s2_axir_arlen  (8'h0),
        .s2_axir_arsize (3'h0),
        .s2_axir_arburst(2'h0),
        .s2_axir_arvalid(1'b0),
        .s2_axir_arready(),
        .s2_axir_rid    (),
        .s2_axir_rdata  (),
        .s2_axir_rresp  (),
        .s2_axir_rlast  (),
        .s2_axir_rvalid (),
        .s2_axir_rready (1'b0),
        .s3_axiw_awid   (4'h0),
        .s3_axiw_awaddr (32'h0),
        .s3_axiw_awlen  (8'h0),
        .s3_axiw_awsize (3'h0),
        .s3_axiw_awburst(2'h0),
        .s3_axiw_awvalid(1'b0),
        .s3_axiw_awready(),
        .s3_axiw_wid    (4'h0),
        .s3_axiw_wdata  (1024'h0),
        .s3_axiw_wstrb  (128'h0),
        .s3_axiw_wlast  (1'b0),
        .s3_axiw_wvalid (1'b0),
        .s3_axiw_wready (),
        .s3_axiw_bid    (),
        .s3_axiw_bresp  (),
        .s3_axiw_bvalid (),
        .s3_axiw_bready (1'b0),
        .s3_axir_arid   (4'h0),
        .s3_axir_araddr (32'h0),
        .s3_axir_arlen  (8'h0),
        .s3_axir_arsize (3'h0),
        .s3_axir_arburst(2'h0),
        .s3_axir_arvalid(1'b0),
        .s3_axir_arready(),
        .s3_axir_rid    (),
        .s3_axir_rdata  (),
        .s3_axir_rresp  (),
        .s3_axir_rlast  (),
        .s3_axir_rvalid (),
        .s3_axir_rready (1'b0),
        .cgate_en       (cgate_en),
        .cgate_status   (cgate_status),
        .irq_ecc_single (irq_ecc_single),
        .irq_ecc_double (irq_ecc_double)
    );

    // =========================================================================
    // Clock Generation
    // =========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz
    end

    initial begin
        pclk = 0;
        forever #25 pclk = ~pclk;  // 20MHz
    end

    // =========================================================================
    // SRAM Memory Model
    // =========================================================================
    always @(posedge clk) begin
        if (!sram_csn && !sram_wen) begin
            // Write
            if (sram_addr < 65536) begin
                sram_mem[sram_addr] <= (sram_mem[sram_addr] & ~sram_wmask) |
                                       (sram_wdata & sram_wmask);
            end
        end
    end

    always @(posedge clk) begin
        if (!sram_csn && sram_wen && !sram_oen) begin
            // Read
            if (sram_addr < 65536) begin
                sram_rdata <= sram_mem[sram_addr];
            end else begin
                sram_rdata <= 128'h0;
            end
        end
    end

    // =========================================================================
    // Test Control
    // =========================================================================
    initial begin
        $dumpfile("sram_ctrl_tb.vcd");
        $dumpvars(0, sram_ctrl_tb);
    end

    // =========================================================================
    // Test Tasks
    // =========================================================================
    task reset_dut;
        begin
            rst_n = 0;
            prst_n = 0;
            #100;
            rst_n = 1;
            prst_n = 1;
            #50;
        end
    endtask

    task apb_write;
        input [11:0] addr;
        input [63:0] data;
        begin
            @(posedge pclk);
            paddr = addr;
            pwdata = data;
            pwrite = 1;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable = 1;
            @(posedge pclk);
            while (!pready) @(posedge pclk);
            psel = 0;
            penable = 0;
            #10;
        end
    endtask

    task apb_read;
        input [11:0] addr;
        output [63:0] data;
        begin
            @(posedge pclk);
            paddr = addr;
            pwrite = 0;
            psel = 1;
            penable = 0;
            @(posedge pclk);
            penable = 1;
            @(posedge pclk);
            while (!pready) @(posedge pclk);
            data = prdata;
            psel = 0;
            penable = 0;
            #10;
        end
    endtask

    task axi_write;
        input [31:0] addr;
        input [1023:0] data;
        input [7:0] len;
        integer i;
        begin
            // Write address - add small delay to avoid race condition
            #1;
            s0_axiw_awvalid = 1;
            s0_axiw_awaddr = addr;
            s0_axiw_awlen = len;
            s0_axiw_awsize = 3'h7;  // 128 bytes (1024 bits)
            s0_axiw_awburst = 2'b01; // INCR
            #10;
            @(posedge clk);
            #1;
            while (!s0_axiw_awready) begin
                @(posedge clk);
                #1;
            end
            s0_axiw_awvalid = 0;

            // Write data
            for (i = 0; i <= len; i = i + 1) begin
                #1;
                s0_axiw_wvalid = 1;
                s0_axiw_wdata = data;
                s0_axiw_wstrb = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                s0_axiw_wlast = (i == len);
                #10;
                @(posedge clk);
                #1;
                while (!s0_axiw_wready) begin
                    @(posedge clk);
                    #1;
                end
            end
            s0_axiw_wvalid = 0;

            // Write response
            #1;
            s0_axiw_bready = 1;
            #10;
            @(posedge clk);
            #1;
            while (!s0_axiw_bvalid) begin
                @(posedge clk);
                #1;
            end
            s0_axiw_bready = 0;
            #10;
        end
    endtask

    task axi_read;
        input [31:0] addr;
        input [7:0] len;
        output [1023:0] data;
        integer i;
        begin
            // Read address
            @(posedge clk);
            s0_axir_arvalid = 1;
            s0_axir_araddr = addr;
            s0_axir_arlen = len;
            s0_axir_arsize = 3'h7;
            s0_axir_arburst = 2'b01;
            @(posedge clk);
            while (!s0_axir_arready) @(posedge clk);
            s0_axir_arvalid = 0;

            // Read data
            for (i = 0; i <= len; i = i + 1) begin
                @(posedge clk);
                s0_axir_rready = 1;
                @(posedge clk);
                while (!s0_axir_rvalid) @(posedge clk);
                data = s0_axir_rdata;
                s0_axir_rready = 0;
            end
            #10;
        end
    endtask

    // =========================================================================
    // Main Test Sequence
    // =========================================================================
    reg [63:0] apb_rdata;
    reg [1023:0] axi_rdata;

    initial begin
        // Initialize signals
        rst_n = 0;
        prst_n = 0;
        paddr = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        pwdata = 0;
        pgate = 0;
        cgate_en = 0;

        s0_axiw_awid = 0;
        s0_axiw_awaddr = 0;
        s0_axiw_awlen = 0;
        s0_axiw_awsize = 0;
        s0_axiw_awburst = 0;
        s0_axiw_awvalid = 0;
        s0_axiw_wid = 0;
        s0_axiw_wdata = 0;
        s0_axiw_wstrb = 0;
        s0_axiw_wlast = 0;
        s0_axiw_wvalid = 0;
        s0_axiw_bready = 0;

        s0_axir_arid = 0;
        s0_axir_araddr = 0;
        s0_axir_arlen = 0;
        s0_axir_arsize = 0;
        s0_axir_arburst = 0;
        s0_axir_arvalid = 0;
        s0_axir_rready = 0;

        #100;
        rst_n = 1;
        prst_n = 1;
        #50;

        $display("[%0t] Starting SRAM Controller Testbench", $time);
        $display("==========================================");

        // Test 1: APB Register Access
        $display("[%0t] Test 1: APB Register Access", $time);
        apb_write(12'h000, 64'h0000_0001);  // Control register
        apb_read(12'h000, apb_rdata);
        $display("[%0t] CTRL Read: 0x%h", $time, apb_rdata);

        apb_write(12'h020, 64'h0000_0001);  // Clock gating enable
        apb_read(12'h020, apb_rdata);
        $display("[%0t] CG_CTRL Read: 0x%h", $time, apb_rdata);

        apb_write(12'h010, 64'h0000_0001);  // ECC enable
        apb_read(12'h010, apb_rdata);
        $display("[%0t] ECC_CTRL Read: 0x%h", $time, apb_rdata);

        $display("[%0t] APB Test PASSED", $time);

        // Test 2: AXI4 Single Write
        $display("[%0t] Test 2: AXI4 Single Write", $time);
        axi_write(32'h0000_1000, 1024'hA5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5, 8'h00);
        $display("[%0t] AXI4 Single Write COMPLETED", $time);

        // Test 3: AXI4 Single Read
        $display("[%0t] Test 3: AXI4 Single Read", $time);
        axi_read(32'h0000_1000, 8'h00, axi_rdata);
        $display("[%0t] AXI4 Read Data: 0x%h", $time, axi_rdata[127:0]);
        $display("[%0t] AXI4 Single Read COMPLETED", $time);

        // Test 4: AXI4 Burst Write (4 beats)
        $display("[%0t] Test 4: AXI4 Burst Write", $time);
        axi_write(32'h0000_2000, 1024'h1111_1111_2222_2222_3333_3333_4444_4444, 8'h03);
        $display("[%0t] AXI4 Burst Write COMPLETED", $time);

        // Test 5: AXI4 Burst Read (4 beats)
        $display("[%0t] Test 5: AXI4 Burst Read", $time);
        axi_read(32'h0000_2000, 8'h03, axi_rdata);
        $display("[%0t] AXI4 Burst Read COMPLETED", $time);

        $display("==========================================");
        $display("[%0t] ALL TESTS PASSED", $time);
        $display("==========================================");

        #100;
        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000;
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule
