.data
	mess1: .asciz "Enter the positive number M: "
	mess2: .asciz "Enter the positive number N: "
	mess3: .asciz "The GCD of M and N is: "
.text
# main program
main:
input_M:
	# Enter the number M
	li a7, 51	# use dialog to input an positive integer, user have to input util data entered is an positve integer
	la a0, mess1
	ecall
	ble a0, zero, input_M	# if input a non-positive number M, try again
	add s0, a0, zero # store number M in s0
# print the information on console for observe easily	
	li a7, 4
	la a0, mess1
	ecall
	
	li a7, 1
	mv a0, s0
	ecall
	
	li a7, 11 # print newline on console
	li a0, 10
	ecall
input_N:	
	# Enter the number N
	li a7, 51	# use dialog to input an positive integer, user have to input util data entered is an positve integer
	la a0, mess2
	ecall
	ble a0, zero, input_N	#if input a non-positive number N, try again
	add s1, a0, zero # store the number N in s1
# print the information on console for observe easily		
	li a7, 4
	la a0, mess2
	ecall
	
	li a7, 1
	mv a0, s1
	ecall
	
# use Euclid algorithm to find GCD
GCD:
	beq s0, s1, result # if s0 = s1, then stop the loop and go to result label
	blt s0, s1, subtract # if s0 < s1, go to subtract label
	sub s0, s0, s1 # else s0 = s0 - s1 > 0
	j GCD # continue to be in loop
subtract:
	sub s1, s1, s0 # s1 = s1 - s0 > 0
	j GCD # continue to be in loop
result:
	# print the GCD of M and N
	li a7, 56
	la a0, mess3
	mv a1, s0
	ecall
# end the program
end_main:
	li a7, 10
	ecall
