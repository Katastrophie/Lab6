.include "outputCompare.s"
    .ifndef ROBOMAL_S
ROBOMAL_S:
  
.data
    
 # Harvard Architecture RoboMAL
 # The most significant 8 bits must be in Hexadecimal and represent the operation 
 # code followed by zeros. The least significant bits 16 bits are the roboMAL
 # operands in hexadecimal. The instruction must be 32 bits long.
 ROBO_Instruction: .word 0x28000000, 0x2C000000, 0x33000000# , 0x29000000, 0x2A000000, 0x2B000000, 
 
 # This array stores variables, it can be in any number format.
 ROBO_Data: .word 80, 5, 4
    
.text


 
# ******************************************************************************
# * Function Name:	 runProgram                                                                                                       
# * Description:	 This function runs the RoboMAL program by first 
# *			 initializing all my simulation registers. It runs the 
# *			 program until the last operation is performed.
# *                                                                                                                         
# * Inputs:		 None                                                                                                                 *
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
    move $s4, $zero # Operad Rehister
    
Roboloop:
    jal simulateClockCycle
    beq $s3, 0x2C00, endProgram
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
    

    # End of the program, robot stops.
    halt:
	li $t0, 0
	SW $t0, OC1RS
	SW $t0, OC3RS
	j end

    # "Turn left" - No robot, so LED4 turns on. 
    left:
# 	li $a0, 0b1000
# 	jal setLEDs
# 	jal oneSecond # displays the LED for roughly one second
# 	
# 	j end

    # "Turn right" - No robot, so LED1 turns on.
    right:
# 	li $a0, 0b0001
# 	jal setLEDs
# 	jal oneSecond # Displays the LED for roughly one second
# 	
# 	j end

    # "Go forward" 
    forwards:
	li $a0, 1
	jal setupOC1
	jal setupOC3
	
	j speed

    # "Go backwards" 
    backwards:
	
	li $a0, 0
	jal setupOC1
	jal setupOC3
	
 	
 	j speed
    speed:
    beq $s4, 0, slow
	beq $s4, 1, medium
	beq $s4, 2, fast
	slow:
	    li $t0, 62 # 25% duty
	j set
	medium:
	    LI $t0, 125 # 50% duty
	j set
	fast:
	    li $t0, 250 # 100% duty
	set:
	SW $t0, OC1RS
	SW $t0, OC3RS
	j end
    
    breaking:
	LW $t0, OC1RS
	ADDI $t0, $t0, -25
	SW $t0, OC1RS
	
	LW $t0, OC3RS
	ADDI $t0, $t0, -25
	SW $t0, OC3RS
	
	j end
   
    end:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4 # put back on stack
    
    jr $ra
.end execute
.endif
    