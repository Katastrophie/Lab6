.include "timer.s"
.include "outputCompare.s"
.include "buttons.s"
.include "robot.s"
        
.GLOBAL main
    
.TEXT
    
    
.ent main
main:
    di
    jal setupButtons
    jal setupOC1
    jal setupOC3
    jal setupTMR1
    jal setupTMR2
    
    # Turn on multi-vector mode to support multiple interrupt requests
    # INTCON<12> = 1
    li      $t0, 1 << 12
    sw      $t0, INTCONSET

    ei
    loop:
	waitpressed:
	    jal getButtons
	    beqz $v0, waitpressed # While (noBtns) {repeat;}
        btnPressed:
        jal runProgram
    
    j loop
    
.end main








