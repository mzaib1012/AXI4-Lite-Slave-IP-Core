// axi_lite_slave.sv
module axi_lite_slave #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 4
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  logic                    s_axi_awvalid,
    output logic                    s_axi_awready,

    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic                    s_axi_wvalid,
    output logic                    s_axi_wready,

    // Write Response Channel
    output logic [1:0]              s_axi_bresp,
    output logic                    s_axi_bvalid,
    input  logic                    s_axi_bready,

    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input  logic                    s_axi_arvalid,
    output logic                    s_axi_arready,

    // Read Data Channel
    output logic [DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [1:0]              s_axi_rresp,
    output logic                    s_axi_rvalid,
    input  logic                    s_axi_rready
);

    // Internal Memory-Mapped Registers
    logic [DATA_WIDTH-1:0] reg0, reg1, reg2, reg3;

    // Handshake Control Logic States
    assign s_axi_awready = ~s_axi_bvalid; 
    assign s_axi_wready  = ~s_axi_bvalid;
    assign s_axi_bresp   = 2'b00; // OKAY response

    // Handle Write Transaction Execution
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg0 <= 0; reg1 <= 0; reg2 <= 0; reg3 <= 0;
            s_axi_bvalid <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid) begin
                s_axi_bvalid <= 1'b1;
                case (s_axi_awaddr[3:2])
                    2'b00: reg0 <= s_axi_wdata;
                    2'b01: reg1 <= s_axi_wdata;
                    2'b10: reg2 <= s_axi_wdata;
                    2'b11: reg3 <= s_axi_wdata;
                endcase
            end else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // Handle Read Transaction Execution
    assign s_axi_arready = ~s_axi_rvalid;
    assign s_axi_rresp   = 2'b00; // OKAY response

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= 0;
        end else begin
            if (s_axi_arvalid && !s_axi_rvalid) begin
                s_axi_rvalid <= 1'b1;
                case (s_axi_araddr[3:2])
                    2'b00: s_axi_rdata <= reg0;
                    2'b01: s_axi_rdata <= reg1;
                    2'b10: s_axi_rdata <= reg2;
                    2'b11: s_axi_rdata <= reg3;
                endcase
            end else if (s_axi_rready && s_axi_rvalid) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule
