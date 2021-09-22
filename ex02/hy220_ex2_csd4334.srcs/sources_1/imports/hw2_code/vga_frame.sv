/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2019/10/01
 * Author: CS220 Instructors
 * Filename: vga_frame.sv
 * Description: This block generates vertical bars with height of 16 rows
 *              for VGA output by creating red, green, blue and black 
 *              bars in tandem.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module vga_frame(
  input logic clk,
  input logic rst,

  input logic i_pix_valid,
  input logic [9:0] i_col,
  input logic [9:0] i_row,

  output logic [3:0] o_red,
  output logic [3:0] o_green,
  output logic [3:0] o_blue
);

always_ff @(posedge clk) begin
  if ( rst ) begin
    o_red   <= 4'h0;
    o_green <= 4'h0;
    o_blue  <= 4'h0;
  end
  else begin
    o_red   <= (i_pix_valid & (i_row[6:5] == 2'b00)) ? 4'hf : 4'h0;
    o_green <= (i_pix_valid & (i_row[6:5] == 2'b01)) ? 4'hf : 4'h0;
    o_blue  <= (i_pix_valid & (i_row[6:5] == 2'b10)) ? 4'hf : 4'h0;
  end
end

endmodule
