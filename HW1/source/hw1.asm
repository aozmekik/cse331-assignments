.data 
inputfile: .asciiz "input.txt"
buffer: .space 128 	# Buffer size can be modified regarding to input
delimeter: .ascii "\n"
endfile:  .ascii ";"
removed: .ascii "X" 	# Junk value to represent removed item

I: .space 32		# Resultant
X: .word 0		# Starting address of X
S: .word 0		# Starting address of sets


.text
j main

findAddressOfSets: 			# Handle input like function, sets the addresses for X and S
la $t0, buffer	
lb $t1, delimeter
sw $t0, X
iterateS: 	addi $t0, $t0, 1	# Next item's address
	  	lb $t2, ($t0)		# Get item from address 
	  	beq $t1, $t2, exit 	# if char is '\n', exit
	  	j iterateS
exit:     	addi $t0, $t0, 1
	  	sw $t0, S
	  	jr $ra

findNumberOfSets:  # $v0 = n, n is the number of Sets (excluding X)
lw $t0, S
move $t1, $zero
lb $t4, delimeter
lb $t5, endfile
iterateCountingSets:	addi $t0, $t0, 1
			lb $t3, ($t0)
			beq $t4, $t3, incCounterSets
			beq $t5, $t3, retCountingSets
			j iterateCountingSets
incCounterSets: 	addi $t1, $t1, 1
			j iterateCountingSets
retCountingSets:	move $v0, $t1
			jr $ra	 

xIsEmpty:	# Returns 0 if X is empty, 1 if not.
lw $t0, X
lb $t1, removed
move $t2, $zero
lb $t4, delimeter
li $t5, 0x2C
iterateX:	lb $t3, ($t0)		 	# Get item
		addi $t0, $t0, 1 
		beq $t1, $t3, iterateX		# 'X' == $t3
		beq $t5, $t3, iterateX		# pass ',' == $t3
		beq $t4, $t3, retXIsEmpty	# '\n' == $t3, end of the X
		li $t2, 1			# not empty
retXIsEmpty: 	move $v0, $t2 		        # Return flag (0 = empty, 1 = not empty)	
		jr $ra


getNthSet: 	# $a0 = j, returns $v0 = address of Sj 
lw $t0, S
move $t1, $zero
lb $t2, delimeter
iterateSets: 	beq $a0, $t1, retGetNthSet
		addi $t0, $t0, 1
		lb $t3, ($t0)
		beq $t2, $t3, incCounterN	# '\n' == $t3, end of one set
		j iterateSets
incCounterN:	addi $t1, $t1, 1
		addi $t0, $t0, 1 		# pass '\n'  
		j iterateSets
retGetNthSet:	move $v0, $t0
		jr $ra		

removeItemsX: 					# $a0 = n, removes items of Sj from X
addi $sp, $sp, -4				# allocate stack frame
sw $ra, ($sp)					# save ret address
lw $t0, X
lb $t3, delimeter
move $t1, $a0
jal getNthSet
iterateRemoveItemsX: 	lb $a0, ($v0)	 			# Get item from Sj
			beq $a0, $t3, retRemoveItemsX		
			jal removeItemX		
			addi, $v0, $v0, 1			# Next item
			j iterateRemoveItemsX
retRemoveItemsX: 	lw, $ra, ($sp)				# load ret address
			addi $sp, $sp, 4			# Free stack frame
			jr $ra

removeItemX:		# Remove $a0 from X, no action if doesn't exist 
lw $t0, X
lb $t1, removed
lb $t3, delimeter
li $t4, 0x2C  	# ',' 
beq $a0, $t4, retRemoveItemX
iterateRemoveItemX: 	lb $t2, ($t0)
			beq $t2, $t3, retRemoveItemX
			beq $t2, $a0, removeItem	# If $a0 exists on X, remove it.
			addi $t0, $t0, 1
			j iterateRemoveItemX 
removeItem:		sb $t1, ($t0)			# Put 'X' to file to indicate removed item.
retRemoveItemX: 	jr $ra

addItemI:		# add $a0 to set I
la $t0, I
li $t1, 0x2C 	# ','
iterateAddItemI:	lb $t3, ($t0)
			beq $t1, $t3, iterate2AddItemI 		# ',' delimeter found.
			j retAddItemI
iterate2AddItemI:	addi $t0, $t0, 2			#  pass both ',' and the number.
			j iterateAddItemI
			
retAddItemI:		sb $t1, ($t0)				# put ','
			addi $t0, $t0, 1
			sb $a0, ($t0)  				# put the number. 
			jr $ra


itemExistInX:		# Returns 0 if item exists in X
lw $t0, X
lb $t1, delimeter
iterateItemExistInX: 	lb $t3, ($t0)
			beq $t3, $t1, notExistInX
			beq $t3, $a0, existInX
			addi $t0, $t0, 1
			j iterateItemExistInX 	
existInX:		move $v0, $zero				# $v0 = 0 if item exists.
			jr $ra
notExistInX:		move $v0, $a0				# $v0 = $a0 if item does not exist.
			jr $ra 


d_j:			# $a0 = j, returns $v0 = length of intersection Sj and X	
addi $sp, $sp, -24
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
lw $s0, X
move $s2, $zero						# zeroed counter
lb $s3, delimeter
li $s4, 0x2C 						# ','
jal getNthSet						# $a0 is given
move $s1, $v0						# address of Sj
iterateD_j: 		lb $a0, ($s1)			# get item from Sj
			beq $a0, $s4, continueD_j	# pass ','
			beq $a0, $s3, retD_j
			jal itemExistInX
			beq $v0, $zero, incLength
continueD_j:		addi $s1, $s1, 1	
			j iterateD_j
incLength:		addi $s2, $s2, 1
			j continueD_j
retD_j:			move $v0, $s2			# ret $v0 = len (Sj intersection X)
			lw $ra, ($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			lw $s4, 20($sp)
			addi $sp, $sp, 24
			jr $ra
			 


argmax:					# ret $v0 = argmax d_j
addi $sp, $sp, -24
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)	
move $s0, $zero 			# $s0 = i
move $s2, $zero				# max result
move $s3, $zero 			# argmax
jal findNumberOfSets
move $s4, $v0				# n, number of sets.
iterateArgmax:		move $a0, $s0
			jal d_j
			move $s1, $v0				# $s1 = d(i)
			bgt $s1, $s2, changeMax 		# d(i) > maxd, hence maxd = d(i)
			addi $s0, $s0, 1			# incr i
			beq  $s4, $s0, retArgmax		# i == n, terminate
			j iterateArgmax
			
changeMax:		move $s2, $s1				# d(i) = maxd
			move $s3, $s0 				# argmax = i
			j iterateArgmax
			
retArgmax:		move $v0, $s3  				# return argmax
			lw $ra, ($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			lw $s4, 20($sp)
			addi $sp, $sp, 24
			jr $ra

greedySetCover:		# greedySetCover algorithm implementation
addi $sp, $sp, -16
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
la $s0, I				# $s0 = I
#sw $zero, ($s0)			# I = 0
li $s1, 1				# $s1 emptyness flag X, (empty: $s1 = 0)
move $s2, $zero				# $s2 = j
iterateSetCover:	jal argmax
			move $s2, $v0		# j = argmax d(i)
			move $a0, $s2	
			jal addItemI		# put j into I
			jal removeItemsX	# remove Sj from X
			jal xIsEmpty
			move $s1, $v0		# set s1 flag
			beqz $s1, retSetCover
			j iterateSetCover
			
retSetCover:		lb $a0, endfile
			jal addItemI 		# put end delimeter to end of I 
			move $v0, $s0
			lw $ra, ($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			addi $sp, $sp, 16
			jr $ra
			
printI:			# prints I to screen
la $t0, I
li $t1, 0x2C
lb $t5, endfile	
li $t4, 48					# num to ascii character number offset (2 + 48 = '2')
iteratePrintI:		lb $t3, ($t0)
			beq $t3, $t1, nextItemI
			beq $t3, $t5, retPrintI
			addi $t3, $t3, 48
			sb $t3, ($t0) 
nextItemI:		addi $t0, $t0, 1
			j iteratePrintI

retPrintI:		la $a0, I
			li $v0, 4	 	# syscall : print I 
			syscall 
			jr $ra

main:
# Open file
li $v0, 13 		# syscall for open file syscall
la $a0, inputfile
li $a1, 0		# flag for read 
li $a2, 0
syscall
move $s0, $v0 		# save fd

# Read file
li $v0, 14		# syscall for read file
move $a0, $s0		# file descriptor
la   $a1, buffer
li   $a2, 128
syscall

# Print file
li $v0, 4
la $a0, buffer
syscall
jal findAddressOfSets	# handle input
jal greedySetCover	# call min set cover algorithm
jal printI		# print I for to see result







# Close file
li $v0, 16		
move $a0, $s0		# fd
syscall

	  





