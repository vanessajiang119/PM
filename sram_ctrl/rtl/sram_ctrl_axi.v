// =============================================================================
// Project: sram_ctrl - SRAM Controller IP
// Module:  AXI4 Interface Module
// Version: 1.0.0
// =============================================================================

module sram_ctrl_axi (
    // =========================================================================
    // Clock and Reset
    // =========================================================================
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ecc_enable,

    // =========================================================================
    // AXI4 Slave Interface (Write Address)
    // =========================================================================
    input  wire [3:0]  s_awid,
    input  wire [31:0] s_awaddr,
    input  wire [7:0]  s_awlen,
    input  wire [2:0]  s_awsize,
    input  wire [1:0]  s_awburst,
    input  wire        s_awvalid,
    output wire        s_awready,

    // AXI4 Slave Interface (Write Data)
    input  wire [3:0]  s_wid,
    input  wire [1023:0] s_wdata,
    input  wire [127:0] s_wstrb,
    input  wire        s_wlast,
    input  wire        s_wvalid,
    output wire        s_wready,

    // AXI4 Slave Interface (Write Response)
    output wire [3:0]  s_bid,
    output wire [1:0]  s_bresp,
    output wire        s_bvalid,
    input  wire        s_bready,

    // AXI4 Slave Interface (Read Address)
    input  wire [3:0]  s_arid,
    input  wire [31:0] s_araddr,
    input  wire [7:0]  s_arlen,
    input  wire [2:0]  s_arsize,
    input  wire [1:0]  s_arburst,
    input  wire        s_arvalid,
    output wire        s_arready,

    // AXI4 Slave Interface (Read Data)
    output wire [3:0]  s_rid,
    output wire [1023:0] s_rdata,
    output wire [1:0]  s_rresp,
    output wire        s_rlast,
    output wire        s_rvalid,
    input  wire        s_rready,

    // =========================================================================
    // Internal Native Interface (Write)
    // =========================================================================
    output wire [31:0] m_waddr,
    output wire        m_wvalid,
    input  wire        m_wready,
    output wire [1023:0] m_wdata,
    output wire [127:0] m_wstrb,
    output wire        m_wlast,

    // =========================================================================
    // Internal Native Interface (Read)
    // =========================================================================
    output wire [31:0] m_raddr,
    output wire        m_rvalid,
    input  wire        m_rready,
    input  wire [1023:0] m_rdata,
    input  wire        m_rlast,
    input  wire [1:0]  m_rresp,

    // =========================================================================
    // Activity Status
    // =========================================================================
    output wire        port_active
);

    // =========================================================================
    // Write Channel State Machine
    // =========================================================================
    localparam W_IDLE     = 2'b00;
    localparam W_ADDR     = 2'b01;
    localparam W_DATA     = 2'b10;
    localparam W_RESPONSE = 2'b11;

    reg [1:0] wstate, wnext;
    reg [7:0] wcount;
    reg [31:0] waddr_hold;
    reg [7:0] wlen_hold;
    reg [2:0] wsize_hold;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wstate <= W_IDLE;
            waddr_hold <= 32'h0;
            wlen_hold  <= 8'h0;
            wsize_hold <= 3'h0;
            wcount     <= 8'h0;
        end else begin
            wstate <= wnext;
            case (wstate)
                W_IDLE: begin
                    if (s_awvalid) begin
                        waddr_hold <= s_awaddr;
                        wlen_hold  <= s_awlen;
                        wsize_hold <= s_awsize;
                        wcount     <= 8'h0;
                    end
                end
                W_DATA: begin
                    if (s_wvalid && s_wready) begin
                        wcount <= wcount + 1;
                    end
                end
                default: ;
            endcase
        end
    end

    always @(*) begin
        wnext = wstate;
        case (wstate)
            W_IDLE:    if (s_awvalid) wnext = W_ADDR;
            W_ADDR:    if (s_awvalid && s_awready) wnext = W_DATA;
            W_DATA:    if (s_wvalid && s_wready && s_wlast) wnext = W_RESPONSE;
            W_RESPONSE: if (s_bvalid && s_bready) wnext = W_IDLE;
            default:   wnext = W_IDLE;
        endcase
    end

    assign s_awready = (wstate == W_IDLE) || (wstate == W_ADDR);
    assign s_wready  = (wstate == W_DATA) && m_wready;

    // Write response
    reg bvalid_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bvalid_reg <= 1'b0;
        end else begin
            if (wstate == W_DATA && s_wvalid && s_wlast && s_wready) begin
                bvalid_reg <= 1'b1;
            end else if (s_bready) begin
                bvalid_reg <= 1'b0;
            end
        end
    end

    assign s_bid    = s_awvalid ? s_awid : s_wid;
    assign s_bresp  = 2'b00; // OKAY
    assign s_bvalid = bvalid_reg;

    // =========================================================================
    // Read Channel State Machine
    // =========================================================================
    localparam R_IDLE  = 2'b00;
    localparam R_ADDR  = 2'b01;
    localparam R_DATA  = 2'b10;

    reg [1:0] rstate, rnext;
    reg [7:0] rcount;
    reg [31:0] raddr_hold;
    reg [7:0] rlen_hold;
    reg [2:0] rsize_hold;
    reg [3:0] rid_hold;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rstate    <= R_IDLE;
            raddr_hold<= 32'h0;
            rlen_hold <= 8'h0;
            rsize_hold<= 3'h0;
            rid_hold  <= 4'h0;
            rcount    <= 8'h0;
        end else begin
            rstate <= rnext;
            case (rstate)
                R_IDLE: begin
                    if (s_arvalid) begin
                        raddr_hold <= s_araddr;
                        rlen_hold  <= s_arlen;
                        rsize_hold <= s_arsize;
                        rid_hold   <= s_arid;
                        rcount     <= 8'h0;
                    end
                end
                R_DATA: begin
                    if (m_rvalid && s_rready) begin
                        rcount <= rcount + 1;
                    end
                end
                default: ;
            endcase
        end
    end

    always @(*) begin
        rnext = rstate;
        case (rstate)
            R_IDLE: if (s_arvalid) rnext = R_ADDR;
            R_ADDR: if (s_arvalid && s_arready) rnext = R_DATA;
            R_DATA: if (m_rvalid && s_rready && m_rlast) rnext = R_IDLE;
            default: rnext = R_IDLE;
        endcase
    end

    assign s_arready = (rstate == R_IDLE) || (rstate == R_ADDR);

    // =========================================================================
    // Internal Interface Outputs (Write)
    // =========================================================================
    assign m_waddr  = waddr_hold;
    assign m_wvalid = (wstate == W_DATA);
    assign m_wdata  = s_wdata;
    assign m_wstrb  = s_wstrb;
    assign m_wlast  = s_wlast;

    // =========================================================================
    // Internal Interface Outputs (Read)
    // =========================================================================
    assign m_raddr  = raddr_hold;
    assign m_rvalid = (rstate == R_DATA);

    assign s_rid    = rid_hold;
    assign s_rdata  = m_rdata;
    assign s_rresp  = m_rresp;
    assign s_rlast  = m_rlast;
    assign s_rvalid = m_rvalid;

    // =========================================================================
    // Activity Status
    // =========================================================================
    assign port_active = s_awvalid | s_wvalid | s_arvalid | bvalid_reg | (rstate != R_IDLE);

endmodule
