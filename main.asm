	.data
FILE_NAME:	.asciiz "output.bmp"
FILE:		.word 0
HEADER:		.byte 'B', 'M'			# signature
		.byte 0x36, 0x88, 0x13, 0x00	# file size
		.byte 0x00, 0x00, 0x00, 0x00	# (reserved)
		.byte 0x36, 0x00, 0x00, 0x00	# data offset
		.byte 0x28, 0x00, 0x00, 0x00	# size
		.byte 0x20, 0x03, 0x00, 0x00	# width
		.byte 0x90, 0x01, 0x00, 0x00	# height
		.byte 0x01, 0x00		# planes
		.byte 0x20, 0x00		# bits per pixel
		.word 0				# compression
		.word 0				# compressed image size
		.word 0				# horizontal resolution
		.word 0				# vertical resolution
		.word 0				# colors used
		.word 0				# important colors
DATA:		.space 1280000			# pixel data

SCALE_X:	.word 200			# sine period
SCALE_Y:	.word 200			# sine amplitude

PHASE:		.word 0				# sine phase (radians scaled)
ASCENDING:	.word 1				# is ascending (boolean)

LIMIT_X:	.word 800			# maximum x-coord (pixels)
SHIFT_X:	.word 0				# starting x-coord (pixels)
SHIFT_Y:	.word 200			# starting y-coord (pixels)

SCALE:		.word 1073741824		# precision scale
K_INV:		.word 652032874			# scale * lim n->inf K(n)
PI_2:		.word 1686629713		# scale * pi / 2
PI_2_NEG:	.word -1686629713		# - scale * pi / 2
ITER:		.byte 32			# number of bits, number of angles

# scale * arctan(2^-i)
ANGLES:		.word 843314856, 497837829, 263043836, 133525158, 67021686, 33543515, 16775850, 8388437, 4194282, 2097149, 1048575, 524287, 262143, 131071, 65535, 32767, 16383, 8191, 4095, 2047, 1023, 511, 255, 127, 63, 31, 15, 8, 4, 2, 1, 0

SCALE_PER_X:	.word 0 # auto-set
SCALE_PER_Y:	.word 0 # auto-set
	.text
	.globl main
main:
	jal	setup_vars
	
	li	$v0, 13			# open file
	la	$a0, FILE_NAME
	li	$a1, 1
	li	$a2, 0
	syscall
	
	sw	$v0, FILE		# save file descriptor
	
	li	$v0, 15			# write header
	lw	$a0, FILE
	la	$a1, HEADER
	li	$a2, 54
	syscall
	
	li	$a0, 0x00FFFFFF
	jal	set_background
	
	li	$a0, 0x00000000
	jal	draw_x_axis
	
	lw	$s0, SHIFT_X		# $s0 = current x-cord
	lw	$s1, LIMIT_X
	lw	$s2, PHASE		# $s2 = theta
	lw	$s3, SCALE_PER_X
	lw	$s4, ASCENDING		# $s4 = is sine ascending (boolean)
loop:
	beq	$s0, $s1, end
	
	lw	$t0, PI_2_NEG		# check and switch ascending mode
	blt	$s2, $t0, start_ascending
	lw	$t0, PI_2
	bgt	$s2, $t0, start_descending
	j	continue
start_ascending:
	li	$s4, 1
	lw	$s2, PI_2_NEG
	add	$s2, $s2, $s3
	j	continue
start_descending:
	li	$s4, 0
	lw	$s2, PI_2
	sub	$s2, $s2, $s3
continue:
	move	$a0, $s2
	jal	cordic			# calculate sin(theta)
	
	lw	$t0, SCALE_PER_Y
	div	$a2, $a0, $t0
	lw	$t0, SHIFT_Y
	add	$a2, $a2, $t0		# scale and shift

	li	$a0, 0x00000000	
	move	$a1, $s0
	jal	set_pixel		# draw the result
	
	addi	$s0, $s0, 1		# increment x-coord
	
	bgtz	$s4, ascending		# increment or decrement theta
	sub	$s2, $s2, $s3
	j	loop
ascending:
	add	$s2, $s2, $s3
	j	loop
end:
	
	li	$v0, 15			# write data
	lw	$a0, FILE
	la	$a1, DATA
	li	$a2, 1280000
	syscall
	
	li	$v0, 16			# close file
	lw	$a0, FILE
	syscall
	
	li	$v0, 10			# exit
	syscall

##################################################################################################
# PROCEDURE: setup_vars
##################################################################################################
setup_vars:
	lw	$t0, PI_2
	lw	$t1, SCALE_X
	div	$t0, $t0, $t1
	sw	$t0, SCALE_PER_X
	
	lw	$t0, SCALE
	lw	$t1, SCALE_Y
	div	$t0, $t0, $t1
	sw	$t0, SCALE_PER_Y
	
	jr	$ra

##################################################################################################
# PROCEDURE: set_background
# INPUT: $a0 bitmap background color
##################################################################################################
set_background:
	li	$t0, 320000
	la	$t1, DATA
loop_0:
	beqz	$t0, end_0
	sw	$a0, ($t1)
	addi	$t0, $t0, -1
	addi	$t1, $t1, 4
	j	loop_0
end_0:
	jr	$ra

##################################################################################################
# PROCEDURE: set_pixel
# INPUT: $a0 color, $a1 x-coord, $a2 y-coord
##################################################################################################
set_pixel:
	la	$t0, DATA
	mul	$a2, $a2, 800
	add	$a2, $a2, $a1
	mul	$a2, $a2, 4
	add	$t0, $t0, $a2
	sw	$a0, ($t0)
	jr	$ra

##################################################################################################
# PROCEDURE: draw_x_axis
# INPUT: $a0 color
##################################################################################################
draw_x_axis:
	li	$t0, 1600
	la	$t1, DATA
	addi	$t1, $t1, 636800
loop_1:
	beqz	$t0, end_0
	sw	$a0, ($t1)
	addi	$t0, $t0, -1
	addi	$t1, $t1, 4
	j	loop_1
end_1:
	jr	$ra

##################################################################################################
# PROCEDURE: cordic
# INPUT: $a0 theta (scaled)
# RETURNS: $a0 sin (scaled)
##################################################################################################
cordic:
	li	$t0, 0			# $t0 = i
	lb	$t1, ITER		# $t1 = 32
	la	$t2, ANGLES		# $t2 = arctan(2^-i)
	
	lw	$t3, K_INV		# $t3 = x
	li	$t4, 0			# $t4 = y
	move	$t5, $a0		# $t5 = z
loop_2:
	beq	$t0, $t1, end_2
	
	srav	$t6, $t4, $t0		# $t6 = y >> i
	srav	$t7, $t3, $t0		# $t7 = x >> i
	lw	$t8, ($t2)		# $t8 = arctan(2^-i)
	
	bltz	$t5, sign_neg
	sub	$t3, $t3, $t6		# x = x - (y >> i)
	add	$t4, $t4, $t7		# y = y + (x >> i)
	sub	$t5, $t5, $t8		# z = z - arctan(2^-i)
	j	sign_end
sign_neg:
	add	$t3, $t3, $t6		# x = x + (y >> i)
	sub	$t4, $t4, $t7		# y = y - (x >> i)
	add	$t5, $t5, $t8		# z = z + arctan(2^-i)
sign_end:
	addi	$t0, $t0, 1
	addi	$t2, $t2, 4
	j	loop_2
end_2:
	move	$a0, $t4
	jr	$ra
