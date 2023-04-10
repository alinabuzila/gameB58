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
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
#
# 1. Health/score [2 marks]: a player's score is determined by the number of stars they collect. The score is out of 3 since
#       there are 3 stars. The score is always displayed in the top right corner as three grey squares which turn green as you collect
#       stars. Collecting all 3 stars means you win. The score is displayed while you play and on the win and game over screens. 
#      
# 2. Fail condition [1 mark]: the fail condition for my game is touching the spikes which are along all 4 sides of the screen (bottom included). When you touch
#         the spikes you lose and will see a game over screen. Note that from the game over screen you can press 'p' to restart.
# 
# 3. Win condition [1 mark]: The player wins if they collect all three stars, ie get a 3/3 score. They will then see a "Winner" screen where they can press 
#       'p' to restart. 
# 
# 4. Moving objects [2 mark]: The three star pickups are moving around the level (specifically moving back and forth or up and down). They disappear when 
#       the player collects (collides) them. 
# 
# 5. Start menu [1 mark]: when initially running the game, there is a start menu that displays the user's options which are 'p' to play and 'q' to quit. 
#       It also has nice platforms graphics drawn. Note these are not the same platforms as in the level (notice different colours and positions), which shows 
#       that i am clearing the screen. 
# 
# Note: my platforms only have collision detection on top. This is intended. In certain games like mario, you can reach certain platforms by jumping 
#   through them from undernearth. 
#
# Link to video demonstration for final submission:
# - https://play.library.utoronto.ca/watch/20d3bbc8d90f453e127ea4ebde931a19
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# Note: my platforms only have collision detection on top. This is intended. In certain games like mario, you can reach certain platforms by jumping 
#   through them from undernearth. 
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
.eqv  WHITE 0xFFFFFF
.eqv  GREEN 0x228B22
.eqv GREY 0xB2BEB5

.eqv  SOME_COLOR 0xad2a11
.eqv  BLACK_COLOR 0x000000
.eqv PLATFORM_COLOR 0xc4a484
    
.data 
    CURR_POS: 0x10009a08
    BASE_ADDRESS: 0x10008000
    PLAT3 : 0x1000B73C
    PLAT1 : 0x10009D64
    PLAT2 : 0x1000ADBC

    START_PLAT: 0x10009B00
    STAR1 : 0x10009B74
    STAR2 : 0x1000A8CC
    STAR3 : 0x1000B540
    STAR1_OFFSET : .word 0
    STAR2_OFFSET : .word 0
    STAR3_OFFSET : .word 0

    STAR1_COLLECTED : .word 0
    STAR2_COLLECTED : .word 0
    STAR3_COLLECTED : .word 0
.text

MENU:
    jal CLEAR_SCREEN
    j MENU_SCREEN # if i have issues change this to j, and inside MENU remove platforms and use jr $ra instead of 

START: 
    # j WIN_SCREEN
    jal ERASE_USER
    jal DRAW_SPIKES
    lw $s1, BASE_ADDRESS
	addi $s1, $s1, 6664
	sw $s1, CURR_POS

    li $t2, 0
    sw $t2, STAR3_OFFSET
    sw $t2, STAR2_OFFSET
    sw $t2, STAR1_OFFSET

    sw $t2, STAR1_COLLECTED
    sw $t2, STAR2_COLLECTED
    sw $t2, STAR3_COLLECTED

    lw $s1, BASE_ADDRESS
    addi $s2, $s1, 7028
	sw $s2, STAR1

    addi $s2, $s1, 10444
	sw $s2, STAR2

    addi $s2, $s1, 13632
	sw $s2, STAR3

    # jal DRAW_STARS
    j main


main: 
    jal DRAW_PLATFORMS
    jal DRAW_SCORE

    # check if they won 
    li $s5, 1
    lw $s4 STAR1_COLLECTED
    beq $s4, $s5, STAR1_WON
    j STAR1_ELSE
    STAR1_WON:
        lw $s4 STAR2_COLLECTED
        beq $s4, $s5, STAR2_WON
        j STAR2_ELSE
        STAR2_WON:
            lw $s4 STAR3_COLLECTED
            beq $s4, $s5, STAR3_WON
            j STAR3_ELSE
            STAR3_WON:
                jal ERASE_USER
                j WIN_SCREEN
            STAR3_ELSE:
                li $s5, 1 # doing nothing 
        STAR2_ELSE:
            li $s5, 1 # doing nothing 
    STAR1_ELSE:
        li $s5, 1 # doing nothing 

    # lw $s1 STAR3_COLLECTED
    # add $t0, $ra, 0 # store current location 
    # blez $s1, DRAW_STARS
    jal DRAW_STAR_3

    li $v0, 32
    li $a0, 28
    syscall

    jal ERASE_STARS


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
    beq $t2, 112, START # ASCII code of 'p' is 112, restart game 

    j main # if another key was pressed (other than the above) go to main

MOVE_LEFT:
    lw $s0 CURR_POS # load curr location in $s0 
    
    # check left boundary, if curr_pos mod 128 is 0 it means we are at left edge of screen, so don't move, go back to main
    li $t0, 256
    lw $s1 BASE_ADDRESS # base address

    # addi $s0, $s0, -8 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos

    # update position on screen 
    addi $s0, $s0, -8 # new pos, move 1 unit left, need to decrease again bc when returning from ERASE_USER $s0 changed
    sw $s0, CURR_POS
    jal DRAW_USER

    sub $s1, $s0, $s1 # diff btwn curr and start
    div $s1, $t0
    mfhi $t0
    beq $t0, $zero, LOSE_SCREEN 

    j main
    
MOVE_RIGHT:
    lw $s0 CURR_POS # load curr location 
    #addi $s0, $s0, 12 #add 12 offset becuase player is 16 pixels, so 4 units wide

    # check right screen boundary 
    li $t0, 240
    lw $s1 BASE_ADDRESS 

    # addi $s0, $s0, 8 # new pos, move 1 unit left 

    jal ERASE_USER # erase character from old pos
    
    # update position on screen 
    addi $s0, $s0, 8 # new pos, move 1 unit right 
    sw $s0, CURR_POS
    jal DRAW_USER

    sub $s1, $s0, $s1 # diff btwn curr and start
    sub $s1, $s0, $t0 
    li $t0, 256
    div $s1, $t0
    mfhi $t1
    beq $t1, $zero, LOSE_SCREEN 

    j main

MOVE_UP:
    lw $s0 CURR_POS # load curr location in $s0 

    # check top screen boundary
    lw $s1 BASE_ADDRESS 
    sub $s2, $s0, $s1 
    blt $s2, 128, LOSE_SCREEN 

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
    bgt $t1, 124, LOSE_SCREEN # if we are in the last row, so we reached the ground

    # bgt $t1, 30, LOSE_SCREEN # if we are in the last row, so we reached the ground
    

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
    addi $t2, $t2, 40 # add width of platform
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
    addi $t2, $t2, 52 # add width of platform
    ble $s0, $t2, CHECK_KEY_INPUT # player on platform start, keep them in same place  

    # player not on platform 1, check platform 2
    lw $t2 PLAT3 
    addi $s0, $s0, 16 # add width of player
    bgt $s0, $t2, check_platform3_edge
    j GRAVITY


check_platform3_edge:
    lw $s0 CURR_POS 
    addi $s0, $s0, 256 # we want player to be on same row as platform to be able to compare locations 

    lw $t2 PLAT3
    addi $t2, $t2, 28 # add width of platform
    ble $s0, $t2, CHECK_KEY_INPUT # player on platform start, keep them in same place  

    # player not on platform 1, gravity can move them downwards 
    j GRAVITY

DRAW_STAR_3: # draw star and check collision 
    lw $s2, STAR3_OFFSET
    lw $s0 CURR_POS  

    li $s3, 4
    mult $s2, $s3
    mflo $s3 # horizontal offset for moving stars 
    
    # Draw star 3
    lw $s1, STAR3 
    add $s1, $s1, $s3 # s1 is location of lower left corner of star 
    li $t1, YELLOW

    lw $s4 STAR3_COLLECTED
    add $a1, $ra, 0 # jump return address 

    bgtz $s4, DRAW_STAR_2 # if STAR3_COLLECTED == 1, we don't want to display star

    # we just collected star, need to mark as collected in STAR3_COLLECTED, check next star
    beq $s1, $s0, REMOVE_STAR3
    addi $s0, $s0, 4
    beq $s1, $s0, REMOVE_STAR3 
    addi $s0, $s0, -256 # accumulative -256 + 4
    beq $s1, $s0, REMOVE_STAR3 
    addi $s0, $s0, -4
    beq $s1, $s0, REMOVE_STAR3 


    # otherwise display star
    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, -252($s1)

    j DRAW_STAR_2

ERASE_STARS: 
    lw $s2, STAR3_OFFSET

    li $s3, 4
    mult $s2, $s3
    mflo $s3 # horizontal offset for moving stars 
    
    # ERASE STAR 3 ###########
    lw $s1, STAR3 
    add $s1, $s1, $s3 # s1 is location of lower left corner of star 
    li $t1, BLACK_COLOR

    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, -252($s1)

    addi $s2, $s2, 1 # update offset 
    li $t1, 4

    beq $s2, $t1, RESET_STAR3_OFFSET_AND_DRAW
    j ELSE1
    RESET_STAR3_OFFSET_AND_DRAW:
        li $s2, 0
    ELSE1:
        sw $s2, STAR3_OFFSET
        
    # ERASE STAR 2 ###########
    lw $s2, STAR2_OFFSET

    li $s3, -256
    mult $s2, $s3
    mflo $s3 # horizontal offset for moving stars 
    
    lw $s1, STAR2 
    add $s1, $s1, $s3 # s1 is location of lower left corner of star 

    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, -252($s1)

    addi $s2, $s2, 1 # update offset
    li $t1, 4

    beq $s2, $t1, RESET_STAR2_OFFSET_AND_DRAW
    j ELSE2
    RESET_STAR2_OFFSET_AND_DRAW:
        li $s2, 0
    ELSE2:
        sw $s2, STAR2_OFFSET

    
    # ERASE STAR 1 ###########
    lw $s2, STAR1_OFFSET

    li $s3, 4
    mult $s2, $s3
    mflo $s3 # horizontal offset for moving stars 
    
    lw $s1, STAR1 
    add $s1, $s1, $s3 # s1 is location of lower left corner of star 


    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, -252($s1)

    addi $s2, $s2, 1 # update offset
    li $t1, 4

    beq $s2, $t1, RESET_STAR1_OFFSET_AND_DRAW
    j ELSE3

    RESET_STAR1_OFFSET_AND_DRAW: 
        li $s2, 0
    ELSE3:
        sw $s2, STAR1_OFFSET

    jr $ra
    

DRAW_STAR_2:
    lw $s2, STAR2_OFFSET
    lw $s0 CURR_POS  

    li $s3, -256
    mult $s2, $s3
    mflo $s3 # horizontal offset for moving stars 
    
    # Draw star 2
    lw $s1, STAR2
    add $s1, $s1, $s3 # s1 is location of lower left corner of star 
    li $t1, YELLOW

    lw $s4 STAR2_COLLECTED

    bgtz $s4, DRAW_STAR_1 # if STAR3_COLLECTED == 1, we don't want to display star

    # we just collected star, need to mark as collected in STAR3_COLLECTED, check next star
    beq $s1, $s0, REMOVE_STAR2
    addi $s0, $s0, 4
    beq $s1, $s0, REMOVE_STAR2
    addi $s0, $s0, -256 # accumulative -256 + 4
    beq $s1, $s0, REMOVE_STAR2
    addi $s0, $s0, -4
    beq $s1, $s0, REMOVE_STAR2


    # otherwise display star
    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, -252($s1)



    
    j DRAW_STAR_1
        # jr $a1
    

DRAW_STAR_1:
    lw $s2, STAR1_OFFSET
    lw $s0 CURR_POS  

    li $s3, 4
    mult $s2, $s3
    mflo $s3 # horizontal offset for moving stars 
    
    # Draw star 2
    lw $s1, STAR1
    add $s1, $s1, $s3 # s1 is location of lower left corner of star 
    li $t1, YELLOW

    lw $s4 STAR1_COLLECTED

    bgtz $s4, REMOVE_STAR1 # if STAR3_COLLECTED == 1, we don't want to display star

    # we just collected star, need to mark as collected in STAR3_COLLECTED, check next star
    beq $s1, $s0, REMOVE_STAR1
    addi $s0, $s0, 4
    beq $s1, $s0, REMOVE_STAR1
    addi $s0, $s0, -256 # accumulative -256 + 4
    beq $s1, $s0, REMOVE_STAR1
    addi $s0, $s0, -4
    beq $s1, $s0, REMOVE_STAR1


    # otherwise display star
    sw $t1, 0($s1)
    sw $t1, 4($s1)
    sw $t1, -252($s1)

    
    jr $a1

REMOVE_STAR3:
    # set the collected to 1
    # go to DRAW_STAR_2
    li $s4 1
    sw $s4, STAR3_COLLECTED
    j DRAW_STAR_2

REMOVE_STAR2:
    # set the collected to 1
    # go to DRAW_STAR_2
    li $s4 1
    sw $s4, STAR2_COLLECTED
    jr $a1

REMOVE_STAR1:
    # set the collected to 1
    # go to DRAW_STAR_2
    li $s4 1
    sw $s4, STAR1_COLLECTED
    jr $a1
   

DRAW_SCORE:

    lw $s0, BASE_ADDRESS
    addi $s0, $s0, 980
    li $t1, GREY
    li $t2, GREY
    li $t3, GREY

    li $s5, 1
    lw $s4 STAR1_COLLECTED
    beq $s4, $s5, STAR1_SCORE_GREEN
    j STAR1_SCORE_ELSE

    STAR1_SCORE_GREEN:
        li $t1, GREEN

    STAR1_SCORE_ELSE:
        lw $s4 STAR2_COLLECTED
        beq $s4, $s5, STAR2_SCORE_GREEN
        j STAR2_SCORE_ELSE
        STAR2_SCORE_GREEN:
            li $t2, GREEN
        STAR2_SCORE_ELSE:
            lw $s4 STAR3_COLLECTED
            beq $s4, $s5, STAR3_SCORE_GREEN
            j STAR3_SCORE_ELSE
            STAR3_SCORE_GREEN:
                li $t3, GREEN
            STAR3_SCORE_ELSE:
                li $a3, 0 # doing nothing 

    sw $t1, 0($s0)
    sw $t1, 4($s0)
    sw $t1, 256($s0)
    sw $t1, 260($s0)

    addi $s0, $s0, 12
    sw $t2, 0($s0)
    sw $t2, 4($s0)
    sw $t2, 256($s0)
    sw $t2, 260($s0)

    addi $s0, $s0, 12
    sw $t3, 0($s0)
    sw $t3, 4($s0)
    sw $t3, 256($s0)
    sw $t3, 260($s0)

    jr $ra 



DRAW_PLATFORMS:
    # lw $s0, BASE_ADDRESS

    lw $s1, PLAT3 
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

    lw $s1, PLAT1 
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
    

    lw $s1, PLAT2 
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


DRAW_SPIKES:
    lw $s0, BASE_ADDRESS

    li $t1, PLATFORM_COLOR

    sw $t1, 0($s0)
    sw $t1, 512($s0)
    sw $t1, 1024($s0)
    sw $t1, 1536($s0)
    sw $t1, 2048($s0)
    sw $t1, 2560($s0)
    sw $t1, 3072($s0)
    sw $t1, 3584($s0)
    sw $t1, 4096($s0)
    sw $t1, 4608($s0)
    sw $t1, 5120($s0)
    sw $t1, 5632($s0)
    sw $t1, 6144($s0)
    sw $t1, 6656($s0)
    sw $t1, 7168($s0)
    sw $t1, 7680($s0)
    sw $t1, 8192($s0)
    sw $t1, 8704($s0)
    sw $t1, 9216($s0)
    sw $t1, 9728($s0)
    sw $t1, 10240($s0)
    sw $t1, 10752($s0)
    sw $t1, 11264($s0)
    sw $t1, 11776($s0)
    sw $t1, 12288($s0)
    sw $t1, 12800($s0)
    sw $t1, 13312($s0)
    sw $t1, 13824($s0)
    sw $t1, 14336($s0)
    sw $t1, 14848($s0)
    sw $t1, 15360($s0)
    sw $t1, 15872($s0)
    
    sw $t1, 0($s0)
    sw $t1, 8($s0)
    sw $t1, 16($s0)
    sw $t1, 24($s0)
    sw $t1, 32($s0)
    sw $t1, 40($s0)
    sw $t1, 48($s0)
    sw $t1, 56($s0)
    sw $t1, 64($s0)
    sw $t1, 72($s0)
    sw $t1, 80($s0)
    sw $t1, 88($s0)
    sw $t1, 96($s0)
    sw $t1, 104($s0)
    sw $t1, 112($s0)
    sw $t1, 120($s0)
    sw $t1, 128($s0)
    sw $t1, 136($s0)
    sw $t1, 144($s0)
    sw $t1, 152($s0)
    sw $t1, 160($s0)
    sw $t1, 168($s0)
    sw $t1, 176($s0)
    sw $t1, 184($s0)
    sw $t1, 192($s0)
    sw $t1, 200($s0)
    sw $t1, 208($s0)
    sw $t1, 216($s0)
    sw $t1, 224($s0)
    sw $t1, 232($s0)
    sw $t1, 240($s0)
    sw $t1, 248($s0)
    
    sw $t1, 252($s0)
    sw $t1, 764($s0)
    sw $t1, 1276($s0)
    sw $t1, 1788($s0)
    sw $t1, 2300($s0)
    sw $t1, 2812($s0)
    sw $t1, 3324($s0)
    sw $t1, 3836($s0)
    sw $t1, 4348($s0)
    sw $t1, 4860($s0)
    sw $t1, 5372($s0)
    sw $t1, 5884($s0)
    sw $t1, 6396($s0)
    sw $t1, 6908($s0)
    sw $t1, 7420($s0)
    sw $t1, 7932($s0)
    sw $t1, 8444($s0)
    sw $t1, 8956($s0)
    sw $t1, 9468($s0)
    sw $t1, 9980($s0)
    sw $t1, 10492($s0)
    sw $t1, 11004($s0)
    sw $t1, 11516($s0)
    sw $t1, 12028($s0)
    sw $t1, 12540($s0)
    sw $t1, 13052($s0)
    sw $t1, 13564($s0)
    sw $t1, 14076($s0)
    sw $t1, 14588($s0)

    sw $t1, 15100($s0)
    sw $t1, 15612($s0)
    sw $t1, 16124($s0)
    
  

    sw $t1, 16128($s0)
    sw $t1, 16136($s0)
    sw $t1, 16144($s0)
    sw $t1, 16152($s0)

    sw $t1, 16160($s0)
    sw $t1, 16168($s0)
    sw $t1, 16176($s0)
    sw $t1, 16184($s0)

    sw $t1, 16192($s0)
    sw $t1, 16200($s0)
    sw $t1, 16208($s0)
    sw $t1, 16216($s0)

    sw $t1, 16224($s0)
    sw $t1, 16232($s0)
    sw $t1, 16240($s0)
    sw $t1, 16248($s0)

    sw $t1, 16256($s0)
    sw $t1, 16264($s0)
    sw $t1, 16272($s0)
    sw $t1, 16280($s0)

    sw $t1, 16288($s0)
    sw $t1, 16296($s0)
    sw $t1, 16304($s0)
    sw $t1, 16312($s0)

    sw $t1, 16320($s0)
    sw $t1, 16328($s0)
    sw $t1, 16336($s0)
    sw $t1, 16344($s0)

    sw $t1, 16352($s0)
    sw $t1, 16360($s0)
    sw $t1, 16368($s0)
    sw $t1, 16376($s0)
    sw $t1, 163684($s0)
    jr $ra


LOSE_SCREEN:
    jal DRAW_SPIKES
    li $a1, WHITE # colour for game over text
    jal DRAW_LOSE_SCREEN
    
    li $t9, 0xffff0000 
    lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before, now $t2 holds value for key pressed

    beq $t2, 112, RESTART_LOGIC # ASCII code of 'p' is 112, restart game 
    j LOSE_SCREEN
    RESTART_LOGIC:
        li $a1, BLACK_COLOR # colour for game over text
        jal DRAW_LOSE_SCREEN
        j START

DRAW_LOSE_SCREEN:
    lw $s1, BASE_ADDRESS
	add $t2, $a1, $zero # pass in the coluur here

    addi $s1, $s1, 1584
        
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 4($s1)
    sw $t2, 8($s1)

    sw $t2, 1280($s1)
    sw $t2, 1284($s1)
    sw $t2, 1288($s1)
    # sw $t2, 1292($s1)
    sw $t2, 780($s1)
    sw $t2, 1036($s1)

    # letter A
    sw $t2, 1300($s1)
    sw $t2, 1044($s1)
    sw $t2, 788($s1)
    sw $t2, 792($s1)
    sw $t2, 796($s1)
    sw $t2, 532($s1)
    sw $t2, 276($s1)
    sw $t2, 20($s1)
    sw $t2, 24($s1)
    sw $t2, 28($s1)
    sw $t2, 32($s1)
    sw $t2, 288($s1)
    sw $t2, 544($s1)
    sw $t2, 800($s1)
    sw $t2, 1056($s1)
    sw $t2, 1312($s1)


    # letter m 
    sw $t2, 1320($s1)
    sw $t2, 1064($s1)
    sw $t2, 808($s1)
    sw $t2, 552($s1)
    sw $t2, 296($s1)
    sw $t2, 40($s1)
    sw $t2, 44($s1)
    sw $t2, 48($s1)
    sw $t2, 304($s1)
    sw $t2, 560($s1)
    sw $t2, 52($s1)
    sw $t2, 56($s1)
    sw $t2, 312($s1)
    sw $t2, 568($s1)
    sw $t2, 824($s1)
    sw $t2, 1080($s1)
    sw $t2, 1336($s1)

    
    # letter e
    sw $t2, 64($s1)
    sw $t2, 320($s1)
    sw $t2, 576($s1)
    sw $t2, 832($s1)
    sw $t2, 1088($s1)
    sw $t2, 1344($s1)

    sw $t2, 68($s1)
    sw $t2, 72($s1)
    sw $t2, 580($s1)
    sw $t2, 1348($s1)
    sw $t2, 1352($s1)

    # letter o
    sw $t2, 88($s1)
    sw $t2, 344($s1)
    sw $t2, 600($s1)
    sw $t2, 856($s1)
    sw $t2, 1112($s1)
    sw $t2, 1368($s1)

    sw $t2, 92($s1)
    sw $t2, 1372($s1)

    sw $t2, 96($s1)
    sw $t2, 352($s1)
    sw $t2, 608($s1)
    sw $t2, 864($s1)
    sw $t2, 1120($s1)
    sw $t2, 1376($s1)

    # letter v 
    sw $t2, 104($s1)
    sw $t2, 360($s1)
    sw $t2, 616($s1)
    sw $t2, 872($s1)
    sw $t2, 1128($s1)
    sw $t2, 1384($s1)

    sw $t2, 1388($s1)

    sw $t2, 112($s1)
    sw $t2, 368($s1)
    sw $t2, 624($s1)
    sw $t2, 880($s1)
    sw $t2, 1136($s1)
    sw $t2, 1392($s1)

    # letter e 
    sw $t2, 120($s1)
    sw $t2, 376($s1)
    sw $t2, 632($s1)
    sw $t2, 888($s1)
    sw $t2, 1144($s1)
    sw $t2, 1400($s1)

    sw $t2, 1404($s1)
    sw $t2, 1408($s1)
    sw $t2, 124($s1)
    sw $t2, 636($s1)
    sw $t2, 128($s1)

    # letter r 
    sw $t2, 136($s1)
    sw $t2, 392($s1)
    sw $t2, 648($s1)
    sw $t2, 904($s1)
    sw $t2, 1160($s1)
    sw $t2, 1416($s1)

    sw $t2, 140($s1)
    sw $t2, 144($s1)

    sw $t2, 400($s1)
    sw $t2, 656($s1)
    sw $t2, 912($s1)
    sw $t2, 1168($s1)
    sw $t2, 1424($s1)

    sw $t2, 912($s1)
    sw $t2, 908($s1)


    # 'p' to play
    
    lw $s1, BASE_ADDRESS
    addi $s1, $s1, 4660

    # '
    sw $t2, 0($s1)
    sw $t2, 256($s1)

    # letter p
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # '
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)


    # letter t
    addi $s1, $s1, 20
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 252($s1)
    sw $t2, 260($s1)

    # letter 0
    addi $s1, $s1, 12
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter p
    addi $s1, $s1, 20
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)


    # letter l
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter 0
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter y
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1028($s1)


    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    
    jr $ra

WIN_SCREEN: 
    li $a1, GREEN # colour for winner text
    jal DRAW_WIN_SCREEN
    
    li $t9, 0xffff0000 
    lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before, now $t2 holds value for key pressed

    beq $t2, 112, RESTART_LOGIC2 # ASCII code of 'p' is 112, restart game
    j WIN_SCREEN
    RESTART_LOGIC2:
        li $a1, BLACK_COLOR # colour for game over text
        jal DRAW_WIN_SCREEN
        j START

DRAW_WIN_SCREEN:
    lw $s1, BASE_ADDRESS
	add $t2, $a1, $zero # pass in the coluur here

    addi $s1, $s1, 1596
    
    # letter w
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 1284($s1)

    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 1284($s1)

    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter i 
    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter n 
    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 0($s1)
    sw $t2, 4($s1)
    sw $t2, 8($s1)
    sw $t2, 12($s1)

    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter n 
    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 4($s1)
    sw $t2, 8($s1)
    sw $t2, 12($s1)

    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter e 
    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 4($s1)
    sw $t2, 8($s1)
    sw $t2, 516($s1)
    sw $t2, 1284($s1)
    sw $t2, 1288($s1)

    # letter r 
    addi $s1, $s1, 20
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    sw $t2, 4($s1)
    sw $t2, 8($s1)
    sw $t2, 12($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 524($s1)

    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter r 
    addi $s1, $s1, 16
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1280($s1)


    # 'p' to play
    
    lw $s1, BASE_ADDRESS
    addi $s1, $s1, 4668

    # '
    sw $t2, 0($s1)
    sw $t2, 256($s1)

    # letter p
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # '
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)


    # letter t
    addi $s1, $s1, 20
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 252($s1)
    sw $t2, 260($s1)

    # letter 0
    addi $s1, $s1, 12
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter p
    addi $s1, $s1, 20
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)


    # letter l
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter 0
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter y
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1028($s1)


    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    jr $ra
        


MENU_SCREEN: 
    li $a1, WHITE # colour for winner text
    # add $a0, $ra, 0
    jal DRAW_MENU_SCREEN
    
    li $t9, 0xffff0000 
    lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before, now $t2 holds value for key pressed

    beq $t2, 112, START_LOGIC # ASCII code of 'p' is 112, restart game 
    j START_ELSE
    START_LOGIC:
        li $a1, BLACK_COLOR # colour for game over text
        jal DRAW_MENU_SCREEN
        j START
    START_ELSE:
        beq $t2, 113, end # ASCII code of 'p' is 112, restart game 
        j MENU_SCREEN

DRAW_MENU_SCREEN:
    # jal DRAW_PLATFORMS
    lw $s1, BASE_ADDRESS
	add $t2, $a1, $zero # pass in the coluur here


    # ############ 'p' to play
    
    addi $s1, $s1, 2620

    # '
    sw $t2, 0($s1)
    sw $t2, 256($s1)

    # letter p
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # '
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)


    # letter t
    addi $s1, $s1, 20
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 252($s1)
    sw $t2, 260($s1)

    # letter 0
    addi $s1, $s1, 12
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter p
    addi $s1, $s1, 20
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)


    # letter l
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter 0
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)

    # letter y
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1028($s1)


    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)


    # ############ 'q' to quit
    
    lw $s1, BASE_ADDRESS
    addi $s1, $s1, 5180

    # '
    sw $t2, 0($s1)
    sw $t2, 256($s1)

    # letter q
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    
    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    # '
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 256($s1)


    # letter t
    addi $s1, $s1, 20
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 252($s1)
    sw $t2, 260($s1)

    # letter 0
    addi $s1, $s1, 12
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 516($s1)
    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

     # letter q
    addi $s1, $s1, 20
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    
    sw $t2, 516($s1)
    sw $t2, 520($s1)
    sw $t2, 1028($s1)
    sw $t2, 1032($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)
    sw $t2, 1280($s1)
    sw $t2, 1536($s1)

    # letter u
    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 1028($s1)

    addi $s1, $s1, 8
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter i
    addi $s1, $s1, 8
    sw $t2, 0($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    # letter t
    addi $s1, $s1, 12
    sw $t2, 0($s1)
    sw $t2, 256($s1)
    sw $t2, 512($s1)
    sw $t2, 768($s1)
    sw $t2, 1024($s1)

    sw $t2, 252($s1)
    sw $t2, 260($s1)





    # ######## draw platforms 

    lw $s1, PLAT3 
    add $s1, $s1, -452
    add $t1, $t2, 0

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

    lw $s1, PLAT1 
    add $s1, $s1, 1284

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

    lw $s1, PLAT1 
    add $s1, $s1, 3764

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
    

    lw $s1, PLAT2 

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


CLEAR_SCREEN:
    # set screen base address in $s0
    lw $s0, BASE_ADDRESS

    li $t0, BLACK_COLOR

    li $t2, 4096     # loop counter for column

    clear_screen:
        sw $t0, 0($s0)     # write black to pixel
        addi $s0, $s0, 4   # advance to next pixel
        addi $t2, $t2, -1  # decrement column counter
        bne $t2, $zero, clear_screen   # loop until column counter is zero
        jr $ra

    jr $ra

 

end:	
	li $v0, 10
	syscall
	
