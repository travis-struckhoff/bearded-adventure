.data
BOT_VEL_ADDR		=	0xffff0010
ANGLE_CONTROL_ADDR	=	0xffff0018
ANGLE_ADDR		=	0xffff0014

BOT_X_LOC		=	0xffff0020
BOT_Y_LOC		=	0xffff0024

SCAN_REQUEST		=	0xffff1010
SCAN_REQUEST_ACK	=	0xffff1204
SCAN_REQUEST_INT_MASK	=	0x2000
SCAN_SECTOR		=	0xffff101c

PLANETS_REQUEST		=	0xffff1014

GET_SET_FIELD		=	0xffff1100
GET_ENERGY		=	0xffff1104


PRINT_INT		=	0xffff0080
PRINT_STRING		=	4

TIMER			=	1000

.align	2
scan_result:	.space	256
planet_result:	.space	32
cur_sector:	.word	0
can_request:	.word	1

.text
main:
find_most_dense:
	li	$t0,	1
	or	$t0,	$t0,	SCAN_REQUEST_INT_MASK
	mtc0	$t0,	$12

	li	$s1,	0
	li	$s2,	0
	li	$s3,	0
scan_sectors:
	bge	$s1,	64,	goto_sector
	sw	$s1,	SCAN_SECTOR
	la	$t0,	scan_result
	sw	$t0,	SCAN_REQUEST
busy_wait:
	lw	$s4,	can_request
	beq	$zero,	$s4,	busy_wait
	sw	$zero,	can_request
	mul	$t1,	$s1,	4
	add	$t1,	$t1,	$t0
	lw	$t0,	0($t1)
	ble	$t0,	$s3,	not_better
	add	$s2,	$s1,	$0
	add	$s3,	$t0,	$0
not_better:
	add	$s1,	$s1,	1
	j	scan_sectors
goto_sector:
	sw	$s2,	PRINT_INT
	div	$t0,	$s2	8
	mul	$t0,	$t0,	8
	sub	$t0,	$s2,	$t0
	mul	$t0,	$t0,	38
	lw	$t1,	BOT_X_LOC
	ble	$t0,	$t1,	not_right
	li	$t2,	0
	j	set_angle_x
not_right:
	li	$t2,	180
set_angle_x:
	sw	$t2,	ANGLE_ADDR
	li	$t3,	1
	sw	$t3,	ANGLE_CONTROL_ADDR
	li	$t4,	10
	sw	$t4,	BOT_VEL_ADDR
while_x:
	beq	$t0,	$t1,	done_while_x
	lw	$t1,	BOT_X_LOC
	j	while_x
done_while_x:	
	div	$t0,	$s2,	8
	mul	$t0,	$t0,	38
	lw	$t1,	BOT_Y_LOC
	ble	$t0,	$t1,	not_down
	li	$t2,	90
	j	set_angle_y
not_down:
	li	$t2,	270
set_angle_y:
	sw	$t2,	ANGLE_ADDR
	sw	$t3,	ANGLE_CONTROL_ADDR
	sw	$t4,	BOT_VEL_ADDR
while_y:
	beq	$t1,	$t0,	done_while_y
	lw	$t1,	BOT_Y_LOC
	j	while_y
done_while_y:
	sw	$zero,	BOT_VEL_ADDR
force_field:
	li	$t7,	5
	li	$t8,	3
	sw	$t7,	GET_SET_FIELD
go_home:
	la	$t5,	planet_result
	sw	$t5,	PLANETS_REQUEST
	lw	$t0,	8($t5)
	add	$t0,	$t0,	163
	lw	$t1,	BOT_X_LOC
	ble	$t0,	$t1,	not_right2
	li	$t2,	0
	j	set_angle_x2
not_right2:
	li	$t2,	180
set_angle_x2:
	sw	$t2,	ANGLE_ADDR
	sw	$t3,	ANGLE_CONTROL_ADDR
	sw	$t3,	BOT_VEL_ADDR
while_x2:
	beq	$t0,	$t1,	done_while_x2
	lw	$t1,	BOT_X_LOC
	j	while_x2
done_while_x2:
	li	$t0,	150
	lw	$t1,	BOT_Y_LOC
	ble	$t0,	$t1,	not_down2
	li	$t2,	90
	j	set_angle_y2
not_down2:
	li	$t2,	270
set_angle_y2:
	sw	$t2,	ANGLE_ADDR
	sw	$t3,	ANGLE_CONTROL_ADDR
	sw	$t3,	BOT_VEL_ADDR
while_y2:
	beq	$t1,	$t0,	done_while_y2
	lw		$t1,	BOT_Y_LOC
	j		while_y2
done_while_y2:
	sw	$zero,	BOT_VEL_ADDR
	sw	$t5,	PLANETS_REQUEST
	lw	$t0,	4($t5)
	li	$t9,	120
while_planet_y:
	beq	$t0,	$t9,	done_while_planet_y
	sw	$t5,	PLANETS_REQUEST
	lw	$t0,		4($t5)
	j	while_planet_y
done_while_planet_y:
	sw	$zero,	GET_SET_FIELD

final:	
	j	final


.kdata
chunkIH:	.space	16
non_intrpt_str:	.asciiz	"Non-interrupt	exception\n"
unhandled_str:	.asciiz	"Unhandled	interrupt	type\n"

.ktext	0x80000180
interrupt_handler:
.set	noat
	add	$k1,	$at,	$0
.set	at

	la	$k0,	chunkIH
	sw	$a0,	0($k0)
	sw	$v0,	4($k0)
	sw	$t0,	8($k0)	
	sw	$t1,	12($k0)	

	mfc0	$k0,	$13
	srl	$k0,	$k0,	2
	and	$k0,	$k0,	0xf
	bne	$k0,	0,	non_intrpt

interrupt_dispatch:
	mfc0	$k0,	$13
	beq	$k0,	$0,	done

	and	$a0,	$k0,	SCAN_REQUEST_INT_MASK
	bne	$a0,	$0,	scan_req_interrupt

	li	$v0,	PRINT_STRING
	la	$a0,	unhandled_str
	syscall
	j	done

scan_req_interrupt:
	sw	$0,	SCAN_REQUEST_ACK

	li	$a0,	1
	sw	$a0,	can_request
	j	interrupt_dispatch



non_intrpt:
	li	$v0,	PRINT_STRING
	la	$a0,	non_intrpt_str
	syscall

done:
	la	$k0,	chunkIH
	lw	$a0,	0($k0)
	lw	$v0,	4($k0)
	lw	$t0,	8($k0)
	lw	$t1,	12($k0)

.set	noat
	add	$at,	$k1,	$0
.set	at
	eret