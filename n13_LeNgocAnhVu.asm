.eqv RED 0x00C00000
.eqv LIGHT_RED 0x00FF0000
.eqv GREEN 0x0000C000
.eqv LIGHT_GREEN 0x0000FF00
.eqv LIGHT_BLUE 0x000000FF
.eqv BLUE 0x000000C0
.eqv LIGHT_YELLOW 0x00FFFF00
.eqv YELLOW 0x00FFD700
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv SEVENSEG_LEFT 0xFFFF0011
.eqv SEVENSEG_RIGHT 0xFFFF0010
.data
	array: .space 100		# store the random numbers
	times: .byte 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f	# number to display on seven segment
	introduction: .asciz "Choose number corresponding to color of highlighted square in order:\n(1) red\n(2) green\n(3) blue\n(4) yellow"
	endgame: .asciz "Game over"
.text
	li s2, 0	# Number round
	li a7, 55	# Display the introduction
	la a0, introduction
	li a1, 1
	ecall
square1:
	li s0, 0x10000000	# Address of the first cell of red square
	addi s1, s0, 12		# Address of the last cell of the current row
	addi t1, s0, 108	# Address of the last cell of red square
	li t0, RED
loop1:
	sw t0, 0(s0)		# Color the row
	addi s0, s0, 4		# Move to adjacent cell
	bgt s0, s1, row1	# If done the current row, move to next row
	j loop1
row1:
	addi s0, s0, 16		# Move to next row
	addi s1, s1, 32		# Address of the last cell of the current row
	bgt s0, t1, square2	# If all cells of red square are colored, coloring green square
	j loop1
square2:
	li s0, 0x10000010	# Address of the first cell of green square
	addi s1, s0, 12		# Address of the last cell of the currenr row
	addi t1, s0, 108	# Address of the last cell of green square
	li t0, GREEN
loop2:
	sw t0, 0(s0)		# Color the cell in the current row
	addi s0, s0, 4		# Move to adjacent cell
	bgt s0, s1, row2	# If done the current row, move to next row
	j loop2
row2:
	addi s0, s0, 16		# Move to next row
	addi s1, s1, 32		# Address of the last cell of the current row
	bgt s0, t1, square3	# If all cells of green square are colored, coloring blue square
	j loop2
square3:
	li s0, 0x10000080	# Address of the first cell of blue square
	addi s1, s0, 12		# Address of the last cell of the current row
	addi t1, s0, 108	# Address of the last cell of blue square
	li t0, BLUE
loop3:
	sw t0, 0(s0)		# Color the cell in the current row
	addi s0, s0, 4		# Move to the adjacent cell
	bgt s0, s1, row3	# If done the current row, move to the next row
	j loop3
row3:
	addi s0, s0, 16		# Move to next row
	addi s1, s1, 32		# Address of the last cell of the current square
	bgt s0, t1, square4	# If all cells of blue square are colored, coloring yellow square
	j loop3
square4:
	li s0, 0x10000090	# Address of the first cell of yellow square
	addi s1, s0, 12		# Address of the last cell of the current row
	addi t1, s0, 108	# Address of the last cell of yellow square
	li t0, YELLOW
loop4:
	sw t0, 0(s0)		# Color the cell in the current row
	addi s0, s0, 4		# Move to the adjacent cell
	bgt s0, s1, row4	# If done the current row, move to the next row
	j loop4
row4:
	addi s0, s0, 16		# Move to next row
	addi s1, s1, 32		# Address of the last cell of the current square
	bgt s0, t1, start	# If all squares are colored, start the main part of game
	j loop4
start:
	# Not enable the interrupt of keypad of Digital Lab Sim 
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	sb zero, 0(t1)
	
	addi s2, s2, 1		# Increase round number by 1
	mv s3, s2		# s3 = s2
	la t2, array		# array[0]
	jal rest		# sleep 1 second to wait for next round
random_phase:
	beqz s3, select_phase	# If random enough s2 times, move to select_phase
	li a7, 42		# Random numbers
	li a1, 4
	ecall
	addi s3, s3, -1		# Decrease the number of times to random by 1
	addi a0, a0, 1		# ID of square
	sw a0, 0(t2)		# Store ID of square into array[i]
	addi t2, t2, 4		# i++
# Check random number to highlight the square corresponding to it
	# If random number is 1
	li s0, 1
	beq a0, s0, light_red
	# If random number is 2
	li s0, 2
	beq a0, s0, light_green
	# If random number is 3
	li s0, 3
	beq a0, s0, light_blue
	# If random number is 4
	li s0, 4
	beq a0, s0, light_yellow
light_red:
	li t3, 1		# Default value, the square hasn't been highlighted yet
initialize1:			# Similar to coloring red square above
	li s0, 0x10000000
	addi s1, s0, 12
	addi t1, s0, 108
	beqz t3, return_red	# If highlighting is done, return initial color to square
	li t0, LIGHT_RED
	j loop11
return_red:
	li t0, RED		# Load initial color after highlighting
loop11:
	sw t0, 0(s0)
	addi s0, s0, 4
	bgt s0, s1, row11
	j loop11
row11:
	addi s0, s0, 16
	addi s1, s1, 32
	ble s0, t1, loop11
	jal rest		# wait for 1 second before return to initial color
	beqz t3, random_phase	# After highlighting the square, back to random phase
	li t3, 0		# Set to 0 because the square highlighted
	j initialize1
light_green:
	li t3, 1		# Default value, the square hasn't been highlighted yet
initialize2:			# Similar to coloring green square above
	li s0, 0x10000010
	addi s1, s0, 12
	addi t1, s0, 108
	beqz t3, return_green	# If highlighting is done, return initial color to square
	li t0, LIGHT_GREEN
	j loop22
return_green:
	li t0, GREEN		# Load initial color after highlighting
loop22:
	sw t0, 0(s0)
	addi s0, s0, 4
	bgt s0, s1, row22
	j loop22
row22:
	addi s0, s0, 16
	addi s1, s1, 32
	ble s0, t1, loop22
	jal rest		# wait for 1 second before return to initial color
	beqz t3, random_phase	# After highlighting the square, back to random phase
	li t3, 0		# Set to 0 because the square highlighted
	j initialize2
light_blue:
	li t3, 1		# Default value, the square hasn't been highlighted yet
initialize3:			# Similar to coloring blue square above
	li s0, 0x10000080
	addi s1, s0, 12
	addi t1, s0, 108
	beqz t3, return_blue	# If highlighting is done, return initial color to square
	li t0, LIGHT_BLUE
	j loop33
return_blue:
	li t0, BLUE		# Load initial color after highlighting
loop33:
	sw t0, 0(s0)
	addi s0, s0, 4
	bgt s0, s1, row33
	j loop33
row33:
	addi s0, s0, 16
	addi s1, s1, 32
	ble s0, t1, loop33
	jal rest		# wait for 1 second before return to initial color
	beqz t3, random_phase	# After highlighting the square, back to random phase
	li t3, 0		# Set to 0 because the square highlighted
	j initialize3
light_yellow:
	li t3, 1		# Default value, the square hasn't been highlighted yet
initialize4:			# Similar to coloring yellow square above
	li s0, 0x10000090
	addi s1, s0, 12
	addi t1, s0, 108
	beqz t3, return_yellow	# If highlighting is done, return initial color to square
	li t0, LIGHT_YELLOW
	j loop44
return_yellow:
	li t0, YELLOW		# Load initial color after highlighting
loop44:
	sw t0, 0(s0)
	addi s0, s0, 4
	bgt s0, s1, row44
	j loop44
row44:
	addi s0, s0, 16
	addi s1, s1, 32
	ble s0, t1, loop44
	jal rest		# wait for 1 second before return to initial color
	beqz t3, random_phase	# After highlighting the square, back to random phase
	li t3, 0		# Set to 0 because the square highlighted
	j initialize4
#-----------------------------------------------------------------------
# - s2 is storing number round
#-----------------------------------------------------------------------
select_phase:
	# Load the interrupt service routine address to the UTVEC register 
	la t0, handler 
	csrrs zero, utvec, t0 
     
	# Set the UEIE (User External Interrupt Enable) bit in UIE register 
	li t1, 0x100 
	csrrs zero, uie, t1       # uie - ueie bit (bit 8)
	# Enable the interrupt of keypad of Digital Lab Sim 
	li t1, IN_ADDRESS_HEXA_KEYBOARD 
	li t2, 0x80  # bit 7 = 1 to enable interrupt    
	sb t2, 0(t1)
	mv s3, s2	# the number of times to press a button
seven_segment:
	li s0, 10
	la t2, times		# Load address of buffer containing value to display digit on seven segment
	rem t0, s3, s0		# t0 = the right digit
	div t1, s3, s0		# t1 = the left digit
	add t0, t0, t2		# Address of the value to display digit t0
	add t1, t1, t2		# Address of the value to display digit t1
	lb t0, 0(t0)		# Value to display digit t0
	lb t1, 0(t1)		# Value to display digit t1
	li s1, SEVENSEG_LEFT
	li s0, SEVENSEG_RIGHT
	sb t0, 0(s0)		# Display digit t0 on the right LED
	sb t1, 0(s1)		# Display digit t1 on the left LED
end_seven_segment:
	la t3, array	# array[0]
wait_to_press:
	# Set the UIE (User Interrupt Enable) bit in USTATUS register 
	csrrsi zero, ustatus, 0x1	# ustatus - enable uie (bit 0)
	beqz s3, start			# If press enough times, move to prepare for new round
	addi a7, zero, 32           
	li a0, 300			# Sleep 300 ms 
	ecall 
	j wait_to_press
handler: 	# Handles the interrupt
	
    	li t1, IN_ADDRESS_HEXA_KEYBOARD 
   	li t2, 0x81      # Check row 1 and re-enable bit 7 
	sb t2, 0(t1)     # Must reassign expected row 
	li t1, OUT_ADDRESS_HEXA_KEYBOARD 
	lb a0, 0(t1) 
    	bnez a0, check_row1	# If a0 != 0, it means the pressed button in the row 1, check what is that button in row 1
    
	li t1, IN_ADDRESS_HEXA_KEYBOARD 
	li t2, 0x82     		# Check row 2 and re-enable bit 7 
	sb t2, 0(t1)     		# Must reassign expected row 
	li t1, OUT_ADDRESS_HEXA_KEYBOARD 
	lb a0, 0(t1) 
	bnez a0, check_row2	# If a0 != 0, it means the pressed button in the row 2, check what is that button in row 2
check_correct:    
    lw t0, 0(t3)		# t0 = array[i]
    bne a0, t0, exit		# If a0 != t0, game over => end game
    addi s3, s3, -1		# Decrease number of times which need pressing by 1
seven_segment1:			# Display the number of times which need pressing on seven segment, similar to seven_segment label
	li s0, 10
	la t2, times
	rem t0, s3, s0
	div t1, s3, s0
	add t0, t0, t2
	add t1, t1, t2
	lb t0, 0(t0)
	lb t1, 0(t1)
	li s1, SEVENSEG_LEFT
	li s0, SEVENSEG_RIGHT
	sb t0, 0(s0)
	sb t1, 0(s1)
end_seven_segment1:
	addi t3, t3, 4		# i = i + 1
	uret
check_row1:
	li t0, 0x21		# Check if pressed button is 1
	beq a0, t0, button_1
	li t0, 0x41		# Check if pressed button is 2
	beq a0, t0, button_2
	li t0, 0xffffff81	# Check if pressed button is 3
	beq a0, t0, button_3
	#li t0, 0x12
	#li a0, 0
	j exit
button_1:
	li a0, 1		# button 1 is pressed, a0 = 1
	j check_correct
button_2:
	li a0, 2		# button 2 is pressed, a0 = 2
	j check_correct
button_3:
	li a0, 3		# button 3 is pressed, a0 = 3
	j check_correct
check_row2:
	li t0, 0x12		# Check if pressed button is 4
	beq a0, t0, button_4
	j exit			# Else exit and game over
button_4:
	li a0, 4		# button 4 is pressed, a0 = 4
	j check_correct
rest:
	li a7, 32		# Wait for 1 second
	li a0, 1000
	ecall
	jr ra
exit:
	li a7, 55		# Print "game over" message
	la a0, endgame
	li a1, 1
	ecall
	li a7, 10		# End program
	ecall
