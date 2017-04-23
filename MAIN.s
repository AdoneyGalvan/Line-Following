.global main
    
.include "MOTORS.s"
.include "SENSORS.s"
.include "BUTTON.s"
.data
   drive_case: .word forward, forward, forward, forward, forward, forward, forward, pivot_right, forward, forward, forward, pivot_right, forward, pivot_left, pivot_left, forward
.text
    
    
.ent main
main:
    jal setup_sensor
    jal left_motor
    jal right_motor
    jal motor_timer
    jal setup_button
#     JAL setup_input_capture_2 # Configures input capture for left motor 
#     JAL setup_input_capture_3 # Configures input capture for right motor 
#     JAL setup_timer_1 # Configures a 16-bit timer using timer 1, for adjust the motor duty cycles
#     
    while:
    JAL get_button
    LI $t0, 1
    BEQ $t0, $v1, TURNON
    J while
    
    move $s1, $zero	# initializes prev sensor value
    
    TURNON:
    jal read_sensor
    move $s0, $v0	# saves sensor value to s0 reg
    beq $s0, $s1, TURNON    # jumps to turn on and reads sensors if sensor value hasn't changed
    
    move $a0, $v0
    jal movement
    move $s1, $s0
    j TURNON
.end main
   
.ent movement
    movement:
    ADDI $sp, $sp, -4
    SW $ra, 0($sp)
    
    move $t0, $a0
    
    move $a0, $zero
    move $a1, $zero
    jal write_to_motors
    
    # loads drive_case address
    la $t1, drive_case
    sll $t0, $t0, 2	# multiplies index by 4
    add $t1, $t0, $t1	# offsets index
    lw $t0, 0($t1)		# loads jump value
    jr $t0
    
    forward:
    # sets wheels to forward
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDCLR

    # sets to 80% duty cycle
    li $a0, 650
    li $a1, 640
    jal write_to_motors
    j end_movement
    
    pivot_left:
    li $t0, 0b10000000
    sw $t0, LATDCLR
    li $t0, 0b1000000
    sw $t0, LATDCLR
    
    li $a0, 710 # left
    li $a1, 710 # right
    jal write_to_motors
    j end_movement
    
    pivot_right:
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDSET
    
    li $a0, 710 # left
    li $a1, 710 # right
    jal write_to_motors
    j end_movement
    
    end_movement:
    
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    jr $ra
.end movement
    
    



