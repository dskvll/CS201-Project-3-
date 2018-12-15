#mips Project 3 recursive base converter
.data # Data declaration section
too_long_input: .asciiz "Input is too long."
out_of_range: .asciiz "Invalid base-27 number." 
empty_input: .asciiz "Input is empty."
user_input: .space 85000
.text # Assembly language instructions
main: # Start of code section

# begins getting user input

li $v0, 8   # read string command
la $a0, user_input #stores user string into register
li $a1, 85000 
syscall # calls previous instructions

add $t7, $0, 0 #initialises register
add $t7, $0, 0 #initialises register
la $t8, user_input # copy address of user input into $t8			
lb $t7,0($t8) # loads the byte value of $t8 into $t7	

#checks for empty input

beq $t7, 10, No_input_error # branches if $t7 is a new line command	
beq $t7, 0 No_input_error # branches if there is literally no input in $t7	

addi $s0, $0, 27 #initialises the register with desired base
addi $t5, $0, 0 	#initialises register for future use
addi $t4, $0, 0	 # initialises register for use
addi $t2, $0, 0
addi $t1, $0, 1 	#initializes register for future use

# processes spaces and disregards them
space_ignore:
	lb $t7,0($t8)# loads the byte value of $t8 into $t7	
	addi $t8, $t8, 1#increments
	addi $t3, $t3, 1#increments
	beq $t7, 32, space_ignore # if the user input is a space then we run the ignore program
	beq $t7, 10, No_input_error # if the user input is = 10(line feed) then there is no input error
	beq $t7, $0, No_input_error #if the value of the user input is null then no input error is called

#proceeds to check the individual letters to ensure that there are no intermittent spaces etc
check_characters:
	lb $t7,0($t8)# loads the byte value of $t8 into $t7	
	addi $t8, $t8, 1 #increments
	addi $t3, $t3, 1 #increments
	addi $t2, $t2, 1
	beq $t7, 10, restart_count # if the value in $t7 is empty it restarts the count
	beq $t7, 0, restart_count  #if the value in $t7 is empty it restarts the count
	bne $t7, 32, check_characters # if the user input is not equal to a space then check characters is run

check_characters_and_spaces:
	lb $t7,0($t8) # loads the byte value of $t8 into $t7
	addi $t8, $t8, 1 #increments
	addi $t3, $t3, 1 #increments
	addi $t2, $t2, 1
	beq $t7, 10, restart_count	#if the value in $t7 is empty it restarts the count
	beq $t7, 0, restart_count	#if the value in $t7 is empty it restarts the 
	bne $t7, 32, Too_Long_Invalid 	#if the user input is not equal to a space then the input is not a valid input
	j check_characters_and_spaces 	#jumps to function
	
addi $t9, $t7, -100

restart_count:
	sub $t8, $t8, $t3 	#restarting the pointer in char_array
	la $t3, 0 			#restarting the counter

continue_check:
	lb $t7,0($t8) #loads the byte value of $t8 into $t7
	addi $t8, $t8, 1 #increments
	beq $t7, 32, continue_check # if the user input is a space then we run the continue check function
	
addi $t8, $t8, -1 #initialises value to ensure proper calculations

check_length:
	lb $t7, ($t8) #loads value from t8 into t7
	addi $t8, $t8, 1 #increments
	addi $t3, $t3, 1 #increments
	beq $t7, 10, reset_pointer # if user input new line then reset pointer
	beq $t7, 0, reset_pointer #if the user input is null then reset pointer
	beq $t7, 32, reset_pointer # if the user input is a space then reset the pointer
	beq $t3, 5, Input_Long_Error # if the user input exceeds four then it is too long
	j check_length # jumps to check length function
	
reset_pointer:
	sub $t8, $t8, $t3 # subtracts the pointer from t8 and stores it in t8
	sub $t3, $t3, $t1 #subtracts t1 from t3 and stores it in t3
	lb $t7, ($t8) #loads the subracted value into t7
	sub $s1, $t3, $t1 # stores the value of t3-t1 into s1
	
Length_to_power:	
	beq $s1, 0, call_recursion	#Bringing base to last power of the string
	mult $t1, $s0 #multiplies the base number by t1
	mflo $t1 #stores the value into t1
	sub $s1, $s1, 1 #decrements
	j Length_to_power
	
li $t6,1500

call_recursion:	#new label to introduce recursive function
	move $a0, $t1 #moves the value  so that the information may be preserved
	move $a2, $t8 #similar to above
	move $a3, $t3 #similar to above
	addi $sp, $sp, -12	#allocate memory
	sw $t1, 0($sp)		#highest power
	sw $t8, 4($sp) 		#string address
	sw $t3, 8($sp)		#counter

	jal ChangeBase #calls the change_base
	lw $a0, 0($sp)
	addi $sp, $sp, 4

	li $v0, 1 # prints contents of a0
	syscall
		
li $v0,10 #ends program
syscall


		ChangeBase:
		lw $a0, 0($sp) #current power
		lw $a2, 4($sp) #string address
		lw $a3, 8($sp) #counter
		addi $sp, $sp, 12
		sw $s7, 16($sp)
		beq $a3, 0, terminate
		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $s6, 4($sp)
		
		beq $a3, 0, Terminate
		
		
		lb $a1, 0($a2)
		
		addi $a3, $a3, -1
		addi $a2, $a2, 1
		
		Ascii_to_decimal:
			blt $a1, 48, Out_of_range_Error #checks if character is before 0 in ASCII chart and returns an error if so
			blt $a1, 58, Number #checks if character is between 48 and 57 if so runs the numbers function
			blt $a1, 65, Out_of_range_Error #checks if character is between 58 and 64 returns an error if so
			blt $a1, 82, Capital_letter #checks if character is between 65 and 78 runs the capitals function
			blt $a1, 97, Out_of_range_Error #checks if character is between 79 and 96 returns an error if so
			blt $a1, 114, Common_letter #checks if character is between 97 and 110 runs the capitals function
			blt $a1, 128, Out_of_range_Error #checks if character is between 111 and 127 returns an error if so
	
		convert:
			mult $a1, $a0 		#multiples the user input by the current power
			mflo $s6			#stores the multiplication value (the sub sum)
			
			div $a0, $s0 		#dividing $a0 to the next power of base
			mflo $a0 			#moves value into $s4
			
			addi $sp, $sp, -12
			sw $a0, 0($sp) #current power
			sw $a2, 4($sp) #string address
			sw $a3, 8($sp) #counter

			jal ChangeBase
			
			lw $v0, 0($sp)
			addi $sp, $sp, 4 
			add $v0, $s6, $v0	# adding up the rest of the calculation for the input
			
			lw $ra, 0($sp)	#reload so we can return them
			lw $s6, 4($sp)	
			lw $s7, 16($sp)
			addi $sp, $sp, 20
			
			jr $ra
	
		Capital_letter:
			addi $a1, $a1, -55 #subtracts 55 to get the value in decimal
			j convert 	

		Common_letter:
			addi $a1, $a1, -87 #subtracts 87 to get the value in decimal
			j convert	

		Number:
			addi $a1, $a1, -48 	##subtracts 48 to get the value in decimal
			j convert				
		
		terminate:
			li $v0, 0
			lw $ra, ($sp)
			lw $s4, 4($sp) #highest power
			lw $s5, 8($sp) #character array
			lw $s6, 12($sp) #subsum
			lw $s7, 16($sp)
			addi $sp, $sp, 20
			
			jr $ra
			
#begins implementing branches
No_input_error:
	la $a0, empty_input #loads string
	li $v0, 4 # print string function
	syscall # calls operating system to do the preceding instruction
	li $v0,10 #ends program
	syscall # calls operating system to do the preceding instruction

Out_of_range_Error:
	la $a0, out_of_range #loads string
	li $v0, 4 # print string function
	syscall # calls operating system to do the preceding instruction
	li $v0,10 #ends program
	syscall	 # calls operating system to do the preceding instruction


Input_Long_Error:
	la $a0, too_long_input #loads string
	li $v0, 4 # print string function
	syscall # calls operating system to do the preceding instruction
	
	li $v0,10 #ends program
	syscall # calls operating system to do the preceding instruction
	
Too_Long_Invalid:
	bgt $t2, 3, Input_Long_Error
	j Out_of_range_Error
