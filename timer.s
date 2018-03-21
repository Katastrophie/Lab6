.ifndef TIMER_S
TIMER_S:

.data
tmr1Tenths: .word 0

.text

# Setup Timer1 to count tenths of a second. All values are stored in tmr1Tenths in data memory.
# TMR1 should now be used to time small delays in the program.
.ent setupTMR1
setupTMR1:
    # Disable TMR1
    sw $zero, T1CON

    # Set input clk to PBCLK - T1CON<1> = 0; (already done)
    # Prescaler of 256 - Set T1CON<5:4> = 0b11
    li $t0, 0b11 << 4
    sw $t0, T1CONSET
    
    # clear the timer
    sw $zero, TMR1
    
    # set the timer count value;
    li $t0, 15624 # 1/10 of a second -1 when using a 40 MHz PBCLK
    sw $t0, PR1

    # Set Priority of Timer 1
    # Priority = 5; Sub-Priority = 1;
    # IPC1<4:2> = 5; IPC1<1:0> = 1
    li      $t0, 0b11111
    sw      $t0, IPC1CLR    # Clear out any priority given to timer1 previously
    
    li      $t0, 0b11001    # sets priority to 0b110, sub-priority to 0b01
    sw      $t0, IPC1SET
    
    li      $t0, 1 << 4
    sw      $t0, IEC0SET    # Enable the interrupt
    sw      $t0, IFS0CLR    # Clears the interrupt flag (avoiding potential spurious interrupt)
      
    jr $ra
.end setupTMR1

# Start TMR1
.ent startTMR1
startTMR1:
    li $t0, 1 << 15
    sw $t0, T1CONSET

    jr $ra
.end startTMR1

# Get how many tenths of a second have elapsed since Timer 1 started.
.ent getTMR1Tenths
getTMR1Tenths:
    lw $v0, tmr1Tenths
    jr $ra
.end getTMR1Tenths


# Waits for a specified amount of time given in $a0
.ent waitForTime
waitForTime:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    jal startTMR1
    keepWaiting:
        jal getTMR1Tenths
        bne $a0, $v0, keepWaiting
    jal stopTMR1

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
.end waitForTime

# Stop Timer1 and clear how many tenths of seconds have elapsed.
.ent stopTMR1
stopTMR1:
    li $t0, 1 << 15
    sw $t0, T1CONCLR
    sw $zero, tmr1Tenths

    jr $ra
.end stopTMR1



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
    LI $t0, 249 # with a prescaler of 8 and PR2 of 249, f_PWM = 20kHz
    SW $t0, PR2
    
    # Start Timer 2
    LI $t0, 1 << 15
    SW $t0, T2CONSET
      
    JR $ra
.end setupTMR2

.ent startTMR2
startTMR2:
    LI $t0, 1 << 15
    SW $t0, T2CONSET
    
    JR $ra    
.end startTMR2
    

# Hook to Timer 1 handler
.section .vector_4, code
    j tmr1Handler

.text
    
.ent tmr1Handler
tmr1Handler:
    di # disable global interrupts - don't want an interrupt to interrupt this interrupt
    
    addi    $sp, $sp, -4	# Prepare stack pointer.
    sw      $t0, 0($sp)         # Push $t0 on stack

    # Increment tmr1Tenths by 1
    lw      $t0, tmr1Tenths
    addi    $t0, $t0, 1
    sw      $t0, tmr1Tenths

    # Clear the interrupt flag
    li      $t0, 1 << 4
    sw      $t0, IFS0CLR        # Clears the interrupt flag

    # Reset Timer1 to Zero
    sw      $zero, TMR1         # Ensures next count occurs
    
    lw      $t0, 0($sp)         # Pop $t0 off of stack.
    addi    $sp, $sp, 4         # Restore stack pointer
    
    ei                          # re-enable global interrupts
    eret                        # exception return, set PC = EPC    
.end tmr1Handler

.endif
