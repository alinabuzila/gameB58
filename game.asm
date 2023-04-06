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
.eqv  PLAYER_COLOR 0xadd8e6
.eqv  YELLOW 0xFFFF00
.eqv  PINK 0xFFC0CB
.eqv  PURPLE 0xBF40BF
.eqv  SOME_COLOR 0xad2a11
.eqv  BLACK_COLOR 0x000000
.eqv PLATFORM_COLOR 0xc4a484
    
.data 
    CURR_POS: 0x10009a00
    BASE_ADDRESS: 0x10008000
    PLAT1: 0x1000B73C
    PLAT2: 0x10009D64
    PLAT3: 0x1000ADBC
    START_PLAT: 0x10009B00
.text

START: 
    jal DRAW_PLATFORMS
    j main

main: 
    jal DRAW_USER
    #j CHECK_KEY_INPUT

    # check for platforms, if player not on any platforms, jump to gravity 
    lw $t2 START_PLAT
    lw $s0 CURR_POS
    addi $s0, $s0, 272
    bge $s0, $t2, check_start_platform_edge # if character is >= left edge of platform, check right edge


    j GRAVITY

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
    li $t0, 256
    lw $s1 BASE_ADDRESS # base address
    sub $s1, $s0, $s1 # diff btwn curr and start
    
    div $s1, $t0
    mfhi $t0
    beqz $t0, main 

    addi $s0, $s0, -8 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos

    # update position on screen 
    addi $s0, $s0, -8 # new pos, move 1 unit left, need to decrease again bc when returning from ERASE_USER $s0 changed
    sw $s0, CURR_POS
    jal DRAW_USER
    j main
    
MOVE_RIGHT:
    lw $s0 CURR_POS # load curr location 
    #addi $s0, $s0, 12 #add 12 offset becuase player is 16 pixels, so 4 units wide

    # check right screen boundary 
    li $t0, 240
    lw $s1 BASE_ADDRESS 
    sub $s1, $s0, $s1 # diff btwn curr and start
    sub $s1, $s0, $t0 
    
    li $t0, 256
    div $s1, $t0
    mfhi $t1
    beqz $t1, main 

    # check for platforms


    addi $s0, $s0, 8 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, 8 # new pos, move 1 unit right 
    sw $s0, CURR_POS
    jal DRAW_USER
    j main

MOVE_UP:
    lw $s0 CURR_POS # load curr location in $s0 

    # check top screen boundary
    lw $s1 BASE_ADDRESS 
    sub $s2, $s0, $s1 
    blt $s2, 128, main 

    # check for platforms above 


    addi $s0, $s0, 1024 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, -1024 # new pos, move 1 unit up 
    sw $s0, CURR_POS
    jal DRAW_USER
    j main

DRAW_USER:
    lw $s0, CURR_POS
    li $t1, PLAYER_COLOR
    #addi $s0, $s0, 240

    sw $t1, 0($s0)
    sw $t1, 4($s0)
    sw $t1, 8($s0)
    sw $t1, 12($s0)
    sw $t1, -256($s0)

    sw $t1, -248($s0)
    sw $t1, -512($s0)
    sw $t1, -508($s0)
    sw $t1, -504($s0)
    
    li $v0, 32
    li $a0, 28
    syscall
	
    jr $ra

ERASE_USER:
    lw $s0, CURR_POS
    li $t1, BLACK_COLOR

    sw $t1, 0($s0)
    sw $t1, 4($s0)
    sw $t1, 8($s0)
    sw $t1, 12($s0)
    sw $t1, -256($s0)

    sw $t1, -248($s0)
    sw $t1, -512($s0)
    sw $t1, -508($s0)
    sw $t1, -504($s0)
    
    
    jr $ra
	
GRAVITY: 
    lw $s0 CURR_POS # load curr location in $s0 
    
    # check left boundary, if curr_pos mod 128 is 0 it means we are at left edge of screen, so don't move, go back to main
    lw $s1 BASE_ADDRESS # load curr location in $s0 
    sub $s1, $s0, $s1 # diff btwn curr and start
    li $t0, 128
    div $s1, $t0
    mflo $t1
    bgt $t1, 124, CHECK_KEY_INPUT # if we are in the last row, so we reached the ground
    #bgt $t1, 30, main # if we are in the last row, so we reached the ground
    

    addi $s0, $s0, 512 # new pos, move 2 unit down 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, 256 # new pos, move 1 unit down 
    sw $s0, CURR_POS

    jal DRAW_USER
    j CHECK_KEY_INPUT
    #j main

check_start_platform_edge:
    lw $s0 CURR_POS
    addi $s0, $s0, 256 # we want player to be on same row as platform to be able to compare locations

    lw $t2 START_PLAT

    addi $t2, $t2, 28 # add width of platform

    ble $s0, $t2, CHECK_KEY_INPUT # player on platform start, keep them in same place 

    # player not on platform start, check platform 1
    lw $t2 PLAT1
    addi $s0, $s0, 16 # add width of player
    bgt $s0, $t2, check_platform1_edge
    j GRAVITY

check_platform1_edge:
    lw $s0 CURR_POS 
    addi $s0, $s0, 256 # we want player to be on same row as platform to be able to compare locations 


    lw $t2 PLAT1
    addi $t2, $t2, 28 # add width of platform
    ble $s0, $t2, CHECK_KEY_INPUT # player on platform start, keep them in same place  

    # player not on platform 1, check platform 2
    lw $t2 PLAT2
    addi $s0, $s0, 16 # add width of player
    bgt $s0, $t2, check_platform2_edge
    j GRAVITY

check_platform2_edge:
    lw $s0 CURR_POS 
    addi $s0, $s0, 256 # we want player to be on same row as platform to be able to compare locations 


    lw $t2 PLAT2
    addi $t2, $t2, 40 # add width of platform
    ble $s0, $t2, CHECK_KEY_INPUT # player on platform start, keep them in same place  

    # player not on platform 1, check platform 2
    lw $t2 PLAT3
    addi $s0, $s0, 16 # add width of player
    bgt $s0, $t2, check_platform3_edge
    j GRAVITY


check_platform3_edge:
    lw $s0 CURR_POS 
    addi $s0, $s0, 256 # we want player to be on same row as platform to be able to compare locations 

    lw $t2 PLAT2
    addi $t2, $t2, 40 # add width of platform
    ble $s0, $t2, CHECK_KEY_INPUT # player on platform start, keep them in same place  

    # player not on platform 1, gravity can move them downwards 
    j GRAVITY


DRAW_PLATFORMS:
    lw $s0, BASE_ADDRESS

    lw $s1, PLAT1
    li $t1, PLATFORM_COLOR

    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, 8($s1)
    sw $t1, 12($s1)
    sw $t1, 16($s1)
    sw $t1, 20($s1)
    sw $t1, 24($s1)

    sw $t1, 260($s1)
    sw $t1, 264($s1)
    sw $t1, 268($s1)
    sw $t1, 272($s1)
    sw $t1, 276($s1)

    lw $s1, PLAT2
    li $t1, YELLOW

    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, 8($s1)
    sw $t1, 12($s1)
    sw $t1, 16($s1)
    sw $t1, 20($s1)
    sw $t1, 24($s1)
    sw $t1, 28($s1)
    sw $t1, 32($s1)
    sw $t1, 36($s1)

    sw $t1, 260($s1)
    sw $t1, 264($s1)
    sw $t1, 268($s1)
    sw $t1, 272($s1)
    sw $t1, 276($s1)
    sw $t1, 280($s1)
    sw $t1, 284($s1)
    sw $t1, 288($s1)
    

    lw $s1, PLAT3
    li $t1, PINK

    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, 8($s1)
    sw $t1, 12($s1)
    sw $t1, 16($s1)
    sw $t1, 20($s1)
    sw $t1, 24($s1)
    sw $t1, 28($s1)
    sw $t1, 32($s1)
    sw $t1, 36($s1)
    sw $t1, 40($s1)
    sw $t1, 44($s1)
    sw $t1, 48($s1)

    sw $t1, 260($s1)
    sw $t1, 264($s1)
    sw $t1, 268($s1)
    sw $t1, 272($s1)
    sw $t1, 276($s1)
    sw $t1, 280($s1)
    sw $t1, 284($s1)
    sw $t1, 288($s1)
    sw $t1, 292($s1)
    sw $t1, 296($s1)
    sw $t1, 300($s1)

    lw $s1, START_PLAT
    li $t1, PURPLE
    
    # starting platform
    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, 8($s1)
    sw $t1, 12($s1)
    sw $t1, 16($s1)
    sw $t1, 20($s1)
    sw $t1, 24($s1)
    
    sw $t1, 256($s1)
    sw $t1, 260($s1)
    sw $t1, 264($s1)
    sw $t1, 268($s1)
    sw $t1, 272($s1)
    sw $t1, 276($s1)

    jr $ra

