.section .text
// 320x240, 1024 bytes/row, 2 bytes per pixel: DE1-SoC
.equ WIDTH, 320
.equ HEIGHT, 240
.equ LOG2_BYTES_PER_ROW, 10
.equ LOG2_BYTES_PER_PIXEL, 1

.equ PIXBUF, 0xc8000000		// Pixel buffer
.equ CHARBUF, 0xc9000000	// Character buffer

.equ QUEUE_BASE, 0x00ff1000

.equ BUTTONS_ADDR,    0xFF200050  /* Address of push-buttons */
.equ SWITCHES_ADDR,   0xFF200040  /* Address of switches; SW0 is bit 0 */
.equ HEX3_HEX0_BASE,  0xFF200020  /* Address of 7-segment display HEX0-HEX3 */

.global _start
_start:
	mov r10, #20 // Queue cap
	
	bl LoadQueueNumbers // can get approx 300 into queue as is, prob more if storing numbers better (i.e., different location, hwords)
	mov r11, #0              // SW0 state: start in OFF scene
	
	bl clear_all_segments // @Author Z. Sūn
	
	bl ClearCharBuffer // Clear character buffer

	mov r0, #0			// RGB565 black
	bl FillColour		// Fill screen with black colour
	bl DrawTVFrame		// Draw TV body and green display area
	bl ShowOffMessage
	
main_loop:
	ldr r7, =SWITCHES_ADDR
	ldr r8, [r7]
	and r8, r8, #1
	cmp r8, #0
	beq switch_off
	cmp r11, #1
	beq functionality_loop
	mov r11, #1
	bl Clear
	bl LoadQueueNumbers
	bl ClearCharBuffer
	bl UpdateDisplay
	b functionality_loop

switch_off:
	cmp r11, #0
	beq main_loop
	mov r11, #0
	bl Clear
	bl ClearCharBuffer
	mov r0, #0
	bl FillColour
	bl DrawTVFrame
	bl ShowOffMessage
	b main_loop

functionality_loop:
	mov r6, #0 // 0 no change, 1 change
	// Read button state
    LDR r7, =BUTTONS_ADDR   // @Author 2h-5
    LDR r8, [r7]            // Read button state (bits 0-2 for KEY0-KEY2)
    
    // Check for KEY0 press (Queue)
    MOV r9, r8              // Copy current button state
    AND r9, r9, #1          // Isolate KEY0 bit
    CMP r9, #1              // Check if KEY0 is pressed (bit 0 = 1)
	mov r2, #0
	bleq Enqueue // Need to update the segment display (printer)
	cmp r2, #0
	movne r6, #1
	
	// Check for KEY1 press (Dequeue)
	MOV r9, r8              // Copy current button state
    AND r9, r9, #2          // Isolate KEY1 bit
    CMP r9, #2              // Check if KEY1 is pressed (bit 0 = 1)
	mov r2, #0
	bleq Dequeue
	cmp r2, #0
	movne r6, #1
	
	// Check for KEY2 press (Clear Queue)
	MOV r9, r8              // Copy current button state
    AND r9, r9, #4          // Isolate KEY1 bit
    CMP r9, #4              // Check if KEY1 is pressed (bit 0 = 1)
	bleq Clear
	moveq r6, #1

	cmp r6, #1
    bleq ClearCharBuffer // Clear character buffer

	cmp r6, #1
	bleq UpdateDisplay
	
	// cmp r6 #1, if button was pressed then debounce
	cmp r6, #1
	beq delay_loop
	
	b main_loop // 🆉. Sun
	
delay_loop:
	// could just loop here until button unpressed
	LDR r8, [r7]
	cmp r8, #0
    BNE delay_loop
    
    B main_loop             // Continue main loop

Clear:
	push {r4-r12, lr}
	
	bl clear_all_segments
	
	ldr r11, =COUNT
	mov r0, #0
	str r0, [r11]
	
	ldr r11, =HEAD
	mov r0, #0
	str r0, [r11]
	
	ldr r11, =TAIL
	mov r0, #0
	str r0, [r11]

	pop {r4-r12, lr}
	
	bx lr
	
Enqueue:
	push {r4-r12, lr}
	
	ldr r11, =COUNT
	ldr r0, [r11]
	cmp r0, r10
	
	blt EnqueueStore
	bl write_full
	
	pop {r4-r12, lr} // github.com/2h-5
	
	mov r2, #0
	bx lr
	
EnqueueStore:
	add r0, #1
	str r0, [r11]
	
	ldr r9, =TAIL
	ldr r0, [r9]
	
	bl divide_by_cap
	add r1, #4
	str r1, [r9]
	
	sub r1, #1
	mov r0, r1, lsr #2
	bl update_display
	
	pop {r4-r12, lr}
	mov r2, #1
	bx lr
	
Dequeue:
	// move head forward
	push {r4-r12, lr}
	
	bl clear_all_segments
	
	ldr r11, =COUNT
	ldr r0, [r11]
	cmp r0, #0
	
	bne DequeueStore
	
	pop {r4-r12, lr} // @Author Sūn
	mov r2, #0
	bx lr
	
DequeueStore:
	sub r0, #1
	str r0, [r11]
	
	ldr r9, =HEAD
	ldr r0, [r9]
	
	bl divide_by_cap
	add r1, #4
	
	str r1, [r9]

	pop {r4-r12, lr}
	mov r2, #1
	bx lr
	
ShowOffMessage:
	push {r4-r7, lr}
	ldr r4, =OFF_MESSAGE
	mov r5, #19
	mov r6, #24
show_off_loop:
	ldrb r7, [r4], #1
	cmp r7, #0
	beq show_off_done
	cmp r7, #32
	beq show_off_space
	mov r0, r5
	mov r1, r6
	mov r2, r7
	bl WriteChar // @Author 🆉. Sūn
show_off_space:
	add r5, #1
	b show_off_loop
show_off_done:
	pop {r4-r7, lr}
	bx lr

UpdateDisplay:
	PUSH {lr}

	bl WriteQueue
	
	bl WriteCurrentServing
	
	POP {lr}
	
	bx lr
	
WriteQueue:
	push {r4-r12, lr}

	// Display "Queue (next 10)"
	ldr r0, =10         // X position
    ldr r1, =10         // Y position
    ldr r2, =0x51       // 'Q'
    bl WriteChar
	
	ldr r0, =11
    ldr r1, =10
    ldr r2, =0x75       // 'u'
    bl WriteChar
	
	ldr r0, =12
    ldr r1, =10
    ldr r2, =0x65       // 'e'
    bl WriteChar
	
	ldr r0, =13
    ldr r1, =10
    ldr r2, =0x75       // 'u'
    bl WriteChar
	
	ldr r0, =14
    ldr r1, =10
    ldr r2, =0x65       // 'e'
    bl WriteChar
	
	ldr r0, =16
    ldr r1, =10
    ldr r2, =0x28       // '('
    bl WriteChar
	
	ldr r0, =17
    ldr r1, =10
    ldr r2, =0x6E       // 'n'
    bl WriteChar
	
	ldr r0, =18
    ldr r1, =10
    ldr r2, =0x65       // 'e'
    bl WriteChar
	
	ldr r0, =19
    ldr r1, =10
    ldr r2, =0x78       // 'x'
    bl WriteChar		// 🆉. Sun
	
	ldr r0, =20
    ldr r1, =10
    ldr r2, =0x74       // 't'
    bl WriteChar
	
	ldr r0, =22
    ldr r1, =10
    ldr r2, =0x31       // '1'
    bl WriteChar
	
	ldr r0, =23
    ldr r1, =10
    ldr r2, =0x30       // '0'
    bl WriteChar
	
	ldr r0, =24
    ldr r1, =10
    ldr r2, =0x29       // ')'
    bl WriteChar
	
	ldr r12, =HEAD
	ldr r12, [r12]
	
	ldr r11, =COUNT
	ldr r0, [r11]
	mov r7, r0, lsl #2
	
	mov r8, #0
	
QueueLoop:
	mov r6, #14 // rightmost x for digit
	sub r9, r6, #3 // leftmost x for digit, 3 less than r6
	
	add r1, r8, r12 // item, offset from head
	
	mov r0, r1
	bl divide_by_cap
	
	ldr r0, =QUEUE_BASE // queue base
	ldr r0, [r0, r1] // load item
	add r8, #4 // increment item
	
	
	// check that next item is less than count
	cmp r8, r7
	bgt QueueLoopEnd // end queueloop if next item > count
	
	// check that next item is less than 40 (40/4 = 10 queue spots), (only showing next 10)
	cmp r8, #40
	bgt AndMore // end queueloop if next item > 40
	
	// write "#" before each number
	push {r0,r1,r6} // 🆉.
	sub r6, #4
	mov r0, r6
    mov r1, r8, lsr #1
	add r1, #10
    ldr r2, =0x23       // '#'
    bl WriteChar
	pop {r0,r1,r6}
	
DigitLoop:
	bl divide_by_10 // puts first digit into r1, remaining digits into r0
	mov r5, r0 // store r0 in r5
	
	ldr r2, =0x30 // ascii number base
	add r2, r1 // add first digit to ascii number base
	mov r0, r6 // move current x position into r0
	mov r1, r8, lsr #1 // move current y position into r1
	add r1, #10 // add 10 to y position to offset
    bl WriteChar
	
	sub r6, #1 // decrement x position
	cmp r5, #0 // check if all digits have been written
	movne r0, r5 // if not load remaining digits into r0
	bne DigitLoop // and write the next digit
	
	cmp r6, r9 // check if 0's need to be written to fill space
	movgt r0, #0 // if so then load 0 into r0
	bgt DigitLoop // and write the zero

DigitLoopEnd:
	b QueueLoop // move on to the next item

AndMore:
	// Display "More waiting"
	mov r0, #10
	mov r1, #32
    ldr r2, =0x4D       // 'M'
    bl WriteChar
	
	mov r0, #11
	mov r1, #32
    ldr r2, =0x6F       // 'o'
    bl WriteChar
	
	mov r0, #12
	mov r1, #32
    ldr r2, =0x72       // 'r'
    bl WriteChar
	
	mov r0, #13
	mov r1, #32			// @Author 🆉. Sūn
    ldr r2, =0x65       // 'e'
    bl WriteChar
	
	mov r0, #15
	mov r1, #32
    ldr r2, =0x77      // 'w'
    bl WriteChar
	
	mov r0, #16
	mov r1, #32
    ldr r2, =0x61       // 'a'
    bl WriteChar
	
	mov r0, #17
	mov r1, #32
    ldr r2, =0x69       // 'i'
    bl WriteChar
	
	mov r0, #18
	mov r1, #32
    ldr r2, =0x74       // 't'
	bl WriteChar
	
	mov r0, #19
	mov r1, #32
    ldr r2, =0x69       // 'i'
    bl WriteChar
	
	mov r0, #20
	mov r1, #32
    ldr r2, =0x6E       // 'n'
    bl WriteChar
	
	mov r0, #21
	mov r1, #32
    ldr r2, =0x67       // 'g'
    bl WriteChar
	
	b QueueLoopEnd // end queueloop
	
QueueLoopEnd:
	pop {r4-r12, lr}
	bx lr
	
WriteCurrentServing:
	push {r4-r12, lr}
	
	// Display "Now serving: #"
    ldr r0, =40         // X position
    ldr r1, =10         // Y position
    ldr r2, =0x4e       // 'N'
    bl WriteChar

    ldr r0, =41
    ldr r1, =10			// @Author 2h-5
    ldr r2, =0x6f       // 'o'
    bl WriteChar

    ldr r0, =42
    ldr r1, =10
    ldr r2, =0x77       // 'w'
    bl WriteChar

    ldr r0, =45
    ldr r1, =10
    ldr r2, =0x73       // 's'
    bl WriteChar

    ldr r0, =46
    ldr r1, =10
    ldr r2, =0x65       // 'e'
    bl WriteChar

    ldr r0, =47
    ldr r1, =10
    ldr r2, =0x72       // 'r'
    bl WriteChar

    ldr r0, =48
    ldr r1, =10
    ldr r2, =0x76       // 'v'
    bl WriteChar

    ldr r0, =49
    ldr r1, =10
    ldr r2, =0x69       // 'i'
    bl WriteChar

    ldr r0, =50
    ldr r1, =10
    ldr r2, =0x6e       // 'n'
    bl WriteChar

    ldr r0, =51
    ldr r1, =10
    ldr r2, =0x67       // 'g'
    bl WriteChar

    ldr r0, =53
    ldr r1, =10
    ldr r2, =0x3a       // ':'
    bl WriteChar

    ldr r0, =55
    ldr r1, =10
    ldr r2, =0x23       // '#'
    bl WriteChar
	
	ldr r12, =HEAD
	ldr r12, [r12]
	
	ldr r11, =COUNT
	ldr r11, [r11]
	cmp r11, #0
	
	popeq {r4-r12, lr}
	bxeq lr
	
	mov r6, #59 // rightmost x for digit
	
	mov r0, r12

	bl divide_by_cap
	
	ldr r0, =QUEUE_BASE // queue base
	ldr r0, [r0, r1] // load item
	//mov r0, #26
	
WriteCurrentServingDigit:
	bl divide_by_10 // puts first digit into r1, remaining digits into r0
	mov r5, r0 // store r0 in r5
	
	ldr r2, =0x30 // ascii number base
	add r2, r1 // add first digit to ascii number base
	mov r0, r6 // move current x position into r0
	ldr r1, =10 // load y position into r1
    bl WriteChar
	
	sub r6, #1 // decrement x position
	cmp r5, #0 // check if all digits have been written
	movne r0, r5 // if not load remaining digits into r0
	bne WriteCurrentServingDigit // and write the next digit
	
	cmp r6, #56 // check if 0's need to be written to fill space
	movgt r0, #0 // if so then load 0 into r0
	bgt WriteCurrentServingDigit // and write the zero

	pop {r4-r12, lr}
	
	bx lr

divide_by_cap:
	push {r4-r11, lr}
	mov r10, r10, lsl #2
	mov r4, r10 // @Author 🆉. Sūn
	mov r5, #0
	mov r6, r0
	
	b loop_start

divide_by_10:
    // Input: r0 = dividend
    // Output: r0 = quotient, r1 = remainder

    push {r4-r11, lr} // Save registers

    mov r4, #10       // r4 = divisor (10)
    mov r5, #0        // r5 = quotient (initialized to 0)
    mov r6, r0        // r6 = dividend (copy of r0)
	
	b loop_start

loop_start:
    cmp r6, r4        // Compare dividend (r6) with divisor (r4)
    blt remainder     // If dividend < divisor, go to remainder calculation

    sub r6, r6, r4    // Subtract divisor from dividend
    add r5, r5, #1    // Increment quotient
    b loop_start      // Loop back

remainder:
    mov r1, r6        // r1 = remainder (remaining dividend)
    mov r0, r5        // r0 = quotient

    pop {r4-r11, pc} // Restore registers and return
	
// r0: colour
FillColour:
    push {r8, r9, r10, lr}	// Save some registers

    mov r10, r0

    // Two loops to draw each pixel
    ldr r8, =WIDTH-1
1:	ldr r9, =HEIGHT-1
2:	mov r0, r8
        mov r1, r9
        mov r2, r10
        bl WritePixel		// Draw one pixel
        subs r9, #1
        bcs 2b
        subs r8, #1
        bcs 1b

    pop {r8, r9, r10, lr} // @Author Z. Sun
    bx lr

// Draw a black TV body with a green RGB565 screen and dark border.
// The character buffer remains responsible for all text rendering.
DrawTVFrame:
    push {r4-r9, lr}
    ldr r4, =0x001f       // brown-ish RGB565 TV surround
    ldr r5, =0x0000       // black bezel
    ldr r6, =0x4d69       // muted green screen

    // Outer body: x=40..279, y=35..204
    mov r7, #40
frame_outer_x:
    mov r8, #35
frame_outer_y:
    mov r0, r7
    mov r1, r8
    mov r2, r4
    bl WritePixel
    add r1, #169
    bl WritePixel
    add r7, #1
    cmp r7, #280
    blt frame_outer_x

    mov r7, #40
frame_outer_vertical:
    mov r0, r7
    mov r1, #35
    mov r2, r4
    bl WritePixel
    mov r1, #204
    bl WritePixel
    add r7, #1
    cmp r7, #280
    blt frame_outer_vertical

    // Black bezel: x=48..271, y=43..196
    mov r7, #48
frame_bezel_x:
    mov r8, #43
frame_bezel_y:
    mov r0, r7
    mov r1, r8
    mov r2, r5
    bl WritePixel
    add r1, #153
    bl WritePixel
    add r7, #1
    cmp r7, #272
    blt frame_bezel_x

    mov r7, #48
frame_bezel_vertical:
    mov r0, r7
    mov r1, #43
    mov r2, r5
    bl WritePixel
    mov r1, #196
    bl WritePixel
    add r7, #1
    cmp r7, #272 
    blt frame_bezel_vertical // Z. Sun

    // Green screen fill: x=52..267, y=48..191
    mov r7, #52
frame_screen_fill_x:
    mov r8, #48
frame_screen_fill_y:
    mov r0, r7
    mov r1, r8
    mov r2, r6
    bl WritePixel
    add r8, #1
    cmp r8, #192
    blt frame_screen_fill_y
    add r7, #1
    cmp r7, #268
    blt frame_screen_fill_x

    // Green screen border pass
    mov r7, #52
frame_screen_x:
    mov r8, #48
frame_screen_y:
    mov r0, r7
    mov r1, r8
    mov r2, r6
    bl WritePixel
    add r1, #143
    bl WritePixel
    add r7, #1
    cmp r7, #268
    blt frame_screen_x

    mov r7, #52
frame_screen_vertical:
    mov r0, r7
    mov r1, #48
    mov r2, r6
    bl WritePixel
    mov r1, #191
    bl WritePixel // github.com/2h-5
    add r7, #1
    cmp r7, #268
    blt frame_screen_vertical

    pop {r4-r9, lr}
    bx lr

// r0: col
// r1: row
// r2: character
WriteChar:
    add r0, #5             // Center 50 columns within the 80-column buffer
    add r1, #5             // Center 23 rows within the 60-row buffer
    lsl r1, #7
    add r1, r0
    ldr r0, =CHARBUF
    strb r2, [r0,r1]
    bx lr

// r0: col (x)
// r1: row (y)
// r2: colour value
WritePixel:
    // Preserve caller coordinates. Frame loops reuse r0/r1 after each pixel.
    push {r0, r1, r3, lr}
    lsl r1, r1, #LOG2_BYTES_PER_ROW
    lsl r0, r0, #LOG2_BYTES_PER_PIXEL
    add r1, r0
    ldr r3, =PIXBUF
    strh r2, [r3,r1]
    pop {r0, r1, r3, lr}
    bx lr

//Clear character buffer
ClearCharBuffer:
    push {r4, r5, r6, lr}
    ldr r4, =CHARBUF
    mov r5, #0 //clear value
    mov r6, #0 //row counter
clear_row_loop:
    cmp r6, #128 //32 rows
    bcs clear_char_end
    mov r0, #0 //col counter
clear_col_loop:
        cmp r0, #64 //32 columns
        bcs next_row
        mov r1, r6, lsl #6 //row * 32
        add r1, r0 //row*32 + col
        strb r5, [r4,r1]
        add r0, #1
        b clear_col_loop
next_row:
        add r6, #1
        b clear_row_loop

clear_char_end:
    pop {r4, r5, r6, lr}
    bx lr

// Subroutine to update the 7-segment display
update_display:
    PUSH {r1-r12, lr}       // Save registers
    
    // Extract digits from number
    MOV r1, r0              // Copy number to r1
    
    // Extract thousands digit
    MOV r3, r1              // Copy number to r3
    LDR r4, =THOUSAND
    LDR r4, [r4]            // Load 1000
    BL divide               // r0 = r3 / r4, r1 = r3 % r4
    MOV r9, r0              // Save thousands digit in r9
    
    // Extract hundreds digit
    MOV r3, r1              // Copy remainder to r3
    LDR r4, =HUNDRED
    LDR r4, [r4]            // Load 100
    BL divide               // r0 = r3 / r4, r1 = r3 % r4
    MOV r10, r0             // Save hundreds digit in r10
    
    // Extract tens digit
    MOV r3, r1              // Copy remainder to r3
    LDR r4, =TEN
    LDR r4, [r4]            // Load 10
    BL divide               // r0 = r3 / r4, r1 = r3 % r4
    MOV r11, r0             // Save tens digit in r11
    MOV r12, r1             // Save ones digit in r12
    
    // Get 7-segment patterns for each digit
    MOV r0, r9              // Load thousands digit
    BL get_pattern_for_digit    // Input: r9 (thousands), Output: r5
    MOV r5, r0                  // Save thousands pattern
    
    MOV r0, r10                 // Load hundreds digit
    BL get_pattern_for_digit    // Input: r10 (hundreds), Output: r6
    MOV r6, r0                  // Save hundreds pattern
    
    MOV r0, r11                 // Load tens digit
    BL get_pattern_for_digit    // Input: r11 (tens), Output: r7
    MOV r7, r0                  // Save tens pattern
    
    MOV r0, r12                 // Load ones digit
    BL get_pattern_for_digit    // Input: r12 (ones), Output: r8
    MOV r8, r0                  // Save ones pattern
    
    // Combine all digits into one 32-bit word
    LSL r5, r5, #24         // Position thousands digit
    LSL r6, r6, #16         // Position hundreds digit
    LSL r7, r7, #8          // Position tens digit
    MOV r4, r5              // Start with thousands
    ORR r4, r4, r6          // Add hundreds
    ORR r4, r4, r7          // Add tens
    ORR r4, r4, r8          // Add ones
    
    // Write to display
    LDR r0, =HEX3_HEX0_BASE // @2h-5
    STR r4, [r0]            // Write all 4 digits at once
    
    POP {r1-r12, pc}        // Restore registers and return

// Get 7-segment pattern for a digit
// Input: r0 = digit (0-9)
// Output: r0 = 7-segment pattern
get_pattern_for_digit:
    PUSH {r1-r3, lr}        // Save registers
    
    // Ensure digit is in range 0-9
    CMP r0, #9
    MOVGT r0, #0            // Default to 0 if out of range
    
    // Get pattern from lookup table
    LDR r1, =PATTERNS_TABLE
    LDR r2, [r1, r0, LSL #2]  // Load pattern for digit (word-aligned)
    MOV r0, r2              // Return pattern in r0
    
    POP {r1-r3, pc}         // Restore registers and return

write_full:
	PUSH {r0-r11, lr}        // Save registers
	
	mov r4, #0
	ldr r5, =PATTERNS_TABLE
	
	ldr r5, [r5,#40]
	lsl r5, r5, #24
	orr r4, r4, r5
	
	ldr r5, =PATTERNS_TABLE
	ldr r5, [r5,#44]
	lsl r5, r5, #16
	orr r4, r4, r5
	
	ldr r5, =PATTERNS_TABLE
	ldr r5, [r5,#48]
	orr r4, r4, r5
	lsl r5, r5, #8
	orr r4, r4, r5
	
    // Write to display
    LDR r0, =HEX3_HEX0_BASE // @Author 🆉. Sūn
    STR r4, [r0]            // Write all 4 digits at once
	
	
    POP {r0-r11, lr}         // Restore registers and return
	
	bx lr

// Clear all 7-segment displays
clear_all_segments:
    PUSH {r0-r1, lr}        // Save registers
    LDR r0, =HEX3_HEX0_BASE
    MOV r1, #0              // Value to clear segments (all off)
    STR r1, [r0]            // Clear all 4 digits at once
    POP {r0-r1, pc}         // Restore registers and return

// Integer division subroutine (r0 = r3 / r4, r1 = r3 % r4)
divide:
    MOV r0, #0              // Initialize quotient
divide_loop:
    CMP r3, r4              // Compare dividend with divisor
    BLT divide_done         // If dividend < divisor, we're done
    SUB r3, r3, r4          // Subtract divisor from dividend
    ADD r0, r0, #1          // Increment quotient
    B divide_loop           // Continue division
divide_done:
    MOV r1, r3              // Set remainder
    BX lr                   // Return

LoadQueueNumbers:
	ldr r0, =QUEUE_BASE
	mov r1, #0
	b LoadQueueNumbersLoop

LoadQueueNumbersLoop:
	mov r2, r1, lsl #2
	str r1, [r0,r2]
	add r1, #1
	cmp r1, r10
	bne LoadQueueNumbersLoop // @Author Z. Sūn
	
	bx lr
	
.section .data
.align 4
TAIL: .word 0x0
.align 4
HEAD: .word 0x0
.align 4
COUNT: .word 0x0

.align 4
OFF_MESSAGE: .asciz "The order status system is off..."

.align 4  // Ensure word alignment
// 7-segment patterns for digits 0-9 (as words for proper alignment)
PATTERNS_TABLE:
    .word 0x0000003F        // 0: 0b00111111
    .word 0x00000006        // 1: 0b00000110
    .word 0x0000005B        // 2: 0b01011011
    .word 0x0000004F        // 3: 0b01001111
    .word 0x00000066        // 4: 0b01100110
    .word 0x0000006D        // 5: 0b01101101
    .word 0x0000007D        // 6: 0b01111101
    .word 0x00000007        // 7: 0b00000111
    .word 0x0000007F        // 8: 0b01111111
    .word 0x0000006F        // 9: 0b01101111
	.word 0x00000071        // F: 0b01110001
	.word 0x0000003E        // U: 0b00111110
	.word 0x00000038        // L: 0b00111000

// Constants
.align 4  // Ensure word alignment
THOUSAND:
    .word 1000              // Constant for digit extraction
HUNDRED:
    .word 100               // Constant for digit extraction
TEN:
    .word 10                // Constant for digit extraction