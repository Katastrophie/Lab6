.include "timer.s"
.include "outputCompare.s"
.include "buttons.s"
        
.global main
    
.text
    
    
.ent main
main:
    
    jal setupButtons
    jal setupOC1
    jal setupOC2
    jal setupTMR2
    jal startTMR2
    
    
    loop:
    
	jal getButtons
	beq $v0, 0b001, btn1pressed
	beq $v0, 0b010, btn2pressed
	beq $v0, 0b011, btn12pressed
	
	nobtnpressed:
	    j waitfordepressed
	    
	btn1pressed:
	    # increment duty cycle by 10%
	    # duty cycle % = OC1RS / (PR + 1)
	    # OC1RS = (duty cycle %) * (PR + 1)
	    # OC1RS = 5% * (249 + 1)
	    LW $t0, OC1RS
	    ADDI $t0, $t0, 25
	    SW $t0, OC1RS
	    
	    LW $t0, OC2RS
	    ADDI $t0, $t0, 25
	    sw $t0, OC2RS 
	    
	    j waitfordepressed
	btn2pressed:
	    # decrement duty cycle by 10%
	    # duty cycle % = OC1RS / (PR + 1)
	    # OC1RS = (duty cycle %) * (PR + 1)
	    # OC1RS = 5% * (249 + 1)
	    LW $t0, OC1RS
	    ADDI $t0, $t0, -25
	    SW $t0, OC1RS
	    
	    j waitfordepressed
	btn12pressed:
	    # stop the motor
	    SW $zero, OC1RS
	    SW $zero, OC2RS
	    j waitfordepressed
	waitfordepressed:
	    jal getButtons
	    beq $v0, 0b011, btn12pressed
	    beqz $v0, loop
	    j waitfordepressed
		
    
    j loop
    
.end main





