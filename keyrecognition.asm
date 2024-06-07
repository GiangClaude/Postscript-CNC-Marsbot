.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv HEADING 0xffff8010 # Integer: An angle between 0 and 359
				# 0 : North (up)
				# 90: East (right)
				# 180: South (down)
				# 270: West (left)
.eqv MOVING 0xffff8050 # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0):
# whether or not to leave a track

.data
String0wrong: .asciiz "Postscript so 0 sai do  "
String4wrong: .asciiz "Postscript so 4 sai do "
String8wrong: .asciiz "Postscript so 8 sai do "
Reasonwrong1:	.asciiz "loi cu phap  "
Reasonwrong2:	.asciiz "thieu bo so "
ChooseAnotherScript: .asciiz "Vui long chon postscipt khac"
NotCheck: .asciiz "Chua check xong doi mot lat"
		
.text
main:	li $t1, IN_ADDRESS_HEXA_KEYBOARD
	li $t2, OUT_ADDRESS_HEXA_KEYBOARD
	li $t3, 0x80 # bit 7 of = 1 to enable interrupt
	sb $t3, 0($t1)

Loop: 	nop
	addi $v0, $zero, 32
	li $a0, 200
	syscall
	nop
	nop
	b Loop # Wait for interrupt

exit: 	li $v0, 10
	syscall
end_main:

.ktext 0x80000180
beq $t6, 1, IntSR
li $v0, 55
la $a0, NotCheck
li $a1, 1 
syscall
j return

IntSR: 	li $t3, 0x01 # check row 1 with key 0, 4, 8, c
sb $t3, 0($t1) # must reassign expected row
lb $a0, 0($t2) # read scan code of key button
beq $a0, 0x11, script0 #if user choose 0 then run script 0
#bnez $a0, print
li $t3, 0x02 # check row 2 with key 4, 5, 6, 7
sb $t3, 0($t1) # must reassign expected row
lb $a0, 0($t2) # read scan code of key button
beq $a0, 0x21, script4 #if user choose 4 then run script 4
#bnez $a0, print
li $t3, 0x04 # check row 3 with key 8, 9, A, B
sb $t3, 0($t1) # must reassign expected row
lb $a0, 0($t2) # read scan code of key button
beq $a0, 0x41, script8 #if user choose 8 then run script 8
#bnez $a0, print
li $t3, 0x08 # check row 4 with key C, D, E, F
sb $t3, 0($t1) # must reassign expected row
lb $a0, 0($t2) # read scan code of key button
beq $a0, 0x81, exit #if user choose c then end program

#s0 = base address of script if exit
#s1 = value of script
script0: add $s0, $zero, $t7 #base address = t7
#if s0 = 1 or 2
#then scipt is wrong --> choose another script
la $a0, String0wrong
beq $s0, 1, WrongScript
beq $s0, 2, WrongScript
lw $s1, 0($t7)
beq $s1, 0, StringSolve #Nếu chuỗi chưa chuyển thành số thì nhảy đến hàm chuyển
#Nếu không thì chạy SCRIPT
j runSCRIPT

script4: add $s0, $zero, $t8 #base address = t8
#if s0 = 1 or 2
#then scipt is wrong --> choose another script
la $a0, String4wrong
beq $s0, 1, WrongScript
beq $s0, 2, WrongScript

lw $s1, 0($t8)
beq $s1, 0, StringSolve #Nếu chuỗi chưa chuyển thành số thì nhảy đến hàm chuyển
#Nếu không thì chạy SCRIPT
j runSCRIPT

script8: add $s0, $zero, $t9 #base address = t9
#if s0 = 1 or 2
#then scipt is wrong --> choose another script
la $a0, String8wrong
beq $s0, 1, ‎WrongScript
beq $s0, 2, ‎WrongScript
lw $s1, 0($t9)
beq $s1, 0, StringSolve #Nếu chuỗi chưa chuyển thành số thì nhảy đến hàm chuyển
#Nếu không thì chạy SCRIPT

runSCRIPT: 
add $s2, $zero, $zero #s2 = index = i = 0
add $s3, $zero, $zero #Gán s3 = address of a[i] = 0

addi $a0, $zero, 135 # Marsbot rotates 135* and start running
jal ROTATE
jal GO
sleep: addi $v0, $zero, 32 # Keep running by sleeping in 2000 ms
li $a0, 2000
syscall

DRAW: jal getVALUE #Get angle 
beq $s1, -1, endDRAW #Nếu s1 = -1 thì kết thúc vẽ 
add $a0, $zero, $s1 # Marsbot rotates
jal ROTATE

jal getVALUE #TRACK or NOT TRACK
beq $s1, $zero, KeepRunning #Nếu s1 = 0 thì không bật TRACK
jal TRACK

KeepRunning: jal getVALUE #Get time
addi $v0, $zero, 32 # Keep running by sleeping in (s1)ms
add $a0, $zero, $s1 
syscall

jal UNTRACK # keep old track if track
#Nếu không bật track thì tắt track cũng không sao
j DRAW
endDRAW: jal STOP
j re_enable

WrongScript: add $a1, $s0, $zero #a1 = scipt wrong
jal WrongMessage
li $v0, 55
la $a0, ChooseAnotherScript
li $a1, 1
syscall

re_enable: li $t3, 0x80 # bit 7 of = 1 to enable interrupt
sb $t3, 0($t1)

next_pc: 	mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
addi $at, $at, 4 # $at = $at + 4 (next instruction)
mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
return: 	eret # Return from exception

WrongMessage:	li $v0, 59
		beq $a1, 2, Reason2
		beq $a1, 3, Reason3
		la $a1, Reasonwrong1 #sai do ly do 1
		j call
Reason2:	la $a1, Reasonwrong2 #sai do ly do 2
		j call
Reason3:	li $v0, 55
		li $a1, 0
call:		syscall
		jr $ra

getVALUE: addi $s2, $s2, 1 #i++
sll $s4, $s2, 2 #Gán s4 = 4i
add $s3, $s4, $s0 #s3 = 4i + base address = address of a[i]
lw $s1, 0($s3) #s1 = a[i]
jr $ra

GO: li $at, MOVING # change MOVING port
addi $k0, $zero,1 # to logic 1,
sb $k0, 0($at) # to start running
jr $ra

STOP: li $at, MOVING # change MOVING port to 0
sb $zero, 0($at) # to stop
jr $ra

TRACK: li $at, LEAVETRACK # change LEAVETRACK port
addi $k0, $zero,1 # to logic 1,
sb $k0, 0($at) # to start tracking
jr $ra

UNTRACK:li $at, LEAVETRACK # change LEAVETRACK port to 0
sb $zero, 0($at) # to stop drawing tail
jr $ra

ROTATE: li $at, HEADING # change HEADING port
sw $a0, 0($at) # to rotate robot
jr $ra
