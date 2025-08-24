.data
	mess: .asciz "Enter the number of elements: "
	inputint: .asciz "Enter an integer: "
	mess1: .asciz "The sum of negative elements: "
	mess2: .asciz "The sum of positive elements: "
	mess3: .asciz "There is no negative number\n"
	mess4: .asciz "There is no positive number\n"
	mess5: .asciz "Error: "
	mess6: .asciz "The number you entered is negative"
.text
main:
	li s0, 0	# store the sum of negative numbers
	li s1, 0	# store the sum of positive numbers
	
	# Enter the number of elements
enter:
	li a7, 51
	la a0, mess
	ecall
	ble a0, zero, error
	j end_enter
error:	
	li a7, 59
	la a0, mess5
	la a1, mess6
	ecall
	j enter
end_enter:	
	add t0, a0, zero	# t0 is the number of elements
	add t1, a0, zero
# print the number of elements on console	
	li a7, 4
	la a0, mess
	ecall
	
	li a7, 1
	mv a0, t0
	ecall
	
	li a7, 11
	li a0, 10
	ecall
# store elements in stack pointed by sp register
enter_array:
	# input element of array from keyboard
	li a7, 51
	la a0, inputint
	ecall
	bnez a1, enter_array	# user have to input until entering a integer
	addi sp, sp, -4		# make space to store element of array
	sw a0, 0(sp)		# store the value of element in stack
	jal appear
	addi t0, t0, -1		# t0 = t0 - 1, is the number of elements which have not been inputed yet
	beqz t0, loop		# if t0 = 0, it means we have already inputed enough elements, go to loop label to calculate
	j enter_array		# else continue to input elements

loop:	# this label is use to classify positive and negative numbers to add to the correct sum
	# t1 is the number of elements which have not been traversed yet
	beqz t1, print		# if t1 = 0, it means we have already traversed completely the array, move to print label to print out the result
	lw t0, 0(sp)		# else load value of each element in stack to t0
	bltz t0, sum_negative	# if t0 < 0, move to sum_negative label
	add s1, s1, t0		# else s1 = s1 + t0, add t0 to the sum of positive numbers
	addi t1, t1, -1		# t1 = t1 - 1, decrease the number of remaining elemenets by 1
	addi sp, sp, 4		# move to the next element of array in stack, pointed by sp
	j loop
sum_negative:	# this label is use to add negative numbers to s0 which is store sum of negative numbers
	add s0, s0, t0		# s0 = s0 + t0
	addi t1, t1, -1		# t1 = t1 - 1, decrease the number of remaining elemenets by 1
	addi sp, sp, 4		# move to the next element of array in stack, pointed by sp
	j loop
print:	
# consider the situation of the negative numbers
	bnez s0, print_negative # if s0 != 0, it means there are several negative numbers, move to print_negative
	 # else there is no negative numbers
	 # print the sentence: There is no negative number
	li a7, 55
	la a0, mess3
	li a1, 1
	ecall
	j print1 # because there is no negative number, move to situation of positive number
print_negative:		# this label is used to print the sum of negative numbers
	# print the sum of negative elements if negative number exists
	li a7, 56
	la a0, mess1
	mv a1, s0
	ecall
print1:	# consider the situation of the positive numbers
	bnez s1, print_positive	# if s1 != 0, it means there are positive numbers, move to print_positive
	
	# else there is no positive numeber
	# print the sentence: There is no positive number
	li a7, 55
	la a0, mess4
	li a1, 1
	ecall
	j end_main # after printing all result, end the program
print_positive:	# this label is used to print the sum of positive numbers
	# print the sentence: The sum of positive elements
	li a7, 56
	la a0, mess2
	mv a1, s1
	ecall
end_main:	# end the program
	li a7, 10
	ecall
appear:
	# print each element of arry on console to observe easily
	li a7, 1
	ecall
	
	li a7, 11
	li a0, 32
	ecall
	jr ra
