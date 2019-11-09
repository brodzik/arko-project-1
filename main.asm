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
DATA:		.space 1280000
K_INV:		.word 652032874
SCALE:		.word 1073741824
ITER:		.byte 32
ANGLES:		.word 843314856, 497837829, 263043836, 133525158, 67021686, 33543515, 16775850, 8388437, 4194282, 2097149, 1048575, 524287, 262143, 131071, 65535, 32767, 16383, 8191, 4095, 2047, 1023, 511, 255, 127, 63, 31, 15, 8, 4, 2, 1, 0
RAD_PER_PIXEL:	.word 8433148
	.text
	.globl main
main:
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
	
	li	$s0, 0
	li	$s1, 800
	li	$s2, 0			# current angle
	lw	$s3, RAD_PER_PIXEL
	li	$s4, 1			# is ascending?
loop:
	beq	$s0, $s1, end
	
	li	$t0, -1686629713		# - scale * pi / 2
	blt	$s2, $t0, start_ascending
	li	$t0, 1686629713			#  scale * pi / 2
	bgt	$s2, $t0, start_descending
	j	continue
start_ascending:
	li	$s4, 1
	li	$s2, -1686629713
	j	continue
start_descending:
	li	$s4, 0
	li	$s2, 1686629713
continue:
	move	$a0, $s2
	jal	cordic
	
	div	$a2, $a0, 5368709	# cordic / (scale / 200)
	addi	$a2, $a2, 200

	li	$a0, 0x00000000	
	move	$a1, $s0
	jal	set_pixel
	
	addi	$s0, $s0, 1
	
	bgtz	$s4, ascending
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
