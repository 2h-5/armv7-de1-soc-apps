	.cpu cortex-a9
	.arch armv7-a
	.fpu softvfp
	.arch_extension mp
	.arch_extension sec // @author Z.
	.eabi_attribute 20, 1
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
	.global	hex_ptr
	.align	2
	.type	hex_ptr, %object
	.size	hex_ptr, 4
hex_ptr:
	.word	-14680032
	.global	pixel_buffer_start
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
	.global	snake_len
	.align	2
	.type	snake_len, %object
	.size	snake_len, 4
snake_len:
	.space	4
	.global	score
	.align	2
	.type	score, %object
	.size	score, 4
score:
	.space	4
	.global	game_over
	.type	game_over, %object
	.size	game_over, 1
game_over:
	.space	1
	.global	paused
	.type	paused, %object
	.size	paused, 1
paused:
	.space	1
	.text
	.align	2
	.global	main
	.syntax unified // © 🆉. Sūn 2026 All rights reserved
	.arm
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	movw	r3, #:lower16:pixel_buffer_start
	movt	r3, #:upper16:pixel_buffer_start
	mov	r2, #-939524096
	str	r2, [r3]
	bl	setup_game
.L7:
	bl	handle_input
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	ldrb	r3, [r3]	@ zero_extendqisi2
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L2
	movw	r3, #:lower16:paused
	movt	r3, #:upper16:paused
	ldrb	r3, [r3]	@ zero_extendqisi2
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L2
	bl	update_game
.L2:
	bl	clear_screen
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L3
	bl	draw_game_over_scene
	b	.L4
.L3:
	bl	draw_playing_scene
.L4:
	bl	wait_for_vsync
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L5
.L6:
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L5:
	ldr	r2, [fp, #-8]
	movw	r3, #54463
	movt	r3, 1
	cmp	r2, r3
	ble	.L6
	b	.L7
	.size	main, .-main
	.align	2
	.global	setup_game
	.syntax unified
	.arm
	.type	setup_game, %function
setup_game:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	mov	r2, #4
	str	r2, [r3]
	movw	r3, #:lower16:score
	movt	r3, #:upper16:score
	mov	r2, #0
	str	r2, [r3]
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	mov	r2, #0
	strb	r2, [r3]
	movw	r3, #:lower16:paused
	movt	r3, #:upper16:paused
	mov	r2, #0
	strb	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #1
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	mov	r2, #0
	str	r2, [r3, #4]
	mov	r3, #39
	str	r3, [fp, #-12]
	mov	r3, #29
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L9
.L10:
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
.L9:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L10
	bl	spawn_food
	bl	update_hex_display // github.com/2h-5
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	setup_game, .-setup_game
	.align	2
	.global	spawn_food
	.syntax unified
	.arm
	.type	spawn_food, %function
spawn_food:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
.L18:
	movw	r3, #:lower16:seed.2
	movt	r3, #:upper16:seed.2
	ldr	r2, [r3]
	movw	r3, #20077
	movt	r3, 16838
	mul	r3, r3, r2
	add	r3, r3, #12288
	add	r3, r3, #57
	movw	r2, #:lower16:seed.2
	movt	r2, #:upper16:seed.2
	str	r3, [r2]
	movw	r3, #:lower16:seed.2
	movt	r3, #:upper16:seed.2
	ldr	r2, [r3]
	lsr	r1, r2, #1
	movw	r3, #51367
	movt	r3, 56679
	umull	r1, r3, r3, r1
	lsr	r3, r3, #5
	mov	r1, #74
	mul	r3, r1, r3
	sub	r3, r2, r3
	add	r3, r3, #3
	mov	r2, r3
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	str	r2, [r3]
	movw	r3, #:lower16:seed.2
	movt	r3, #:upper16:seed.2
	ldr	r2, [r3]
	movw	r3, #20077
	movt	r3, 16838
	mul	r3, r3, r2
	add	r3, r3, #12288
	add	r3, r3, #57
	movw	r2, #:lower16:seed.2
	movt	r2, #:upper16:seed.2
	str	r3, [r2]
	movw	r3, #:lower16:seed.2
	movt	r3, #:upper16:seed.2
	ldr	r2, [r3]
	movw	r3, #34079
	movt	r3, 20971
	umull	r1, r3, r3, r2
	lsr	r3, r3, #4
	mov	r1, #50
	mul	r3, r1, r3
	sub	r3, r2, r3 // © 🆉. Sun 2026 All rights reserved
	add	r3, r3, #5
	mov	r2, r3
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	str	r2, [r3, #4]
	mov	r3, #0
	strb	r3, [fp, #-5]
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L12
.L15:
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r2, [fp, #-12]
	ldr	r2, [r3, r2, lsl #3]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3]
	cmp	r2, r3
	bne	.L13
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-12]
	lsl	r3, r3, #3
	add	r3, r2, r3
	ldr	r2, [r3, #4]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3, #4]
	cmp	r2, r3
	bne	.L13
	mov	r3, #1
	strb	r3, [fp, #-5]
	b	.L14
.L13:
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L12:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-12]
	cmp	r2, r3
	blt	.L15
.L14:
	ldrb	r3, [fp, #-5]
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	bne	.L20
	b	.L18
.L20:
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	spawn_food, .-spawn_food
	.align	2
	.global	handle_input
	.syntax unified // @author 2h-5
	.arm
	.type	handle_input, %function
handle_input:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	movw	r3, #:lower16:key_ptr
	movt	r3, #:upper16:key_ptr
	ldr	r3, [r3]
	ldr	r3, [r3]
	and	r3, r3, #15
	str	r3, [fp, #-8]
	movw	r3, #:lower16:previous_keys.1
	movt	r3, #:upper16:previous_keys.1
	ldr	r3, [r3]
	mvn	r3, r3
	ldr	r2, [fp, #-8]
	and	r3, r3, r2
	str	r3, [fp, #-12]
	movw	r3, #:lower16:previous_keys.1
	movt	r3, #:upper16:previous_keys.1
	ldr	r2, [fp, #-8]
	str	r2, [r3]
	ldr	r3, [fp, #-12]
	and	r3, r3, #1
	cmp	r3, #0
	beq	.L22
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	ldrb	r3, [r3]	@ zero_extendqisi2
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L22
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3]
	str	r3, [fp, #-16]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3, #4]
	rsb	r2, r3, #0
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	str	r2, [r3]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r2, [fp, #-16]
	str	r2, [r3, #4]
.L22:
	ldr	r3, [fp, #-12]
	and	r3, r3, #2
	cmp	r3, #0
	beq	.L23
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	ldrb	r3, [r3]	@ zero_extendqisi2
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L23
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r3, [r3]
	str	r3, [fp, #-20]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	ldr	r2, [r3, #4]
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	str	r2, [r3]
	ldr	r3, [fp, #-20]
	rsb	r2, r3, #0
	movw	r3, #:lower16:direction
	movt	r3, #:upper16:direction
	str	r2, [r3, #4]
.L23:
	ldr	r3, [fp, #-12]
	and	r3, r3, #4
	cmp	r3, #0
	beq	.L24
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	ldrb	r3, [r3]	@ zero_extendqisi2
	eor	r3, r3, #1
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L24
	movw	r3, #:lower16:paused
	movt	r3, #:upper16:paused
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	movne	r3, #1
	moveq	r3, #0
	uxtb	r3, r3
	eor	r3, r3, #1
	uxtb	r3, r3
	and	r3, r3, #1
	uxtb	r2, r3
	movw	r3, #:lower16:paused
	movt	r3, #:upper16:paused
	strb	r2, [r3]
.L24:
	ldr	r3, [fp, #-12]
	and	r3, r3, #8
	cmp	r3, #0
	beq	.L26
	bl	setup_game
.L26:
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	handle_input, .-handle_input
	.align	2
	.global	update_game
	.syntax unified // © Sūn 2026 All rights reserved
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
	cmp	r3, #2
	ble	.L28
	ldr	r3, [fp, #-28]
	cmp	r3, #76
	bgt	.L28
	ldr	r3, [fp, #-24]
	cmp	r3, #4
	ble	.L28
	ldr	r3, [fp, #-24]
	cmp	r3, #54
	ble	.L29
.L28:
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	mov	r2, #1
	strb	r2, [r3]
	bl	update_hex_display
	b	.L27
.L29:
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L31
.L33:
	ldr	r2, [fp, #-28]
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r1, [fp, #-8]
	ldr	r3, [r3, r1, lsl #3]
	cmp	r2, r3
	bne	.L32
	ldr	r1, [fp, #-24]
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #3
	add	r3, r2, r3
	ldr	r3, [r3, #4]
	cmp	r1, r3
	bne	.L32
	movw	r3, #:lower16:game_over
	movt	r3, #:upper16:game_over
	mov	r2, #1
	strb	r2, [r3]
	bl	update_hex_display
	b	.L27
.L32:
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L31:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L33
	ldr	r2, [fp, #-28]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3]
	cmp	r2, r3
	bne	.L34
	ldr	r2, [fp, #-24]
	movw	r3, #:lower16:food
	movt	r3, #:upper16:food
	ldr	r3, [r3, #4]
	cmp	r2, r3 // 🆉. 
	bne	.L34
	mov	r3, #1
	b	.L35
.L34:
	mov	r3, #0
.L35:
	strb	r3, [fp, #-13]
	ldrb	r3, [fp, #-13]
	and	r3, r3, #1
	strb	r3, [fp, #-13]
	ldrb	r3, [fp, #-13]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L36
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	b	.L37
.L36:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	sub	r3, r3, #1
.L37:
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-20]
	str	r3, [fp, #-12]
	b	.L38
.L39:
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
.L38:
	ldr	r3, [fp, #-12]
	cmp	r3, #0
	bgt	.L39
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	mov	r2, r3
	sub	r3, fp, #28
	ldm	r3, {r0, r1}
	stm	r2, {r0, r1}
	ldrb	r3, [fp, #-13]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L27
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	cmp	r3, #500
	bge	.L41
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	add	r2, r3, #1
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	str	r2, [r3]
.L41:
	movw	r3, #:lower16:score
	movt	r3, #:upper16:score
	ldr	r3, [r3]
	add	r2, r3, #1
	movw	r3, #:lower16:score
	movt	r3, #:upper16:score
	str	r2, [r3]
	bl	spawn_food
	bl	update_hex_display
.L27:
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	update_game, .-update_game // © Z. 2026 All rights reserved
	.section	.rodata
	.align	2
.LC0:
	.ascii	"SNAKE GAME\000"
	.align	2
.LC1:
	.ascii	"SCORE: \000"
	.text
	.align	2
	.global	draw_playing_scene
	.syntax unified
	.arm
	.type	draw_playing_scene, %function
draw_playing_scene:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	bl	draw_rect_frame
	movw	r1, #:lower16:.LC0
	movt	r1, #:upper16:.LC0
	mov	r0, #2
	bl	draw_centered_text
	movw	r3, #:lower16:.LC1
	movt	r3, #:upper16:.LC1
	sub	r2, fp, #16
	ldm	r3, {r0, r1}
	stm	r2, {r0, r1}
	sub	r3, fp, #16
	mov	r2, r3
	mov	r1, #36
	mov	r0, #57
	bl	draw_text
	movw	r3, #:lower16:score
	movt	r3, #:upper16:score
	ldr	r3, [r3]
	mov	r2, r3
	mov	r1, #43
	mov	r0, #57
	bl	draw_decimal
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
	b	.L44
.L47:
	movw	r3, #:lower16:snake
	movt	r3, #:upper16:snake
	ldr	r2, [fp, #-8]
	ldr	r0, [r3, r2, lsl #3]
	movw	r2, #:lower16:snake
	movt	r2, #:upper16:snake
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #3
	add	r3, r2, r3 // github.com/2h-5
	ldr	r1, [r3, #4]
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bne	.L45
	movw	r3, #65535
	b	.L46
.L45:
	mov	r3, #2016
.L46:
	mov	r2, r3
	bl	draw_grid_cell
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L44:
	movw	r3, #:lower16:snake_len
	movt	r3, #:upper16:snake_len
	ldr	r3, [r3]
	ldr	r2, [fp, #-8]
	cmp	r2, r3
	blt	.L47
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	draw_playing_scene, .-draw_playing_scene
	.section	.rodata
	.align	2
.LC2:
	.ascii	"GAME OVER!\000"
	.align	2
.LC3:
	.ascii	"Your final score:\000"
	.text
	.align	2
	.global	draw_game_over_scene
	.syntax unified
	.arm
	.type	draw_game_over_scene, %function
draw_game_over_scene:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #40
	bl	draw_rect_frame // @author 2h-5
	movw	r1, #:lower16:.LC2
	movt	r1, #:upper16:.LC2
	mov	r0, #28
	bl	draw_centered_text
	movw	r1, #:lower16:.LC3
	movt	r1, #:upper16:.LC3
	mov	r0, #31
	bl	draw_centered_text
	movw	r3, #:lower16:score
	movt	r3, #:upper16:score
	ldr	r3, [r3]
	str	r3, [fp, #-8]
	mov	r3, #0
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bne	.L49
	ldr	r3, [fp, #-12]
	add	r2, r3, #1
	str	r2, [fp, #-12]
	sub	r3, r3, #4
	add	r3, r3, fp
	mov	r2, #48
	strb	r2, [r3, #-24]
	b	.L50
.L49:
	mov	r3, #0
	str	r3, [fp, #-16]
	b	.L51
.L52:
	ldr	r2, [fp, #-8]
	movw	r3, #26215
	movt	r3, 26214
	smull	r1, r3, r3, r2
	asr	r1, r3, #2
	asr	r3, r2, #31
	sub	r1, r1, r3
	mov	r3, r1
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #1
	sub	r1, r2, r3
	uxtb	r2, r1
	ldr	r3, [fp, #-16]
	add	r1, r3, #1
	str	r1, [fp, #-16]
	add	r2, r2, #48
	uxtb	r2, r2
	sub	r3, r3, #4
	add	r3, r3, fp
	strb	r2, [r3, #-36]
	ldr	r2, [fp, #-8]
	movw	r3, #26215
	movt	r3, 26214
	smull	r1, r3, r3, r2
	asr	r1, r3, #2
	asr	r3, r2, #31
	sub	r3, r1, r3
	str	r3, [fp, #-8]
.L51:
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	bgt	.L52
	b	.L53
.L54:
	ldr	r3, [fp, #-16]
	sub	r3, r3, #1
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-12]
	add	r2, r3, #1
	str	r2, [fp, #-12]
	sub	r1, fp, #40
	ldr	r2, [fp, #-16]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	sub	r3, r3, #4
	add	r3, r3, fp
	strb	r2, [r3, #-24]
.L53:
	ldr	r3, [fp, #-16]
	cmp	r3, #0
	bgt	.L54
.L50:
	sub	r2, fp, #28
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	sub	r3, fp, #28
	mov	r1, r3
	mov	r0, #34
	bl	draw_centered_text
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	draw_game_over_scene, .-draw_game_over_scene // © 🆉. Sūn 2026 All rights reserved
	.align	2
	.global	draw_rect_frame
	.syntax unified
	.arm
	.type	draw_rect_frame, %function
draw_rect_frame:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	mov	r3, #8
	str	r3, [fp, #-8]
	b	.L56
.L59:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L57
.L58:
	ldr	r3, [fp, #-12]
	add	r3, r3, #16
	mov	r2, #31
	mov	r1, r3
	ldr	r0, [fp, #-8]
	bl	draw_pixel
	ldr	r3, [fp, #-12]
	rsb	r3, r3, #223
	mov	r2, #31
	mov	r1, r3
	ldr	r0, [fp, #-8]
	bl	draw_pixel
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L57:
	ldr	r3, [fp, #-12]
	cmp	r3, #3
	ble	.L58
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L56:
	ldr	r3, [fp, #-8]
	cmp	r3, #312
	blt	.L59
	mov	r3, #16
	str	r3, [fp, #-16]
	b	.L60
.L63:
	mov	r3, #0
	str	r3, [fp, #-20]
	b	.L61
.L62:
	ldr	r3, [fp, #-20]
	add	r3, r3, #8
	mov	r2, #31
	ldr	r1, [fp, #-16]
	mov	r0, r3
	bl	draw_pixel // 2h-5
	ldr	r3, [fp, #-20]
	rsb	r3, r3, #308
	add	r3, r3, #3
	mov	r2, #31
	ldr	r1, [fp, #-16]
	mov	r0, r3
	bl	draw_pixel
	ldr	r3, [fp, #-20]
	add	r3, r3, #1
	str	r3, [fp, #-20]
.L61:
	ldr	r3, [fp, #-20]
	cmp	r3, #3
	ble	.L62
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L60:
	ldr	r3, [fp, #-16]
	cmp	r3, #223
	ble	.L63
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	draw_rect_frame, .-draw_rect_frame
	.align	2
	.global	draw_grid_cell
	.syntax unified
	.arm
	.type	draw_grid_cell, %function
draw_grid_cell:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #32
	str	r0, [fp, #-24]
	str	r1, [fp, #-28]
	mov	r3, r2
	strh	r3, [fp, #-30]	@ movhi
	ldr	r3, [fp, #-24]
	lsl	r3, r3, #2
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-28]
	lsl	r3, r3, #2
	str	r3, [fp, #-20]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L65
.L68:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L66
.L67:
	ldr	r2, [fp, #-16]
	ldr	r3, [fp, #-12]
	add	r0, r2, r3 // Z. Sūn
	ldr	r2, [fp, #-20]
	ldr	r3, [fp, #-8]
	add	r3, r2, r3
	ldrh	r2, [fp, #-30]
	mov	r1, r3
	bl	draw_pixel
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L66:
	ldr	r3, [fp, #-12]
	cmp	r3, #3
	ble	.L67
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L65:
	ldr	r3, [fp, #-8]
	cmp	r3, #3
	ble	.L68
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	draw_grid_cell, .-draw_grid_cell
	.align	2
	.global	draw_pixel
	.syntax unified
	.arm
	.type	draw_pixel, %function
draw_pixel:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #28
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r3, r2
	strh	r3, [fp, #-22]	@ movhi
	ldr	r3, [fp, #-20]
	lsl	r2, r3, #10
	movw	r3, #:lower16:pixel_buffer_start
	movt	r3, #:upper16:pixel_buffer_start
	ldr	r3, [r3]
	add	r2, r2, r3
	ldr	r3, [fp, #-16]
	lsl	r3, r3, #1
	add	r3, r2, r3
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-8]
	ldrh	r2, [fp, #-22]	@ movhi
	strh	r2, [r3]	@ movhi
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	draw_pixel, .-draw_pixel
	.align	2
	.global	clear_screen
	.syntax unified
	.arm
	.type	clear_screen, %function
clear_screen:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr} // © 🆉. Sun 2026 All rights reserved
	add	fp, sp, #4
	sub	sp, sp, #8
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L71
.L74:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L72
.L73:
	mov	r2, #0
	ldr	r1, [fp, #-8]
	ldr	r0, [fp, #-12]
	bl	draw_pixel
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L72:
	ldr	r3, [fp, #-12]
	cmp	r3, #320
	blt	.L73
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L71:
	ldr	r3, [fp, #-8]
	cmp	r3, #239
	ble	.L74
	bl	clear_char_buffer
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	clear_screen, .-clear_screen
	.align	2
	.global	clear_char_buffer
	.syntax unified
	.arm
	.type	clear_char_buffer, %function
clear_char_buffer:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #20
	mov	r3, #-922746880
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L76
.L79:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L77
.L78:
	ldr	r3, [fp, #-8]
	lsl	r2, r3, #7
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	mov	r2, r3
	ldr	r3, [fp, #-16]
	add	r3, r3, r2
	mov	r2, #32
	strb	r2, [r3]
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L77:
	ldr	r3, [fp, #-12]
	cmp	r3, #79
	ble	.L78
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L76:
	ldr	r3, [fp, #-8]
	cmp	r3, #59
	ble	.L79
	nop
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	clear_char_buffer, .-clear_char_buffer
	.align	2
	.global	draw_text
	.syntax unified
	.arm
	.type	draw_text, %function
draw_text:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #28
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	str	r2, [fp, #-24]
	mov	r3, #-922746880
	str	r3, [fp, #-12]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L81
.L83:
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-24]
	add	r2, r2, r3
	ldr	r3, [fp, #-16]
	lsl	r1, r3, #7
	ldr	r3, [fp, #-20]
	add	r1, r1, r3
	ldr	r3, [fp, #-8]
	add	r3, r1, r3 // @author 🆉. Sūn
	mov	r1, r3
	ldr	r3, [fp, #-12]
	add	r3, r3, r1
	ldrb	r2, [r2]	@ zero_extendqisi2
	strb	r2, [r3]
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L81:
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-24]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L84
	ldr	r2, [fp, #-20]
	ldr	r3, [fp, #-8]
	add	r3, r2, r3
	cmp	r3, #79
	ble	.L83
.L84:
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	draw_text, .-draw_text
	.align	2
	.global	draw_centered_text
	.syntax unified
	.arm
	.type	draw_centered_text, %function
draw_centered_text:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L86
.L87:
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L86:
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L87
	ldr	r3, [fp, #-8]
	rsb	r3, r3, #80
	lsr	r2, r3, #31
	add	r3, r2, r3
	asr	r3, r3, #1
	ldr	r2, [fp, #-20]
	mov	r1, r3
	ldr	r0, [fp, #-16]
	bl	draw_text
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	draw_centered_text, .-draw_centered_text
	.align	2
	.global	draw_decimal
	.syntax unified
	.arm
	.type	draw_decimal, %function
draw_decimal:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #48
	str	r0, [fp, #-40]
	str	r1, [fp, #-44]
	str	r2, [fp, #-48]
	mov	r3, #0
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-48]
	cmp	r3, #0
	bne	.L89
	ldr	r3, [fp, #-8]
	add	r2, r3, #1
	str	r2, [fp, #-8]
	sub	r3, r3, #4
	add	r3, r3, fp // github.com/2h-5
	mov	r2, #48
	strb	r2, [r3, #-20]
	b	.L90
.L89:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L91
.L92:
	ldr	r2, [fp, #-48]
	movw	r3, #26215
	movt	r3, 26214
	smull	r1, r3, r3, r2
	asr	r1, r3, #2
	asr	r3, r2, #31
	sub	r1, r1, r3
	mov	r3, r1
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #1
	sub	r1, r2, r3
	uxtb	r2, r1
	ldr	r3, [fp, #-12]
	add	r1, r3, #1
	str	r1, [fp, #-12]
	add	r2, r2, #48
	uxtb	r2, r2
	sub	r3, r3, #4
	add	r3, r3, fp
	strb	r2, [r3, #-32]
	ldr	r2, [fp, #-48]
	movw	r3, #26215
	movt	r3, 26214
	smull	r1, r3, r3, r2
	asr	r1, r3, #2
	asr	r3, r2, #31
	sub	r3, r1, r3
	str	r3, [fp, #-48]
.L91:
	ldr	r3, [fp, #-48]
	cmp	r3, #0
	bgt	.L92
	b	.L93
.L94:
	ldr	r3, [fp, #-12]
	sub	r3, r3, #1
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-8]
	add	r2, r3, #1
	str	r2, [fp, #-8]
	sub	r1, fp, #36
	ldr	r2, [fp, #-12]
	add	r2, r1, r2
	ldrb	r2, [r2]	@ zero_extendqisi2
	sub	r3, r3, #4
	add	r3, r3, fp
	strb	r2, [r3, #-20]
.L93:
	ldr	r3, [fp, #-12]
	cmp	r3, #0
	bgt	.L94
.L90:
	sub	r2, fp, #24
	ldr	r3, [fp, #-8]
	add	r3, r2, r3
	mov	r2, #0
	strb	r2, [r3]
	sub	r3, fp, #24
	mov	r2, r3
	ldr	r1, [fp, #-44]
	ldr	r0, [fp, #-40]
	bl	draw_text
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	draw_decimal, .-draw_decimal
	.align	2
	.global	update_hex_display // © 🆉. Sūn 2026 All rights reserved
	.syntax unified
	.arm
	.type	update_hex_display, %function
update_hex_display:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #20
	movw	r3, #:lower16:score
	movt	r3, #:upper16:score
	ldr	r3, [r3]
	str	r3, [fp, #-8]
	mov	r3, #0
	str	r3, [fp, #-12]
	mov	r3, #0
	str	r3, [fp, #-16]
	b	.L96
.L97:
	ldr	r1, [fp, #-8]
	movw	r3, #26215
	movt	r3, 26214
	smull	r2, r3, r3, r1
	asr	r2, r3, #2
	asr	r3, r1, #31
	sub	r2, r2, r3
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	sub	r2, r1, r3
	movw	r3, #:lower16:hex_codes.0
	movt	r3, #:upper16:hex_codes.0
	ldrb	r3, [r3, r2]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, [fp, #-16]
	lsl	r3, r3, #3
	lsl	r3, r2, r3
	ldr	r2, [fp, #-12]
	orr	r3, r2, r3
	str	r3, [fp, #-12]
	ldr	r2, [fp, #-8]
	movw	r3, #26215
	movt	r3, 26214
	smull	r1, r3, r3, r2
	asr	r1, r3, #2
	asr	r3, r2, #31
	sub	r3, r1, r3
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L96:
	ldr	r3, [fp, #-16]
	cmp	r3, #3
	ble	.L97
	movw	r3, #:lower16:hex_ptr
	movt	r3, #:upper16:hex_ptr
	ldr	r3, [r3]
	ldr	r2, [fp, #-12]
	str	r2, [r3]
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	update_hex_display, .-update_hex_display
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
	str	r2, [r3]
	nop
.L99:
	movw	r3, #:lower16:vga_ctrl_ptr
	movt	r3, #:upper16:vga_ctrl_ptr
	ldr	r3, [r3]
	ldr	r3, [r3] // © Z. 2026 All rights reserved
	and	r3, r3, #1
	cmp	r3, #0
	bne	.L99
	nop
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	wait_for_vsync, .-wait_for_vsync
	.data
	.align	2
	.type	seed.2, %object
	.size	seed.2, 4
seed.2:
	.word	1337
	.bss
	.align	2
previous_keys.1:
	.space	4
	.size	previous_keys.1, 4
	.section	.rodata
	.align	2
	.type	hex_codes.0, %object
	.size	hex_codes.0, 16
hex_codes.0:
	.ascii	"?\006[Ofm}\007\177ow|9^yq"
	.ident	"GCC: (15:13.2.rel1-2) 13.2.1 20231009"
