.ifndef MOTORS
    MOTORS:
    .Data
    left_count: .word 0
    right_count: .word 0
    n_count: .word 0
    .Text
    # Left Motor JD Top
    # Right Motor JD Bottom
    # writes to motors individually
    # a0 - duty cylce of right motor
    # a1 - duty cycle of left motor
    .ent write_to_motors
	write_to_motors:
	# pops on stack
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	# takes duty cycle as input for each motor
	move $s0, $a0	# left duty cycle
	move $s1, $a1	# right duty cycle

	# writes to motors
	sw $s0, OC2RS
	sw $s1, OC3RS

	# pops off stack
	lw $ra, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12

	jr $ra
    .end write_to_motors
	
    .ent motor_timer
	motor_timer:
	# Setup timer 2 as the clock source for the output compare
	# 1) Turn off Global interrupts
	# 2) Turn mulit vector mode
	# 3) Turn off timer 2
	# 4) Set as a 16-bit timer
	# 5) Select the prescalar value of the peripheral clock
	# 6) Set the timer 2 register to zero
	# 7) Set the period register of timer 2

	EI
	# Setup multi vector mode (enabling interrupt vector table)
	# INTCON<12> = 1 for multi vector mode
	LI $t0, 1 << 12
	SW $t0, INTCONSET

	# Turn off timer 2
	LI $t0, 1 << 15
	SW $t0, T2CONCLR

	# Setting up timer 2 as a 16 bit 
	# T2CON<3> = 0, 16-bit Timer Mode Select Bit
	LI $t0, 1 << 3
	SW $t0, T2CONCLR

	# Selecting the parent clock for the timer 
	# T2CON<1> = 0, Internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T2CONCLR

	# Setting the prescalar value for the peripheral clock
	# T2CON<6:4> = 0b001, 2 prescalar value
	LI $t0, 7 << 4
	SW $t0, T2CONCLR
	LI $t0, 1 << 4
	SW $t0, T2CONSET

	# Setting the counter timer count register to 0
	SW $zero, TMR2

	# Set the period register value
	# CLK = 40Mhz, prescalar = 2, TimerCLK = (40Mhz/2)
	LI $t0, 999
	SW $t0, PR2

	# Turn on timer 2
	LI $t0, 1 << 15
	SW $t0, T2CONSET 
	EI
	JR $ra
    .end motor_timer
	
    .ent left_motor
	left_motor:
	# Setup output compare 2 
	# 1) Set the corresponding TRIS pins as outputs
	# 2) Turn off the output compare module
	# 3) Set the OC2R register for the desired duty cycle
	# 4) Set the OCR2S buffer register for the desired duty cycle
	# 5) Select the output compare mode 
	# 6) Select timer 2 as clock source
	# 7) Select 16-bit compare mode
	# 8) Turn on output compare 2 module 
	# 9) Set the priority for output compare 2 interrupt
	# 10) Enable output compare interrupt
	# 11) Enable global interrupts

	DI # Turning off all external interrupts 

	# **************************************************************************
	# Setting up output capture 2 
	# Set TRISD pins 7 an 1 as output, pin 7 direction, pin 1 enable 
	SW $zero, LATD
	LI $t0, 1 << 1
	SW $t0, TRISDCLR

	LI $t0, 1 << 7
	SW $t0, TRISDCLR

	# Turn off output compare module 2
	# OC2CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, OC2CONCLR

	# Setting the duty cycle of the motor
	# Set register OC2R to 0
	LI $t0, 0
	SW $t0, OC2R

	# Setting the duty cycle of the motor
	# Set butter register OC2RS to 0
	LI $t0, 0
	SW $t0, OC2RS

	# Selecting timer 2 as the clock source
	# OC2CON<3> = 0
	LI $t0, 1 << 3
	SW $t0, OC2CONCLR

	# Selecting the operation mode or
	# OC2CON<2:0> = 0b110
	LI $t0, 7
	SW $t0, OC2CONCLR

	LI $t0, 6
	SW $t0, OC2CONSET

	# Selecting compare mode for the output compare module
	# OC2CON<5> = 0
	LI $t0, 1
	SW $t0, OC2CONCLR

	# Turn on output compare module 2
	# OC2CON<15> = 1
	LI $t0, 1 << 15
	SW $t0, OC2CONSET

	# Set the priority for the output compare interrupt 
	# IPC2<20:18> = 0b110
	LI $t0, 7 << 18
	SW $t0, IPC2CLR

	LI $t0, 6 << 18
	SW $t0, IPC2SET

	# Enable the output compare interrupt
	# IEC0<10> = 1
	LI $t0, 1 << 10
	SW $t0, IEC0SET

	EI
	JR $ra
    .end left_motor

    .ent right_motor
	right_motor:
	# Setup output compare 3 
	# 1) Set the corresponding TRIS pins as outputs
	# 2) Turn off the output compare module
	# 3) Set the OCR3 register for the desired duty cycle
	# 4) Set the OCR3S buffer register for the desired duty cycle
	# 5) Select the output compare mode 
	# 6) Select timer 3 as clock source
	# 7) Select 16-bit compare mode
	# 8) Turn on output compare 3 module 
	# 9) Set the priority for output compare 3 interrupt
	# 10) Enable output compare interrupt
	# 11) Enable global interrupts

	DI # Turning off all external interrupts 

	# Setup multi vector mode (enabling interrupt vector table)
	# INTCON<12> = 1 for multi vector mode
	LI $t0, 1 << 12
	SW $t0, INTCONSET

	# **************************************************************************
	# Setting up output capture 3 
	# Set TRISD pins 6 and 2 as output, pin 6 direction, pin 2 enable 
	SW $zero, LATD
	LI $t0, 1 << 2
	SW $t0, TRISDCLR

	LI $t0, 1 << 6
	SW $t0, TRISDCLR

	# Turn off output compare module 3
	# OC3CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, OC3CONCLR

	# Setting the duty cycle of the motor
	# Set register OC3R to 0
	LI $t0, 0
	SW $t0, OC3R

	# Setting the duty cycle of the motor
	# Set butter register OC2RS to 0
	LI $t0, 0
	SW $t0, OC3RS

	# Selecting timer 2 as the clock source
	# OC3CON<3> = 0
	LI $t0, 1 << 3
	SW $t0, OC3CONCLR

	# Selecting the operation mode or
	# OC3CON<2:0> = 0b110
	LI $t0, 7
	SW $t0, OC3CONCLR

	LI $t0, 6
	SW $t0, OC3CONSET

	# Selecting compare mode for the output compare module
	# OC3CON<5> = 0
	LI $t0, 1
	SW $t0, OC3CONCLR

	# Turn on output compare module 2
	# OC3CON<15> = 1
	LI $t0, 1 << 15
	SW $t0, OC3CONSET

	# Set the priority for the output compare interrupt 
	# IPC3<20:18> = 0b110
	LI $t0, 7 << 18
	SW $t0, IPC3CLR

	LI $t0, 6 << 18
	SW $t0, IPC3SET

	# Enable the output compare interrupt
	# IEC0<14> = 1
	LI $t0, 1 << 14
	SW $t0, IEC0SET

	EI
	JR $ra
    .end right_motor
    
    .ent setup_input_capture_2
	setup_input_capture_2:
	DI

	# Turn off input capture 2 RD9
	# IC2CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, IC2CONCLR

	# Select clock source timer 2
	# IC2CON<7> = 1
	LI $t0, 1 << 7
	SW $t0, IC2CONSET

       # 16-Bit resource capture
       # IC2CON<8> = 0
       LI $t0, 1 << 8
       SW $t0, IC2CONCLR

       # Interrupt on every event
       # IC2CON<6:5> = 0b00
       LI $t0,  3 << 5
       SW $t0, IC2CONCLR

       # Edge Detection Mode 
       # IC2CON<2:0> = 0b011
       LI $t0, 7 
       SW $t0, IC2CONCLR

       LI $t0, 1
       SW $t0, IC2CONSET

       # *************************************************8
       # Set interrupt priority 
       # Disable interrupt
       # IEC0<9> = 0
       LI $t0, 1 << 9
       SW $t0, IEC0CLR

       # Set interrupt priority
       # IPC2<12:10> = 0b110
       LI $t0, 7 << 10
       SW $t0, IPC2CLR

       LI $t0, 6 << 10
       SW $t0, IPC2SET

       # Set interrupt priority 
       # Disable interrupt
       # IEC0<9> = 0
       LI $t0, 1 << 9
       SW $t0, IEC0SET

       EI  
       JR $ra
    .end setup_input_capture_2

    .section .vector_9, code
    J input_capture_handler_2 

    .Text
    .ent input_capture_handler_2  
	input_capture_handler_2:
	    DI

	    ADDI $sp, $sp, -8
	    SW $ra, 0($sp)
	    SW $t0, 4($sp)

	    # Clear interrupt flag
	    # IFS0<9> = 0, Cleared interrupt flag
	    LI $t0, 1 << 9
	    SW $t0, IFS0CLR
	    
	    LW $t0, left_count # Load count value 
	    ADDI $t0, $t0, 1 # Add one to the right_count 
	    SW $t0, left_count # Update right_count	    
	    
# 	    LW $t0, left_count # Load count value 
# 	    ADDI $t0, $t0, 1 # Add one to the left_count 
# 	    SW $t0, left_count # Update left_count
# 	    LI $t0, 2 
# 	    LW $t1, left_count
# 	    BEQ $t0, $t1, left_mea_two   # Check if right count equal to 2, jump to left_mea_two
# 	    LW $t1, IC2BUF # Load the current timer count   
# 	    SW $t1, left_one
# 	    J endleft
# 	    
# 	    left_mea_two:
# 	    SW $zero, left_count # Reset the left_count
# 	    LW $t0, left_one
# 	    LW $t1, IC2BUF # Load the current timer count 
# 	    SUB $t0, $t1, $t0 # Get the difference between the two measurements
# 	    LW $t1, left_sum
# 	    ADD $t0, $t1, $t0
# 	    SW $t0, left_sum
# 	    
# 	    LW $t0, n_left # Increment n_left
# 	    ADDI $t0, $t0, 1
# 	    SW $t0, n_left
# 	    endleft:
	    
	    LW $ra, 0($sp)
	    LW $t0, 4($sp)
	    ADDI $sp, $sp, 8

	    EI
	    ERET 
    .end input_capture_handler_2

    .ent setup_input_capture_3
	setup_input_capture_3:
	DI

	# Turn off input capture 1 RD6
	# IC3CON<15> = 0
	LI $t0, 1 << 15
	SW $t0, IC3CONCLR

	# Select clock source timer 2
	# IC3CON<7> = 1
	LI $t0, 1 << 7
	SW $t0, IC3CONSET

       # 16-Bit resource capture
       # IC3CON<8> = 0
       LI $t0, 1 << 8
       SW $t0, IC3CONCLR

       # Interrupt on every event
       # IC3CON<6:5> = 0b00
       LI $t0,  3 << 5
       SW $t0, IC3CONCLR

       # Edge Detection Mode 
       # IC3CON<2:0> = 0b011
       LI $t0, 7 
       SW $t0, IC3CONCLR

       LI $t0, 1
       SW $t0, IC3CONSET

       # *************************************************8
       # Set interrupt priority 
       # Disable interrupt
       # IEC0<13> = 0
       LI $t0, 1 << 13
       SW $t0, IEC0CLR

       # Set interrupt priority
       # IPC3<12:10> = 0b110
       LI $t0, 7 << 10
       SW $t0, IPC3CLR

       LI $t0, 6 << 10
       SW $t0, IPC3SET

       # Set interrupt priority 
       # Disable interrupt
       # IEC0<13> = 0
       LI $t0, 1 << 13
       SW $t0, IEC0SET

       EI  
       JR $ra
    .end setup_input_capture_3

    .section .vector_13, code
    J input_capture_handler_3 

    .Text
    .ent input_capture_handler_3  
	input_capture_handler_3:
	    DI

	    ADDI $sp, $sp, -8
	    SW $ra, 0($sp)
	    SW $t0, 4($sp)
	    
	    # Clear interrupt flag
	    # IFS0<13> = 0, Cleared interrupt flag
	    LI $t0, 1 << 13
	    SW $t0, IFS0CLR
	   
	    LW $t0, right_count # Load count value 
	    ADDI $t0, $t0, 1 # Add one to the right_count 
	    SW $t0, right_count # Update right_count	    
	    
# 	    LW $t0, right_count # Load count value 
# 	    ADDI $t0, $t0, 1 # Add one to the right_count 
# 	    SW $t0, right_count # Update right_count
# 	    LI $t0, 2 
# 	    LW $t1, right_count
# 	    BEQ $t0, $t1, right_mea_two   # Check if right count equal to 2, jump to right_mea_two
# 	    LW $t1, IC3BUF # Load the current timer count   
# 	    SW $t1, right_one
# 	    J endright
# 	    
# 	    right_mea_two:
# 	    SW $zero, right_count # Reset the right_count
# 	    LW $t0, right_one
# 	    LW $t1, IC3BUF # Load the current timer count 
# 	    SUB $t0, $t1, $t0 # Get the difference between the two measurements
# 	    LW $t1, right_sum
# 	    ADD $t0, $t1, $t0
# 	    SW $t0, right_sum
# 	    
# 	    LW $t0, n_right # Increment n_right
# 	    ADDI $t0, $t0, 1
# 	    SW $t0, n_right
# 	    endright:
	    
	    LW $ra, 0($sp)
	    LW $t0, 4($sp)
	    ADDI $sp, $sp, 8

	    EI
	    ERET 
    .end input_capture_handler_3

    .ent setup_timer_1
	setup_timer_1:
	DI

	# Turn off timer 1
	# TICON<15> = 0
	LI $t0, 1 << 15
	SW $t0, T1CONCLR

	# Select parent clock
	# T1CON<1> = 0, internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T1CONCLR

	# Set prescalar value 
	# T1CON<5:4> = 0b10 1:64
	LI $t0, 3 << 4
	SW $t0, T1CONCLR

	LI $t0, 2 << 4
	SW $t0, T1CONSET

	# Set the TMR1 to zero
	SW $zero, TMR1

	# Set the period register 
	# Peripheral Clock is running at 40MHz, Prescalar 64, Timer Running at 625000Hz
	# 
	LI $t0, 8000
	SW $t0, PR1

	# Setup Timer 1 interrupt
	# Disable timer 1 interrupt
	# IEC0<4> = 0
	LI $t0, 1 << 4
	SW $t0, IEC0CLR

	# Set interrupt priority
	# IPC1<4:2> = 0b110
	LI $t0, 7 << 2
	SW $t0, IPC1CLR

	LI $t0, 6 << 2
	SW $t0, IPC1SET

	# Enable timer 1 interrupt
	# IEC0<4> = 0
	LI $t0, 1 << 4
	SW $t0, IEC0SET

	EI
	JR $ra
    .end setup_timer_1

    .section .vector_4, code
    J timer_1_handler 

    .Text
     .ent timer_1_handler 
 	timer_1_handler:
 	DI
 
 	ADDI $sp, $sp, -12
 	SW $ra, 0($sp)
 	SW $t0, 4($sp)
 	SW $t1, 8($sp)
 
 	# Clear interrupt flag
 	# IFS0<4> = 0, Cleared interrupt flag
 	LI $t0, 1 << 4
 	SW $t0, IFS0CLR
 	
	LW $t0, left_count # Load the left counter time
	MUL $t0, $t0, 10
	LW $t1, right_count # Load the right counter time
	MUL $t1, $t1, 10
	SW $zero, right_count # Reset the left counter
	SW $zero, left_count # Reset the right counter
	
	LW $t2, n_count # Increment the trial number for right
	ADDI $t2, $t2, 1 
	SW $t2, n_count
	
	LW $t2, n_count # Check if count is greater than 50
	SLT $t3, $t2, 5
	BNEZ $t3, endadjust # If 0 preceed if 1 jump to endadjust
	
	BEQ $t0, $t1, endadjust # If both timer count equal do not adjust 
	SLT $t0, $t0, $t1  # Check if the right count is greater
	BEQZ $t0, decrement # If left is not greater than right decrement 
	J increment
	
	increment:
	LW $t0, OC2R
	BEQ $t0, $t1, endadjust
	ADDI $t0, $t0, 20
	SW $t0, OC2RS
	J endadjust
	
	decrement:
	LW $t0, OC2R
	BEQ $t0, $t1, endadjust
	ADDI $t0, $t0, -20
	SW $t0, OC2RS
	
 	endadjust:
    
 	LW $ra, 0($sp)
 	LW $t0, 4($sp)
 	LW $t1, 8($sp)
	ADDI $sp, $sp, 12
 
 	EI
 	ERET
     .end timer_1_handler 
     
     .ent turn_on_input_capture
	turn_on_input_capture:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 1 << 15
	SW $t0, T1CONSET 
	SW $t0, IC2CONSET
	SW $t0, IC3CONSET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end turn_on_input_capture
    
    .ent turn_off_input_capture
	turn_off_input_capture:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 1 << 15
	SW $t0, T1CONCLR 
	# SW $t0, IC2CONCLR
	# SW $t0, IC3CONCLR
	SW $zero, n_count
	SW $zero, left_count
	SW $zero, right_count
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end turn_off_input_capture
.endif





