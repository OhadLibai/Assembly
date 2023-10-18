.data

inMsg: .asciiz "Enter a number: "
msg: .asciiz "Calculating F(n) for n = "
fibNum: .asciiz "\nF(n) is: "
.text

main:

	li $v0, 4
	la $a0, inMsg
	syscall

	# take input from user
	li $v0, 5
	syscall
	addi $a0, $v0, 0
	
	jal print_and_run
	
	# exit
	li $v0, 10
	syscall

print_and_run:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	add $t0, $a0, $0 

	# print message
	li $v0, 4
	la $a0, msg
	syscall

	# take input and print to screen
	add $a0, $t0, $0
	li $v0, 1
	syscall

	jal fib

	addi $a1, $v0, 0
	li $v0, 4
	la $a0, fibNum
	syscall

	li $v0, 1
	addi $a0, $a1, 0
	syscall
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

#################################################
#         DO NOT MODIFY ABOVE THIS LINE         #
#################################################	
	
fib:	
	#base case
	beq $a0, $zero, exit_0
	addi $t4, $zero, 1
	beq $t4, $a0, exit_1
	
	# initialize registers for prev_prev == $t0,prev == $t1, curr == $t2, counter==$t5
	addi $t0 ,$zero, 0
	addi $t1, $zero, 1
	addi $t2, $zero, 0
	addi $t5, $zero, 1
	fib_loop: beq $t5 , $a0, exit_fib_loop
		#the fib step
		add $t2, $t0,$t1
		add $t0, $zero,$t1
		add $t1, $zero, $t2
		
		addi $t5, $t5, 1
		j fib_loop
	
	exit_0: addi $v0, $zero, 0
		j finish
	exit_1: addi $v0, $t4, 0
		j finish
	exit_fib_loop: add $v0, $zero, $t2
		j finish
	  
	finish:
		jr $ra