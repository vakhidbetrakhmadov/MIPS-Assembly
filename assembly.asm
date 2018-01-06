# Author: Vakhid Betrakhmadov
# 20.10.2017
################################

.data

buffer: .space 45
dot: .asciiz "."
newline: .asciiz "\n"
minus_sign: .asciiz "-"
 
.text

Main:
	# Take input string #

	li $v0, 8 # "read string" command
	la $a0, buffer # into input buffer
	li $a1, 45 # of size
	syscall

	# Parse input string into 4 integers and sign character #

	la $s0, buffer # buffer_ptr = buffer

 	move $a0 ,$s0 # arg1 = buffer_ptr
	jal Count # digits = Count(buffer_ptr)
	move $a0, $s0 # arg1 = buffer_ptr
	move $a1, $v0 # arg2 = digits
	add $s0, $s0, $v0 # buffer_ptr += digits
	addi $s0, $s0, 1 # buffer_ptr += 1 (dot character)
	jal Stoi # int_value = Stoi(buffer_ptr, digits)
	move $s4, $v0 # int1_int = int_value

	move $a0 ,$s0 # arg1 = buffer_ptr
	jal Count # digits = Count(buffer_ptr)
	move $a0, $s0 # arg1 = buffer_ptr
	move $a1, $v0 # arg2 = digits
	add $s0, $s0, $v0 # buffer_ptr += digits
	addi $s0, $s0, 1 # buffer_ptr += 1 (space charcter)
	move $s2, $v0 # int1_float_digits = digits
	jal Stoi # int_value = Stoi(buffer_ptr, digits)
	move $s5, $v0 # int1_float = int_value

	lbu $s1, 0($s0) # sign = *buffer_ptr (+ or - or *)
	addi $s0, $s0, 2 # buffer_ptr += 2 (sign and space characters)

	move $a0 ,$s0 # arg1 = buffer_ptr
	jal Count # digits = Count(buffer_ptr)
	move $a0, $s0 # arg1 = buffer_ptr
	move $a1, $v0 # arg2 = digits
	add $s0, $s0, $v0 # buffer_ptr += digits
	addi $s0, $s0, 1 # buffer_ptr += 1 (dot character)
	jal Stoi # int_value = Stoi(buffer_ptr, digits)
	move $s6, $v0 # int2_int = int_value

	move $a0 ,$s0 # arg1 = buffer_ptr
	jal Count # digits = Count(buffer_ptr)
	move $a0, $s0 # arg1 = buffer_ptr
	move $a1, $v0 # arg2 = digits
	move $s3, $v0 # int2_float_digits = digits
	jal Stoi # int_value = Stoi(buffer_ptr, digits)
	move $s7, $v0 # int2_float = int_value

	# Prepare all argumets for subroutine call #

	move $a0, $s4 # arg1 = int1_int
	move $a1, $s5 # arg2 = int1_float
	move $a2, $s6 # arg3 = int2_int
	move $a3, $s7 # arg4 = int2_float

	addi $sp, $sp, -8 # make room on stack for two more argumets
	sw $s3, 4($sp) # push int2_float_digits on the stack
	sw $s2, 0($sp) # push int1_float_digits on the stack

	# Select subroutine to be called based on the sign character #

	li $t0, '+' # plus = '+'
	li $t1, '-' # minus = '-'
	beq $s1, $t0, if_sign_plus # if sign == plus; Go to if_sign_plus
	beq $s1, $t1, if_sign_minus # if sign == minus; Go to if_sign_minus

#if_sign_multiplication
	jal Mul

# Figure out number of digits after the dot if multiplication # 
	add $t0, $s2, $s3 # digits_after_dot = int1_float_digits * int2_float_digits
# END Figure out number of digits after the dot if multiplication # 

	j if_sign_exit
if_sign_plus:
	jal Add

# Figure out number of digits after the dot if plus # 
	ble $s2, $s3, if_less1 # if int1_float_digits < int2_float_digits; Go to if_less
	move $t0, $s2 # digits_after_dot = int1_float_digits
	j if_less1_exit
if_less1:
	move $t0, $s3 # digits_after_dot = int2_float_digits
if_less1_exit:
# END Figure out number of digits after the dot if plus# 

	j if_sign_exit
if_sign_minus:
	jal Sub

# Figure out number of digits after the dot if minus # 
	ble $s2, $s3, if_less2 # if int1_float_digits < int2_float_digits; Go to if_less
	move $t0, $s2 # digits_after_dot = int1_float_digits
	j if_less2_exit
if_less2:
	move $t0, $s3 # digits_after_dot = int2_float_digits
if_less2_exit:
# END Figure out number of digits after the dot if minus # 

if_sign_exit:
	
	# Output results #

	move $a0, $v0 # arg1 = ans_int
	move $a1, $v1 # arg1 = ans_float
	move $a2, $t0 # arg1 = digits_after_dot

	jal Print_output

	addi $sp, $sp, 8 # close room on stack

	li $v0, 10
	syscall


#################################################################################################################################################
# arguments: $a0 - ans_int, $a1 - ans_float, $a2 - digits_after_dot
Print_output:
	addi $sp, $sp, -4 # save return adress on stack
	sw $ra, 0($sp)

	move $t9, $a0 # copy ans_int into $t9
	blt $t9, $zero, answer_is_negative # if ans_int < 0; Go to answer_is_negative
	blt $a1, $zero, answer_is_negative # if ans_float < 0; Go to answer_is_negative
	j answer_is_positive # otherwise; Go to answer_is_positive
answer_is_negative:
	# Print minus sign #
	li $v0, 4
	la $a0, minus_sign 
	syscall

	# Get absolute values of ans_int and ans_float #
	move $t0, $t9 # temp = ans_int
	li $t1, -2 # two = -2
	mul $t9, $t9, $t1 # ans_int = ans_int * (-2)
	add $t9, $t9, $t0 # ans_int = ans_int + temp

	move $t0, $a1 # temp = ans_int
	li $t1, -2 # two = -2
	mul $a1, $a1, $t1 # ans_int = ans_int * (-2)
	add $a1, $a1, $t0 # ans_int = ans_int + temp
	# END Get absolute values of ans_int and ans_float #
answer_is_positive:
	# Print ans_int #
	move $a0, $t9
	li $v0, 1
	syscall
	# Print dot #
	li $v0, 4
	la $a0, dot
	syscall

	# Count digits in ans_float part #
	addi $sp, $sp, -8
	sw $a1, 4($sp)
	sw $a2, 0($sp)

	move $a0, $a1
	jal Count_int # digits = Count_int(ans_float)
	
	lw $a2, 0($sp)
	lw $a1, 4($sp)
	addi $sp, $sp, 8
	# END Count digits in ans_float part #

	beq $a2, $v0, print_zero_loop_exit # if digits == digits_after_dot; Go to print_zero_loop_exit
	sub $a2, $a2, $v0 # zeros_to_print = digits_after_dot - digits

	# Print zeros #
	li $t0, 0 # i = 0
	li $a0, 0
	li $v0, 1
print_zero_loop:
	beq $t0, $a2, print_zero_loop_exit
	addi $t0, $t0, 1
	syscall
	j print_zero_loop
print_zero_loop_exit:
	
	# Print ans_float #
	move $a0, $a1
	li $v0, 1
	syscall

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra

#################################################################################################################################################
# arguments: $a0 - an integer
# returns: $v0 - digits in the integer
Count_int:
	li $v0, 1
	li $t0, 10

count_int_loop:
	blt $a0, $t0, count_int_loop_exit
	addi $v0, $v0, 1
	div $a0, $t0
	mflo $a0
	j count_int_loop

count_int_loop_exit:
	jal $ra

#################################################################################################################################################
# arguments: $a0 - int1_int, $a1 - int1_float, $a2 - int2_int, $a3 - int2_float
# returns: $v0 - ans_int, $v1 - ans_float
Mul:
	lw $t0, 0($sp) # int1_float_digits = *($sp + 0)
	lw $t1, 4($sp) # int2_float_digits = *($sp + 4)

	addi $sp, $sp, -28 # make room on stack for 7 registers
	sw $ra, 24($sp) # save $ra on stack
	sw $s5, 20($sp) # save $s5 on stack
	sw $s4, 16($sp) # save $s4 on stack
	sw $s3, 12($sp) # save $s3 on stack
	sw $s2, 8($sp) # save $s2 on stack
	sw $s1, 4($sp) # save $s1 on stack
	sw $s0, 0($sp) # save $s0 on stack

	move $s0, $t0 # int1_float_digits
	move $s1, $t1 # int2_float_digits
	move $s2, $a0 # int1_int
	move $s3, $a1 # int1_float
	move $s4, $a2 # int2_int
	move $s5, $a3 # int2_float

	li $a0, 10 # arg1 = 10
	move $a1, $s0 # arg2 = int1_float_digits
	jal Pow # pow(10,int1_float_digits)
	mul $s2, $s2, $v0 # int1_int *= pow(10,int1_float_digits)
	add $s2, $s2, $s3 # int1_int += int1_float

	li $a0, 10 # arg1 = 10
	move $a1, $s1 # arg2 = int2_float_digits
	jal Pow # pow(10,int2_float_digits)
	mul $s4, $s4, $v0 # int2_int *= pow(10,int2_float_digits)	
	add $s4, $s4, $s5 # int2_int += int2_float

	add $t0, $s0, $s1 # int1_float_digits + int2_float_digits
	li $a0, 10 # arg1 = 10
	move $a1, $t0 # arg2 = int1_float_digits + int2_float_digits
	jal Pow # pow(10,int1_float_digits + int2_float_digits)
	mul $t0,$s2,$s4 # int1_int * int2_int
	div $t0, $v0 # (int1_int * int2_int) / pow(10,int1_float_digits + int2_float_digits)

	mflo $v0
	mfhi $v1

	lw $s0, 0($sp) # save $s0 on stack
	lw $s1, 4($sp) # save $s1 on stack
	lw $s2, 8($sp) # save $s2 on stack
	lw $s3, 12($sp) # save $s3 on stack
	lw $s4, 16($sp) # save $s4 on stack
	lw $s5, 20($sp) # save $s5 on stack
	lw $ra, 24($sp) # save $ra on stack
	addi $sp, $sp, 28 # close room on stack 

	jr $ra

#################################################################################################################################################
# arguments: $a0 - int1_int, $a1 - int1_float, $a2 - int2_int, $a3 - int2_float
# returns: $v0 - ans_int, $v1 - ans_float
Sub:
	lw $t9, 0($sp) # pop int1_float_digits from the stack
	lw $t8, 4($sp) # pop int2_float_digits from the stack
	addi $sp, $sp, 8 # close room on stack

	addi $sp, $sp, -12  # make room on stack for 3 registers
	sw $ra, 8($sp) # push $ra on stack
	sw $t8, 4($sp) # push int2_float_digits on stack
	sw $t9, 0($sp) # push int1_float_digits on stack

	li $t0, 2
	mul $t1, $a2, $t0 # int2_int * 2
	sub $a2, $a2, $t1 # int2_int -= (int2_int * 2)
	mul $t1, $a3, $t0 # int2_float * 2
	sub $a3, $a3, $t1 # int2_float -= (int2_float * 2)

	jal Add

	lw $t9, 0($sp) # pop int1_float_digits from the stack 
	lw $t8, 4($sp) # pop int2_float_digits from the stack
	lw $ra, 8($sp) # pop $ra from the stack
	addi $sp, $sp, 12 # close room on stack

	addi $sp, $sp, -8  # make room on stack for 2 registers
	sw $t8, 4($sp) # push int2_float_digits on stack
	sw $t9, 0($sp) # push int1_float_digits on stack

	jr $ra

#################################################################################################################################################
# arguments: $a0 - int1_int, $a1 - int1_float, $a2 - int2_int, $a3 - int2_float
# returns: $v0 - ans_int, $v1 - ans_float
Add: 
	lw $t0, 0($sp) # int1_float_digits = *($sp + 0)
	lw $t1, 4($sp) # int2_float_digits = *($sp + 4)

	addi $sp, $sp, -28 # make room on stack for 7 registers
	sw $ra, 24($sp) # save $ra on stack
	sw $s5, 20($sp) # save $s5 on stack
	sw $s4, 16($sp) # save $s4 on stack
	sw $s3, 12($sp) # save $s3 on stack
	sw $s2, 8($sp) # save $s2 on stack
	sw $s1, 4($sp) # save $s1 on stack
	sw $s0, 0($sp) # save $s0 on stack

	move $s0, $t0 # int1_float_digits
	move $s1, $t1 # int2_float_digits
	move $s2, $a0 # int1_int
	move $s3, $a1 # int1_float
	move $s4, $a2 # int2_int
	move $s5, $a3 # int2_float

	beq $s0, $s1, if_exit # if int1_float_digits == int2_float_digits; Go to if_exit
	blt $s0, $s1, if # if int1_float_digits < int2_float_digits; Go to if
#else 
	sub $t0, $s0, $s1 # power = int1_float_digits - int2_float_digits
	li $a0, 10 # arg1 = 10
	move $a1, $t0 # arg2 = power
	jal Pow
	mul $s5, $s5, $v0 # int2_float = int2_float * pow(10,power)
	move $t0, $s0 # max_float_digits = int1_float_digits
	j if_exit
if:
	sub $t0, $s1, $s0 # power = int2_float_digits - int1_float_digits
	li $a0, 10 # arg1 = 10
	move $a1, $t0 # arg2 = power
	jal Pow
	mul $s3, $s3, $v0 # int1_float = int1_float * pow(10,power)
	move $t0, $s1 # max_float_digits = int2_float_digits
if_exit: 															# $t0 = max_float_digits #
	li $a0, 10 # arg1 = 10
	move $a1, $t0 # arg2 = max_float_digits
	jal Pow # pow(10,max_float_digits)
	mul $s2, $s2, $v0 # int1_int *= pow(10,max_float_digits)
	mul $s4, $s4, $v0 # int2_int *= pow(10,max_float_digits)
	add $s2, $s2, $s3 # int1_int += int1_float
	add $s4, $s4, $s5 # int2_int += int2_float

	add $t0, $s2, $s4 # int1_int + int2_int
	div $t0, $v0 # (int1_int + int2_int) / pow(10,max_float_digits)

	mflo $v0
	mfhi $v1

	lw $s0, 0($sp) # save $s0 on stack
	lw $s1, 4($sp) # save $s1 on stack
	lw $s2, 8($sp) # save $s2 on stack
	lw $s3, 12($sp) # save $s3 on stack
	lw $s4, 16($sp) # save $s4 on stack
	lw $s5, 20($sp) # save $s5 on stack
	lw $ra, 24($sp) # save $ra on stack
	addi $sp, $sp, 28 # close room on stack 

	jr $ra

#################################################################################################################################################
# arguments: $a0 - buffer (string representation of an int) , $a1 - digits (number of digits in the int)
# returns: $v0 - int as integer
Stoi:
	addi $sp, $sp, -28 # make room on stack for 7 registers
	sw $ra, 24($sp) # save $ra on stack
	sw $s5, 20($sp) # save $s5 on stack
	sw $s4, 16($sp) # save $s4 on stack
	sw $s3, 12($sp) # save $s3 on stack
	sw $s2, 8($sp) # save $s2 on stack
	sw $s1, 4($sp) # save $s1 on stack
	sw $s0, 0($sp) # save $s0 on stack

	li $s0, 0 # i = 0 
	li $s1, 0 # answer = 0
	addi $s2, $a1, -1 # power = digits - 1
	move $s3, $a0 # buffer_cp = buffer
	move $s4, $a1 # digits_cp = digits
loop_stoi:
	slt $t0, $s0, $s4 # $t0 = (i < digits_cp)
	beq $t0, $zero, loop_exit_stoi # if $t0 == 0; exit loop
	lbu $s5, 0($s3) # next_digit = *buffer_cp 
	addiu $s5, $s5, -48 # next_digit -= 48 (48 is '0' ASCII code)
	li $a0, 10 # base = 10
	move $a1, $s2 # power_value = power
	jal Pow
	mul $s5, $s5, $v0 # next_digit = next_digit * 10^power
	add $s1, $s1, $s5 # answer += next_digit
	addi $s2, $s2, -1 # --power
	addi $s3, $s3, 1 # ++ buffer_cp
	addi $s0, $s0, 1 # ++i
	j loop_stoi
loop_exit_stoi:
	move $v0,$s1
	
	lw $s0, 0($sp) # restore $s0 from stack
	lw $s1, 4($sp) # restore $s1 from stack
	lw $s2, 8($sp) # restore $s2 from stack
	lw $s3, 12($sp) # restore $s3 from stack
	lw $s4, 16($sp) # restore $s4 from stack
	lw $s5, 20($sp) # restore $s5 from stack
	lw $ra, 24($sp) # restore $ra from stack
	addi $sp, $sp, 28 # close room on stack

	jr $ra

#################################################################################################################################################
# arguments $a0 - base, $a1 - power_value
# returns: $v0 - pow(base,power value)
Pow:
	li $t0, 1 # answer = 1
	li $t1, 0 # i = 0
loop_pow:
	slt $t9, $t1, $a1
	beq $t9, $zero, loop_exit_pow  # if i >= power_value; exit loop
	mul $t0,$t0,$a0 # answer *= base
	addi $t1, $t1, 1 # i++
	j loop_pow # loop again
loop_exit_pow:
	move $v0,$t0 # copy return value
	jr $ra	

#################################################################################################################################################
# Counts number of digits in the given string representation of an integer.
#
# arguments: $a0 - buffer (string representation of an int)
# returns: $v0 - digits (number of digits in the int)
Count:
	li $v0, 0 # count = 0
	move $t0,$a0 # buffer_cp = buffer
	li $t9, '0' # zero_char = '0'
	li $t8, '9' # nine_char = '9'
loop_count: 
	lbu $t1, 0($t0) # next_value = *buffer
	blt $t1, $t9, loop_exit_count # if next_value < zero_char; Go exit loop
	bgt $t1, $t8, loop_exit_count # if next_value > nine_char; Go exit loop
	addi $v0, $v0, 1 # count++
	addi $t0, $t0, 1 # buffer++
	j loop_count # loop again
loop_exit_count: 
	jr $ra

#################################################################################################################################################
# arguments: $a0 - int1_int, $a1 - int1_float, $a2 - int2_int, $a3 - int2_float
# returns: $v0 - ans_int, $v1 - ans_float
#Add_1: 
#	lw $t0, 0($sp) # int1_float_digits = *($sp + 0)
#	lw $t1, 4($sp) # int2_float_digits = *($sp + 4)
#
#	addi $sp, $sp, -28 # make room on stack for 7 registers
#	sw $ra, 24($sp) # save $ra on stack
#	sw $s5, 20($sp) # save $s5 on stack
#	sw $s4, 16($sp) # save $s4 on stack
#	sw $s3, 12($sp) # save $s3 on stack
#	sw $s2, 8($sp) # save $s2 on stack
#	sw $s1, 4($sp) # save $s1 on stack
#	sw $s0, 0($sp) # save $s0 on stack
#
#	move $s0, $t0 # int1_float_digits
#	move $s1, $t1 # int2_float_digits
#	move $s2, $a0 # int1_int
#	move $s3, $a1 # int1_float
#	move $s4, $a2 # int2_int
#	move $s5, $a3 # int2_float
#
#	beq $s0, $s1, if_exit_1 # if int1_float_digits == int2_float_digits; Go to if_exit
#	blt $s0, $s1, if_1 # if int1_float_digits < int2_float_digits; Go to if 
#else 
#	sub $t0, $s0, $s1 # power = int1_float_digits - int2_float_digits
#	li $a0, 10 # base = 10
#	move $a1, $t0 # power_value = power
#	jal Pow
#	mul $s5, $s5, $v0 # int2_float = int2_float * 10^power
#	j if_exit_1
#if_1:
#	sub $t0, $s1, $s0 # power = int2_float_digits - int1_float_digits `23 
#	li $a0, 10 # base = 10
#	move $a1, $t0 # power_value = power
#	jal Pow
#	mul $s3, $s3, $v0 # int1_float = int1_float * 10^power
#	move $s0, $s1 # int1_float_digits = int2_float_digits
#if_exit_1: 															# (int1_float_digits == int2_float_digits)
#	li $a0, 10 # base = 10
#	move $a1, $s0 # power_value = int1_float_digits 				
#	jal Pow # $v0 = 10^int1_float_digits
#	add $v1, $s3, $s5 # ans_float = int1_float + int2_float
#	sub $t0, $v0, $v1 # temp = 10^int1_float_digits - ans_float
#	li $t1, 0 # carry = 0
#	bgt $t0, $zero, exit # if temp > 0: Go to exit
#	sub $v1, $v1, $v0 # ans_float = int1_float - int2_float
#	li $t1, 1 # carry = 1
#exit:
#	add $v0, $s2, $s4 # ans_int = int1_int + int2_int
#	add $v0, $v0, $t1 # ans_int += carry
#
#	lw $s0, 0($sp) # save $s0 on stack
#	lw $s1, 4($sp) # save $s1 on stack
#	lw $s2, 8($sp) # save $s2 on stack
#	lw $s3, 12($sp) # save $s3 on stack
#	lw $s4, 16($sp) # save $s4 on stack
#	lw $s5, 20($sp) # save $s5 on stack
#	lw $ra, 24($sp) # save $ra on stack
#	addi $sp, $sp, 28 # close room on stack 
#
#	jr $ra