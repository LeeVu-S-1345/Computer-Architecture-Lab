.eqv TIMER_NOW	0xFFFF0018
.data
	array: .space 10000
	mess: .asciz "Input the filename (including file extension) containing numbers to sort:"
	filename: .space 36
	des: .space 10002
	mess1: .asciz "Error: This filename doesn't exist or invalid extension"
	display: .asciz "Execution time (ms): "
	fail_mess: .asciz "There are not any numbers"
	menu: .asciz "Enter the number corresponding to sorting algorithm you choose:\n(1) Bubble sort\n(2) Selection sort\n(3) Insertion sort"
.text
	li s7, TIMER_NOW 	# time now
	
	# Input the filename
	li a7, 54
	la a0, mess
	la a1, filename
	li a2, 36
	ecall
	
	# Delete character '/n' in filename buffer
	li t0, 0	# Index of string
	li s1, 10	# New line character
	la s0, filename
count:	# Find the length of string filename
	lb t1, 0(s0)
	beq t1, s1, extract	# If flename[i] = '\n', go to delete '\n'
	addi t0, t0, 1
	addi s0, s0, 1
	j count
# ---------------------------------------------------
# Now register t0 is as index of chracter '\n' of filename
# ---------------------------------------------------
extract:
	la s0, filename
	add s0, s0, t0
	sb zero, 0(s0)		# Delete character '\n'
end_extract:
	
	# Open file
	li a7, 1024
	la a0, filename
	li a1, 0
	ecall
	mv s6, a0	# Discriptor of file
	
	# Read file
	li a7, 63
	mv a0, s6
	la a1, des
	li a2, 10000
	ecall
	
	addi a0, a0, 1
	beqz a0, print_mess
	
	# Close file
	li a7, 57
	mv a0, s6
	ecall
select:
	li a7, 51
	la a0, menu
	ecall
	ble a0, zero, select	# If input is not a number or input is a number which is less than 0, input again
	li s1, 3
	bgt a0, s1, select	# If input is a number which is greater than 3, input again
	addi sp, sp, -4	
	sw a0, 0(sp)		# Store the type of sorting algorithm in stack
initialize_1:
	la s0, des	# des[0]
	li a0, 0	# Count the number of integers
	li t0, 0
	li s1, 48	# Character '0'
	li s2, 57	# Character '9'
	la t4, array	# array[0]
	li s5, 45	# Character '-'
	li s6, 1	# Mark the point time, we reach the character '\0'
	li t5, 1	# Default value of t5 to check if there are any negative numbers
	j get_element
check_negative:
	addi s0, s0, 1			# i = i + 1
	lb t1, 0(s0)			# des[i]
	beqz t1, select_sort		# If t1 is null, move to check kind of selected sorting algorithm
	blt t1, s1, no_negative	# If des[i] < '0', it is not a negative number
	bgt t1, s2, no_negative	# If des[i] > '9', it is not a negative number
	li t5, 0			# Mark that there is a negative number
	j continue_of_negative
no_negative:
	addi s0, s0, 1
get_element:
	beqz s6, select_sort	# If s6 is '\0', go to check type of selected sorting algorithm
	lb t1, 0(s0)
	beqz t1, mark		# If t1 is '\0', set s6 to 0
	beq t1, s5, check_negative	# If '-' appears, we need to check wether there exists a negative number
	blt t1, s1, convert_integer	# If des[i] < '0', continue
	bgt t1, s2, convert_integer	# If des[i] > '9', continue
continue_of_negative:
	addi s0, s0, 1
	addi t0, t0, 1
	j get_element
mark:
	li s6, 0
convert_integer:
	addi s0, s0, 1
	beqz t0, get_element	# If t0=0 which means we have not just taken any numbers, back to get element
	addi a0, a0, 1		# Else count++
	addi t2, s0, -2
	li s3, 0	# Store the value when convert to integer
	li s4, 1	# Store number which is the exponential of 10
	li t3, 10
loop:
	lb t1, 0(t2)
	sub t1, t1, s1		# t1 = t1 - '0'
	mul t1, t1, s4
	add s3, s3, t1		# Get number of each class
	mul s4, s4, t3		# Next class of integer: s4 = s4 * 10
	addi t0, t0, -1		# Decrease the number of character in one get_element
	addi t2, t2, -1		# Back to the previous element
	bnez t0, loop		# If all elements haven't traversed, go on loop
	beqz t5, get_negative	# if t5 = 0, there is a negative number, move to multiply s3 with -1
	sw s3, 0(t4)		# array[i] = s3
	addi t4, t4, 4		# array[i+1]
	beqz s6, select_sort	# If s6 = '\0', go to check the type of selected sorting algorithm
	j get_element
get_negative:
	li t6, -1
	mul s3, s3, t6		# s3 = -s3
	li t5, 1		# return default value of t5
	sw s3, 0(t4)		# array[i] = s3
	addi t4, t4, 4		# array[i+1]
	beqz s6, select_sort	# If s6 = '\0', go to check the type of selected sorting algorithm
	j get_element
select_sort:
	beqz a0, fail	# If there aren't any numbers, output error
	lw a1, 0(sp)	# Load type of sorting algorithm
	sw a0, 0(sp)	# Store the number of integers in array

# Check if users choose bubble sort
	li s0, 1
	beq a1, s0, bubble_sort
# Check if users choose selection sort
	li s0, 2
	beq a1, s0, selection_sort
# Check if users choose insertion sort
	li s0, 3
	beq a1, s0, insertion_sort
#---------------------------------------------------
bubble_sort:
	lw s8, 0(s7)	# Take start time
	lw a0, 0(sp)
	addi a0, a0, -1
	slli a1, a0, 2
	la a0, array	# The adress of array[0]
	add a1, a0, a1 # The addess of the last element array[n-1]
sort1:
	la s0, array
	li s4, 0			# Set s4 to 0 as a default value. It means there aren't stil any swaps
	beq a0, a1, display_time	# If there is only one element which hasn't been sorted
loop_bubble:
	lw s2, 0(s0)	# s2 = array[i]
	addi s1, s0, 4
	lw s3, 0(s1)	# s3 = array[i+1]
	bgt s2, s3, swap # If array[i] > array[i+1], swap them
	j check
swap:
	li s4, 1	# Set 1 because there is swap occuring
	sw s2, 0(s1)
	sw s3, 0(s0)
check:
	addi s0, s0, 4
	beq s0, a1, loop_bubble1
	j loop_bubble
loop_bubble1:
	beqz s4, display_time	# If there aren't any swaps, end the algorithm
	addi a1, a1, -4
	j sort1
#----------------------------------------------------
selection_sort:
	lw s8, 0(s7)	# Take start time
	lw a0, 0(sp)
	slli a1, a0, 2	# a1 = a0 * 4
	la a0, array	# a0 = the adress of array[0]
	add a1, a0, a1 # a1 = the addess of memory right after the last element
sort2:
	beq a0, a1, display_time	# If i = n, end the algorithm
	mv t0, a0			# idx = i
	addi s0, a0, 4			# j = i + 1
loop_selection:
	beq s0, a1, next		# If j = n, end the internal loop
	lw s1, 0(s0)			# s1 = array[j]
	lw t1, 0(t0)			# t1 = array[idx]
	bgt t1, s1, update		# If array[idx] > array[j], idx = j
	addi s0, s0, 4			# j = j + 1
	j loop_selection
update:
	mv t0, s0			# idx = j
	addi s0, s0, 4			# j = j + 1
	j loop_selection
next:
	lw s2, 0(t0)			# temp = array[idx]
	lw s3, 0(a0)			# temp1 = array[i]
	sw s3, 0(t0)			# array[idx] = temp
	sw s2, 0(a0)			# array[i] = temp1
	addi a0, a0, 4			# i = i + 1
	j sort2
#----------------------------------------------------
insertion_sort:
	lw s8, 0(s7)	# Take start time
	lw a0, 0(sp)
	slli a1, a0, 2	# a1 = a0 * 4
	la a0, array	# a0 = the adress of array[0]
	add a1, a0, a1 # a1 = the addess of memory right after the last element
	la s1, array
	addi s1, s1, 4	# s0 = array[1]
sort3:
	beq s1, a1, display_time	# If s1 = n, end the algorithm
	lw s3, 0(s1)			# s3 = array[i]
	addi s0, s1, -4			# s1 = i - 1
loop_insertion:
	lw s2, 0(s0)
	bge s3, s2, continue	# If array[i] >= array[j] with i>j, do nothing
	blt s0, a0, continue	# If j < 0, do nothing
	addi t0, s0, 4		# t0 = j + 1
	sw s2, 0(t0)		# array[j+1] = array[j]
	addi s0, s0, -4		# j = j - 1
	j loop_insertion
continue:
	addi s0, s0, 4		# j = j + 1
	sw s3, 0(s0)		# array[j] = array[i]
	addi s1, s1, 4		# i++
	j sort3
#----------------------------------------------------
# - s8 is currently storing the start time of execution of sorting algorithm
#----------------------------------------------------
display_time:
	li a7 56
	la a0, display
	lw a1, 0(s7)		# Take the end time
	sub a1, a1, s8		# Compute execution time = end time - start time
	ecall
#----------------------------------------------------
	lw a0, 0(sp)
	slli a1, a0, 2	# a1 = a0 * 4
	la a0, array	# a0 = the adress of array[0]
	add a1, a0, a1 # a1 = the addess of memory right after the last element
	li t0, 32	# character space
	la s0, des	# des[0]
	li a2, 0	# Length of string
	li t5, 45	# Character '-'
initialize_2:
	beq a0, a1, write_file
	lw t1, 0(a0)		# array[i]
	li t2, 10		# decimal system
	mv t3, sp		# current status of sp
	bgez t1, process	# If array[i] >=0, move to process
	# Else add '-' to des before add number
	sub t1, zero, t1	# t1 = -t1
	sb t5, 0(s0)		# des[i] = '-'
	addi s0, s0, 1		# i++
	addi a2, a2, 1		# length++
process:
	rem s1, t1, t2		# s1 = array[i] % 10
	addi sp, sp, -1
	sb s1, 0(sp)
	div t1, t1, t2		# array[i] = array[i] / 10
	beqz t1, process_1
	j process
process_1:
	beq sp, t3, add_space	# If sp equals to its initial status, move to add space
	lb s1, 0(sp)
	addi sp, sp, 1
	addi s1, s1, 48		# s1 = s1 + '0'
	sb s1, 0(s0)		# des[i] = s1
	addi s0, s0, 1		# i = i + 1
	addi a2, a2, 1		# Increase length by 1
	j process_1
add_space:
	sb t0, 0(s0)		# des[i] = ' '
	addi a2, a2, 1		# Increase length by 1
	addi s0, s0, 1		# i++
	addi a0, a0, 4		# Next element in array
	j initialize_2
write_file:
	addi a2, a2, -1		# delete the final space
	# Open file
	li a7, 1024
	la a0, filename
	li a1, 1
	ecall
	mv s6, a0	# Discriptor of file
	
	# Write file
	li a7, 64
	mv a0, s6
	la a1, des
	ecall

	# Close file
	li a7, 57
	mv a0, s6
	ecall
	j exit
print_mess:
	li a7, 55	# Print message error
	la a0, mess1
	li a1, 0
	ecall
	j exit
fail:
	li a7, 55	# Print message error
	la a0, fail_mess
	li a1, 0
	ecall
exit:	
	li a7, 10	# exit code
	ecall
