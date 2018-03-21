.ifndef OUTPUTCOMPARE_S
OUTPUTCOMPARE_S:
    
.ent setupOC1
setupOC1:
    # OC1R, OC1RS, OC1CON
    # OC1 is on pin RD00, (Digilent JD-02)
    
    # the H-bridge module will have JD-01 (RD09) be the dir pin
    # and JD-02 (RD00) be the en pin (which should be driven by the PWM signal)
    
    # Setting dir and en pins as outputs
    li $t0, 0b1000000001
    sw $t0, TRISDCLR
    sw $t0, LATDCLR
    
    # Clear all associated hardware registers
    sw $zero, OC1CON
    sw $zero, OC1R
    sw $zero, OC1RS
    
    # Setup initial duty cycle - commented out because we want our motor to start off
    LI $t0, 2   # num => duty cycle % = num / (PR + 1); num = duty cycle * (PR + 1)
    SW $t0, OC1R
    
    # OC1CON<15> = 1 (turn on the output compare module)
    # OC1CON<5> = 0 (setting the output compare as a 16-bit value)
    # OC1CON<3> = 0 (set timer 2 as the base timer for the PWM signal)
    # OC1CON<2:0> = 0b110 (setup output compare in PWM mode without fault)
    LI $t0, 0b1000000000000110
    SW $t0, OC1CONSET
    
    JR $ra
.end setupOC1  

.ent setupOC3
setupOC3:

    # OC3R, OC3RS, OC3CON
    # OC3 is on pin RD02, (Digilent JD-08)

    # the H-bridge module will have JD-07 (RD01) be the dir pin
    # and JD-08 (RD02) be the en pin (which should be driven by the PWM signal)

    # Setting dir and en pins as outputs
    li $t0, 0b110
    sw $t0, TRISDCLR
    sw $t0, LATDCLR

    # Clear all associated hardware registers
    sw $zero, OC3CON
    sw $zero, OC3R
    sw $zero, OC3RS
    
    # Setup initial duty cycle - commented out because we want our motor to start off
    LI $t0, 2   # num => duty cycle % = num / (PR + 1); num = duty cycle * (PR + 1)
    SW $t0, OC3R

    # OC2CON<15> = 1 (turn on the output compare module)
    # OC2CON<5> = 0 (setting the output compare as a 16-bit value)
    # OC2CON<3> = 0 (set timer 2 as the base timer for the PWM signal)
    # OC2CON<2:0> = 0b110 (setup output compare in PWM mode without fault)
    li $t0, 0b1000000000000110
    sw $t0, OC3CONSET
    
    jr $ra
.end setupOC3


# a0 = Left Wheel DC%
# a1 = Right Wheel DC%
.ent forwardOCMs
forwardOCMs:
    # Disable OCM Outputs
    sw $zero, OC1RS
    sw $zero, OC3RS
    
    # Ensure Dir Pins set to go "Forward"
    li $t0, 0b1 << 1
    sw $t0, LATDSET

    li $t0, 0b1
    sw $t0, LATDCLR
    
    
    # Set Duty Cycle of OCMs
    sw $a0, OC1RS
    sw $a1, OC3RS

    jr $ra
.end forwardOCMs

# a0 = Left Wheel DC%
# a1 = Right Wheel DC%
.ent backwardOCMs
backwardOCMs:
    # Disable both H-Bridges
    sw $zero, OC1RS
    sw $zero, OC3RS
    
    # Ensure Dir Pins set to go "Forward"
    li $t0, 0b1
    sw $t0, LATDSET
    li $t0, 0b1 << 9
    sw $t0, LATDCLR
    
    # Set Duty Cycle of OCMs
    sw $a0, OC1RS
    sw $a1, OC3RS

    jr $ra
.end backwardOCMs
    
.endif
