/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2019/XX/XX
 * Author: Your name here
 * Filename: vga_sync.sv
 * Description: Implements VGA HSYNC and VSYNC timings for 640 x 480 @ 60Hz
 *
 ******************************************************************************/

`timescale 1ns/1ps

module vga_sync(
  input logic clk,
  input logic rst,

  output logic o_pix_valid,
  output logic [9:0] o_col,
  output logic [9:0] o_row,

  output logic o_hsync,
  output logic o_vsync
);

parameter FRAME_HPIXELS           = 640;
parameter FRAME_HFPORCH           = 16;
parameter FRAME_HSPULSE           = 96;
parameter FRAME_HBPORCH           = 48;
parameter FRAME_MAX_HCOUNT        = 800;

parameter FRAME_VLINES            = 480;
parameter FRAME_VFPORCH           = 10;
parameter FRAME_VSPULSE           = 2;
parameter FRAME_VBPORCH           = 29;
parameter FRAME_MAX_VCOUNT        = 521;

logic hcnt_clr;
logic [9:0] hcnt;
logic hs_set;
logic hs_clr;
logic hsync, hsync_delayed;
logic vcnt_clear;
logic [9:0] vcnt;
logic vs_set;
logic vs_clr;
logic vsync;

// hcnt_clr
always_comb begin
    if( hcnt == (FRAME_MAX_HCOUNT - 1)) begin
        hcnt_clr = 1;
    end 
    else begin
        hcnt_clr = 0;
    end
end

// hcnt
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        hcnt <= 0;
    end
    else if(hcnt_clr) begin
        hcnt <= 0;
    end
    else begin
        hcnt <= hcnt + 1;
    end
end

// hs_set
always_comb begin
    if(hcnt == FRAME_HPIXELS + FRAME_HFPORCH - 1) begin
        hs_set = 1;
    end
    else begin
        hs_set = 0;
    end
end

// hs_clr
always_comb begin
    if(hcnt == FRAME_HPIXELS + FRAME_HFPORCH + FRAME_HSPULSE - 1) begin
        hs_clr = 1;
    end
    else begin
        hs_clr = 0;
    end
end

// hsync
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        hsync <= 0;
    end
    else begin
        hsync <= (~hs_clr && (hs_set || hsync));
    end
end

// hsync_delayed
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        hsync_delayed <= 0;
    end
    else begin
        hsync_delayed <= hsync;
    end
end

// vcnt_clear
always_comb begin
    if((vcnt == FRAME_MAX_VCOUNT - 1) && hcnt_clr) begin
        vcnt_clear = 1;
    end
    else begin
        vcnt_clear = 0;
    end
end

// vcnt
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        vcnt <= 0;
    end
    else begin
         if(vcnt_clear) begin
            vcnt <= 0;
         end
         else begin
            if(hcnt_clr) begin
                vcnt <= vcnt + 1;
            end
            else begin
                vcnt <= vcnt;
            end
        end
    end
end

// vs_set
always_comb begin
    if((vcnt == FRAME_VLINES + FRAME_VFPORCH - 1) && hcnt_clr) begin
        vs_set = 1;
    end
    else begin
        vs_set = 0;
    end
end

// vs_clr
always_comb begin
    if((vcnt == FRAME_VLINES + FRAME_VFPORCH + FRAME_VSPULSE - 1) && hcnt_clr) begin
        vs_clr = 1;
    end
    else begin
        vs_clr = 0;
    end
end

// vsync
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        vsync <= 0;
    end
    else begin
        vsync <= (~vs_clr && (vs_set || vsync));
    end
end

// o_pix_valid
always_comb begin
    if((hcnt < FRAME_HPIXELS) && (vcnt < FRAME_VLINES)) begin
        o_pix_valid = 1;
    end
    else begin
        o_pix_valid = 0;
    end
end

assign o_col = hcnt;
assign o_row = vcnt;
assign o_hsync = ~hsync_delayed;
assign o_vsync = ~vsync;

endmodule
