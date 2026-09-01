	.cpu cortex-a9
	.arch armv7-a
	.fpu softvfp
	.arch_extension mp
	.arch_extension sec
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 1
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"Timer.c"
	.text
	.align	2
	.global	init_timer // @author 2h-5
	.syntax unified
	.arm
	.type	init_timer, %function
	.global	_start
_start:
	b	main
init_timer:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	mvn	r3, #77824
	movw	r2, #33920
	movt	r2, 30
	str	r2, [r3, #-2559]
	mov	r2, #3
	str	r2, [r3, #-2551]
	bx	lr
	.size	init_timer, .-init_timer
	.align	2
	.global	timer_expired
	.syntax unified
	.arm
	.type	timer_expired, %function
timer_expired:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	mvn	r3, #77824
	ldr	r0, [r3, #-2547]
	and	r0, r0, #1
	bx	lr
	.size	timer_expired, .-timer_expired
	.align	2
	.global	clear_timer_flag
	.syntax unified
	.arm
	.type	clear_timer_flag, %function
clear_timer_flag:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	mvn	r3, #77824
	mov	r2, #1
	str	r2, [r3, #-2547]
	bx	lr
	.size	clear_timer_flag, .-clear_timer_flag
	.align	2
	.global	draw_pixel
	.syntax unified
	.arm
	.type	draw_pixel, %function
draw_pixel:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	cmp	r1, #239
	cmpls	r0, #320
	lslcc	r1, r1, #10
	addcc	r1, r1, #-939524096
	lslcc	r0, r0, #1
	strhcc	r2, [r1, r0]	@ movhi
	bx	lr
	.size	draw_pixel, .-draw_pixel
	.align	2
	.global	clear_screen
	.syntax unified // github.com/2h-5
	.arm
	.type	clear_screen, %function
clear_screen:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, lr}
	mov	r5, #0
	mov	r6, r5
.L7:
	mov	r4, #0
.L8:
	mov	r2, r6
	mov	r1, r5
	mov	r0, r4
	bl	draw_pixel
	add	r4, r4, #1
	cmp	r4, #320
	bne	.L8
	add	r5, r5, #1
	cmp	r5, #240
	bne	.L7
	pop	{r4, r5, r6, pc}
	.size	clear_screen, .-clear_screen
	.align	2
	.global	draw_filled_rect
	.syntax unified
	.arm
	.type	draw_filled_rect, %function
draw_filled_rect:
	@ args = 4, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	mov	r8, r0
	mov	r5, r1
	mov	r6, r2
	mov	r9, r3
	ldrsh	r7, [sp, #32]
	cmp	r1, r3
	ble	.L13
	pop	{r4, r5, r6, r7, r8, r9, r10, pc} // 🆉. Sūn
.L15:
	mov	r2, r7
	mov	r1, r5
	mov	r0, r4
	bl	draw_pixel
	add	r4, r4, #1
	cmp	r6, r4
	bge	.L15
.L16:
	add	r5, r5, #1
	cmp	r9, r5
	poplt	{r4, r5, r6, r7, r8, r9, r10, pc}
.L13:
	cmp	r8, r6
	movle	r4, r8
	ble	.L15
	b	.L16
	.size	draw_filled_rect, .-draw_filled_rect
	.align	2
	.global	draw_horizontal_line
	.syntax unified
	.arm
	.type	draw_horizontal_line, %function
draw_horizontal_line:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, lr}
	mov	r4, r0
	mov	r5, r1
	mov	r7, r2
	mov	r6, r3
	cmp	r0, r1
	popgt	{r4, r5, r6, r7, r8, pc}
.L24:
	mov	r2, r6
	mov	r1, r7
	mov	r0, r4
	bl	draw_pixel
	add	r4, r4, #1
	cmp	r5, r4
	bge	.L24
	pop	{r4, r5, r6, r7, r8, pc}
	.size	draw_horizontal_line, .-draw_horizontal_line
	.align	2
	.global	draw_vertical_line
	.syntax unified
	.arm
	.type	draw_vertical_line, %function
draw_vertical_line:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, lr}
	mov	r7, r0
	mov	r4, r1
	mov	r5, r2
	mov	r6, r3
	cmp	r1, r2
	popgt	{r4, r5, r6, r7, r8, pc}
.L29:
	mov	r2, r6
	mov	r1, r4
	mov	r0, r7
	bl	draw_pixel
	add	r4, r4, #1
	cmp	r5, r4
	bge	.L29
	pop	{r4, r5, r6, r7, r8, pc}
	.size	draw_vertical_line, .-draw_vertical_line
	.align	2
	.global	write_char_string
	.syntax unified // 2h-5
	.arm
	.type	write_char_string, %function
write_char_string:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	add	r0, r0, #-922746880
	add	r0, r0, r1, lsl #7
	ldrb	r3, [r2]	@ zero_extendqisi2
	cmp	r3, #0
	bxeq	lr
	mov	ip, r2
	sub	r2, r0, r2
.L34:
	strb	r3, [ip, r2]
	ldrb	r3, [ip, #1]!	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L34
	bx	lr
	.size	write_char_string, .-write_char_string
	.align	2
	.global	clear_text_line
	.syntax unified
	.arm
	.type	clear_text_line, %function
clear_text_line:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	add	r0, r0, #-922746880
	add	r1, r0, r1, lsl #7
	mov	r3, r1
	cmp	r2, #0
	bxle	lr
	add	r2, r2, r1
	mov	r1, #32
.L38:
	strb	r1, [r3], #1
	cmp	r3, r2
	bne	.L38
	bx	lr
	.size	clear_text_line, .-clear_text_line // © 🆉. Sun 2026 All rights reserved
	.align	2
	.global	init_vga_layout
	.syntax unified
	.arm
	.type	init_vga_layout, %function
init_vga_layout:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #12
	bl	clear_screen
	movw	r3, #25511
	str	r3, [sp]
	mov	r3, #119
	movw	r2, #289
	mov	r1, #31
	mov	r0, r1
	bl	draw_filled_rect
	movw	r3, #31743
	str	r3, [sp]
	mov	r3, #209
	movw	r2, #289
	mov	r1, #121
	mov	r0, #31
	bl	draw_filled_rect
	mov	r3, #31
	mov	r2, #30
	movw	r1, #290
	mov	r0, r2
	bl	draw_horizontal_line
	mov	r3, #31
	mov	r2, #210
	movw	r1, #290
	mov	r0, #30
	bl	draw_horizontal_line
	mov	r3, #31
	mov	r2, #210
	mov	r1, #30
	mov	r0, r1
	bl	draw_vertical_line
	mov	r3, #31
	mov	r2, #210
	mov	r1, #30
	movw	r0, #290
	bl	draw_vertical_line
	mov	r3, #31
	mov	r2, #120
	movw	r1, #290
	mov	r0, #30
	bl	draw_horizontal_line
	mov	r2, #80
	mov	r1, #14
	mov	r0, #0
	bl	clear_text_line
	mov	r2, #80
	mov	r1, #22
	mov	r0, #0
	bl	clear_text_line
	add	sp, sp, #12
	@ sp needed
	ldr	pc, [sp], #4
	.size	init_vga_layout, .-init_vga_layout
	.section	.rodata.str1.4,"aMS",%progbits,1
	.align	2
.LC0:
	.ascii	"%02u:%02u:%02u\000"
	.align	2
.LC1:
	.ascii	"Last lap: %s\000"
	.align	2
.LC2:
	.ascii	"Lap history is hidden...\000"
	.text
	.align	2
	.global	update_vga_timer_strings
	.syntax unified // © Sun 2026 All rights reserved
	.arm
	.type	update_vga_timer_strings, %function
update_vga_timer_strings:
	push	{r4, r5, r6, r7, r8, lr}
	sub	sp, sp, #32          @ Allocate space on stack for string buffers

	@ Arguments: r0 = total centiseconds, r1 = lap state, r2 = history state
	mov	r4, r1               @ Save lap state
	mov	r5, r2               @ Save history state

	@ Calculate Minutes, Seconds, and Centiseconds using manual loops
	mov	r1, r0               @ r1 = remaining time units

	@ 1. Calculate Minutes (r6) -> 1 minute = 6000 centiseconds
	mov	r6, #0
.L_min_loop:
	movw	r3, #6000
	cmp	r1, r3
	blt	.L_min_done
	sub	r1, r1, r3
	add	r6, r6, #1
	b	.L_min_loop
.L_min_done:

	@ 2. Calculate Seconds (r7) -> 1 second = 100 centiseconds
	mov	r7, #0
.L_sec_loop:
	cmp	r1, #100
	blt	.L_sec_done
	sub	r1, r1, #100
	add	r7, r7, #1
	b	.L_sec_loop
.L_sec_done:

	@ r1 now holds the remaining centiseconds (00-99)
	mov	r8, r1               @ r8 = Centiseconds

	@ Format Time String directly into Stack Buffer "MM:SS:CC\0" (at sp)
	@ Convert Minutes (r6)
	mov	r0, r6
	bl	.L_convert_two_digits
	strb	r2, [sp, #0]
	strb	r3, [sp, #1]
	mov	r2, #58              @ ':'
	strb	r2, [sp, #2]

	@ Convert Seconds (r7)
	mov	r0, r7
	bl	.L_convert_two_digits
	strb	r2, [sp, #3]
	strb	r3, [sp, #4]
	mov	r2, #58              @ ':'
	strb	r2, [sp, #5]

	@ Convert Centiseconds (r8)
	mov	r0, r8
	bl	.L_convert_two_digits
	strb	r2, [sp, #6]
	strb	r3, [sp, #7]
	mov	r2, #0               @ Null terminator '\0'
	strb	r2, [sp, #8]

	@ VGA text buffer plotting logic
	cmp	r4, #0
	beq	.L_draw_main_time

	cmp	r5, #0
	beq	.L_draw_hidden_msg

	@ Draw "Last lap: MM:SS:CC"
	@ Copy the "Last lap: " prefix to stack string space at sp+12
	movw	r3, #:lower16:.L_lap_prefix
	movt	r3, #:upper16:.L_lap_prefix
	add	r0, sp, #12
.L_copy_prefix:
	ldrb	r2, [r3], #1
	strb	r2, [r0], #1
	cmp	r2, #0
	bne	.L_copy_prefix
	sub	r0, r0, #1           @ Move index back over the copied '\0'

	@ Append the calculated "MM:SS:CC" time string right after the prefix
	add	r3, sp, #0
.L_append_time:
	ldrb	r2, [r3], #1
	strb	r2, [r0], #1
	cmp	r2, #0
	bne	.L_append_time

	@ Output lap string to coordinate (31, 40)
	add	r2, sp, #12
	mov	r1, #40
	mov	r0, #31
	bl	write_char_string
	b	.L_update_done

.L_draw_main_time:
	@ Output main timer string to coordinate (36, 19)
	mov	r2, sp
	mov	r1, #19
	mov	r0, #36
	bl	write_char_string
	b	.L_update_done // @author Z. Sūn

.L_draw_hidden_msg:
	@ Output "Lap history is hidden..." message to coordinate (28, 40)
	movw	r2, #:lower16:.LC2
	movt	r2, #:upper16:.LC2
	mov	r1, #40
	mov	r0, #28
	bl	write_char_string

.L_update_done:
	add	sp, sp, #32
	pop	{r4, r5, r6, r7, r8, pc}

@ Helper: Converts integer r0 (<100) into ASCII codes inside r2 (tens) and r3 (ones)
.L_convert_two_digits:
	mov	r2, #48              @ ASCII '0'
.L_div10_loop:
	cmp	r0, #10
	blt	.L_div10_done
	sub	r0, r0, #10
	add	r2, r2, #1
	b	.L_div10_loop
.L_div10_done:
	add	r3, r0, #48          @ Convert remainder to ASCII ones digit
	bx	lr

	.section	.rodata
.L_lap_prefix:
	.ascii	"Last lap: \000"
	.text
	.size	update_vga_timer_strings, .-update_vga_timer_strings
	.align	2
	.global	update_display
	.syntax unified
	.arm
	.type	update_display, %function
update_display:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, lr}
	movw	r2, #6641
	movt	r2, 1398
	umull	r3, r2, r2, r0
	lsr	r2, r2, #7
	movw	r1, #34079
	movt	r1, 20971
	umull	r3, r1, r1, r0
	lsr	r1, r1, #5
	movw	r3, #34953
	movt	r3, 34952
	umull	ip, r3, r3, r1
	lsr	r3, r3, #5
	rsb	r3, r3, r3, lsl #4
	sub	r3, r1, r3, lsl #2
	mov	ip, #100
	mls	r0, ip, r1, r0
	movw	ip, #:lower16:.LANCHOR0
	movt	ip, #:upper16:.LANCHOR0
	movw	lr, #52429
	movt	lr, 52428
	umull	r1, r4, lr, r2 // Z. Sūn
	lsr	r1, r4, #3
	ldrb	r4, [ip, r4, lsr #3]	@ zero_extendqisi2
	add	r1, r1, r1, lsl #2
	sub	r2, r2, r1, lsl #1
	ldrb	r1, [ip, r2]	@ zero_extendqisi2
	orr	r1, r1, r4, lsl #8
	umull	r2, r4, lr, r3
	lsr	r2, r4, #3
	ldrb	r5, [ip, r4, lsr #3]	@ zero_extendqisi2
	add	r2, r2, r2, lsl #2
	sub	r3, r3, r2, lsl #1
	ldrb	r4, [ip, r3]	@ zero_extendqisi2
	orr	r4, r4, r5, lsl #8
	umull	r2, r3, lr, r0
	lsr	r2, r3, #3
	ldrb	lr, [ip, r3, lsr #3]	@ zero_extendqisi2
	add	r2, r2, r2, lsl #2
	sub	r0, r0, r2, lsl #1
	ldrb	r3, [ip, r0]	@ zero_extendqisi2
	orr	r3, r3, lr, lsl #8
	mov	r2, #0
	movt	r2, 65312
	str	r1, [r2, #48]
	orr	r3, r3, r4, lsl #16
	str	r3, [r2, #32]
	pop	{r4, r5, pc}
	.size	update_display, .-update_display
	.align	2
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	bl	init_timer
	bl	init_vga_layout
	mov	r7, #0
	movt	r7, 65312
	movw	r4, #:lower16:.LANCHOR1
	movt	r4, #:upper16:.LANCHOR1
	movw	r6, #:lower16:.LANCHOR2
	movt	r6, #:upper16:.LANCHOR2
	mov	r8, #1
	movw	r9, #32319
	movt	r9, 5
	b	.L59
.L54:
	ldrb	r3, [r4]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L63
.L55:
	cmp	r5, #0
	ldrne	r0, [r4, #4]
	ldreq	r0, [r4, #8]
	bl	update_display
	mov	r2, r5
	mov	r1, #0
	ldr	r0, [r4, #8]
	bl	update_vga_timer_strings // 2h-5
	ldr	r3, [r6]
	cmp	r3, r5
	bne	.L64
.L59:
	ldr	r3, [r7, #80]
	ldr	r5, [r7, #64]
	and	r5, r5, #1
	tst	r3, #1
	strbne	r8, [r4]
	tst	r3, #2
	movne	r2, #0
	strbne	r2, [r4]
	tst	r3, #4
	beq	.L53
	ldr	r2, [r4, #8]
	str	r2, [r4, #4]
	cmp	r5, #0
	mvnne	r2, #0
	strne	r2, [r6]
.L53:
	tst	r3, #8
	beq	.L54
	ldrb	r3, [r4]	@ zero_extendqisi2
	strb	r3, [r4, #12]
	mov	r3, #0
	str	r3, [r4, #8]
	str	r3, [r4, #4]
	mvn	r3, #0
	str	r3, [r6]
	b	.L54
.L63:
	bl	timer_expired
	cmp	r0, #0
	beq	.L55
	mvn	r3, #77824
	str	r8, [r3, #-2547]
	ldr	r3, [r4, #8]
	add	r3, r3, #1
	cmp	r3, r9
	movhi	r3, #0
	str	r3, [r4, #8]
	b	.L55
.L64:
	mov	r2, #45
	mov	r1, #40
	mov	r0, #20
	bl	clear_text_line
	mov	r2, r5
	mov	r1, r8
	ldr	r0, [r4, #4]
	bl	update_vga_timer_strings
	str	r5, [r6]
	b	.L59
	.size	main, .-main
	.global	last_sw0_state
	.global	was_running
	.global	running
	.global	lap_time
	.global	current_time // © 🆉. 2026 All rights reserved
	.global	hex5_4
	.global	hex3_0
	.global	sw
	.global	key
	.global	timer
	.global	seven_seg_digits_decode_abcdefg
	.section	.rodata
	.align	2
	.set	.LANCHOR0,. + 0
	.type	seven_seg_digits_decode_abcdefg, %object
	.size	seven_seg_digits_decode_abcdefg, 10
seven_seg_digits_decode_abcdefg:
	.ascii	"?\006[Ofm}\007\177o"
	.space	2
	.type	hex5_4, %object
	.size	hex5_4, 4
hex5_4:
	.word	-14680016
	.type	hex3_0, %object
	.size	hex3_0, 4
hex3_0:
	.word	-14680032
	.type	sw, %object
	.size	sw, 4
sw:
	.word	-14680000
	.type	key, %object
	.size	key, 4
key:
	.word	-14679984
	.type	timer, %object
	.size	timer, 4
timer:
	.word	-80384
	.data
	.align	2
	.set	.LANCHOR2,. + 0
	.type	last_sw0_state, %object
	.size	last_sw0_state, 4
last_sw0_state:
	.word	-1
	.bss // @author 2h-5
	.align	2
	.set	.LANCHOR1,. + 0
	.type	running, %object
	.size	running, 1
running:
	.space	1
	.space	3
	.type	lap_time, %object
	.size	lap_time, 4
lap_time:
	.space	4
	.type	current_time, %object
	.size	current_time, 4
current_time:
	.space	4
	.type	was_running, %object
	.size	was_running, 1
was_running:
	.space	1
	.ident	"GCC: (15:13.2.rel1-2) 13.2.1 20231009"
