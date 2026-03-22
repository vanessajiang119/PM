// =============================================================================
// Project: sram_ctrl - SRAM Controller IP
// Module:  SRAM Controller Core
// Version: 1.0.1 (Fixed AXI arbitration)
// =============================================================================

module sram_ctrl_core (
    // =========================================================================
    // Clock and Reset
    // =========================================================================
    input  wire        clk,
    input  wire        rst_n,

    // =========================================================================
    // Port 0 Interface
    // =========================================================================
    input  wire [31:0] p0_waddr,
    input  wire        p0_wvalid,
    output reg         p0_wready,
    input  wire [1023:0] p0_wdata,
    input  wire [127:0] p0_wstrb,
    input  wire        p0_wlast,
    input  wire [31:0] p0_raddr,
    input  wire        p0_rvalid,
    output reg         p0_rready,
    output reg  [1023:0] p0_rdata,
    output reg         p0_rlast,
    output reg  [1:0]  p0_rresp,

    // =========================================================================
    // Port 1 Interface
    // =========================================================================
    input  wire [31:0] p1_waddr,
    input  wire        p1_wvalid,
    output reg         p1_wready,
    input  wire [1023:0] p1_wdata,
    input  wire [127:0] p1_wstrb,
    input  wire        p1_wlast,
    input  wire [31:0] p1_raddr,
    input  wire        p1_rvalid,
    output reg         p1_rready,
    output reg  [1023:0] p1_rdata,
    output reg         p1_rlast,
    output reg  [1:0]  p1_rresp,

    // =========================================================================
    // Port 2 Interface
    // =========================================================================
    input  wire [31:0] p2_waddr,
    input  wire        p2_wvalid,
    output reg         p2_wready,
    input  wire [1023:0] p2_wdata,
    input  wire [127:0] p2_wstrb,
    input  wire        p2_wlast,
    input  wire [31:0] p2_raddr,
    input  wire        p2_rvalid,
    output reg         p2_rready,
    output reg  [1023:0] p2_rdata,
    output reg         p2_rlast,
    output reg  [1:0]  p2_rresp,

    // =========================================================================
    // Port 3 Interface
    // =========================================================================
    input  wire [31:0] p3_waddr,
    input  wire        p3_wvalid,
    output reg         p3_wready,
    input  wire [1023:0] p3_wdata,
    input  wire [127:0] p3_wstrb,
    input  wire        p3_wlast,
    input  wire [31:0] p3_raddr,
    input  wire        p3_rvalid,
    output reg         p3_rready,
    output reg  [1023:0] p3_rdata,
    output reg         p3_rlast,
    output reg  [1:0]  p3_rresp,

    // =========================================================================
    // SRAM Interface (128-bit)
    // =========================================================================
    output reg  [15:0] sram_addr,
    output reg         sram_csn,
    output reg         sram_wen,
    output reg  [127:0] sram_wdata,
    input  wire [127:0] sram_rdata,
    output reg  [15:0] sram_wmask,
    output reg         sram_oen,

    // =========================================================================
    // ECC Control
    // =========================================================================
    input  wire        ecc_enable,
    input  wire        ecc_bypass,
    output wire        ecc_error_single,
    output wire        ecc_error_double,
    output wire [15:0] ecc_error_addr,

    // =========================================================================
    // Activity Status
    // =========================================================================
    input  wire [3:0]  port_active
);

    // =========================================================================
    // State Machine
    // =========================================================================
    localparam IDLE  = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ  = 2'b10;

    reg [1:0] state, next_state;

    // =========================================================================
    // Request Detection
    // =========================================================================
    wire [3:0] w_requests = {p3_wvalid, p2_wvalid, p1_wvalid, p0_wvalid};
    wire [3:0] r_requests = {p3_rvalid, p2_rvalid, p1_rvalid, p0_rvalid};
    wire       any_wvalid = |w_requests;
    wire       any_rvalid = |r_requests;

    // Round-robin pointers
    reg [1:0] w_ptr;
    reg [1:0] r_ptr;

    // Selected port
    reg [1:0] w_sel;
    reg [1:0] r_sel;
    reg       w_grant;
    reg       r_grant;

    // =========================================================================
    // Arbitration Logic
    // =========================================================================
    always @(*) begin
        w_grant = 1'b0;
        r_grant = 1'b0;
        w_sel = 2'b00;
        r_sel = 2'b00;

        // Write arbitration (priority based on w_ptr) - if-else chain
        w_grant = 1'b0;
        w_sel = 2'b00;
        if (any_wvalid) begin
            if (w_requests[(w_ptr + 0) % 4]) begin
                w_sel = (w_ptr + 0) % 4;
                w_grant = 1'b1;
            end else if (w_requests[(w_ptr + 1) % 4]) begin
                w_sel = (w_ptr + 1) % 4;
                w_grant = 1'b1;
            end else if (w_requests[(w_ptr + 2) % 4]) begin
                w_sel = (w_ptr + 2) % 4;
                w_grant = 1'b1;
            end else if (w_requests[(w_ptr + 3) % 4]) begin
                w_sel = (w_ptr + 3) % 4;
                w_grant = 1'b1;
            end
        end

        // Read arbitration (priority based on r_ptr) - if-else chain
        r_grant = 1'b0;
        r_sel = 2'b00;
        if (any_rvalid) begin
            if (r_requests[(r_ptr + 0) % 4]) begin
                r_sel = (r_ptr + 0) % 4;
                r_grant = 1'b1;
            end else if (r_requests[(r_ptr + 1) % 4]) begin
                r_sel = (r_ptr + 1) % 4;
                r_grant = 1'b1;
            end else if (r_requests[(r_ptr + 2) % 4]) begin
                r_sel = (r_ptr + 2) % 4;
                r_grant = 1'b1;
            end else if (r_requests[(r_ptr + 3) % 4]) begin
                r_sel = (r_ptr + 3) % 4;
                r_grant = 1'b1;
            end
        end
    end

    // =========================================================================
    // State Machine
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            w_ptr <= 2'b00;
            r_ptr <= 2'b00;
        end else begin
            state <= next_state;
            case (next_state)
                WRITE: w_ptr <= w_sel + 1;
                READ:  r_ptr <= r_sel + 1;
                default: ;
            endcase
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (w_grant) next_state = WRITE;
                else if (r_grant) next_state = READ;
            end
            WRITE: next_state = IDLE;
            READ:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // =========================================================================
    // SRAM Control
    // =========================================================================
    reg [31:0] current_addr;
    reg [7:0] beat_count;
    reg [1023:0] write_data;
    reg [127:0] write_strb;

    // Address and data latching
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_addr <= 32'h0;
            beat_count   <= 8'h0;
            write_data   <= 1024'h0;
            write_strb   <= 128'h0;
        end else begin
            case (state)
                IDLE: begin
                    beat_count <= 8'h0;
                    if (w_grant) begin
                        current_addr <= p0_waddr;
                        write_data   <= p0_wdata;
                        write_strb   <= p0_wstrb;
                    end else if (r_grant) begin
                        current_addr <= p0_raddr;
                    end
                end
                WRITE: begin
                    current_addr <= current_addr + 16;
                    beat_count   <= beat_count + 1;
                end
                READ: begin
                    current_addr <= current_addr + 16;
                    beat_count   <= beat_count + 1;
                end
                default: ;
            endcase
        end
    end

    // SRAM signals
    always @(*) begin
        sram_addr  = current_addr[15:0];
        sram_csn   = (state == IDLE);
        sram_wen   = (state == WRITE) ? 1'b0 : 1'b1;
        sram_oen   = (state == READ)  ? 1'b0 : 1'b1;

        // Select write data based on granted port
        case (w_sel)
            2'b00: sram_wdata = write_data[127:0];
            2'b01: sram_wdata = write_data[255:128];
            2'b10: sram_wdata = write_data[383:256];
            2'b11: sram_wdata = write_data[511:384];
            default: sram_wdata = write_data[127:0];
        endcase

        // Select write strb
        case (w_sel)
            2'b00: sram_wmask = {16{write_strb[15:0]}};
            2'b01: sram_wmask = {16{write_strb[31:16]}};
            2'b10: sram_wmask = {16{write_strb[47:32]}};
            2'b11: sram_wmask = {16{write_strb[63:48]}};
            default: sram_wmask = 16'hFFFF;
        endcase
    end

    // =========================================================================
    // Port Ready and Response
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p0_wready <= 1'b0;
            p1_wready <= 1'b0;
            p2_wready <= 1'b0;
            p3_wready <= 1'b0;
            p0_rready <= 1'b0;
            p1_rready <= 1'b0;
            p2_rready <= 1'b0;
            p3_rready <= 1'b0;
            p0_rdata  <= 1024'h0;
            p1_rdata  <= 1024'h0;
            p2_rdata  <= 1024'h0;
            p3_rdata  <= 1024'h0;
            p0_rlast  <= 1'b0;
            p1_rlast  <= 1'b0;
            p2_rlast  <= 1'b0;
            p3_rlast  <= 1'b0;
            p0_rresp  <= 2'b00;
            p1_rresp  <= 2'b00;
            p2_rresp  <= 2'b00;
            p3_rresp  <= 2'b00;
        end else begin
            // Default: deassert ready
            p0_wready <= 1'b0;
            p1_wready <= 1'b0;
            p2_wready <= 1'b0;
            p3_wready <= 1'b0;
            p0_rready <= 1'b0;
            p1_rready <= 1'b0;
            p2_rready <= 1'b0;
            p3_rready <= 1'b0;

            case (state)
                WRITE: begin
                    case (w_sel)
                        2'b00: p0_wready <= 1'b1;
                        2'b01: p1_wready <= 1'b1;
                        2'b10: p2_wready <= 1'b1;
                        2'b11: p3_wready <= 1'b1;
                    endcase
                end
                READ: begin
                    case (r_sel)
                        2'b00: begin
                            p0_rready <= 1'b1;
                            p0_rdata  <= {{896{1'b0}}, sram_rdata};
                            p0_rlast  <= 1'b1;
                            p0_rresp  <= 2'b00;
                        end
                        2'b01: begin
                            p1_rready <= 1'b1;
                            p1_rdata  <= {{896{1'b0}}, sram_rdata};
                            p1_rlast  <= 1'b1;
                            p1_rresp  <= 2'b00;
                        end
                        2'b10: begin
                            p2_rready <= 1'b1;
                            p2_rdata  <= {{896{1'b0}}, sram_rdata};
                            p2_rlast  <= 1'b1;
                            p2_rresp  <= 2'b00;
                        end
                        2'b11: begin
                            p3_rready <= 1'b1;
                            p3_rdata  <= {{896{1'b0}}, sram_rdata};
                            p3_rlast  <= 1'b1;
                            p3_rresp  <= 2'b00;
                        end
                    endcase
                end
                default: ;
            endcase
        end
    end

    // =========================================================================
    // ECC Error Outputs (placeholder)
    // =========================================================================
    assign ecc_error_single = 1'b0;
    assign ecc_error_double = 1'b0;
    assign ecc_error_addr   = 16'h0;

endmodule
