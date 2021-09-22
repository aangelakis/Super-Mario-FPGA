/*******************************************************************************
 * CS220: Digital Circuit Lab
 * Computer Science Department
 * University of Crete
 * 
 * Date: 2019/XX/XX
 * Author: Your name here
 * Filename: maze_controller.sv
 * Description: Your description here
 *
 ******************************************************************************/

/*
    I tried to do the whole exercise but unfortunately I was not able to do it.
    The o_player_bcol and the o_player_brow for some reason, they take values that are not valid and I couldn't find the reason.
*/
`timescale 1ns/1ps

module maze_controller(
  input clk,
  input rst,

  input  i_control,
  input  i_up,
  input  i_down,
  input  i_left,
  input  i_right,

  output logic        o_rom_en,
  output logic [10:0] o_rom_addr,
  input  logic [15:0] i_rom_data,

  output logic [5:0] o_player_bcol,
  output logic [5:0] o_player_brow,

  input  logic [5:0] i_exit_bcol,
  input  logic [5:0] i_exit_brow,

  output logic [7:0] o_leds
);

logic [1:0] cnt; //cnt for the i_control button
logic [5:0] current_player_bcol, current_player_brow; //indicates the current position of the player
logic [5:0] new_bcol, new_brow;
logic [5:0] tmp_col , tmp_row;
//logic [5:0] tmp_col_old, tmp_row_old;
logic move_valid;
logic start_condition;
logic [3:0] red, green, blue;

//the states of the FSM
typedef enum logic[3:0] {
IDLE_state, PLAY_state, UP_state, DOWN_state, LEFT_state, RIGHT_state, READROM_state, CHECK_state, UPDATE_state, END_state
} FSM_State;
FSM_State CurrentState, NextState;

//the flip flop for the FSM states
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        CurrentState <= IDLE_state;
    end
    else begin
        CurrentState <= NextState;
    end
end 

//flip flop for the new_bcol
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        new_bcol <= 1;
    end
    else begin
        new_bcol <= tmp_col;
    end
end

//flip flop for the new_brow
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        new_brow <= 0;
    end
    else begin
        new_brow <= tmp_row;
    end
end


always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        cnt <= 0;
    end
    else begin 
        if (i_control) begin
            cnt <= cnt + 1;
        end
        else if(i_up || i_down || i_left || i_right) begin
            cnt <= 0;
        end
        else 
            cnt <= cnt;
    end
end


assign start_condition = (cnt == 3);
assign move_valid = ~(red == 0 && green == 0 && blue == 0);
//assign red = i_rom_data[15:12];
//assign green = i_rom_data[11:8];
//assign blue = i_rom_data[7:4];

//the CL for the FSM 
always_comb begin
    NextState = CurrentState;
    o_rom_en = 0;
    o_leds = 0;
    
    tmp_row = new_brow;
    tmp_col = new_bcol;
//    tmp_row = current_player_brow;
//    tmp_col = current_player_bcol;
    //o_player_bcol = current_player_bcol;
    //o_player_brow = current_player_brow;
    case ( CurrentState )
        IDLE_state: begin
            o_leds = 1;
            current_player_bcol = new_bcol;
            current_player_brow = new_brow;
            if( start_condition ) begin
                NextState = PLAY_state;
            end
            else begin
                NextState = IDLE_state;
            end
        end
        PLAY_state: begin
            o_leds = 2;
//            tmp_row_old = tmp_row;
//            tmp_col_old = tmp_col;
            
            if( current_player_bcol == i_exit_bcol && current_player_brow == i_exit_brow ) begin
                NextState = END_state;
            end
            else if( i_up ) begin
                NextState = UP_state;
            end
            else if ( i_down ) begin
                NextState = DOWN_state;
            end
            else if ( i_left ) begin
                NextState = LEFT_state;
            end
            else if ( i_right ) begin
                NextState = RIGHT_state;
            end
            else 
                NextState = PLAY_state;
                
        end
        UP_state: begin
            o_leds = 3;
            tmp_row = current_player_brow - 1;
            tmp_col = current_player_bcol;
            NextState = READROM_state;
        end
        DOWN_state: begin
            o_leds = 4;
            tmp_row = current_player_brow + 1;
            tmp_col = current_player_bcol;    
            NextState = READROM_state;
        end
        LEFT_state: begin
            o_leds = 5;
            tmp_row = current_player_brow;
            tmp_col = current_player_bcol - 1;
            NextState = READROM_state;
        end
        RIGHT_state: begin
            o_leds = 6;
            tmp_row = current_player_brow;
            tmp_col = current_player_bcol + 1;
            NextState = READROM_state;
        end
        READROM_state: begin
            o_leds = 7;
            if(new_brow < 0 || new_bcol < 0 || new_brow > 37 || new_bcol > 37) begin
                tmp_col = current_player_bcol;
                tmp_row = current_player_brow;
                NextState = PLAY_state;
//                o_rom_en = 0;
            end   
            else begin 
                o_rom_en = 1;
                o_rom_addr = new_bcol*32 + new_brow;  
                NextState = CHECK_state;       
            end
        end
        CHECK_state: begin
            o_leds = 8;
            red = i_rom_data[15:12]; 
            green = i_rom_data[11:8];
            blue = i_rom_data[7:4];  
         
            if(move_valid) begin
                NextState = UPDATE_state;
            end
            else begin
               tmp_col = current_player_bcol;
               tmp_row = current_player_brow;
               NextState = PLAY_state;
            end
        end
        UPDATE_state: begin
            o_leds = 9;
            current_player_bcol = new_bcol;
            current_player_brow = new_brow;
            NextState = PLAY_state;
        end
        END_state: begin
            o_leds = 10;
            if( i_control ) begin
                tmp_col = 1;
                tmp_row = 0;
                NextState = IDLE_state;
            end
        end
        default: begin
            NextState = IDLE_state;
        end        
    endcase
end

//assign o_rom_addr = (new_bcol/16)*32 + (new_brow/16);
assign o_player_bcol = current_player_bcol;
assign o_player_brow = current_player_brow;

endmodule