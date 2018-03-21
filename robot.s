.include "outputCompare.s"
.include "timer.s"

.ifndef ROBOMAL_S
ROBOMAL_S:
  
.data
    
# Harvard Architecture RoboMAL
# The most significant 8 bits must be in Hexadecimal and represent the operation 
# code followed by zeros. The least significant bits 16 bits are the roboMAL
# operands in hexadecimal. The instruction must be 32 bits long.
ROBO_Instruction: .word 0x2A000001, 0x2D00001E, 0x33000000 # , 0x2C000011, 0x2B000011, 0x33000000# , 0x29000000, 0x2A000000, 0x2B000000, 
# The above instructions tell the robot to go forward, 
# continue the last operation for approximately 30 tenths of a second (3 sec), 
# then halt the program.
    

# This array stores variables, it can be in any number format.
ROBO_Data: .word 80, 5, 4

# These are wheel speeds
slow:   .word 175   # 70% Duty Cycle
medium: .word 212   # 85% Duty Cycle
fast:   .word 249   # 100% Duty Cycle

.text

# ******************************************************************************
# * Function Name:	 runProgram                                                                                                       
# * Description:	 This function runs the RoboMAL program by first 
# *			 initializing all my simulation registers. It runs the 
# *			 program until the last operation is performed.
# *                                                                                                                         
# * Inputs:		 None
# * Outputs:		 None
# *                                                                                                                         
# * Errors:		 If the user doesn't change the end operation in the 
# *			 code with the highest 32 bits of the last operation in 
# *			 Robo_Instruction the program will end early. It will 
# *			 not end if the end operation in runProgram does not 
# *			 exist in the Robo_Instruction.
# *         
# * Registers Preserved: It perserves s0-4 as my accumilation, program counter,
# *                      instruction register, opcode register, and 
# *                      operand register respectively. 
# *                                                                                                                   
# *                                                                                                                         
# * Preconditions:	 The program has to run until the last operation in the 
# *			 Robo_Instruction.                                                                                                         
# *                                                                                                                         
# * Revision History:	 2.26.18, Kaitlin Ferguson                                                                                                       
# ******************************************************************************
.ent runProgram
runProgram:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # initialize my CPU registers to 0
    move $s0, $zero # Accumilation Regiester
    move $s1, $zero # Program Counter
    move $s2, $zero # Instruction Register
    move $s3, $zero # Opcode Register
    move $s4, $zero # Operand Register
    
Roboloop:
    jal simulateClockCycle
    beq $s3, 0x3300, endProgram # Halt Instruction Received, Return to Main
    j Roboloop
endProgram:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
.end runProgram
 
# ******************************************************************************
# * Function Name:	 simulateClockCycle                                                                                                   
# * Description:	 This function calls the the fetch, decode, and execute 
# *			 cycle that the simulation uses.                                                                                  
# * Inputs:		 None                                                                                                                 
# * Outputs:		 None                                                                                                               
# *                                                                                                                         
# * Errors:		 None.
# *         
# * Registers Preserved: None
# *                                                                                                                                                                                                                      
# * Preconditions:	 None                                                                                                       
# *                                                                                                                         
# * Revision History:	 2.26.18, Kaitlin Ferguson                                                                                                       
# ******************************************************************************
.ent simulateClockCycle
simulateClockCycle:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal fetch
    jal decode
    jal execute
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
.end simulateClockCycle
    

# ******************************************************************************
# * Function Name: fetch                                                                                                  
# * Description:	 This function operates the fetch part of the 
# *			 simulation cycle, it fetches the current instruction 
# *			 and stores it in memory.
# *                                                                                            
# * Inputs:		 Robo_Instruction, the array of instructions you want 
# *			 the RoboMAL to perform. If empty, no operations will 
# *			 be preformed.
# *
# * Outputs:		 The current operation from Robo_Instruction                                                                                                               
# *                                                                                                                         
# * Errors:		 None
# *         
# * Registers Preserved: The program counter s1 and the instruction register s2.
# *                                                                                                                                                                                                                      
# * Preconditions:	 None                                                                                                       
# *                                                                                                                         
# * Revision History:	 2.26.18, Kaitlin Ferguson                                                                                                       
# ******************************************************************************
.ent fetch
fetch:
    # Getting instruction at base + 4*offset
    la $t0, ROBO_Instruction # base of instruction memory
    sll $t1, $s1, 2	     # PC * 4
    add $t0, $t0, $t1        # ROBO_Instruction + 4*PC
			     # ROBO_Instruction[PC]
    lw $s2, 0($t0)	     # fetch the instruction, store in s2
    # Assuming sequential program, prepare for next fetch
    addi $s1, $s1, 1	     # PC += 1
    jr $ra       
.end fetch
    

# ******************************************************************************
# * Function Name:	 decode                                                                                               
# * Description:	 This function operates the decode part of the 
# *			 simulation cycle, it determines the operation code and 
# *			 operand. 
# *                                                                                            
# * Inputs:		 The current operation from Robo_Instruction
# *
# * Outputs:		 The operation code and operand                                                                                                               
# *                                                                                                                         
# * Errors:		 If the instruction is not 32 bits or isn't in the 
# *			 right format specified above Robo_MAL, the operation 
# *			 won't perform as intended. 
# *         
# * Registers Preserved: The instruction register s2, opcode register s3,
# *                      and operand register s4.
# *                                                                                                                                                                                                                      
# * Preconditions:	 Instructions must be the right format and length.                                                                                                     
# *                                                                                                                         
# * Revision History:	 2.26.18, Kaitlin Ferguson                                                                                                       
# ******************************************************************************
.ent decode
decode:
    # break up instruction register into opcode and operand
    # instruction is 0x????_????
    # opcode is 0x????_0000
    # operand is 0x0000_????
    # li $t0, 0xFFFF0000 # don't need to mask, shift right
    # and $s3, $s2, $t0	 # empties lower bits for us
    srl $s3, $s2, 16	# opcode is s3 = 0x????
    li $t0, 0xFFFF
    and $s4, $s2, $t0   # operand is s4 = 0x????
    
    jr $ra    
.end decode
    
# ******************************************************************************
# * Function Name: execute                                                                                               
# * Description:	 This function operates the execute part of the 
# *			 simulation cycle, it executes the operand based on the 
# *			 operation code. 
# *                                                                                            
# * Inputs:		 The operation code and operand.
# *
# * Outputs:		 The result of the operation to the operand.                                                                                                                
# *                                                                                                                         
# * Errors:		 None
# *         
# * Registers Preserved: The accumilation register s0 and s5. 
# *                                                                                                                                                                                                                      
# * Preconditions:	 None                                                                                                    
# *                                                                                                                         
# * Revision History:	 2.26.18, Kaitlin Ferguson                                                                                                       
# ******************************************************************************
.ent execute
execute:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    

    # Robot Control Instructions (RCI):
    beq $s3, 0x2800, left
    beq $s3, 0x2900, right
    beq $s3, 0x2A00, forwards
    beq $s3, 0x2B00, backwards
    beq $s3, 0x2C00, breaking
    beq $s3, 0x2D00, continue       # Allows continuing of the last command
                                    # for a set amount of tenths of a second.
    

    # End of the program, robot stops.
    halt:
	sw $zero, OC1RS
	sw $zero, OC3RS
	j end

    # "Turn left" - No robot, so LED4 turns on. 
    left:
        # Need to set DC% of Left Wheel < DC% of Right Wheel
        lw $a0, medium # Left Wheel
        lw $a1, fast # Right Wheel
        jal forwardOCMs
	
	j end

    # "Turn right" - No robot, so LED1 turns on.
    right:
        # Need to set DC% of Right Wheel < DC% of Left Wheel
        lw $a0, fast # Left Wheel
        lw $a1, medium # Right Wheel
        jal forwardOCMs

        j end

    # "Go forward" 
    forwards:
        # Kick Start Forward Drive
        lw $a0, fast # 100% duty
        lw $a1, fast
        jal forwardOCMs

        jal startTMR1
        li $t0, 1   # Wait for 0.1 sec.
        waitForTMRFWD:
            jal getTMR1Tenths
            bne $t0, $v0, waitForTMRFWD
        jal stopTMR1
        
        # Now set desired speed
        beq $s4, 0, slowFWD
	beq $s4, 1, mediumFWD
	beq $s4, 2, fastFWD
	slowFWD:
	    lw $a0, slow # 70% duty
            lw $a1, slow
            j setFWD
	mediumFWD:
	    lw $a0, medium # 85% duty
            lw $a1, medium
            j setFWD
	fastFWD:
	    lw $a0, fast # 100% duty
            lw $a1, fast
	setFWD:
        jal forwardOCMs

	j end

    # "Go backwards" 
    backwards:
# 	jal setupOC1back
# 	jal setupOC3

	# Kick Start Backward Drive
        lw $a0, fast # 100% duty
        lw $a1, fast
        jal backwardOCMs

        jal startTMR1
        li $t0, 1   # Wait for 0.1 sec.
        waitForTMRRev:
            jal getTMR1Tenths
            beqz $v0, waitForTMRRev
        jal stopTMR1
        
        # Now set desired speed
        beq $s4, 0, slowREV
	beq $s4, 1, mediumREV
	beq $s4, 2, fastREV
	slowREV:
	    lw $a0, slow # 25% duty
            lw $a1, slow
            j setREV
	mediumREV:
	    lw $a0, medium # 50% duty
            lw $a1, medium
            j setREV
	fastREV:
	    lw $a0, fast # 100% duty
            lw $a1, fast
	setREV:
        jal backwardOCMs

	j end
    
    breaking:
	jal startTMR2
	move $zero, $t1
	breakrobot:
	beq $t1, $s4, end
	lw $t0, OC1RS
	addi $t0, $t0, -25
	sw $t0, OC1RS
	
	lw $t0, OC3RS
	addi $t0, $t0, -25
	sw $t0, OC3RS
	add $t1, 1
	j breakrobot
	
	j end
   
    continue:
        move $a0, $s4
        jal waitForTime

        j end
    
    end:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4 # put back on stack
    
    jr $ra
.end execute

.endif
