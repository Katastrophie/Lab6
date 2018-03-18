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

.ent setupOC2
setupOC2:

    # OC2R, OC2RS, OC2CON
    # OC2 is on pin RD01, (Digilent JD-07)

    # the H-bridge module will have JD-07 (RD01) be the dir pin
    # and JD-10 (RD12) be the en pin (which should be driven by the PWM signal)

    # Setting dir and en pins as outputs
    LI $t0, 0b1000000000010
    SW $t0, TRISDCLR
    SW $t0, LATDCLR

    # Clear all associated hardware registers
    SW $zero, OC2CON
    SW $zero, OC2R
    SW $zero, OC2RS

    # OC2CON<15> = 1 (turn on the output compare module)
    # OC2CON<5> = 0 (setting the output compare as a 16-bit value)
    # OC2CON<3> = 0 (set timer 2 as the base timer for the PWM signal)
    # OC2CON<2:0> = 0b110 (setup output compare in PWM mode without fault)
    LI $t0, 0b1000000000000110
    SW $t0, OC2CONSET
    
    jr $ra
.end setupOC2
    
.endif





