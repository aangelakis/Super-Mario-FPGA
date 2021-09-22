/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2019/10/01
 * Author: CS220 Instructors
 * Filename: vga_tb.sv
 * Description: A testbench that generates clock and reset and 
 *              captures VGA output in VGA Simulator format
 *
 ******************************************************************************/

`timescale 1ns/1ps

// Only for Icarus Verilog
//`define VCD_WAVES

// 40 ns -> 25 MHz
`define VGA_CLK_PERIOD  40
`define SIM_CYCLES  1000000


module vga_tb;

integer fileout;

logic clk;
logic rst;

always #(`VGA_CLK_PERIOD/2) clk = ~clk;

logic hsync;
logic vsync;
logic [3:0] red;
logic [3:0] green;
logic [3:0] blue;

vga_maze_top vga0 (
  .clk (clk),
  .rst (rst),
  .o_hsync(hsync),
  .o_vsync(vsync),
  .o_red(red),
  .o_green(green),
  .o_blue(blue)
);


// clk and reset
initial begin
  fileout = $fopen("vga_log.txt");

  $timeformat(-9, 0, " ns", 6);

`ifdef VCD_WAVES
  $dumpfile("vga_tb_waves.vcd");
  $dumpvars;
`endif


  clk = 0;
  rst = 1;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
  #1;
  rst = 0;
  @(posedge clk);


  repeat (`SIM_CYCLES) @(posedge clk);
  #1;

  $fclose(fileout);
  $finish;
end

always @(posedge clk) begin
  if ( ~rst ) begin
    $fdisplay(fileout, "%t: %b %b %b %b %b", $time, hsync, vsync, red, green, blue);
  end
end

endmodule
