// tb_axi_lite.sv
module tb_axi_lite;
    logic clk = 0; logic rst_n = 0;
    
    logic [3:0]  awaddr=0;  logic awvalid=0; logic awready;
    logic [32:1] wdata=0;   logic wvalid=0;  logic wready;
    logic [1:0]  bresp;     logic bvalid;    logic bready=0;
    logic [3:0]  araddr=0;  logic arvalid=0; logic arready;
    logic [31:0] rdata;     logic [1:0] rresp; logic rvalid; logic rready=0;

    axi_lite_slave dut (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wvalid(wvalid), .s_axi_wready(wready),
        .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, tb_axi_lite);
        #10 rst_n = 1; #10;

        // --- Execute Write Transaction to Register 1 ---
        @(posedge clk);
        awaddr = 4'h4; awvalid = 1; // Addr 4 maps to reg1
        wdata  = 32'hDEADBEEF; wvalid = 1;
        bready = 1;
        
        wait(awready && wready);
        @(posedge clk);
        awvalid = 0; wvalid = 0;
        wait(bvalid);
        @(posedge clk);
        bready = 0;

        #20;

        // --- Execute Read Transaction from Register 1 ---
        @(posedge clk);
        araddr = 4'h4; arvalid = 1;
        rready = 1;
        
        wait(arready);
        @(posedge clk);
        arvalid = 0;
        wait(rvalid);
        @(posedge clk);
        rready = 0;

        #40; $finish;
    end
endmodule
