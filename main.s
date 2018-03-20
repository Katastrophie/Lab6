.include "timer.s"
.include "outputCompare.s"
.include "buttons.s"
.include "robot.s"
        
.GLOBAL main
    
.TEXT
    
    
.ent main
main:
    
    jal setupButtons
    jal setupOC1
    jal setupOC3
    jal setupTMR2
    jal startTMR2
    
    
    loop:
	waitpressed:
	    jal getButtons
	    beqz $v0, runProgram
	j waitpressed
    
    j loop
    
.end main





