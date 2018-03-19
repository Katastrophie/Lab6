.ifndef OUTPUTCOMPARE_S
OUTPUTCOMPARE_S:
    
.ent setupOC1
setupOC1:
    # OC1R, OC1RS, OC1CON
    # OC1 is on pin RD00, (Digilent JD-02)
    
    # the H-bridge module will have JD-01 (RD09) be the dir pin
    # and JD-02 (RD00) be the en pin (which should be driven by the PWM signal)
    
    # Setting dir and en pins as outputs
    LI $t0, 0b1000000001
    SW $t0, TRISDCLR
    SW $t0, LATDCLR
    
    # Clear all associated hardware registers
    SW $zero, OC1CON
    SW $zero, OC1R
    SW $zero, OC1RS
    
    # Setup initial duty cycle - commented out because we want our motor to start off
    # LI $t0, num   # num => duty cycle % = num / (PR + 1); num = duty cycle * (PR + 1)
    # SW $t0, OC1R
    # SW $t0, OC1RS
    
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
    LI $t0, 0b110
    SW $t0, TRISDCLR
    SW $t0, LATDCLR

    # Clear all associated hardware registers
    SW $zero, OC3CON
    SW $zero, OC3R
    SW $zero, OC3RS

    # OC2CON<15> = 1 (turn on the output compare module)
    # OC2CON<5> = 0 (setting the output compare as a 16-bit value)
    # OC2CON<3> = 0 (set timer 2 as the base timer for the PWM signal)
    # OC2CON<2:0> = 0b110 (setup output compare in PWM mode without fault)
    LI $t0, 0b1000000000000110
    SW $t0, OC3CONSET
    
    jr $ra
.end setupOC3
    
.endif





