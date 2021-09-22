/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2019/10/01
 * Author: CS220 Instructors
 * Filename: vga_maze_top.sv
 * Description: The top module that instantiates vga_sync and vga_frame 
 *
 ******************************************************************************/

`timescale 1ns/1ps

module vga_maze_top(
  input logic clk,
  input logic rst,

  output logic o_hsync,
  output logic o_vsync,
  output logic [3:0] o_red,
  output logic [3:0] o_green,
  output logic [3:0] o_blue
);


logic pixel_valid;
logic [9:0] col;
logic [9:0] row;
logic clk_25;

clk_wiz_0 clk_wiz_25_inst (
  .clk_out1     (clk_25),
  .reset        (rst),
  .locked       (),
  .clk_in1      (clk)
 );


vga_sync vs (
  .clk(clk_25),
  .rst(rst),
  .o_pix_valid(pixel_valid),
  .o_col(col),
  .o_row(row),
  .o_hsync(o_hsync),
  .o_vsync(o_vsync)
);

vga_frame vf (
  .clk(clk_25),
  .rst(rst),
  .i_pix_valid(pixel_valid),
  .i_col(col),
  .i_row(row),
  .o_red(o_red),
  .o_green(o_green),
  .o_blue(o_blue)
);

endmodule
