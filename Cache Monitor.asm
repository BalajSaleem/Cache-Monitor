.data

msg1:	.asciiz "Welcome to Array Manipulater! \n"

msg2:	.asciiz "Please enter the Dimensions of the matrix\n"

msg22:	.asciiz "Press 1 to enter Values Your Self \nPress 2 to Automatically Populate it \n"

msg3:	.asciiz "Please enter the values row by row\n"

msg4:	.asciiz "The array has been populated by consecutive numbers (1,2,3...)\n"

menuMsg:.asciiz "\nEnter: \n 1. Get a specific element \n 2. Print the Array row by row \n 3. Print trace \n 4. Get the other Trace \n 5. Get Row-Major Sum \n 6. Get Column Major sum \n 7. exit \n"	

msg5:	.asciiz "--New Row has Started--\n"

msg6:	.asciiz "Enter Row Number : "

msg7:	.asciiz "Enter Column Number : "

msg8: 	.asciiz "The number at the entered location is : "

nxt: 	.asciiz "\n"

dash:	.asciiz " | "

msg9:	.asciiz "The trace is : "

msg10:	.asciiz "The Sum of All the rows is : "

msg11:	.asciiz"Sum of rows respectively : \n" 

msg12:	.asciiz "The Sum of All the columns is : "

msg13:	.asciiz"Sum of columns respectively : \n" 

.text
############################ Menu ########################################
	
	#welcome
	li $v0, 4
	la $a0, msg1
	syscall
	
	#dimensions entered
	li $v0, 4
	la $a0, msg2
	syscall
	#dimensions stored
	li $v0, 5
	syscall
	move $s0, $v0 						#s0 has the dimensions now 		N
	
	mul $s2, $s0, $s0 					#s2 has total number of elements 	NxN
	jal makeArray
	move $s1, $v0 						#s1 has the starting point of array	
	
	
	#method of element entry 
	li $v0, 4
	la $a0, msg22
	syscall
	
	li $v0, 5
	syscall
	move $a0, $v0
	jal populateArray
	
	

selection:	
	#menu
	li $v0, 4
	la $a0, menuMsg
	syscall
	#take users input
	li $v0, 5
	syscall
	move $s3, $v0 						#s3 has the choice of the user
	
	
	#go to respected function call depending on the slection
	beq $s3,1,specificNumber 
	beq $s3,2,prnt
	beq $s3,3,trc1
	beq $s3,4,trc2
	beq $s3,5,rwMjrSum
	beq $s3,6,clMjrSum
	beq $s3,7,end
	
	
	#ALL available functions
	clMjrSum:
	jal colSum
	j afterSelection
	
	
	rwMjrSum:
	jal rowSum
	j afterSelection
	
	
	trc2:
	li $v0, 4
	la $a0, msg9
	syscall
	jal trace2
	move $a0, $v1
	li $v0, 1
	syscall
	
	j afterSelection
	
	
	trc1:
	li $v0, 4
	la $a0, msg9
	syscall
	jal trace
	move $a0, $v1
	li $v0, 1
	syscall
	
	j afterSelection
	
	prnt:
	jal printArray
	j afterSelection
	
	specificNumber:
 	#ask for the row number
 	li $v0, 4
	la $a0, msg6
	syscall
	#store the row number
	li $v0, 5
	syscall
	move $a2, $v0 		#a2 has the row number
	
	
	 #ask for the col number
 	li $v0, 4
	la $a0, msg7
	syscall
	#store the col number
	li $v0, 5
	syscall
	move $a1, $v0 		#a1 has the col 
	
	
	
	jal getNumber
	move $t1, $v0		#t1 has the item
	#show printing message
 	li $v0, 4
	la $a0, msg8
 	syscall
 	
 	#print the number
 	move $a0, $t1		#a0 has the item
 	li $v0, 1
 	syscall
	
	
	j afterSelection
	
	
	afterSelection:
	j selection
	end:
	##temp##
	li $v0, 10
	syscall  
	  
########################Array Opperationss########################

makeArray:

	
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
	
	
	#Allocating memory 4 times as much as s0
	li $v0, 9		
	#allocate (s2 * 4) space
	mul $a0, $s2, 4
	syscall
	
	
	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
   	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
   	addi $sp, $sp, 20
   	jr $ra
	
populateArray:
	#move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
	
	

	
	beq $a0, 1, userEntry			#check whether to populate it with user values or not.
	
	autoEntry:
		li $t2, 1			#t2 is the first integer
		li $t0, 0 			#t0 is the counter
		move $t1, $s1 			#t1 is the address pointer
		loop1:
			beq $t0, $s2, endloop1 	#count up to all elements
			sw $t2 0($t1)
			addi $t1, $t1, 4
			addi $t0, $t0, 1
			addi $t2, $t2, 1 
			j loop1 			#increment and jump back
		endloop1:
	
		li $v0, 4
		la $a0, msg4
		syscall	
		j finish
	
	userEntry:
		#enter values message
		li $v0, 4
		la $a0, msg3
		syscall		
		
		li $t0, 0 			#t0 is the counter
		move $t1, $s1 			#t1 is the address pointer
		loop:
			beq $t0, $s2, endloop 	#count up to all elements
			
			#tell when new row starts
			div $t0, $s0
			mfhi $t7
			beqz $t7, meso
			here:
			
			li $v0, 5
			syscall			#get the integer for this location
			sw $v0, 0($t1)
			addi $t1, $t1, 4
			addi $t0, $t0, 1
			j loop 			#increment and jump back
			
			meso: #special message that indicated new row
				li $v0, 4
				la $a0, msg5
				syscall
				j here
			
		endloop:
		j finish


	finish:
		lw   $ra, 0($sp)
    		lw   $s0, 4($sp) 
   		lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   		lw   $s2, 12($sp)
 		lw   $s3, 16($sp)
   		addi $sp, $sp, 20
   		jr $ra
   		
   		
 getNumber:
 
 	##################################
 	#gets row and column arguments in a2, and a1 respectively
 	#returns the number in v0
 	################################
 	#move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
	

	move $t0, $a2 		#t0 has the row number

	move $t1, $a1 		#t0 has the col number
	
	#t8 has the offset
	
	subi $t3, $t0, 1	#row - 1
	subi $t4, $t1, 1	#col - 1
 	
 	mul $t3, $t3, $s0	# (row - 1) * N
 	mul $t3, $t3, 4		# (row - 1) * N * 4
 	
 	mul $t4, $t4, 4		# (col - 1) * N * 4
 	
 	add $t8, $t3, $t4	#offset
 	
 	#t5 has the address
 	add $t5, $s1, $t8	#address of the location
 	
 	lw $t6, 0($t5)		#a0 has the item
 	
 	move $v0, $t6 		#return the number
 	#move stack
 	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
  	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
   	addi $sp, $sp, 20
   	jr $ra
 
 
 printArray:
 	 #move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
 	
 	li $t0, 0 			#t0 is the counter
	move $t1, $s1 			#t1 is the address pointer
	loop2:
		beq $t0, $s2, endloop2	#count up to all elements
		#tell when new row starts
		div $t0, $s0
		mfhi $t7
		beqz $t7, row
		here1:
		
		#print the number
		lw $a0, 0($t1)
		li $v0, 1
		syscall 
		#print the Dash
		
		li $v0, 4
		la $a0, dash
		syscall
		
		addi $t1, $t1, 4
		addi $t0, $t0, 1
		j loop2 			#increment and jump back
		
		row: 			#nextRow
			li $v0, 4
			la $a0, nxt
			syscall
			j here1
			
	endloop2:

	
	#Move Stack
	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
   	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
  	addi $sp, $sp, 20
  	jr $ra
   		


 trace:
  	 #move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
 	
 	#a1 and a2 are used as arguments for getNumber
 	li $a2, 1 		#row number
 	li $a1, 1		#col number
 	li $t2, 0		#Loop counter
 	li $v1, 0		#total
 	loop3:
 	#use the getNumber to calculate trace
 	beq $t2, $s0, endloop3
 	bgt $t2, $s0, endloop3
 	jal getNumber
 	add $v1, $v1, $v0	#number at traced location received in v0
 	addi $a2, $a2, 1
 	addi $a1, $a1, 1
 	addi $t2, $t2, 1
 	j loop3
 	endloop3:
 	
 	
 	#Move Stack
	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
   	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
  	addi $sp, $sp, 20
  	jr $ra
   		
 	
 trace2:
 	 #move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
 	
 	#a1 and a2 are used as arguments for getNumber
 	li $a2, 1 		#row number
 	move $a1, $s0		#col number
 	li $t2, 0		#Loop counter
 	li $v1, 0		#total
 	loop4:
 	#use the getNumber to calculate trace
 	beq $t2, $s0, endloop4
 	bgt $t2, $s0, endloop4
 	jal getNumber
 	add $v1, $v1, $v0	#number at traced location received in v0
 	addi $a2, $a2, 1
 	addi $a1, $a1, -1
 	addi $t2, $t2, 1
 	j loop4
 	endloop4:
 	
 	
 	#Move Stack
	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
   	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
  	addi $sp, $sp, 20
  	jr $ra
 

 rowSum:
 	 	 #move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
	
 	li $t2, 0		#row counter
 	li $v1, 0		#total
 	move $t4, $s1		#start address
 	li $t6, 0		#prev rows sum
 	#going row by row to calculate sum
 	
 	#print message for each row sum
 	li $v0, 4
	la $a0, msg11
	syscall	
 	
 	loop5:			#Row Loop
 	beq $t2, $s0, endloop5
 	li $t3, 0		#column counter
 	
		loop6:		#Column Loop
		beq $t3, $s0, endloop6
		lw $t5, 0($t4) 		#obtain the item in the row
		add $v1, $v1, $t5 	#add this item to the total
		addi $t4, $t4, 4
		addi $t3, $t3, 1
		 j loop6 
		endloop6:
	sub $t7, $v1, $t6 	#get sum for this row specifically
	move $t6, $v1		#make this the previous rows sum
	#print row sum
	li $v0, 1
	move $a0,$t7
	syscall
	#go to next line
	li $v0, 4
	la $a0, nxt
	syscall	
 	addi $t2, $t2, 1	#increment loop
 	j loop5
 	endloop5:
 	
 	#print total sum message
 	li $v0, 4
	la $a0, msg10
	syscall
	#print the sum of all rows
	li $v0, 1
	move $a0,$v1
	syscall

 	#Move Stack
	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
   	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
  	addi $sp, $sp, 20
  	jr $ra
 	
 
 colSum:
 	#move stack
	addi $sp, $sp, -20 
  	sw   $ra, 0($sp)
    	sw   $s0, 4($sp)
   	sw   $s1, 8($sp)
	sw   $s2, 12($sp) #STORE EVERYTHING TO STACK
	sw   $s3, 16,($sp)
	
 	li $t2, 0		#col counter
 	li $v1, 0		#total
 	move $t4, $s1		#start address
 	li $t6, 0		#prev rows sum
 	#going row by row to calculate sum
 	
 	mul $t8, $s0,4 		#gap to next row
 	move $t0, $s1		#col start address
 	#print message for each row sum
 	li $v0, 4
	la $a0, msg13
	syscall	
 	
 	loop7:			#Row Loop
 	beq $t2, $s0, endloop7
 	li $t3, 0		#row counter
 	move $t4, $t0		#new row start address
		loop8:		#Column Loop
		beq $t3, $s0, endloop8
		lw $t5, 0($t4) 		#obtain the item in the row
		add $v1, $v1, $t5 	#add this item to the total
		add $t4, $t4, $t8	#increment to next row
		addi $t3, $t3, 1
		 j loop8 
		endloop8:
		
	sub $t7, $v1, $t6 	#get sum for this col specifically
	move $t6, $v1		#make this the previous col sum
	#print col sum
	li $v0, 1
	move $a0,$t7
	syscall
	#go to next line
	li $v0, 4
	la $a0, nxt
	syscall	
 	addi $t2, $t2, 1	#increment loop
 	addi $t0, $t0, 4	#go to next column
 	j loop7
 	endloop7:
 	
 	#print total sum message
 	li $v0, 4
	la $a0, msg12
	syscall
	#print the sum of all cols
	li $v0, 1
	move $a0,$v1
	syscall

 	#Move Stack
	lw   $ra, 0($sp)
    	lw   $s0, 4($sp) 
   	lw   $s1, 8($sp) #RETURN VARIABLES FROM THE STACK
   	lw   $s2, 12($sp)
 	lw   $s3, 16($sp)
  	addi $sp, $sp, 20
  	jr $ra
 
 