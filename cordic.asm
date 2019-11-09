	.data
K_INV:	.word 652032874
SCALE:	.word 1073741824
ITER:	.byte 32
ANGLES:	.word 843314856, 497837829, 263043836, 133525158, 67021686, 33543515, 16775850, 8388437, 4194282, 2097149, 1048575, 524287, 262143, 131071, 65535, 32767, 16383, 8191, 4095, 2047, 1023, 511, 255, 127, 63, 31, 15, 8, 4, 2, 1, 0
THETA:	.word 1686629713
	.text
	.globl main
main:
	li	$t0, 0			# $t0 = i
	lb	$t1, ITER		# $t1 = 32
	la	$t2, ANGLES		# $t2 = arctan(2^-i)
	
	lw	$t3, K_INV		# $t3 = x
	li	$t4, 0			# $t4 = y
	lw	$t5, THETA		# $t5 = z
loop:
	beq	$t0, $t1, end
	
	srav	$s1, $t4, $t0		# $s1 = y >> i
	srav	$s2, $t3, $t0		# $s2 = x >> i
	lw	$s3, ($t2)		# $s3 = arctan(2^-i)
	
	bltz	$t5, sign_neg
	sub	$t3, $t3, $s1		# x = x - (y >> i)
	add	$t4, $t4, $s2		# y = y + (x >> i)
	sub	$t5, $t5, $s3		# z = z - arctan(2^-i)
	j	sign_end
sign_neg:
	add	$t3, $t3, $s1		# x = x + (y >> i)
	sub	$t4, $t4, $s2		# y = y - (x >> i)
	add	$t5, $t5, $s3		# z = z + arctan(2^-i)
sign_end:
	addi	$t0, $t0, 1
	addi	$t2, $t2, 4
	j	loop
end:
	li	$v0, 1
	move	$a0, $t4
	syscall
	
	li	$v0, 10			# exit
	syscall
