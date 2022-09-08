# Author:	Benjamin Daluz
# Date:		August 4, 2022
# Description:	A program based on Connect 4 but with 3 players, users are able to 
#		input pieces through the side, and there are randomly generated obstacles

.data

topRow: .asciiz "  A   B   C   D   E   F   G   H   I \n"
hBorder: .asciiz " --- --- --- --- --- --- --- --- ---\n"
vBorder: .asciiz "|"

prompt1: .asciiz "It is player "
prompt1.5: .asciiz "'s turn.\n"
prompt2: .asciiz "Enter a letter to enter through the top or a number to enter through the side:\n"

endprompt1: .asciiz "Player "
endprompt2: .asciiz " is the winner."

errormessage: .asciiz "\nPlease enter another row or column:\n"
errorinputm: .asciiz "\nPlease enter a capital letter from A-I or a number from 1-9:\n"

newline: .asciiz "\n"

array:
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ','O', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	.byte	' ', ' ',' ', ' ',' ', ' ',' ', ' ',' '
	
obstacleb:
	.byte 'O'
		
end: .word 0
counter: .word 0

.text
	li $v0, 32	#puts the program to sleep for 1 millisecond
	li $a0, 1	#this will help the program seem more random since the obstacles wil alternate more often 
	syscall
	
	li $v0, 30	#$a0 will be based on time in milliseconds so it will always be random
	syscall
	
	li $a1, 0
	jal lfsr32	#$v0 will contain lfsr'd bits
	li $t1, 2	#load divisor with 2
	
	div $v0, $t1	#divides the bits by 2
	mfhi $t2	#move from hi, takes the remainder and moves it into $t2
	
	move $a0, $t2	#moves remainder into $a0, it will either be 0 or 1 since we are dividing an integer by 2
	
	la $a3, array	#loads base address into $a3
	jal obstacle	#obstacle (int counter, char array[][10])
	
	la $t0, end	#loads variable end's address into $t0
    	lw $t1, 0($t0)	#accesses the element at address $t0
    	li $t2, 1	#loads 1 into $t2
    	
while:	beq $t1, $t2, finish	#while (end != 1), the end game prompt prints after this while loop

	la $a3, array 	#$a1 = height of matrix (9) or Row index | $a2 = length of matrix (9) or Column index
	la $a1, 8
	la $a2, 8	
	jal printgrid
	
	li $t1, 3		#load 3
	lw $t2, counter		#load counter
	div $t2, $t1		#counter % 3
	mfhi $t3		#take the remainder as playerTurn
	addi $t2, $t2, 1
	sw $t2, counter		#store the counter to update i
	
	la $a0, prompt1		#prints first part of the player turn prompt
	li $v0, 4
	syscall
	
	addi $a0, $t3, 1	#used to display the appropriate player turn
	li $v0, 1
	syscall
	
	la $a0, prompt1.5	#prints the rest of the player turn prompt
	li $v0, 4
	syscall
	
	la $a0, prompt2		#prints the second prompt
	li $v0, 4
	syscall
	
	li $v0, 12
	syscall
	move $a1, $v0	#move input to $a1
	
	la $a0, newline	#prints newline after the prompt
	li $v0, 4
	syscall
	
	#when making the grid input function, keep the input as $a1 and counter as $a0 for function arguments.
	#void piece(char grid[9][9], int playerTurn, char input), $a0 is the playerTurn, $a1 is the player input, $a2 is the base address
	
	move $a0, $t3		#moves the counter into $a0 so that the function knows the player turn
	jal offset
	la $a2, array		#loads the base address
	jal piece		#$a1 is the input, $a0 is the playerturn counter, $a2 is the base address
	
	
	#int checker(char grid[9][9], int playerTurn), $a2 will be kept as array base address and $a0 will remain as player turn
	#$a0 will be used as the playerTurn counter from now on (0 is player1, 1 is player2, 2 is player3
	
	#jal offset
	move $a0, $t3		#moves the counter back to $a0 because it gets manipulated in the piece function
	jal checker		#$a0, is the playerturn counter, $a2 is the base address
	
	
	la $t0, end	#loads the address of variable "end" into $t0
    	lw $t1, ($t0)	#loads the element at address $t0 into $t1
    	li $t2, 1	#reloads $t2 as 1 so that the condition isn't changed when j while executes, just initializing 1 into $t2
    	j while
	

	
finish: la $a3, array	#loads the base address of the array 
	la $a1, 8	#loads 8 into $a1 and $a2 as row and column
	la $a2, 8	#void printGrid(char grid[][9], int row, int col)
	jal printgrid
	
	la $a0, endprompt1	#loads the first part of the end prompt to be printed
	li $v0, 4
	syscall
	
	li $t1, 3		#load 3
	lw $t2, counter		#load counter
	div $t2, $t1		#counter % 3
	mfhi $a0		#take the remainder as playerTurn
	beq $a0, 0, print3	#if the remainder = 0 (counter = 3), jump to print 3 
	
	li $v0, 1
	syscall
	j endprm
	
print3: li $a0, 3	#loads 3 to be printed
	li $v0, 1	#prints 3 so it shows up as "Player 3 is the winner" if the game finished on player 3's move 
	syscall	
	
endprm:	la $a0, endprompt2	#loads the second part of the end prompt to be printed
	li $v0, 4
	syscall
	
	li $a0, 67	#plays low note for .1 seconds
	li $a1, 100	#duration: 100 ms
	li $a2, 96	#96 = synth wave
	li $a3, 100	#volume is at 100
	li $v0, 33	#cues for a sound cue
	syscall

	li $a0, 69	#plays high note for .3 seconds
	li $a1, 300	#duration: 100 ms
	li $a2, 96	#96 = synthwave
	li $a3, 100	#volume is at 100
	li $v0, 33	#cues for sound cue
	syscall

	li $a0, 67	#plays low note for .1 seconds
	li $a1, 100	#duration: 100 ms
	li $a2, 96	#96 = synthwave
	li $a3, 100	#volume is at 100
	li $v0, 33	#cues for sound cue
	syscall

	li $a0, 71	#plays higher note for .5 seconds
	li $a1, 500	#duration: 100 ms
	li $a2, 96	#96 = synthwave
	li $a3, 100	#volume is at 100
	li $v0, 33	#cues for sound cue
	syscall
	
	li $v0, 10	#ends the program
	syscall
	
printgrid:
	li $t1, 0	
	li $t2, 0
	
	la $a0, topRow	#prints the top row coordinates
	li $v0, 4
	syscall
	
for1:	blt $a1, $t1, done	#keep running while i >= 0
		
	la $a0, hBorder
	li $v0, 4
	syscall
		
	for2: blt $a2, $t2, next	#keep reunning while j >= 0
		
		la $a0, vBorder
		li $v0, 4
		syscall
		
		li $a0, 32         # ascii code for 32 is a space character
		li $v0, 11
		syscall
		
		la $t3, array
		
		li $t5, 8
		sub $t6, $t5, $a1	#$t6 = 8-i
		mul $t7, $t6, 9		#multiplies by 9 since 9 columns per row
		sub $t6, $t5, $a2	#$t6 = 8-j
		add $t7, $t7, $t6	#$s0 = (8-i)*9 + (8-j)
		add $t7, $t7, $t3	#$s0 = (8-i)*9 + (8-j) + base address
		
		lb $a0, ($t7)      # This is responsible for printing the pieces
		li $v0, 11
		syscall
		
		li $a0, 32         # ascii code for 32 is a space character
		li $v0, 11
		syscall
		
		sub $a2, $a2, 1	#j--
		j for2
		
next: 	la $a0, vBorder		#the label "next" continues the instructions in the first for loop
	li $v0, 4
	syscall
	
	li $a0, 32	# ascii code for 32 is a space character
	li $v0, 11
	syscall
	syscall		#this prints the space character for a second time
	
	add $t4, $a1, 1
	
	la $a0, ($t4)	#prints the coordinate on the side
	li $v0, 1
	syscall
	
	la $a0, newline
	li $v0, 4
	syscall
	
	addi $a2, $a2, 9	#resets the j loop
	sub $a1, $a1, 1		#i--
	j for1
	
done: 	la $a0, hBorder
	li $v0, 4
	syscall
		
	jr $ra

		#void piece(char grid[9][9], int playerTurn, char input), $a0 is the playerTurn, $a1 is the input coordinates, $a2 is the base address
piece:		#counter = 0 -> player 1's turn, counter = 1 -> player 2's turn, counter = 2 -> player 3's turn
	
check:	ble $a1, 57, checknum	#this will check if the input is a number or letter coordinate 
	bge $a1, 65, checklett	#the number coordinates are all below 65, and letters are 65 and above
	j errorinput
	
checknum:
	bge $a1, 49, nextfor	#if the ascii code is between 57 and 49, it will jump to the for loop used for numbers
	j errorinput
checklett:
	ble $a1, 73, input	#if the ascii code is between 65 and 73, it will jump to the for loop used for numbers
	j errorinput
	
	#$a0 will not need to be interacted with after it has been set by the piece, use it to set piece
	
input:	li $t0, 0 #this is i
	li $t1, 9
	forP:	bge $t0, $t1, nextfor	#i = 0, while i < 9, This one scans for letters, use $a1
	
		addi $t4, $t0, 1	#$t4 = i + 1
		mul $t6, $t4, 9		#$t6 = (i+1) * 9, multiplies by 9 since 9 columns per row
		sub $t5, $a1, 65	#$t5 = $a1 - 65, determines the column, $a1 is from 65 to 73
		add $t6, $t6, $t5	#$t6 = (i+1)*9 + ($a1 - 65)
		add $t6, $t6, $a2	#$t6 = (i+1)*9 + ($a1 - 65) + base address
		move $t7, $t6
	
		addi $t4, $t0, 0	#$t4 = i
		mul $t6, $t4, 9		#$t6 = (i) * 9, multiplies by 9 since 9 columns per row
		sub $t5, $a1, 65	#$t5 = $a1 - 65, determines the column, $a1 is from 65 to 73
		add $t6, $t6, $t5	#$t6 = (i)*9 + ($a1 - 65)
		add $t6, $t6, $a2	#$t6 = (i)*9 + ($a1 - 65) + base address
		
		lb $t8, ($t6)
		lb $t9, ($t7)
		
		bne $t8, 32, elseP	#checks if the element at $t6 is equal to a space
		bne $t9, 32, elseP	#checks if the element at $t7 is equal to a space
		addi $t0, $t0, 2
   		j forP	
	
	elseP:	beq $t8, 32, elseP1
		addi $t4, $t0, -1	#$t4 = i - 1
		mul $t6, $t4, 9		#$t6 = (i-1) * 9, multiplies by 9 since 9 columns per row
		sub $t5, $a1, 65	#$t5 = $a1 - 65, determines the column, $a1 is from 65 to 73
		add $t6, $t6, $t5	#$t6 = (i)*9 + ($a1 - 65)
		add $t6, $t6, $a2	#$t6 = (i)*9 + ($a1 - 65) + base address
		
		blt $t6, $a2, error
		
		la $t8, ($t6)		#if it is, then load the address into a variable
		
 		add $sp, $sp, $a0	#decrements depending on the player turn (we are adding by a negative number)
 		lb $t7, ($sp)		#loads the element stored at [$sp + (-1, -2, or -3)] 
 		sub $sp, $sp, $a0	#restores the decrement
		sb $t7, ($t8)		#stores the element at [$sp + (-1, -2, or -3)] into $t8
		
		j finishP
	
	elseP1: la $t8, ($t6)		#if it is, then load the address into a variable
	
 		add $sp, $sp, $a0	#decrements depending on the player turn (we are adding by a negative number)
 		lb $t7, ($sp)		#loads the element stored at [$sp + (-1, -2, or -3)] 
 		add $sp, $sp, $a0	#restores the decrement
		sb $t7, ($t8)		#stores the element at [$sp + (-1, -2, or -3)] into $t8
		
		j finishP
	
nextI:	addi $t0, $t0, 1	#i++
	j forP
	
nextfor:li $t0, 8
	li $t1, -1
	forP2:	ble $t0, $t1, finishP	#j = 8, while j > -1, This one scans for numbers (based on their ascii code), input - 57 = -result *-1 = result
	
		addi $t6, $t0, -1	#$t6 = j - 1
		sub $t5, $a1, 57	#$t5 = $a1 - 57, determines the column, input is from 57 to 49
		mul $t5, $t5, -9	#$t5 = -$t5 * -1 = 0 to 8 depending on input; $t5 = 57 - $a1
		add $t6, $t6, $t5	#$t6 = (j-1) + (57 - input)
		add $t6, $t6, $a2	#$t6 = (j-1) + (57 - input) + base address
		move $t7, $t6
		
		addi $t6, $t0, 0	#$t6 = j
		sub $t5, $a1, 57	#$t5 = $a1 - 57, determines the column, input is from 57 to 49
		mul $t5, $t5, -9	#$t5 = -$t5 * -1 = 0 to 8 depending on input; $t5 = 57 - $a1
		add $t6, $t6, $t5	#$t6 = (j) + (57 - input)
		add $t6, $t6, $a2	#$t6 = (j) + (57 - input) + base address
		
		lb $t8, ($t6)
		lb $t9, ($t7)
		
		bne $t8, 32, elsePj	#checks if the element at $t6 is a space
		bne $t9, 32, elsePj	#checks if the element at $t7 is a space
		beq $t0, 0, elsePj	#checks if j != 0, if it is a 0 then jump to else
		addi $t0, $t0, -2
   		j forP2
   		
 	elsePj: bne $t8, 32, elsePj1	#checks if the element at $t6 is a space
 		la $t8, ($t6)		#if it is, then load the address into a variable
 		
 		add $sp, $sp, $a0	#decrements depending on the player turn (we are adding by a negative number)
 		lb $t7, ($sp)		#loads the element stored at [$sp + (-1, -2, or -3)] 
 		sub $sp, $sp, $a0	#restores the decrement
		sb $t7, ($t8)		#stores the element at [$sp + (-1, -2, or -3)] into $t8
		
		j finishP
		
	elsePj1:addi $t4, $t0, 1	#$t4 = j + 1
		bgt $t4, 8, error	#if j+1 > 8
		
		
	next1:	addi $t6, $t6, 1
		la $t8, ($t6)		#loads the address into variable $t8
		
		add $sp, $sp, $a0	#decrements depending on the player turn (we are adding by a negative number)
		lb $t7, ($sp)		#loads the element stored at [$sp + (-1, -2, or -3)] 
		sub $sp, $sp, $a0	#restores the decrement
		sb $t7, ($t8)		#stores the element at [$sp + (-1, -2, or -3)] into $t8
		
		j finishP  	
		
	
nextJ:	addi $t0, $t0, -1	#j--
	j forP2

finishP:jr $ra

error:	move $t9, $a0	#temporarily move to $t9
	move $t8, $v0
	la $a0, errormessage
	li $v0, 4
	syscall
	li $v0, 12
	syscall
	move $a1, $v0	#move input to $a1
	move $v0, $t8
	move $a0, $t9	#move piece back to $a0
	j piece
	
	#int checker(char grid[9][9], int playerTurn), $a2 will be kept as array base address and $a0 will remain as player turn
checker:
	li $t0, 0
	li $t1, 1
	li $t2, 2
	beq $a0, $t0, X1
	beq $a0, $t1, Y1
	beq $a0, $t2, Z1
	#emm
	
	#the following labels will load the ascii code so that newest placed piece will be checked for any new connections
	#this also allows for the game to end right away and for the player # to be displayed at the end game screen to show the winner
	
X1:	li $a0, 88
	j firstFor
	
Y1:	li $a0, 89
	j firstFor
	
Z1:	li $a0, 90
	j firstFor
	
	#for (int i = 0; i < 9; ++i) { //this for loop checks for row connections
        #for (int j = 0; j < 6; ++j) { //6 because there are only 6 posible connections of a connect 4 for each row due to its size
        #    counter = 0;
        #    for (int k = 0; k <= 3; ++k) {
        #        if (grid[i][j+k] == piece) {
        #            counter++;
        #        }
        #        if (counter == 4) {
        #            return 1;
        #        }
        #    }
        #   }
        #} //end of first for loop	
        
firstFor: 
	li $t0, 0	#i = 0
	li $t9, 9	#i < 9
starti1:	bge $t0, $t9, secondFor	#secondFor will be for column connections, replace this with secondFor
			li $t1, 0		#j = 0
			li $t8, 6		#while j < 6		
	startj1:	bge $t1, $t8, endi1
			li $a1, 0		#initializes the connection counter
				li $t2, 0	#k = 0
				li $t7, 3	#while k <= 3
		startk1:	bgt $t2, $t7, endj1	#still need to calculate the array address, need to lb the address to see if the elements are the same
		
				mul $t3, $t0, 9		#$t3 = (i * 9), accounts for row index 
				add $t3, $t3, $t1	#$t3 = (i * 9) + j, row index + column index
				add $t3, $t3, $t2	#$t3 = (i * 9) + (j + k), row index + column index + k to scan through array
				add $t3, $t3, $a2	#$t3 = (i * 9) + (j + k) + base address, row index + column index + k to scan through array + base address
				
				lb $t4, ($t3)		#loads the element at the calculated address to see if it equal to X, Y, or Z
				
				addi $t2, $t2, 1	#k++
				
				bne $t4, $a0, ifcount
				addi $a1, $a1, 1
				
		ifcount:	bne $a1, 4, startk1
				j return1
	endj1:		addi $t1, $t1, 1	#j++
			j startj1
endi1:	addi $t0, $t0, 1	#i++
	j starti1
			
				
secondFor: 
	li $t1, 0	#j = 0
	li $t9, 9	#j < 9
starti2:	bge $t1, $t9, thirdFor	#thirdFor will be for diagnol connections
			li $t0, 0		#i = 0
			li $t8, 6		#while i < 6		
	startj2:	bge $t0, $t8, endi2
			li $a1, 0		#initializes the connection counter
				li $t2, 0	#k = 0
				li $t7, 3	#while k <= 3
		startk2:	bgt $t2, $t7, endj2	#still need to calculate the array address, need to lb the address to see if the elements are the same
		
				add $t3, $t0, $t2	#$t3 = (i + k), accounts for row index 
				mul $t3, $t3, 9		#$t3 = (i + k) * 9	
				add $t3, $t3, $t1	#$t3 = ((i + k) * 9) + j, accounts for column index		
				add $t3, $t3, $a2	#$t3 = ((i + k) * 9) + j, accounts for column index + base address
				
				
				lb $t4, ($t3)		#loads the element at the calculated address to see if it equal to X, Y, or Z
				
				addi $t2, $t2, 1	#k++
				
				bne $t4, $a0, ifcount2	#if $t4 is equal to the current player's piece, add 1 else go back to the for loop, $a0 = player piece
				addi $a1, $a1, 1
				
		ifcount2:	bne $a1, 4, startk2	#$a1 = counter
				j return1
	endj2:		addi $t0, $t0, 1	#i++
			j startj2
endi2:	addi $t1, $t1, 1	#j++
	j starti2	
	

thirdFor:	#copy the C conditional since there is an if operator, example: the bgt's for the first for loop will link to the instruction under it on line 373	
	li $t0, 1	#i = 1
	li $t9, 8	#i <= 8
starti3:	bgt $t0, $t9, finishline
			li $t1, 1	#j = 1
			li $t8, 8	#j <= 8
			li $a1, 0	#$a1 = counter
	startj3:	bgt $t1, $t8, endi3
			
			#NOTE: BREAK JUMPS TO THE NEXT FOR LOOP OR JUMPS TO ENDJ3 IF ITS DOWNL
			
			addi $t2, $t0, 0	#a = i
			addi $t3, $t1, 0	#b = j
		upL:	bgt $t2, -1, upL1	#--a, --b
			bgt $t3, -1, upL1
			j elsebreak1
			upL1:	mul $t4, $t2, 9		#$t4 = (a * 9) 
				add $t4, $t4, $t3	#$t4 = (a * 9) + b
				add $t4, $t4, $a2	#$t4 = (a * 9) + b + base address
				lb $t5, ($t4)		#loads the element at address $t4
				
				addi $t2, $t2, -1	#--a
				addi $t3, $t3, -1	#--b
				
				bne $t5, $a0, elsebreak1
					addi $a1, $a1, 1
					beq $a1, 4, return1
				j upL
		elsebreak1:				
			addi $t2, $t0, 1	#a = i
			addi $t3, $t1, 1	#b = j
		downR:	blt $t2, 9, downR1	#++a, ++b
			blt $t3, 9, downR1
			j elsebreak2
			downR1:	mul $t4, $t2, 9		#$t4 = (a * 9) 
				add $t4, $t4, $t3	#$t4 = (a * 9) + b
				add $t4, $t4, $a2	#$t4 = (a * 9) + b + base address
				lb $t5, ($t4)		#loads the element at address $t4
				
				addi $t2, $t2, 1	#++a
				addi $t3, $t3, 1	#++b
				
				bne $t5, $a0, elsebreak2
					addi $a1, $a1, 1
					beq $a1, 4, return1		
				j downR
		elsebreak2:
			li $a1, 0	
			addi $t2, $t0, 0	#a = i
			addi $t3, $t1, 0	#b = j
		upR:	blt $t2, 9, upR1	#++a, --b
			bgt $t3, -1, upR1
			j elsebreak3
			upR1:	mul $t4, $t2, 9		#$t4 = (a * 9) 
				add $t4, $t4, $t3	#$t4 = (a * 9) + b
				add $t4, $t4, $a2	#$t4 = (a * 9) + b + base address
				lb $t5, ($t4)		#loads the element at address $t4
				
				addi $t2, $t2, 1	#++a
				addi $t3, $t3, -1	#--b
				
				bne $t5, $a0, elsebreak3
					addi $a1, $a1, 1
					beq $a1, 4, return1		
				j upR
		elsebreak3:
			addi $t2, $t0, -1	#a = i-1
			addi $t3, $t1, 1	#b = j+1
		downL:	bgt $t2, -1, downL1	#--a, ++b
			blt $t3, 9, downL1
			j endj3
			downL1:	mul $t4, $t2, 9		#$t4 = (a * 9) 
				add $t4, $t4, $t3	#$t4 = (a * 9) + b
				add $t4, $t4, $a2	#$t4 = (a * 9) + b + base address
				lb $t5, ($t4)		#loads the element at address $t4
				
				addi $t2, $t2, -1	#--a
				addi $t3, $t3, 1	#++b
				
				bne $t5, $a0, endj3
					addi $a1, $a1, 1
					beq $a1, 4, return1		
				j downL		 			 
				
						 					 		 					 
	endj3:		li $a1, 0			#resets counter
			addi $t1, $t1, 1					 					 					 					 
			j startj3
endi3:	addi $t0, $t0, 1
	j starti3
	 				 
	 				 	 				 	 				 
				 				 				 				 
finishline: 			  
	jr $ra
			   
return1:
	la $t0, end	#loads the address of variable "end" into $sp
	li $t1, 1	#loads 1 into $t1
    	sw $t1, 0($t0)	#end = 1, stores 1 into the variable at $sp
    	jr $ra
    	
errorinput:
	move $t9, $a0	#temporarily move to $t9
	
	la $a0, errorinputm
	li $v0, 4
	syscall
	li $v0, 12
	syscall
	move $a1, $v0	#move input to $a1
	move $a0, $t9	#move piece back to $a0
	
	j check
	
	#playerInput[2][6] = obstacle(); = $t1
   	#playerInput[6][2] = obstacle(); = $t0
	
	#playerInput[6][6] = obstacle1();
	#playerInput[2][2] = obstacle1();
	
obstacle:
	beq $a0, 1, ver2
				
	li $t3, 2		#this executes if $a0 is 0
	mul $t0, $t3, 9		#$t0 = (2 * 9)
	add $t0, $t0, 6		#$t0 = (2 * 9) + 6
	add $t0, $t0, $a3	#$t0 = (2 * 9) + 6 + base address
	move $t1, $t0
	
	li $t3, 6
	mul $t0, $t3, 9		#$t0 = (6 * 9)
	add $t0, $t0, 2		#$t0 = (6 * 9) + 2
	add $t0, $t0, $a3	#$t0 = (6 * 9) + 2 + base address
	
	lb $t2, obstacleb
	sb $t2, ($t1)		#stores the obstacle into $t1
	sb $t2, ($t0)		#stores the obstacle into $t0			
										
	jr $ra
ver2:				#this executes if $a0 is 1 or if $a0 is an odd number
	li $t3, 2
	mul $t0, $t3, 9		#$t0 = (2 * 9)
	add $t0, $t0, 2		#$t0 = (2 * 9) + 2
	add $t0, $t0, $a3	#$t0 = (2 * 9) + 2 + base address
	move $t1, $t0
	
	li $t3, 6
	mul $t0, $t3, 9		#$t0 = (6 * 9)
	add $t0, $t0, 6		#$t0 = (6 * 9) + 6
	add $t0, $t0, $a3	#$t0 = (6 * 9) + 6 + base address
	
	lb $t2, obstacleb
	sb $t2, ($t1)		#stores obstacle into $t1
	sb $t2, ($t0)		#stores obstacle into $t0
	
	jr $ra
	
lfsr32:	
	li $t0, 0
	
	bne $a1, $t0, elsel	#branch if (input != 0)
	la $v0, ($a0)
	j donel
	
elsel:	li $s0, 0	#int i = 0
	li $t1, 31
forl:	beq $s0, $t1, donel
		
	srl $t2, $a0, 0	
	srl $t3, $a0, 10
	srl $t4, $a0, 30
	srl $t5, $a0, 31
	

	xor $s1, $t2, $t3
	xor $s1, $s1, $t4
	xor $s1, $s1, $t5

	srl $t2, $a0, 1
	sll $t3, $s1, 31

	or $v0, $t2, $t3
	move $a0, $v0 
	addi $s0, $s0, 1
	j forl 
donel:	jr $ra
	
offset:

	li $t0, 88		#loads $t0 with X
	addi $sp, $sp, -1	#decrements the stack pointer
	sb $t0, ($sp)		#stores X in the first element of the stack
	
	li $t1, 89		#loads $t0 with Y
	addi $sp, $sp, -1	#decrements the stack pointer
	sb $t1, ($sp)		#stores Y to the top of the stack
	
	li $t2, 90		#loads $t0 with Z
	addi $sp, $sp, -1	#decrements the stack pointer
	sb $t2, ($sp)		#stores Z to the top of the stack with Y right below it
	
	addi $sp, $sp, -1	#decrements the stack pointer
	mul $a0, $a0, -1	#$a0 = 0, -1, or -2
	addi $a0, $a0, -1	#$a0 = -1, -2, or -3 (this calculates the offset so that the above elements can be accessed
	sb $a0, ($sp)		#depending on the player turn, this works because $a0 will hold the player turn counter)
	
	addi $sp, $sp, 4	#deallocates the stack	

	
	#$a0 will be added to the stack pointer in the piece function in order to access the different pieces depending on the player turn.
	#if player turn is 1, then the offset will be -1($sp) to access X and the same for the other elements
	
	#mul $a0, $a0, -1
	#0 = 0
	#1 = -1
	#2 = -2
	
	#addi $a0, $a0, -1
	#0 = -1
	#1 = -2
	#2 = -3
	
	#sb $a0, -4($sp)
	
	jr $ra
	
