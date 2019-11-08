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