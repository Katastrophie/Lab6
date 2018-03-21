.ifndef BUTTONS_S
BUTTONS_S:

    
# Buttons Library
# This library only works for Digilent ProMX795F512L Board
# void setupButtons(void)
# int getButtons(void)
# void testButtons(void)
    
.text
     
# void setupButtons(void)
.ent setupButtons
setupButtons:
    # Buttons 1 & 2 are in RG06 & RG07
    LI $t0, 0xC0	# TRISGSET = 0b11000000;
    SW $t0, TRISGSET

    # Button 3 is in RA00
    LI $t0, 0x1		# TRISASET = 0b1;
    SW $t0, TRISASET

    # DDPCONbits.JTAGEN = 0; // Disable JTAG controller so we can use button 3
    LW $t0, DDPCON	    # Load the current contents of DDPCON Register
    ANDI $t0, $t0, 0xFFF7   # Disable only JTAGEN bit (which is bit 3 of DDPCON)
    SW $t0, DDPCON	    # Store new contents (only bit 3 cleared) to DDPCON

    JR $ra
.end setupButtons
    
# int getButtons(void)
.ent getButtons
getButtons:
    ADDI $sp, $sp, -12 # push s0, s1, s2 onto the stack to preserve them
    SW $s0, 0($sp)
    SW $s1, 4($sp)
    SW $s2, 8($sp)
    
    # Get buttons
    LW	$s0, PORTG
    ANDI $s1, $s0, 0xC0	# PORTG & 0xC0
    # Get button 3
    LW	$s0, PORTA
    ANDI $s2, $s0, 0x1	# PORTA & 0x1
    
    SRL $s1, $s1, 6	# s1 = s1 >> 6 (s1[0] = btn1, s1[1] = btn2)
    SLL $s2, $s2, 2	# (s2[2] = btn3)
    OR $v0, $s1, $s2
        
    LW $s2, 8($sp)
    LW $s1, 4($sp)
    LW $s0, 0($sp)
    ADDI $sp, $sp, 12 # pop s0,s1,s2 off the stack to get their previous data values
    
    JR $ra
.end getButtons
    
     
.endif






