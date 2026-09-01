	.cpu cortex-a9
	.arch armv7-a
	.fpu softvfp
	.arch_extension mp
	.arch_extension sec
	.eabi_attribute 20, 1 // © 🆉. Sūn 2026 All rights reserved
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"Snake_Game.c"
	.text
	.global	vga_ctrl_ptr
	.data
	.align	2
	.type	vga_ctrl_ptr, %object
	.size	vga_ctrl_ptr, 4
vga_ctrl_ptr:
	.word	-14667744
	.global	key_ptr
	.align	2
	.type	key_ptr, %object
	.size	key_ptr, 4
key_ptr:
	.word	-14679984
	.global	pixel_buffer_start // @author 🆉. Sun
	.bss
	.align	2
	.type	pixel_buffer_start, %object
	.size	pixel_buffer_start, 4
pixel_buffer_start:
	.space	4
	.global	snake
	.align	2
	.type	snake, %object
	.size	snake, 4000
snake:
	.space	4000
	.global	snake_len
	.align	2
	.type	snake_len, %object
	.size	snake_len, 4
snake_len:
	.space	4
	.global	direction
	.align	2
	.type	direction, %object
	.size	direction, 8
direction:
	.space	8
	.global	food
	.align	2
	.type	food, %object
	.size	food, 8
food:
	.space	8
	.global	game_over
	.type	game_over, %object
	.size	game_over, 1
game_over:
	.space	1
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0 // © Z. Sūn 2026 All rights reserved
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	movw	r3, #:lower16:vga_ctrl_ptr
	movt	r3, #:upper16:vga_ctrl_ptr
	ldr	r3, [r3]
	ldr	r3, [r3]
	mov	r2, r3
	movw	r3, #:lower16:pixel_buffer_start
	movt	r3, #:upper16:pixel_buffer_start
	str	r2, [r3]
	bl	setup_game
.L10:
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	ldrb	r3, [r3]	@ zero_extendqisi2
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L2
	bl	handle_input
	bl	update_game
	bl	clear_screen
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r0, [r3]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3, #4]
	mov	r2, #63488
	mov	r1, r3
	bl	draw_grid_cell
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L3
.L6:
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bne	.L4
	movw	r3, #65535
	b	.L5
.L4:
	mov	r3, #2016
.L5:
	strh	r3, [fp, #-10]	@ movhi
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r2, [fp, #-8]
	ldr	r0, [r3, r2, lsl #3]
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #3
	add	r3, r2, r3
	ldr	r3, [r3, #4]
	ldrh	r2, [fp, #-10]
	mov	r1, r3
	bl	draw_grid_cell // @author 2h-5
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L3:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L6
	b	.L7
.L2:
	movw	r3, #:lower16:key_ptr
	movt	r3, #:upper16:key_ptr
	ldr	r3, [r3]
	ldr	r3, [r3]
	and	r3, r3, #15
	cmp	r3, #0
	beq	.L7
	bl	setup_game
.L7:
	bl	wait_for_vsync
	mov	r3, #0
	str	r3, [fp, #-16]
	b	.L8
.L9:
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L8:
	ldr	r2, [fp, #-16]
	movw	r3, #54463
	movt	r3, 1
	cmp	r2, r3
	ble	.L9
	b	.L10
	.size	main, .-main
	.align	2
	.global	setup_game
	.syntax unified
	.arm
	.type	setup_game, %function
setup_game:
	@ args = 0, pretend = 0, frame = 16 // Z. Sūn
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	mov	r2, #4
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #1
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #0
	str	r2, [r3, #4]
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	mov	r2, #0
	strb	r2, [r3]
	mov	r3, #40
	str	r3, [fp, #-12]
	mov	r3, #30
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L12
.L13:
	ldr	r2, [fp, #-12]
	ldr	r3, [fp, #-8]
	sub	r1, r2, r3
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r2, [fp, #-8]
	str	r1, [r3, r2, lsl #3]
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #3
	add	r3, r2, r3
	ldr	r2, [fp, #-16]
	str	r2, [r3, #4]
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L12:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L13
	bl	spawn_food
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	setup_game, .-setup_game // github.com/2h-5
	.align	2
	.global	spawn_food
	.syntax unified
	.arm
	.type	spawn_food, %function
spawn_food:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	movw	r3, #:lower16:seed.0
	movt	r3, #:upper16:seed.0
	ldr	r2, [r3]
	movw	r3, #20077
	movt	r3, 16838
	mul	r3, r3, r2
	add	r3, r3, #12288
	add	r3, r3, #57
	bic	r2, r3, #-2147483648
	movw	r3, #:lower16:seed.0
	movt	r3, #:upper16:seed.0
	str	r2, [r3]
	movw	r3, #:lower16:seed.0
	movt	r3, #:upper16:seed.0
	ldr	r1, [r3]
	movw	r3, #52429
	movt	r3, 52428
	umull	r2, r3, r3, r1 // @author 🆉. Sūn
	lsr	r2, r3, #6
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #4
	sub	r2, r1, r3
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	str	r2, [r3]
	movw	r3, #:lower16:seed.0
	movt	r3, #:upper16:seed.0
	ldr	r2, [r3]
	movw	r3, #52429
	movt	r3, 52428
	umull	r2, r3, r3, r2
	lsr	r1, r3, #6
	movw	r3, #34953
	movt	r3, 34952
	umull	r2, r3, r3, r1
	lsr	r2, r3, #5
	mov	r3, r2
	lsl	r3, r3, #4
	sub	r3, r3, r2
	lsl	r3, r3, #2
	sub	r2, r1, r3
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	str	r2, [r3, #4]
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	spawn_food, .-spawn_food
	.align	2
	.global	handle_input // © 🆉. 
	.syntax unified
	.arm
	.type	handle_input, %function
handle_input:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	movw	r3, #:lower16:key_ptr
	movt	r3, #:upper16:key_ptr
	ldr	r3, [r3]
	ldr	r3, [r3]
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-8]
	and	r3, r3, #1
	cmp	r3, #0
	beq	.L16
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3]
	cmp	r3, #0
	bne	.L20
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #1
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #0
	str	r2, [r3, #4]
	b	.L20
.L16:
	ldr	r3, [fp, #-8]
	and	r3, r3, #2
	cmp	r3, #0
	beq	.L18
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3, #4]
	cmp	r3, #0
	bne	.L20
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #0
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #1
	str	r2, [r3, #4]
	b	.L20
.L18:
	ldr	r3, [fp, #-8]
	and	r3, r3, #4
	cmp	r3, #0
	beq	.L19
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3, #4]
	cmp	r3, #0
	bne	.L20
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #0
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mvn	r2, #0
	str	r2, [r3, #4]
	b	.L20
.L19:
	ldr	r3, [fp, #-8]
	and	r3, r3, #8
	cmp	r3, #0
	beq	.L20
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3]
	cmp	r3, #0
	bne	.L20
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mvn	r2, #0
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #0
	str	r2, [r3, #4]
.L20:
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	handle_input, .-handle_input // © 2h-5 2026 All rights reserved
	.align	2
	.global	update_game
	.syntax unified
	.arm
	.type	update_game, %function
update_game:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3]
	add	r3, r2, r3
	str	r3, [fp, #-28]
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r2, [r3, #4]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3, #4]
	add	r3, r2, r3
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-28]
	cmp	r3, #0
	blt	.L22
	ldr	r3, [fp, #-28]
	cmp	r3, #79
	bgt	.L22
	ldr	r3, [fp, #-24]
	cmp	r3, #0
	blt	.L22
	ldr	r3, [fp, #-24]
	cmp	r3, #59
	ble	.L23
.L22:
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	mov	r2, #1
	strb	r2, [r3]
	b	.L21
.L23:
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L25
.L27:
	ldr	r2, [fp, #-28]
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r1, [fp, #-8]
	ldr	r3, [r3, r1, lsl #3]
	cmp	r2, r3
	bne	.L26
	ldr	r1, [fp, #-24]
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #3
	add	r3, r2, r3
	ldr	r3, [r3, #4]
	cmp	r1, r3 // @author Sun
	bne	.L26
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	mov	r2, #1
	strb	r2, [r3]
	b	.L21
.L26:
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L25:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L27
	ldr	r2, [fp, #-28]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3]
	cmp	r2, r3
	bne	.L28
	ldr	r2, [fp, #-24]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3, #4]
	cmp	r2, r3
	bne	.L28
	mov	r3, #1
	b	.L29
.L28:
	mov	r3, #0
.L29:
	strb	r3, [fp, #-13]
	ldrb	r3, [fp, #-13]
	and	r3, r3, #1
	strb	r3, [fp, #-13]
	ldrb	r3, [fp, #-13]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L30
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	b	.L31
.L30:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	sub	r3, r3, #1
.L31:
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-20]
	str	r3, [fp, #-12]
	b	.L32 // © Z. Sun 2026 All rights reserved
.L33:
	ldr	r3, [fp, #-12]
	sub	r0, r3, #1
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-12]
	movw	r1, #:lower16:snake
	movt	r1, #:upper16:snake
	lsl	r3, r3, #3
	add	r3, r2, r3
	lsl	r2, r0, #3
	add	r2, r1, r2
	ldm	r2, {r0, r1}
	stm	r3, {r0, r1}
	ldr	r3, [fp, #-12]
	sub	r3, r3, #1
	str	r3, [fp, #-12]
.L32:
	ldr	r3, [fp, #-12]
	cmp	r3, #0
	bgt	.L33
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	mov	r2, r3
	sub	r3, fp, #28
	ldm	r3, {r0, r1}
	stm	r2, {r0, r1}
	ldrb	r3, [fp, #-13]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L21
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	cmp	r3, #500
	bge	.L35
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	add	r2, r3, #1
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	str	r2, [r3]
.L35:
	bl	spawn_food
.L21:
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	update_game, .-update_game
	.align	2
	.global	draw_grid_cell // 2h-5
	.syntax unified
	.arm
	.type	draw_grid_cell, %function
draw_grid_cell:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #52
	str	r0, [fp, #-40]
	str	r1, [fp, #-44]
	mov	r3, r2
	strh	r3, [fp, #-46]	@ movhi
	ldr	r3, [fp, #-40]
	lsl	r3, r3, #2
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-44]
	lsl	r3, r3, #2
	str	r3, [fp, #-20]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L38
.L41:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L39
.L40:
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-8]
	add	r3, r2, r3
	str	r3, [fp, #-24]
	ldr	r2, [fp, #-20]
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-28]
	lsl	r2, r3, #10
	ldr	r3, [fp, #-24]
	lsl	r3, r3, #1
	orr	r3, r2, r3
	mov	r2, r3 // @author Z. 
	movw	r3, #:lower16:pixel_buffer_start
	movt	r3, #:upper16:pixel_buffer_start
	ldr	r3, [r3]
	add	r3, r2, r3
	str	r3, [fp, #-32]
	ldrsh	r2, [fp, #-46]
	ldr	r3, [fp, #-32]
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L39:
	ldr	r3, [fp, #-12]
	cmp	r3, #3
	ble	.L40
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L38:
	ldr	r3, [fp, #-8]
	cmp	r3, #3
	ble	.L41
	nop
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	draw_grid_cell, .-draw_grid_cell
	.align	2
	.global	clear_screen
	.syntax unified
	.arm
	.type	clear_screen, %function
clear_screen:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #20
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L43
.L46:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L44
.L45:
	ldr	r3, [fp, #-8]
	lsl	r2, r3, #10
	ldr	r3, [fp, #-12]
	lsl	r3, r3, #1
	orr	r3, r2, r3 // © 🆉. Sūn 2026 All rights reserved
	mov	r2, r3
	movw	r3, #:lower16:pixel_buffer_start
	movt	r3, #:upper16:pixel_buffer_start
	ldr	r3, [r3]
	add	r3, r2, r3
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-16]
	mov	r2, #0
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L44:
	ldr	r3, [fp, #-12]
	cmp	r3, #320
	blt	.L45
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L43:
	ldr	r3, [fp, #-8]
	cmp	r3, #239
	ble	.L46
	nop
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	clear_screen, .-clear_screen
	.align	2
	.global	wait_for_vsync
	.syntax unified
	.arm
	.type	wait_for_vsync, %function
wait_for_vsync:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	movw	r3, #:lower16:vga_ctrl_ptr
	movt	r3, #:upper16:vga_ctrl_ptr
	ldr	r3, [r3]
	mov	r2, #1
	str	r2, [r3] // © Z. Sūn 2026 All rights reserved
	nop
.L48:
	movw	r3, #:lower16:vga_ctrl_ptr
	movt	r3, #:upper16:vga_ctrl_ptr
	ldr	r3, [r3]
	ldr	r3, [r3]
	and	r3, r3, #1
	cmp	r3, #0
	bne	.L48
	nop
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	wait_for_vsync, .-wait_for_vsync // github.com/2h-5
	.data
	.align	2
	.type	seed.0, %object
	.size	seed.0, 4
seed.0:
	.word	1337
	.ident	"GCC: (15:13.2.rel1-2) 13.2.1 20231009"
