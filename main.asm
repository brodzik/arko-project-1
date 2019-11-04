	.data
NEW_LINE: .asciiz "\n"
INV_K:	.word 0x26DD3B6A
SCALE:	.word 1073741824
N_TAB:	.byte 32
CTAB:	.word 0x3243F6A8, 0x1DAC6705, 0x0FADBAFC, 0x07F56EA6, 0x03FEAB76, 0x01FFD55B, 0x00FFFAAA, 0x007FFF55, 0x003FFFEA, 0x001FFFFD, 0x000FFFFF, 0x0007FFFF, 0x0003FFFF, 0x0001FFFF, 0x0000FFFF, 0x00007FFF, 0x00003FFF, 0x00001FFF, 0x00000FFF, 0x000007FF, 0x000003FF, 0x000001FF, 0x000000FF, 0x0000007F, 0x0000003F, 0x0000001F, 0x0000000F, 0x00000008, 0x00000004, 0x00000002, 0x00000001, 0x00000000
THETA:	.word 843314856
	.text
	.globl main
main:
	li	$t0, 0			# $t0 = i
	lb	$t1, N_TAB		# $t1 = N_TAB
	la	$t2, CTAB		# $t2 = CTAB + i
	
	lw	$t3, INV_K		# $t3 = x
	li	$t4, 0			# $t4 = y
	lw	$t5, THETA		# $t5 = z
loop:
	beq	$t0, $t1, end
	
	li	$s0, 0			# d = sign of z
	bgtz	$t5, pos
	li	$s0, -1
pos:
	
	srlv	$s1, $t4, $t0
	xor	$s1, $s1, $s0
	sub	$s1, $s1, $s0
	sub	$s1, $t3, $s1		# $s1 = tx
	
	srlv	$s2, $t3, $t0
	xor	$s2, $s2, $s0
	sub	$s2, $s2, $s0
	add	$s2, $s2, $t4		# $s2 = ty
	
	lw	$s3, ($t2)
	xor	$s3, $s3, $s0
	sub	$s3, $s3, $s0
	sub	$s3, $t5, $s3		# $s3 = tz
	
	move	$t3, $s1		# x = tx
	move	$t4, $s2		# y = ty
	move	$t5, $s3		# z = tz
	
	addi	$t0, $t0, 1
	addi	$t2, $t2, 4
	j	loop
end:
	li	$v0, 1
	move	$a0, $t4
	syscall
	
	li	$v0, 4
	la	$a0, NEW_LINE
	syscall
	
	li	$v0, 10			# exit
	syscall