.data
	mess: .asciz "The least frequent lowercase letter is: "
	mess1: .asciz "\nIts positions: "
	mess2: .asciz "Enter a string: "
	str: .space 1000	# Store string 
	fre: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # Array to count frequence, fre[i] stores the frequece of letter 'a'+i
.text
main:
	la t0, str		# Load address of str[0] to t0
	la t1, fre		# Load address of fre[0] to t1
	li s2, 1000000000	# s2 is used to store the least frequence
	li s3, 0		# s3 stores the length of the string
# print the sentence "Enter a string: "
	li a7, 4
	la a0, mess2
	ecall

# Instead of entering a string, user enters a number of characters
# Each reading a character, increase the frequence of this character by 1 if it is a lowercase letter
# Finish entering when user input character '\n'

input:
	li a7, 12		# Read a character
	ecall			# a0 stores the input character
	addi a0, a0, -10	# a0 = a0 - 10
	beqz a0, end_input	# If a0 is '\n', then finish entering (compare a0-10 with 0 instead a0 with 10)
	addi s3, s3, 1		# The length of the string increases by 1
	addi a0, a0, 10		# Return the previous value of a0
	sb a0, 0(t0)		# Store a0 in str[i]
	jal frequency		# Jump to label frequency in order to count frequence
	addi t0, t0, 1		# i = i + 1
	j input			# Continue to input
frequency: # count the frequence of a letter
	addi s0, a0, -97	# s0 = a0 - 97 = a0 - 'a'
	addi s1, a0, -122	# s1 = a0 -122 = a0 - 'z'
	mul s1, s0, s1		# s1 = s0 x s1 = (a0 - 'a') x (a0 - 'z')
	bgtz s1, skip_frequency  	# s1 = (a0 - 'a') x (a0 - 'z') > 0.
					# In other word, if a0 is not a lower case, skip counting
	
	slli s0, s0, 2		# s0 = s0 x 4 ( s0 is the i-th element)
	add s0, s0, t1		# s0 = s0 + t1 ( address of fre)
	lw s1, 0(s0)		# s1 = fre[s0]
	addi s1, s1, 1		# since character a0 appears once again, increase its frequence by 1: fre[s0]=fre[s0]+1
	sw s1, 0(s0)		# restore the new frequence of the character
skip_frequency: # skip counting the frequence of a letter if it is not a lowercase letter
	jr ra
end_input:
	li t2, 0	# i = t2 = 0
	li t3, 26	# the number of lowercase letters
	slli t3, t3, 2	# t3 = t3 * 4
find_minimum_frequence:	# this is used for finding the least frequence
	add t4, t1, t2		# t4 points to memory of the frequence of letter 'a' + i
	lw s1, 0(t4)		# load the frequence of a letter to s1
	beqz s1, continue	# if s1 = 0, skip count frequence because the letter do not appear anytime
	bgt s1, s2, continue	# if s1 = fre[i] > s2, skip updating the least frequence and move to continue label
	add s2, s1, zero	# else update the new least frequence
continue:
	addi t2, t2, 4		# i = i + 1, move to the frequence of the next letter
	beq t2, t3, end_finding	# if we have already traversed all lowercase letters, end finding the least frequence
	j find_minimum_frequence	# else continue to find the least frequence	
# At present:
# - s2 stores the least frequence
# - t1 stores the address of fre[0]
# - s3 stores the length of the string
# - t3 is the number of lowercase letters
# ------------------------------------------------------------------------------------------
# traverse the frequence of each letter a - z
# if a letter has its frequence which is equal to the minimum frequence, print its positions
end_finding:
	li t2, 0	# i = t2 = 0
traverse:
	add t4, t1, t2		# t4 points to memory of the frequence of letter 'a' + i
	lw s1, 0(t4)		# load the frequence of a letter to s1
	beq s1, s2, preparation	# if s1 = s2, it means the frequence of this letter is the least, then print its position
skip_print: # else move to the frequence of the next letter
	addi t2, t2, 4		# i = i + 1
	beq t2, t3, end		# if i = t3 = 26, we have already traversed the letter a - z, end the program
	j traverse		# else continue to traverse
preparation:
	srli t2, t2, 2		# t2 = t2 / 4
	addi s0, t2, 97		# s0 = 'a' + i
	slli t2, t2, 2		# t2 = t2 * 4
	la t0, str		# t0 stores the address of str[0]
	li t4, 0		# t4 = j = 0, j is the position of the letter s0 in string
	
	li a7, 4
	la a0, mess
	ecall
	
	li a7, 11
	add a0, s0, zero
	ecall
	
	li a7, 4
	la a0, mess1
	ecall
print:
	beq t4, s3, end_print	# if j is equal to the length of the string, exit the print label
	add s1, t0, t4		# s1 = address of str[j]
	lb s1, 0(s1)		# s1 = str[j]
	bne s1, s0, skip	# if s1 is not the letter stored in s0, skip print position
	
	# else  print position
	li a7, 1
	addi a0, t4, 1
	ecall
	# print space
	li a7, 11
	li a0, 32
	ecall
skip:	
	addi t4, t4, 1		# j = j + 1
	j print
end_print:
	# print newline
	li a7, 11
	li a0, 10
	ecall
	j skip_print	# continue to consider the frequence of the next letter
end: # end the program
	li a7, 10
	ecall
