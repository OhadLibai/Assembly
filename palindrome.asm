# check if user provided string is palindrome

.data

userInput: .space 64
stringAsArray: .space 256

welcomeMsg: .asciiz "Enter a string: "
calcLengthMsg: .asciiz "Calculated length: "
newline: .asciiz "\n"
yes: .asciiz "The input is a palindrome!"
no: .asciiz "The input is not a palindrome!"
notEqualMsg: .asciiz "Outputs for loop and recursive versions are not equal"

.text

main:

	li $v0, 4
	la $a0, welcomeMsg
	syscall
	la $a0, userInput
	li $a1, 64
	li $v0, 8
	syscall

	li $v0, 4
	la $a0, userInput
	syscall
	
	# convert the string to array format
	la $a1, stringAsArray
	jal string_to_array
	
	addi $a0, $a1, 0
	
	# calculate string length
	jal get_length
	addi $a1, $v0, 0
	
	li $v0, 4
	la $a0, calcLengthMsg
	syscall
	
	li $v0, 1
	addi $a0, $a1, 0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	la $a0, stringAsArray
	
	# Swap a0 and a1
	addi $t0, $a0, 0
	addi $a0, $a1, 0
	addi $a1, $t0, 0
	addi $t0, $zero, 0
	
	# Function call arguments are caller saved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	
	# check if palindrome with loop
	jal is_pali_loop
	
	# Restore function call arguments
	lw $a0, 4($sp)
	lw $a1, 0($sp)
	addi $sp, $sp, 8
	
	addi $s0, $v0, 0
	
	# check if palindrome with recursive calls
	jal is_pali_recursive
	bne $v0, $s0, not_equal
	
	beq $v0, 0, not_palindrome

	li $v0, 4
	la $a0, yes
	syscall
	j end_program

	not_palindrome:
		li $v0, 4
		la $a0, no
		syscall
		j end_program
	
	not_equal:
		li $v0, 4
		la $a0, notEqualMsg
		syscall
		
	end_program:
	li $v0, 10
	syscall
	
string_to_array:	
	add $t0, $a0, $zero
	add $t1, $a1, $zero
	addi $t2, $a0, 64

	
	to_arr_loop:
		lb $t4, ($t0)
		sw $t4, ($t1)
		
		addi $t0, $t0, 1
		addi $t1, $t1, 4
	
		bne $t0, $t2, to_arr_loop
		
	jr $ra


#################################################
#         DO NOT MODIFY ABOVE THIS LINE         #
#################################################
	
get_length:
	# $t1 == length, $t2 == index, $t3 == curr char
	lb $t0, newline
	
	#initialization step:
	add $t1, $zero, $zero
	addi $t2, $a0, 0
	lw $t3, 0($t2)
	
	len_loop: beq $t0, $t3, finish_get_length
		addi $t1, $t1, 1
		addi  $t2, $t2, 4
		lw $t3, 0($t2)
		j len_loop
	
	finish_get_length: addi $v0, $t1,0	
		jr $ra
	
is_pali_loop:
	# $t1 == left pointer, $t2 == right pointer, $t3 == left char , $t4 == right char
	
	#base case len==0
	beq $a0, $zero, pali
	
	#initialize:
	addi $t8,$zero, -4
	addi $t7, $a0, 0
	
	add_4_loop: addi $t8, $t8, 4
		    addi $t7, $t7, -1
	bne $zero, $t7, add_4_loop
	add $t2, $a1, $t8
	
	add $t1 , $a1, $zero 
	
	lw $t3, 0($t1)
	lw $t4, 0($t2)
	
	# checking palindrome
	loop: beq $a1,$t2, pali # can be sliced to half, but this way does not require using slti plus additional registers
	bne $t3,$t4, not_pali
	addi $t1, $t1, 4
	addi $t2, $t2, -4
	lw $t3 , 0($t1)
	lw $t4 , 0 ($t2)
	j loop
	
	pali: addi $v0, $zero, 1
		j finish_pali_loop
	not_pali: addi $v0 , $zero, 0
		j finish_pali_loop
	
	finish_pali_loop: jr $ra
	
	
is_pali_recursive:
	# string of length 0 case
	bne $a0, 0, check_R_pointer_recursively
	addi $v0, $zero, 1
	jr $ra
	
	check_R_pointer_recursively:
	bne $t9 ,$zero after_R_pointer_recursively
	addi $t9, $a0, 0
	addi $t8, $a1, -4
	
	#adjustments
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal R_pointer_recursively #recurse on R_pointer
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	
	
	addi $t2, $t8,0
	addi $t1, $a1, 0
	addi $v0, $zero, 1
	
	after_R_pointer_recursively:
	bne $a1,$t2, not_done
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	j finish_pali_recursive
	
	not_done:
	beq $t3,$t4, continue_recurse
	addi $v0, $v0,-1
	
	continue_recurse:
	lw $t3 , 0($t1)
	lw $t4 , 0 ($t2)	
	addi $t1, $t1, 4
	addi $t2, $t2, -4
	
	#adjustments
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal is_pali_recursive #recurse
		
	finish_pali_recursive: 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

R_pointer_recursively:
	bne $t9,$zero, finish_R_pointer
	
	addi $t9,$t9, -1
	addi $t8,$t8,4
	
	#adjustments
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal R_pointer_recursively #recurse
	
	finish_R_pointer: 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra