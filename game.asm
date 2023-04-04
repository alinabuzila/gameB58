#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Alina Buzila, 1007268216, buzilaal, alina.buzila@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - no, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################



# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# .eqv  
#.eqv  CURR_POS 0x10008000
.eqv  RED_COLOR 0xff0000
.eqv  BLACK_COLOR 0x000000
    
.data 
    CURR_POS: 0x10008080
    BASE_ADDRESS: 0x10008000
.text

main: 
    jal DRAW_USER
    j CHECK_KEY_INPUT
    #j GRAVITY

CHECK_KEY_INPUT:
    li $t9, 0xffff0000 
    lw $t8, 0($t9)
    bne $t8, 1, main # if no keystroke event, return to main 

    # otherwise react to keys 
    lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before, now $t2 holds value for key pressed
    beq $t2, 97, MOVE_LEFT   # ASCII code of 'a' is 0x61 or 97 in decimal
    beq $t2, 100, MOVE_RIGHT   # ASCII code of 'd' is 100
    beq $t2, 119, MOVE_UP   # ASCII code of 'w' is 

    j main # if another key was pressed (other than the above) go to main

MOVE_LEFT:
    lw $s0 CURR_POS # load curr location in $s0 
    
    # check left boundary, if curr_pos mod 128 is 0 it means we are at left edge of screen, so don't move, go back to main
    li $t0, 128
    div $s0, $t0
    mfhi $t0
    beqz $t0, main 

    addi $s0, $s0, -4 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos

    # update position on screen 
    addi $s0, $s0, -4 # new pos, move 1 unit left, need to decrease again bc when returning from ERASE_USER $s0 changed
    sw $s0, CURR_POS
    jal DRAW_USER
    j main
    
MOVE_RIGHT:
    lw $s0 CURR_POS # load curr location in $s0 

    # check left boundary, if curr_pos mod 128 is 0 it means we are at left edge of screen, so don't move, go back to main
    li $t0, 127
    div $s0, $t0
    mfhi $t1
    beqz $t1, main 

    addi $s0, $s0, 4 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, 4 # new pos, move 1 unit right 
    sw $s0, CURR_POS
    jal DRAW_USER
    j main

MOVE_UP:
    lw $s0 CURR_POS # load curr location in $s0 

    # check left boundary, if curr_pos mod 128 is 0 it means we are at left edge of screen, so don't move, go back to main
    lw $s1 BASE_ADDRESS # load curr location in $s0 
    sub $s1, $s0, $s1 # diff btwn curr and start
    blt $s1, 128, main 

    addi $s0, $s0, -128 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, -128 # new pos, move 1 unit up 
    sw $s0, CURR_POS
    jal DRAW_USER
    j main

DRAW_USER:
    lw $s0, CURR_POS
    li $t1, RED_COLOR

    sw $t1, 0($s0)
    
    li $v0, 32
    li $a0, 28
    syscall
	
    jr $ra

ERASE_USER:
    lw $s0, CURR_POS
    li $t1, BLACK_COLOR

    sw $t1, 0($s0)
    
    jr $ra
	
GRAVITY: 
    lw $s0 CURR_POS # load curr location in $s0 
    
    # check left boundary, if curr_pos mod 128 is 0 it means we are at left edge of screen, so don't move, go back to main
    lw $s1 BASE_ADDRESS # load curr location in $s0 
    sub $s1, $s0, $s1 # diff btwn curr and start
    li $t0, 128
    div $s1, $t0
    mflo $t1
    bgt $t1, 30, CHECK_KEY_INPUT # if we are in the last row, so we reached the ground

    addi $s0, $s0, 128 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, 128 # new pos, move 1 unit down 
    sw $s0, CURR_POS

    jal DRAW_USER
    j CHECK_KEY_INPUT
    #j main
