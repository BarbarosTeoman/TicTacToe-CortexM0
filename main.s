					;Some global definitions:
					;=0xFFFFFFFF -> white color
					;=0xFFEEEEEE -> gray color
					;=0xFF000000 -> black color
					;=0xFFFF0000 -> red color
					;=0xFF0000FF -> blue color
					;=0x20000800 -> current cell
					;=0x20000804 -> the symbol on the queue
					;=0x20000808 - 0x20000824 -> each cell's state
					;=0x40010000 -> lcd address
					;=0x40010004 -> lcd row address
					;=0x40010008 -> lcd column address
					;=0x4001000C -> lcd control address
					;=0x40010010 -> lcd button address
Stack_Size			EQU	0x800						;Define stack size

					;Define vector for interrupts and stack
					AREA STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem			SPACE	Stack_Size
__initial_sp
					AREA RESET, DATA, READONLY
					EXPORT 	__Vectors
					EXPORT	__Vectors_End
__Vectors			DCD		__initial_sp
					DCD		Reset_Handler
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		0
					DCD		Button_Handler

__Vectors_End

;--------------------------------------------------------------------------------------------------------------------------------------		
					;DEFINE THE BUTTON HANDLER
					AREA 	button, CODE, READONLY
Button_Handler		PROC
					EXPORT	Button_Handler
					push	{r1}
					ldr		r0, =0x40010010	
					ldr		r1, =0x40010000	
					ldrb	r7, [r0]																; Read value from the button address
;--------------------------------------------------------------------------------------------------------------------------------------		
					;CLEAR THE PREVIOUS CELL TO WHITE
					subs 	r6, #34              													;Going to the top left corner of the previous cell
					subs 	r4, #34              
					movs 	r3, r4
					movs 	r2, r6
					adds 	r2, r2, #69          													;Temporary register to check if we have drawn 69 pixels, the right side of the cell
					
nr5				    str    	r6, [r1]																;Storing row to row register
					movs	r4, r3
nc5				    str		r4, [r1, #0x4] 															;Storing column to column register
					ldr		r5, =0xFFFFFFFF
					str     r5, [r1, #0x8]   
					adds    r4, r4, #1     															;Incrementing the column counter

					movs 	r5, r3
					adds 	r5, r5, #69
					cmp     r4, r5        															;Checking if we reached to the end of the row
					bne     nc5
					
					adds    r6, r6, #1     															;Increment the row counter
					cmp		r6, r2
					bne		nr5
					subs 	r6, #35
					subs 	r4, #35
					str    	r6, [r1] 
					str		r4, [r1, #0x4]
     
					;DRAW X IF THERE WAS A "X" ON PREVIOUS CELL 
					ldr		r3, =0x20000800
					ldr		r0,	[r3]      															;1st cell in on 0x20000808, 2nd one on 0x2000080C, so we implemented a formula for that++
					adds	r0, #1																	;r3 += 4(r0 + 1), where r0 is the cell number and r3 is the address
					lsls	r0, r0, #2
					adds	r3, r0
     
					ldr		r0, [r3]      															;Here we are getting the value of that address, if it is 0 that means the cell was empty
					cmp		r0, #0        															;so we won't draw anything, if it is 1 there was a "X" so we are 
					beq		next10																	;drawing a "X" there again, if it is 2 we are drawing an "O"
					cmp		r0, #1
					bne		drawO2
					
					subs	r6, #30        															;How to draw "X" and "O" is described under
					subs	r4, #30
					push	{r4}
					adds	r4, #60
					movs	r5, r4
					pop		{r4}
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
newpixel5			ldr     r3, =0xFFFF0000
					str     r3, [r1, #0x8]
					adds    r4, #1
					adds    r6, #1
					str    	r6, [r1]       
					str		r4, [r1, #0x4]
					cmp     r4, r5
					bne     newpixel5
					subs    r6, #60
					subs	r5, #60
newpixel6			ldr     r3, =0xFFFF0000
					str     r3, [r1, #0x8]
					subs    r4, #1
					adds    r6, #1
					str    	r6, [r1]        
					str		r4, [r1, #0x4]
					cmp     r4, r5
					bne     newpixel6
					subs	r6, #30
					adds	r4, #30
					b		next10
					;DRAW O IF THERE WAS AN "O" ON PREVIOUS CELL
drawO2				subs	r6, #25
					subs	r4, #25
					movs	r5, #0	
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
upper3				ldr     r3, =0xFFFF0000
					str     r3, [r1, #0x8]
					adds    r4, #1
					str		r4, [r1, #0x4]		
					adds 	r5, #1
					cmp     r5, #50
					bne     upper3
right3				ldr     r3, =0xFFFF0000
					str     r3, [r1, #0x8]
					adds    r6, #1
					str    	r6, [r1]
					adds 	r5, #1
					cmp     r5, #100
					bne     right3
bottom3				ldr     r3, =0xFFFF0000
					str     r3, [r1, #0x8]
					subs    r4, #1
					str		r4, [r1, #0x4]
					adds 	r5, #1
					cmp     r5, #150
					bne     bottom3
left3				ldr     r3, =0xFFFF0000
					str     r3, [r1, #0x8]
					subs    r6, #1
					str    	r6, [r1]
					adds 	r5, #1
					cmp     r5, #200
					bne     left3
					adds	r6, #25
					adds	r4, #25

;--------------------------------------------------------------------------------------------------------------------------------------
					;CHECKING IF IT IS OUR FIRST TIME AFTER PRESSING ANY BUTTON
next10				cmp 	r6,#0                    											;Our coordinates become (0,0) only when we are running the code for the first time
					bne		next11                      										;by using that, in the first time we are going to the 
					movs 	r4, #90																;center and jumping to draw gray section
					movs	r6, #50
					b		next6
;--------------------------------------------------------------------------------------------------------------------------------------	
					;CLEAR THE MAP AND RAM
next11              cmp     r7, #0x08           												;Checking if B is pressed
                    bne     next7               												;If b is not pressed checking if the other button is pressed

                    ldr     r5, =0xFFFFFFFF     											
                    ldr     r1, =0x40010000     												;Lcd row register
                    
                    ;SET THE BACKGROUND TO WHITE
                    movs    r3, #0              												;Starting from top left corner
nr8                 str     r3, [r1]            												;Storing row to row register
                    movs    r4, #0
nc8                 str     r4, [r1, #0x4]      												;Storing column to column register
                    str     r5, [r1, #0x8]
                    adds    r4, r4, #1           												;Incrementing the column counter
                    ldr     r2, =320
                    cmp     r4, r2             													;Checking if we have reached to the end of the row
                    bne     nc8
                    adds    r3, r3, #1         													;Increment the row counter
                    cmp     r3, #240
                    bne     nr8
            
                    ;DRAWING HORIZONTAL BLACK LINES
                    ldr     r5, =0xFF000000     												
                    movs    r3, #15             												;Moving to first horizontal line's left coordinate
nr7                 str     r3, [r1]            												;Storing row to row register
                    movs    r4, #55
nc7                 str     r4, [r1, #0x4]     													;Storing column to column register
                    str     r5, [r1, #0x8]
                    adds    r4, r4, #1         													;Incrementing the column counter
                    ldr     r2, =266
                    cmp     r4, r2           													;Checking if we have reached to the end of the line
                    bne     nc7
                    adds    r3, r3, #70         												;There are 70 pixels between each horizontal line
                    cmp     r3, #230
                    bls     nr7

                    ;DRAW VERTICAL BLACK LINES
                    movs    r3, #15            													;Moving to first vertical line's top coordinate
                    movs    r4, #55      
nr6                 str     r4, [r1, #0x4]    													;Storing column to column register
                    movs    r3, #15                   
nc6                 str     r3, [r1]           													;Storing row to row register
                    str     r5, [r1, #0x8]                    
                    adds    r3, r3, #1         													;Incrementing the row counter
                    cmp     r3, #225           													;Checking if we have reached to the end of the line
                    bne     nc6
                    adds    r4, r4, #70         												;There are 70 pixels between each vertical line
                    ldr     r2, =300
                    cmp     r4, r2
                    bls     nr6
                    
                    movs    r6, #50              												;Going back to first cell's center
                    str     r6, [r1]
                    movs    r4, #90
                    str     r4, [r1, #0x4]
                    movs    r2, #1
                    str     r2, [r1, #0xc]       												;Refreshing screen
                    
                    ;CLEAR THE RAM EXCEPT FIRST ADDRESS
                    ldr     r5, =0x20000800    												
                    movs    r2, #0              												;Looping through the first 15 bytes of the ram, and clearing them
                    movs    r3, #1
ram_clear           str     r2, [r5]
                    adds    r5, r5, #4
                    adds    r3, r3, #1
                    cmp     r3, #15
                    bne     ram_clear
                    
                    ldr     r2, =0x20000800      												;Setting the value of the first byte to 1, which means, we are on the 1st cell
                    movs    r3, #1
                    str     r3, [r2]
                    b       next6
                    
;--------------------------------------------------------------------------------------------------------------------------------------                    
                    ;DRAW "X" OR "O" DEPENDING ON THE PREVIOUS DRAWN LETTER
next7				cmp		r7, #0x04															; Checking if A is pressed
					bne		next2station
					
					
					ldr		r2, =0x20000800
					ldr		r0, [r2]
					ldr		r3, [r2, #0x4]  													; taking value that decides for what should be drawn next ("x" or "o")
					
					;CHECKING IF THE CELL THAT WE ARE ON IS EMPTY, IF NOT SKIP THE DRAW PART
					movs	r5, r0   															; taking current cell number that we are on
					adds	r5, #1    
					lsls	r5, r5, #2
					adds	r2, r5   															; calculating the adress that we should go for checking
					ldr		r5, [r2] 
					cmp		r5, #0  															; checking empty or marked as "x"-"o"   
					bne		station2 
					
					;CHECKING IF WE HAVE TO DRAW "X" OR "O", DEPENDING ON THE VALUE OF r3
					ldr		r2, =0x20000800
					cmp		r3, #1  															; deciding what should be drawn if current cell is empty
					bne		next9
;--------------------------------------------------------------------------------------------------------------------------------------					
					;DRAWING "O"
					subs	r6, #25  															; going to the top left of the current cell
					subs	r4, #25  															
					movs	r5, #0
					str    	r6, [r1]  															; updating row counter
					str    	r4, [r1, #0x4]  													; updating column counter
					push	{r0}
					adds	r0, #1
					lsls	r0, r0, #2
					adds	r2, r0  															; calculating the adress we should go for to write "2" which means "o"
					movs	r0, #2
					str		r0, [r2] 															; writing "2" to current cell's address
					pop		{r0}
					
upper				ldr     r3, =0xFFFF0000  												
					str     r3, [r1, #0x8]   													; printing color
					adds    r4, #1  															; moving right on row 
					str		r4, [r1, #0x4]														; updating column counter
					adds 	r5, #1
					cmp     r5, #50  															; checking if we have drawn 50 pixels red for top of "o"
					bne     upper
					
right				ldr     r3, =0xFFFF0000  										
					str     r3, [r1, #0x8]  													; printing color
					adds    r6, #1  															; moving down on column
					str    	r6, [r1]  															; updating row counter
					adds 	r5, #1
					cmp     r5, #100  															; checking if we have drawn 50 pixels red for right of "o"
					bne     right	
					
bottom				ldr     r3, =0xFFFF0000  
					str     r3, [r1, #0x8]  													; printing color
					subs    r4, #1  															; moving left on row
					str		r4, [r1, #0x4]  													; updating cloumn counter
					adds 	r5, #1
					cmp     r5, #150  															; checking if we have drawn 50 pixels red for bottom of "o"
					bne     bottom	
					
left				ldr     r3, =0xFFFF0000   										
					str     r3, [r1, #0x8]  													; printing color
					subs    r6, #1  															; moving up on cloumn
					str    	r6, [r1]															; updating row counter
					adds 	r5, #1
					cmp     r5, #200  															; checking if we have drawn 50 pixels red for left of "o"
					bne     left
					
					;GOING BACK TO THE CENTER OF THE CELL, AND CHANGING THE 2ND BYTE OF THE RAM TO 0 WHICH MEANS WE WILL DRAW "X" WHEN WE PRESS "A" BUTTON
					adds	r6, #25  															; when we finish the drawing "o" we are going back the center
					adds	r4, #25  															
					ldr		r2, =0x20000800
					movs    r3, #0
					str		r3, [r2, #0x4] 													    ; writing 0 on 0x20000804,which means that next letter will be "x" 
					
station2			b		section123			
next2station		b		next2				
					
;--------------------------------------------------------------------------------------------------------------------------------------
					;DRAWING "X"
next9				subs	r6, #30 															 ; going to the top left of the current cell
					subs	r4, #30  															 
					push	{r4}
					adds	r4, #60
					movs	r5, r4
					pop		{r4}
					str    	r6, [r1]  	 													     ; updating row counter
					str    	r4, [r1, #0x4]  													 ; updating cloumn counter
					adds	r0, #1
					lsls	r0, r0, #2
					adds	r2, r0 															 	 ; calculating the adress we should go for to write "1" which means "x"
					movs	r0, #1
					str		r0, [r2]   															 ; writing "2" to current cell's address
newpixel			ldr     r3, =0xFFFF0000   													 
					str     r3, [r1, #0x8]   													 ; printing color
					adds    r4, #1   															 ; moving right on row 
					adds    r6, #1   															 ; moving down on column
					str    	r6, [r1]    														 ; updating row counter   
					str		r4, [r1, #0x4]  													 ; updating cloumn counter
					cmp     r4, r5    															 ; checking if we have drawn 60 pixels red for first line of "x"
					bne     newpixel
					
					subs    r6, #60
					subs	r5, #60
newpixel2			ldr     r3, =0xFFFF0000   													
					str     r3, [r1, #0x8]
					subs    r4, #1   															 ; moving left on row
					adds    r6, #1   															 ; moving down on column
					str    	r6, [r1]    													 	 ; updating row counter     
					str		r4, [r1, #0x4]   													 ; updating cloumn counter
					cmp     r4, r5   															 ; checking if we have drawn 60 pixels red for second line of "x"
					bne     newpixel2
					
					;GOING BACK TO THE CENTER OF THE CELL, AND CHANGING THE 2ND BYTE OF THE RAM TO 1 WHICH MEANS WE WILL DRAW "O" WHEN WE PRESS "A" BUTTON
					subs	r6, #30  															 ; when we finish the drawing "x" we are going back the center
					adds	r4, #30	 															 
					ldr		r2, =0x20000800
					movs	r3, #1
					str		r3, [r2, #0x4]  													 ; writing 0 on 0x20000804,which means that next letter will be "o" 
;--------------------------------------------------------------------------------------------------------------------------------------
					;AFTER EACH TIME WE DRAW "X" OR "O" WE ARE CHECKING IF ANY WINNING CONDITION IS SATISFIED, IF SO WE ARE DRAWING A LINE AND FREEZING THE GAME 
section123			push	{r0,r1,r2,r3,r4,r5,r6,r7} 											 ; pushing all register to stack to keep their values safe
					ldr		r2, =0x20000800
					ldr		r1, [r2, #0x8]                  									 ; read cell 1 character
					ldr		r3, [r2, #0xC]                  									 ; read cell 2 character
					ldr		r4, [r2, #0x10]                  									 ; read cell 3 character
					movs	r2, #0  
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6       									 					 ; sum up all of 3 addresses of section123 to r2 register and compare with 6 to check if there is "o-o-o" condition
					bne		compare      									 					 ; checking for "x-x-x" condition
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #50
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		horizontalLine
compare				cmp		r1, #1
					bne		section456
					cmp		r3, #1
					bne		section456
					cmp		r4, #1
					bne		section456      													 ; checking if each cell of section123 is "x", if not goes to other section
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #50
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		horizontalLine
section456			ldr		r2, =0x20000800
					ldr		r1, [r2, #0x14]                										 ; read cell 4 character
					ldr		r3, [r2, #0x18]                 									 ; read cell 5 character
					ldr		r4, [r2, #0x1C]                  									 ; read cell 6 character
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare2
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #120
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		horizontalLine
compare2			cmp		r1, #1
					bne		section789
					cmp		r3, #1
					bne		section789
					cmp		r4, #1
					bne		section789
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #120
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		horizontalLine
section789			ldr		r2, =0x20000800
					ldr		r1, [r2, #0x20]                										 ; read cell 7 character
					ldr		r3, [r2, #0x24]                										 ; read cell 8 character
					ldr		r4, [r2, #0x28]                										 ; read cell 9 character
					LTORG                                										 ; BUG fixer
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare3
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #190
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		horizontalLine
compare3			cmp		r1, #1
					bne		section147
					cmp		r3, #1
					bne		section147
					cmp		r4, #1
					bne		section147
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #190
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		horizontalLine
section147			ldr		r2, =0x20000800
					ldr		r1, [r2, #0x8]                									   	 ; read cell 1 character
					ldr		r3, [r2, #0x14]                									   	 ; read cell 4 character
					ldr		r4, [r2, #0x20]                									   	 ; read cell 7 character
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare4
					ldr		r1, =0x40010000
					movs 	r4, #90
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		verticalLine
compare4			cmp		r1, #1
					bne		section258
					cmp		r3, #1
					bne		section258
					cmp		r4, #1
					bne		section258
					ldr		r1, =0x40010000
					movs 	r4, #90
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		verticalLine
section258			ldr		r2, =0x20000800
					ldr		r1, [r2, #0xC]              									   	 ; read cell 2 character
					ldr		r3, [r2, #0x18]              									   	 ; read cell 5 character
					ldr		r4, [r2, #0x24]              									   	 ; read cell 8 character
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare5
					ldr		r1, =0x40010000
					movs 	r4, #160
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		verticalLine
compare5			cmp		r1, #1
					bne		section369
					cmp		r3, #1
					bne		section369
					cmp		r4, #1
					bne		section369
					ldr		r1, =0x40010000
					movs 	r4, #160
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		verticalLine
section369			ldr		r2, =0x20000800
					ldr		r1, [r2, #0x10]                  									 ; read cell 3 character
					ldr		r3, [r2, #0x1C]                  									 ; read cell 6 character
					ldr		r4, [r2, #0x28]                  									 ; read cell 9 character
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare6
					ldr		r1, =0x40010000
					movs 	r4, #230
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		verticalLine
compare6			cmp		r1, #1
					bne		section159
					cmp		r3, #1
					bne		section159
					cmp		r4, #1
					bne		section159
					ldr		r1, =0x40010000
					movs 	r4, #230
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		verticalLine
section159			ldr		r2, =0x20000800
					ldr		r1, [r2, #0x8]                        								 ; read cell 1 character
					ldr		r3, [r2, #0x18]                       								 ; read cell 5 character
					ldr		r4, [r2, #0x28]                       								 ; read cell 9 character
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare7
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		L2Rline
compare7			cmp		r1, #1
					bne		section357
					cmp		r3, #1
					bne		section357
					cmp		r4, #1
					bne		section357
					ldr		r1, =0x40010000
					movs 	r4, #70
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		L2Rline
section357			ldr		r2, =0x20000800
					ldr		r1, [r2, #0x10]                        								; read cell 3 character
					ldr		r3, [r2, #0x18]                        								; read cell 5 character
					ldr		r4, [r2, #0x20]                        								; read cell 7 character
					movs	r2, #0
					adds	r2,	r1
					adds	r2,	r3
					adds	r2,	r4
					cmp		r2,	#6
					bne		compare8
					ldr		r1, =0x40010000
					movs 	r4, #250
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		R2Lline
compare8			cmp		r1, #1
					bne		finished
					cmp		r3, #1
					bne		finished
					cmp		r4, #1
					bne		finished
					ldr		r1, =0x40010000
					movs 	r4, #250
					movs	r6, #30
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
					b		R2Lline
verticalLine		movs	r2, #0             													; drawing vertical line on the state "x-x-x" or "o-o-o"  to finish game
					ldr		r3, =0xFF0000FF
newRow				str     r3, [r1, #0x8]
					cmp		r2, #180
					beq		station
					adds	r6, #1
					adds	r2, #1
					str    	r6, [r1]
					b		newRow
horizontalLine		movs	r2, #0              												; drawing horizontal line on the state "x-x-x" or "o-o-o"  to finish game
					ldr		r3, =0xFF0000FF
newColumn			str     r3, [r1, #0x8]
					cmp		r2, #180
					beq		station
					adds	r4, #1
					adds	r2, #1
					str    	r4, [r1, #0x4]
					b		newColumn
L2Rline				ldr		r3, =0xFF0000FF        												; drawing diagonal line from left to right on the state "x-x-x" or "o-o-o"  to finish game
newpixel7			str     r3, [r1, #0x8]
					adds    r4, #1
					adds    r6, #1
					str    	r6, [r1]       
					str		r4, [r1, #0x4]
					cmp     r4, #250
					bne     newpixel7
					beq		station
R2Lline				ldr		r3, =0xFF0000FF        												; drawing diagonal line from right to left on the state "x-x-x" or "o-o-o"  to finish game
newpixel8			str     r3, [r1, #0x8]
					subs    r4, #1
					adds    r6, #1
					str    	r6, [r1]       
					str		r4, [r1, #0x4]
					cmp     r4, #70
					bne     newpixel8
					beq		station
finished			pop	{r0,r1,r2,r3,r4,r5,r6,r7}					
					
;--------------------------------------------------------------------------------------------------------------------------------------
					;IF ANY ARROW KEY IS PRESSED, WE ARE UPDATING THE COORDINATES, AND FIRST BYTE OF THE RAM WHICH CORRESPONDS TO THE CELL WHICH WE ARE CURRENTLY ON
next2				cmp		r7, #0x10															; Check if Up pressed
					bne		next3
					cmp		r6, #120															; If the row value less than 50 go to bottom
					blt		inc1
					subs	r6, r6, #70			
					
					ldr		r2, =0x20000800
					ldr		r3, [r2]
					subs	r3, #3
					str		r3, [r2]
					
					b		next3
inc1				movs	r6, #190

					ldr		r2, =0x20000800
					ldr		r3, [r2]
					adds	r3, #6
					str		r3, [r2]

next3				cmp		r7, #0x20															; Check if Down pressed
					bne		next4
					cmp		r6, #120
					bgt		inc2
					adds	r6, r6, #70
					
					ldr		r2, =0x20000800
					ldr		r3, [r2]
					adds	r3, #3
					str		r3, [r2]
					
					b		next4
inc2				movs	r6, #50

					ldr		r2, =0x20000800
					ldr		r3, [r2]
					subs	r3, #6
					str		r3, [r2]

next4				cmp		r7, #0x40															; Check if Left pressed
					bne		next5
					cmp		r4, #160
					blt		inc3
					subs	r4, r4, #70
					
					ldr		r2, =0x20000800
					ldr		r3, [r2]
					subs	r3, #1
					str		r3, [r2]
					
					b		next5
inc3				movs	r4, #230

					ldr		r2, =0x20000800
					ldr		r3, [r2]
					adds	r3, #2
					str		r3, [r2]

next5				cmp		r7, #0x80														    ; Check if Right pressed
					bne		next6
					cmp		r4, #160
					bgt		inc4
					adds	r4, r4, #70
					
					ldr		r2, =0x20000800
					ldr		r3, [r2]
					adds	r3, #1
					str		r3, [r2]
					
					b		next6
inc4				movs	r4, #90

					ldr		r2, =0x20000800
					ldr		r3, [r2]
					subs	r3, #2
					str		r3, [r2]

					b		next6

station				b		nothing		
		
;--------------------------------------------------------------------------------------------------------------------------------------
					;DRAWING THE CELL WHICH WE ARE CURRENTLY ON TO GRAY IF WE JUST MOVED TO A DIFFERENT CELL OR DRAW A "X" OR "O", ITS ONLY USAGE IS TO INDICATE WHERE WE CURRENTLY ARE
next6				subs 	r6, #34
					subs 	r4, #34
					movs 	r7, r4
					movs 	r2, r6
					adds 	r2, r2, #69
		
nr4					str    	r6, [r1]
					movs	r4, r7
nc4					str		r4, [r1, #0x4] 														;store col to col register  
					ldr		r5, =0xFFEEEEEE
					str     r5, [r1, #0x8]
					adds    r4, r4, #1     														;increment the col counter
					movs 	r5, r7
					adds 	r5, r5, #69
					cmp     r4, r5        														;check if we reached end of row
					bne     nc4
					adds    r6, r6, #1     														;increment the row counter
					cmp		r6, r2
					bne		nr4
					
					;WE MIGHT JUST PAINTED ON "X" OR "O", SO WE HAVE TO DRAW THEM AGAIN
					subs 	r6, #35
					subs 	r4, #35
					
					str    	r6, [r1] 
					str		r4, [r1, #0x4]
					
					;CHECKING IF THERE WAS SOMETHING BEFORE WE PAINTED THE CELL TO GRAY, WE ARE DOING THAT BY CHECKING THE VALUE OF THE CELL'S RAM ADDRESS
					ldr		r3, =0x20000800
					ldr		r0,	[r3]
					adds	r0, #1
					lsls	r0, r0, #2
					adds	r3, r0
					ldr		r0, [r3]
					cmp		r0, #0
					beq		nothing
					cmp		r0, #1
					bne		drawO
					
					;DRAWING "X"
					subs	r6, #30
					subs	r4, #30
					push	{r4}
					adds	r4, #60
					movs	r5, r4
					pop		{r4}
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
newpixel3			ldr     r3, =0xFFFF0000    													; drawing left to right diagonal of "X"
					str     r3, [r1, #0x8]
					adds    r4, #1
					adds    r6, #1
					str    	r6, [r1]       
					str		r4, [r1, #0x4]
					cmp     r4, r5
					bne     newpixel3
					subs    r6, #60
					subs	r5, #60
newpixel4			ldr     r3, =0xFFFF0000    													; drawing right to left diagonal of "X"
					str     r3, [r1, #0x8]
					subs    r4, #1
					adds    r6, #1
					str    	r6, [r1]        
					str		r4, [r1, #0x4]
					cmp     r4, r5
					bne     newpixel4
					subs	r6, #30
					adds	r4, #30
					b		nothing
					
					;DRAWING "O"
drawO				subs	r6, #25  
					subs	r4, #25
					movs	r5, #0	
					str    	r6, [r1]
					str    	r4, [r1, #0x4]
upper2				ldr     r3, =0xFFFF0000          											; drawing upper edge of "O"
					str     r3, [r1, #0x8]
					adds    r4, #1
					str		r4, [r1, #0x4]		
					adds 	r5, #1
					cmp     r5, #50
					bne     upper2
right2				ldr     r3, =0xFFFF0000         											; drawing right edge of "O"
					str     r3, [r1, #0x8]
					adds    r6, #1
					str    	r6, [r1]
					adds 	r5, #1
					cmp     r5, #100
					bne     right2
bottom2				ldr     r3, =0xFFFF0000        												; drawing bottom edge of "O"
					str     r3, [r1, #0x8]
					subs    r4, #1
					str		r4, [r1, #0x4]
					adds 	r5, #1
					cmp     r5, #150
					bne     bottom2	
left2				ldr     r3, =0xFFFF0000          											; drawing left edge of "O"
					str     r3, [r1, #0x8]
					subs    r6, #1
					str    	r6, [r1]
					adds 	r5, #1
					cmp     r5, #200
					bne     left2
					adds	r6, #25
					adds	r4, #25

nothing				movs    r3, #1
					str     r3, [r1, #0xc] 														;refresh screen
					
					;CLEAR THE PENDING BIT
					movs	r7, #0
					ldr		r0, =0x40010010	
					str 	r7, [r0]
					pop		{r1}
					bx		lr
					ENDP
						
				
;--------------------------------------------------------------------------------------------------------------------------------------	
					;DEFINING THE RESET HANDLER, THAT RETURNS BACK FROM AN INTERRUPT
					AREA	somearea, CODE, READONLY
Reset_Handler		PROC
					EXPORT Reset_Handler
					ldr		r0, =0xE000E100
					movs	r1, #1
					str		r1, [r0]
					CPSIE	i
					ldr		r0, =__main
					bx		r0
					ENDP
				
;--------------------------------------------------------------------------------------------------------------------------------------	
					;MAIN FUNCTION WHICH RUNS WHEN WE RUN THE CODE
__main				PROC
	
					;DRAWING THE MAP
					ldr		r5, =0xFFFFFFFF             									    ;How to draw the map is described up, in the B button section
					ldr		r1, =0x40010000
					
					;SETTING THE BACKGROUND TO WHITE
					movs 	r3, #0
nr1					str    	r3, [r1]
					movs	r4, #0
nc1					str		r4, [r1, #0x4] 	
					str     r5, [r1, #0x8]
					adds    r4, r4, #1     
					ldr 	r2, =320
					cmp     r4, r2       
					bne     nc1
					adds    r3, r3, #1     	
					cmp		r3, #240
					bne		nr1
			
;--------------------------------------------------------------------------------------------------------------------------------------
					;DRAWING HORIZONTAL BLACK LINES
					ldr		r5, =0xFF000000 
					movs 	r3, #15
nr2					str    	r3, [r1]
					movs	r4, #55
nc2					str		r4, [r1, #0x4] 	
					str     r5, [r1, #0x8]
					adds    r4, r4, #1     	
					ldr 	r2, =266
					cmp     r4, r2       
					bne     nc2
					adds    r3, r3, #70     	
					cmp		r3, #230
					bls		nr2

;--------------------------------------------------------------------------------------------------------------------------------------
					;DRAWING VERTICAL BLACK LINES
					movs	r3, #15					
					movs 	r4, #55
					
nr3					str    	r4, [r1, #0x4]
					movs	r3, #15
					
nc3					str		r3, [r1] 															 ;store col to col register  
					str     r5, [r1, #0x8]
					
					adds    r3, r3, #1     
					cmp     r3, #225       	
					bne     nc3
					adds    r4, r4, #70     	
					ldr 	r2, =300
					cmp		r4, r2
					bls		nr3

					movs    r2, #1
					str     r2, [r1, #0xc] 	
										
;--------------------------------------------------------------------------------------------------------------------------------------
					;SETTING THE FIRST BYTE OF THE RAM TO 1, WHICH CORRESPONDS TO 1ST CELL
					ldr		r2, =0x20000800
					movs	r3, #1
					str		r3, [r2]
							
;--------------------------------------------------------------------------------------------------------------------------------------		
					;MAIN LOOP
main_loop    		ldr		r1, =0x40010000
				
					b       main_loop		
					ENDP
					END
