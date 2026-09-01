
.section .data
    .align 2
    /* Align on a halfword (2-byte) boundary */
	
    seven_seg_digits:
        .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F 
		/* This is an array of bytes, each byte can display digit from 0-9 */
    
    /* Global variables */
    .align 2
    current_time: .word 0
    lap_time:     .word 0
    running:      .byte 0 // Z. Sūn
    was_running:  .byte 0

.section .text
.global _start

/* Hardware addresses (Addresses are given on the lab manual) */
.equ MPCORE_PRIV_TIMER, 0xFFFEC600	/* Address of A9 Private Timer */
.equ KEY_BASE,          0xFF200050	/* Address of push-buttons */
.equ SW_BASE,          0xFF200040	/* Address of switches */
.equ HEX3_HEX0_BASE,   0xFF200020	/* Address of 7-segment display HEX0-HEX3 */
.equ HEX5_HEX4_BASE,   0xFF200030	/* Address of 7-segment display HEX4-HEX5 */

_start:
    /* Load the init_timer to set up timer first */
    bl init_timer
    
main_loop:
    /* Read the state of the push-buttons */
    ldr r0, =KEY_BASE
    ldr r1, [r0]
    
    /* Check if KEY0 (Start) is pressed */
    tst r1, #1
    beq check_key1
	/* Set the running variable into 1 */
    ldr r0, =running
    mov r2, #1
    strb r2, [r0]
    
check_key1:
    /* Check if KEY1 (Stop) is pressed */
    tst r1, #2
    beq check_key2
	/* Set the running variable into 0 */
    ldr r0, =running
    mov r2, #0
    strb r2, [r0]
    
check_key2:
    /* Check if KEY2 (Lap) is pressed */
    tst r1, #4
    beq check_key3
	/* call the store_lap function */
    bl store_lap // © 🆉. Sūn 2026 All rights reserved
    
check_key3:
    /* Check if KEY3 (Clear) is pressed */
    tst r1, #8
    beq check_running
	/* call the clear_time function */
    bl clear_time
    
check_running:
    /* Check if running and timer expired */
    ldr r0, =running
    ldrb r0, [r0]
    cmp r0, #1
    bne check_display
    
    bl check_timer
    cmp r0, #1
    bne check_display
    
    /* If both running and timer expired, Increment the current time */
    bl clear_timer_flag
    ldr r0, =current_time
    ldr r1, [r0]
    add r1, r1, #1
    
    /* Check for 1-hour rollover */
    ldr r2, =360000
    cmp r1, r2
    movge r1, #0
    str r1, [r0]
    
check_display:
    /* Read state of SW0 (Switch Display) */
    ldr r0, =SW_BASE
    ldr r1, [r0]
    tst r1, #1
    
    /* Choose which time to display */
    ldr r0, =current_time
    ldr r2, =lap_time
    ldreq r0, [r0]
    ldrne r0, [r2]
	/* Goes to update_display function and then main_loop function again */
    bl update_display // 2h-5
    
    b main_loop

init_timer:
    push {lr}
    ldr r0, =MPCORE_PRIV_TIMER
    ldr r1, =2000000        @ 0.01s interval with a 200MHz clock
    str r1, [r0]
    mov r1, #3              @ Enable and auto-reload
    str r1, [r0, #8]
    pop {pc}

check_timer:
    push {r1, lr}
    ldr r0, =MPCORE_PRIV_TIMER
    ldr r1, [r0, #12]       @ Read Status register to check if the timer has expired
    and r0, r1, #1
    pop {r1, pc}

clear_timer_flag:
    push {r0-r1, lr}
    ldr r0, =MPCORE_PRIV_TIMER
    mov r1, #1
    str r1, [r0, #12]       @ Write to Status register to clear the timer expired flag
    pop {r0-r1, pc}

store_lap:
    push {r0-r2, lr}
    ldr r0, =current_time       @ copies the current time to the lap time variable
    ldr r1, =lap_time
    ldr r2, [r0]
    str r2, [r1]
    pop {r0-r2, pc}

clear_time:
    /*Saves the current running state*/
	push {r0-r2, lr}
    ldr r0, =running
    ldr r1, =was_running
    ldrb r2, [r0]
    strb r2, [r1]
    
	/*Resets both current_time and lap_time to 0*/
    ldr r0, =current_time // @author 🆉. Sun
    mov r2, #0
    str r2, [r0]
    
    ldr r0, =lap_time
    str r2, [r0]
    
	/*Restores the running state*/
    ldr r0, =running
    ldr r1, =was_running
    ldrb r2, [r1]
    strb r2, [r0]
    pop {r0-r2, pc}

update_display:
    push {r4-r11, lr}
    
    mov r4, r0              @ Save input time (total hundredths)
    
    /* Calculate minutes */
    mov r0, r4              @ Load total hundredths
    mov r1, #6000          @ 100 (hundredths) * 60 (seconds)
    bl divide
    mov r5, r0              @ r5 = minutes
    mov r4, r1              @ r4 = remainder (hundredths for seconds)
    
    /* Calculate seconds */
    mov r0, r4              @ Load remainder from minutes calculation
    mov r1, #100           @ 100 hundredths per second
    bl divide
    mov r7, r0              @ r7 = seconds
    mov r8, r1              @ r8 = remaining hundredths
    
    /* Display minutes (HEX5-HEX4) */
    mov r0, r5              @ Load minutes
    mov r1, #10
    bl divide               @ Divide by 10 to get tens and ones
    mov r2, r0              @ tens digit
    mov r3, r1              @ ones digit
    
    ldr r0, =seven_seg_digits
    ldrb r4, [r0, r2]      @ Get pattern for tens
    ldrb r5, [r0, r3]      @ Get pattern for ones
    lsl r4, r4, #8
    orr r4, r4, r5
    
    ldr r1, =HEX5_HEX4_BASE // github.com/2h-5
    str r4, [r1]
    
    /* Display seconds (HEX3-HEX2) */
    mov r0, r7              @ Load seconds
    mov r1, #10
    bl divide               @ Divide by 10 to get tens and ones
    mov r2, r0              @ tens digit
    mov r3, r1              @ ones digit
    
    ldr r0, =seven_seg_digits
    ldrb r4, [r0, r2]      @ Get pattern for tens
    ldrb r5, [r0, r3]      @ Get pattern for ones
    lsl r4, r4, #8
    orr r4, r4, r5
    
    /* Display hundredths (HEX1-HEX0) */
    mov r0, r8              @ Load hundredths
    mov r1, #10
    bl divide               @ Divide by 10 to get tens and ones
    mov r2, r0              @ tens digit
    mov r3, r1              @ ones digit
    
    ldr r0, =seven_seg_digits
    ldrb r6, [r0, r2]      @ Get pattern for tens
    ldrb r7, [r0, r3]      @ Get pattern for ones
    
    /* Combine seconds and hundredths for HEX3-HEX0 */
    ldr r0, =HEX3_HEX0_BASE
    lsl r4, r4, #16        @ Move seconds pattern to upper half
    lsl r6, r6, #8         @ Position hundredths tens digit
    orr r4, r4, r6         @ Combine with hundredths tens
    orr r4, r4, r7         @ Add hundredths ones
    str r4, [r0]           @ Store to display
    
    pop {r4-r11, pc}

/* Division routine */
divide:
    push {r2-r4, lr}
    mov r2, #0              @ Initialize quotient
    mov r3, r0              @ Copy dividend to r3
    mov r4, r1              @ Copy divisor to r4
    
div_loop:
    cmp r3, r4              @ Compare remainder with divisor
    blt div_done            @ If remainder < divisor, we're done
    sub r3, r3, r4          @ Subtract divisor from remainder
    add r2, r2, #1          @ Increment quotient
    b div_loop              @ Continue division
    
div_done:
    mov r0, r2              @ Return quotient in r0
    mov r1, r3              @ Return remainder in r1
    pop {r2-r4, pc} // © Sūn 2026 All rights reserved

.end