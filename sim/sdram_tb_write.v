`timescale  1ns / 1ns

module sdram_tb_write();

`include "Config-AC.v"

parameter CYCLE = 10;

reg           clk;
reg           rst_n;

wire [ 3 : 0] sdram_cmd;
wire [ 1 : 0] sdram_bank;
wire [12 : 0] sdram_addr;
wire [15 : 0] sdram_dq;

wire [ 3 : 0] init_cmd;
wire [ 1 : 0] init_bank;
wire [12 : 0] init_addr;
wire          init_end;

wire          wr_en;
wire [15 : 0] wr_data;

wire          wr_ack;
wire          wr_end;
wire [ 3 : 0] wr_sdram_cmd;
wire [ 1 : 0] wr_sdram_bank;
wire [12 : 0] wr_sdram_addr;
wire          wr_sdram_en;
wire [15 : 0] wr_sdram_data;

initial begin
    clk   = 1'b1;
    rst_n = 1'b0;
    #(CYCLE * 10)
    rst_n = 1'b1;
end

always #(CYCLE / 2) clk = ~clk;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_en <= 1'b0;
    end
    else if (wr_end == 1'b1) begin
        wr_en <= 1'b0;
    end
    else if (init_end == 1'b1) begin
        wr_en <= 1'b1;
    end
    else begin
        wr_en <= wr_en;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_data <= 16'd0;
    end
    else if (wr_data == 16'd10) begin
        wr_data <= 16'd0;
    end
    else if (wr_ack == 1'b1) begin
        wr_data <= wr_data + 1'b1;
    end
    else begin
        wr_data <= wr_data;
    end
end

assign sdram_cmd  = (init_end == 1'b1) ? wr_sdram_cmd  : init_cmd;
assign sdram_bank = (init_end == 1'b1) ? wr_sdram_bank : init_bank;
assign sdram_addr = (init_end == 1'b1) ? wr_sdram_addr : init_addr;

assign sdram_dq = (wr_sdram_en) ? wr_sdram_data : 16'hz;

sdram_init sdram_init_inst(
    .init_clk  (clk),
    .init_rst_n(rst_n),

    .init_cmd  (init_cmd),
    .init_bank (init_bank),
    .init_addr (init_addr),
    .init_end  (init_end)
);

sdram_write sdram_write_inst(
    .wr_clk       (clk),
    .wr_rst_n     (rst_n),
    .wr_en        (wr_en),
    .wr_addr      (24'h000000),
    .wr_data      (wr_data),
    .wr_bst_len   (10'd10),
    .init_end     (init_end),

    .wr_ack       (wr_ack),
    .wr_end       (wr_end),
    .wr_sdram_cmd (wr_sdram_cmd),
    .wr_sdram_bank(wr_sdram_bank),
    .wr_sdram_addr(wr_sdram_addr),
    .wr_sdram_en  (wr_sdram_en),
    .wr_sdram_data(wr_sdram_data)
);

W989DxDB sdram_inst(
    .clk  (clk),
    .cke  (1'b1),
    .addr (sdram_addr),
    .ba   (sdram_bank),
    .cs_n (sdram_cmd[3]),
    .ras_n(sdram_cmd[2]),
    .cas_n(sdram_cmd[1]),
    .we_n (sdram_cmd[0]),
    .dq   (sdram_dq),
    .dqm  (2'b0)
);

reg [79 : 0] state_curr;

always @(*) begin
    case (sdram_write_inst.state_curr)
        3'b000:  state_curr = "STATE_IDLE";
        3'b001:  state_curr = "STATE_ACT ";
        3'b011:  state_curr = "STATE_TRCD";
        3'b010:  state_curr = "STATE_WR  ";
        3'b100:  state_curr = "STATE_DATA";
        3'b101:  state_curr = "STATE_PRE ";
        3'b111:  state_curr = "STATE_TRP ";
        3'b110:  state_curr = "STATE_END ";
        default: state_curr = "STATE_IDLE";
    endcase
end

endmodule