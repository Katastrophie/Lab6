.ifndef TIMER_S
TIMER_S:
    
.ent setupTMR2
setupTMR2:
    # Disable the timer
    SW $zero, T2CON
    
    # Set input clk to PBCLK - T2CON<1> = 0; (already done)
    # Set input clk as 16-bit timer - T2CON<3> = 0; (already done)
    # Prescaler of 8 - Set T2CON<6:4> = 0b011
    LI $t0, 0b011 << 4
    SW $t0, T2CONSET
    
    # clear the timer
    SW $zero, TMR2
    
    # set the timer count value;
    # setting up the PWM frequency:
    # f_PWM = f_PBCLK / (prescaler * (PR2 + 1))
    # f_PWM * (prescaler * (PR2 + 1)) = f_PBCLK
    # (f_PBCLK / f_PWM) = prescaler * (PR2 + 1)
    # (f_PBCLK / f_PWM)*(1/prescaler) - 1 = PR2
    # (40MHz / 20kHz) * (1/8) - 1 = 249
    LI $t0, 249 # with a prescaler of 8 and PR2 of 499, f_PWM = 20kHz
    SW $t0, PR2
      
    JR $ra
.end setupTMR2

.ent startTMR2
startTMR2:
    LI $t0, 1 << 15
    SW $t0, T2CONSET
    
    JR $ra    
.end startTMR2
    
.endif


