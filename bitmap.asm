	.data
fout:	.asciiz "output.bmp"
header:	.byte 'B', 'M'			# signature
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
data:	.space 1280000

	.text
	.globl main
	j main
set_background:
	li	$t0, 0
	li	$t1, 320000
	la	$t2, data
loop:
	beq	$t0, $t1, end
	
	li	$t3, 0x00FF0000
	sw	$t3, ($t2)
	
	addi	$t0, $t0, 1
	addi	$t2, $t2, 4
	j loop
end:
	jr $ra

main:
	li	$v0, 13			# open file
	la	$a0, fout
	li	$a1, 1
	li	$a2, 0
	syscall
	
	move	$s0, $v0		# $s0 = file descriptor
	
	li	$v0, 15			# write header
	move	$a0, $s0
	la	$a1, header
	li	$a2, 54
	syscall
	
	jal set_background
	
	li	$v0, 15			# write data
	move	$a0, $s0
	la	$a1, data
	li	$a2, 1280000
	syscall
	
	li	$v0, 16			# close file
	move	$a0, $s0
	syscall
	
	li	$v0, 10			# exit
	syscall