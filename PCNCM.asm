.eqv  HEADING    0xffff8010    # Integer: An angle between 0 and 359 
                               # 0 : North (up) 
                               # 90: East (right) 
                               # 180: South (down) 
                               # 270: West  (left) 
.eqv  MOVING     0xffff8050    # Boolean: whether or not to move 
.eqv  LEAVETRACK 0xffff8020    # Boolean (0 or non-0): 
                               #    whether or not to leave a track 
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv  MASK_CAUSE_KEYMATRIX 0x00000800     # Bit 11: Key matrix interrupt 
.data
	script0: .asciiz "0,0,8820,90,0,2000,180,1,8820,90,1,2666,0,0,4410,270,1,2666,0,0,4410,90,1,2666"
	script4: .asciiz "71,1,,1700,37,1,1700,17,1,1700,0,1,1700,341,1,1700,320,1,1700,295,1,1700,180,1,8820,90,0,7000,270,1,2300,345,1,4520,15,1,4000,75,1,2500,90,0,2000,180,1,8820,90,1,2666,0,0,4410,270,1,2666,0,0,4410,90,1,2666"
	script8: .asciiz "180,0,7000,90,0,5000,270,1,2300,345,1,4520,15,1,4000,75,1,2500"
	String0wrong: .asciiz "Postscript so 0 sai do  "
	String4wrong: .asciiz "Postscript so 4 sai do "
	String8wrong: .asciiz "Postscript so 8 sai do "
	StringAllwrong: .asciiz "Tat ca Postscript deu sai "
	Reasonwrong1:	.asciiz "loi cu phap"
	Reasonwrong2:	.asciiz "thieu bo so"
	EndofProgram: .asciiz "Chuong trinh ket thuc!"
	ChooseAnotherScript: .asciiz "Vui long chon postscipt khac"
	NotCheck: .asciiz "Chua check xong doi mot lat"
	Array: .word
	
.text
main:		li $t1, IN_ADDRESS_HEXA_KEYBOARD
		li $t2, OUT_ADDRESS_HEXA_KEYBOARD
		li $t3, 0x80 # bit 7 of = 1 to enable interrupt
		sb $t3, 0($t1)
		la $k0, Array
		jal StringCheck
		
Loop: 	nop
	addi $v0, $zero, 32
	li $a0, 200
	syscall
	nop
	nop
	b Loop # Wait for interrupt
			
end_of_main:	li $v0, 55
		la $a0, EndofProgram
		li $a1, 1
		syscall
		li $v0, 10
		syscall
		
#------------------------------
#StringCheck: Kiem tra du lieu dau vao
#a0: dia chi cac chuoi
#t7, t8, t9: giu gia tri 1 neu chuoi 0, 4, 8 sai
#a1: bit gia tri dung sai
#s0: dem so chuoi sai
#k0: dia chi mang
#------------------------------
StringCheck:	li $s0, 0
SC_InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $ra,0($sp)  
mainSC:		la $a0, script0
        	jal Check
        	addi $t7, $a0, 0 #t7 = gia tri dung/sai cua chuoi 0
        	la $a0, String0wrong #Gan a0 = message khi chuoi 0 sai
        	jal WrongMessage1
        	nop
Check_script4: 	la $a0, script4
        	jal Check
        	addi $t8, $a0, 0 #t8 = gia tri dung/sai cua chuoi 4
        	la $a0, String4wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage1
       		nop
Check_script8:	la $a0, script8
        	jal Check
        	addi $t9, $a0, 0 #t9 = gia tri dung/sai cua chuoi 8
        	la $a0, String8wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage1
       		nop
       		blt $s0, 3, SC_ResSR
       		li $a1, 3
       		la $a0, StringAllwrong
       		jal WrongMessage1
       		j end_of_main
SC_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_StringCheck: 	addi $t6, $t6, 1 #luu t6 = 1 => da hoan thanh check
			jr $ra    
#------------------
WrongMessage1:	li $v0, 59
		beq $a1, 0, end_of_WN
		beq $a1, 2, Reason2
		beq $a1, 3, Reason3
		la $a1, Reasonwrong1 #sai do ly do 1
		j call
Reason2:	la $a1,Reasonwrong2 #sai do ly do 2
		j call
Reason3:	li $v0, 55
		li $a1, 0
call:		addi $s0, $s0, 1
		syscall
end_of_WN:	jr $ra    
#---------------
#Check: Kiem tra 1 chuoi co vi pham hay khong
#a0: dia chi ban dau cua script
#a1: Gia tri dung sai
#a2: byte duoc load
#a3: dem so dau phay
#v0: byte truoc byte hien tai
#Loi sai : Co chu hoac ky hieu ( 1), Khong du bo so(2)
#---------------
Check:		li $a3, 0 #gan a3 = 0
loop_Check:	lb $a2, 0($a0)
		beq $a2, 0x2C, is_comma
		beq $a2, 0x00, end_string
		beq $a2, 0x20, next_loop #neu a2 = dau cach thi bo qua
		blt $a2, 0x30, wrong1
		bgt $a2, 0x39, wrong1
		j next_loop
is_comma:	beq $v0, 0x2C, wrong1
		addi $a3, $a3, 1 #so dau phay cong 1
next_loop:	addi $a0, $a0, 1 #Tang a0 + 1 => chi den byte tiep theo
		addi $v0, $a2, 0 #v0 giu byte truoc 
		j loop_Check
wrong1:		li $a1, 1 #gan a1 = 1, day sai do xuat hien chu hoac ky hieu
		li $a0, 1
		jr $ra #Quay ve ctr con goc
wrong2: 	li $a1, 2 #a1= 2, day sai do thieu bo so
		li $a0, 2
		jr $ra
end_string:	beq $v0, 0x2C, wrong1 #Neu ky tu cuoi cung cua chuoi la , => sai
		addi $a3, $a3, -2
		li $a2, 3 #gan a2 = 3
		div $a3, $a2 #a3/3 
		mfhi $a2 #a2 = a3 mod 3 = so dau phay mod 3
		bnez $a2, wrong2 #neu a2 != 0 => so dau phay khong chia 3 du 2 => khong du bo so
		addi $a0, $k0, 0 #a1 = k0 => Chuoi dung va a0 chua dia chi mang cua chuoi dang xet
		addi $a3, $a3, 5 #a3= a3 + 3 = so cac so + 2 (de pt cuoi cung cua mang mang gia tri -1)
		sll $a3, $a3, 2 #a3= a3*4
		add $k0, $k0, $a3 #k0 chi den dia chi moi de nhan vao chuoi tiep theo neu chuoi dung
		li $a2, -1
		sw $a2, -4($k0)
		li $a1, 0
		jr $ra 
#-------------------------
.ktext 0x80000180


Check_Cause:	mfc0  $t4, $13
		li    $t3, MASK_CAUSE_KEYMATRIX # if Cause value confirm Key.. 
        	and   $at, $t4,$t3 
        	bne   $at,$t3, return #Neu khong phai ngat do bam ban phim thi quay lai
        	beq $t6, 1, IntSR
		li $v0, 55
		la $a0, NotCheck
		li $a1, 1 
		syscall
		j return
IntSR: 			
	li $t3, 0x81 # check row 1 with key 0, 4, 8, c
	sb $t3, 0($t1) # must reassign expected row
	lb $a0, 0($t2) # read scan code of key button
	beq $a0, 0x11, Found_script0 #if user choose 0 then run script 0
	bne $a0, 0x00, PleaseAnother
	li $t3, 0x82 # check row 2 with key 4, 5, 6, 7
	sb $t3, 0($t1) # must reassign expected row
	lb $a0, 0($t2) # read scan code of key button
	beq $a0, 0x12, Found_script4 #if user choose 4 then run script 4
	bne $a0, 0x00, PleaseAnother
	li $t3, 0x84 # check row 3 with key 8, 9, A, B
	sb $t3, 0($t1) # must reassign expected row
	lb $a0, 0($t2) # read scan code of key button
	beq $a0, 0x14, Found_script8 #if user choose 8 then run script 8
	bne $a0, 0x00, PleaseAnother
	li $t3, 0x88 # check row 4 with key C, D, E, F
	sb $t3, 0($t1) # must reassign expected row
	lb $a0, 0($t2) # read scan code of key button
	beq $a0, 0x18, end_of_main #if user choose c then end program
	bne $a0, 0x00, PleaseAnother
#s0 = base address of script if exit
#s1 = value of script
Found_script0: add $a1, $zero, $t7 #base address = t7 #if s0 = 1 or 2 then scipt is wrong --> choose another script
		la $a0, String0wrong
		la $s3, script0
		j Found
Found_script4: add $a1, $zero, $t8 #base address = t8
#if s0 = 1 or 2 then scipt is wrong --> choose another script
		la $a0, String4wrong
		la $s3, script4
		j Found
Found_script8: add $a1, $zero, $t9 #base address = t9
#if s0 = 1 or 2 then scipt is wrong --> choose another script
		la $a0, String8wrong
		la $s3, script8
Found:	beq $a1, 1, WrongScript
	beq $a1, 2, WrongScript
	addi $a0, $s3, 0 #nap dia chi stringX vao $a0
	lw $s1, 0($a1)
	bne $s1, 0, StringRun #Nếu chuỗi chưa chuyển thành số thì nhảy đến hàm chuyển
	#Nếu không thì chạy SCRIPT
	addi $a2, $a1, 0 #a2 luu bien mang
	jal StringSolve	
StringRun:	addi $s0, $a2, 4 #dia chi mang bat dau xet bat dau tu pt t2
		jal MarsbotControl
		j re_enable
WrongScript: 	jal WrongMessage2
PleaseAnother:		li $v0, 55
			la $a0, ChooseAnotherScript
			li $a1, 1
			syscall

re_enable: 	#li $t3, 0x80 # bit 7 of = 1 to enable interrupt
		#sb $t3, 0($t1)

next_pc: 	mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
		addi $at, $at, 4 # $at = $at + 4 (next instruction)
		mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
return: 	eret # Return from exception

#------------------
WrongMessage2:	li $v0, 59
		beq $a1, 0, end_of_WN
		beq $a1, 2, Reason2_2
		beq $a1, 3, Reason3_2
		la $a1, Reasonwrong1 #sai do ly do 1
		j call_2
Reason2_2:	la $a1,Reasonwrong2 #sai do ly do 2
		j call_2
Reason3_2:	li $v0, 55
		li $a1, 0
call_2:		addi $s0, $s0, 1
		syscall
end_of_WN_2:	jr $ra
#-----------------
#StringSolve: Xu ly bien doi chuoi thanh so
#a0: dia chi chuoi
#a1: dia chi mang 
#s0: byte duoc load
#s1: dem so truoc ','
#s2: So da duoc xu ly
#s3: 10
#s4: Dem tu 1 - s1 khi chuyen so
#s5: 10^i
#------------------
StringSolve:	addi $sp, $sp, 4 #Luu sp sang o nho khac do co su dung sp
		li $s0, 1 #Gan gia tri s0 khac 0 de bat dau ctr 
		addi $s3, $zero, 1
		sw $s3, 0($a1)	#Luu bit 1 vao pt dau tien mang de xac dinh chuoi da duoc chuyen
		addi $a1, $a1, 4 #Luu gia tri tu pt thu 2
mainSS:		li $s3, 10
		li $s2, 0
		li $s1, 1
		li $s5, 1
SS_loop:	lb $s0, 0($a0) #s0 = byte duoc xet
		beq $s0, 0x20, SS_nextbyte
		beq $s0, 0x2C, Into_Array
		beq $s0, 0x00, Into_Array
		addi $sp, $sp, 1
		sb $s0, 0($sp) #luu byte vao stack
		addi $s1, $s1, 1 #dem so chu so cua so do
SS_nextbyte:	addi $a0, $a0, 1
		j SS_loop
Into_Array:	li $s4, 1
		addi $v0, $s0, 0
Into_loop:	beq $s4, $s1, SaveArray
		lb $s0, 0($sp)
		addi $sp, $sp, -1
		addi $s0, $s0, -48 #Doi gia tri $s0 sang so
		mult $s0, $s5
		mflo $s0 #s0 = s0*10^i
		add $s2, $s0, $s2 #s2 + s0
		#Next
		mult $s5, $s3
		mflo $s5 #s5 = 10^(i+1)
		addi $s4, $s4, 1
		j Into_loop
SaveArray:	sw $s2, 0($a1)
		add $a1, $a1, 4	
		addi $a0, $a0, 1
		beq $v0, 0x00, end_of_StringSolve
		j mainSS
#______________
end_of_StringSolve: 	addi $sp, $sp, -4
			jr $ra  
#----------------------------
#MarsbotControl	: Trinh dieu khien Marsbot
#k1: luu dia chi tro ve cho Move_non
#s0: dia chi mang ( luu truoc khi vao ctrinh con)
#s1: -1 => Dau hieu ket thuc mang
#a1: rotate - goc xoay
#a0: tg chay
#a2: bit track - untrack
#-------------------------
MarsbotControl: li $k0, 0
		li $s1, -1
MB_InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $ra,0($sp) 
FirstRun:	li $a1, 160
		li $a0, 8000
		jal ROTATE
		nop
		jal GO
		nop
		addi    $v0,$zero,32    # Keep running by sleeping in 2000 ms        
        	syscall 
TakeData:	lw $a1, 0($s0) #Load goc xoay
		addi $s0, $s0, 4
		beq $a1, $s1, MB_EndScript #Neu gia tri load duoc = -1 => ket thuc
		lw $a2, 0($s0) #load bit track/untrack
		addi $s0, $s0, 4
		lw $a0, 0($s0) # Load tg chay
		addi $s0, $s0, 4
MB_Run:		jal ROTATE
		nop
		beq $a2, 0, Leave 
		jal     TRACK           # and draw new track line 
        	nop  
Leave:		addi    $v0,$zero,32    # Keep running by sleeping in 2000 ms        
        	syscall 	#a0 la tham so tg quay
       		jal     UNTRACK         # keep old track 
        	nop 
MB_nextData:  	j TakeData  
MB_EndScript:	jal STOP
MB_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_MarsbotControl:	jr $ra		

#----------------------------------------------------------- 
# GO procedure, to start running 
# param[in]    none 
#----------------------------------------------------------- 
GO:     li    $at, MOVING     # change MOVING port 
        addi  $k0, $zero,1    # to  logic 1, 
        sb    $k0, 0($at)     # to start running 
        nop         
        jr    $ra 
        nop 
#----------------------------------------------------------- 
# STOP procedure, to stop running 
# param[in]    none 
#----------------------------------------------------------- 
STOP:   li    $at, MOVING     # change MOVING port to 0 
        sb    $zero, 0($at)   # to stop 
        nop 
        jr    $ra 
        nop 
#----------------------------------------------------------- 
# TRACK procedure, to start drawing line  
# param[in]    none 
#-----------------------------------------------------------              
TRACK:  li    $at, LEAVETRACK # change LEAVETRACK port 
        addi  $k0, $zero,1    # to  logic 1, 
        sb    $k0, 0($at)     # to start tracking 
        nop 
        jr    $ra 
        nop         
#----------------------------------------------------------- 
# UNTRACK procedure, to stop drawing line 
# param[in]    none 
#-----------------------------------------------------------         
UNTRACK:li    $at, LEAVETRACK # change LEAVETRACK port to 0 
        sb    $zero, 0($at)   # to stop drawing tail 
        nop 
        jr    $ra 
        nop 
#----------------------------------------------------------- 
# ROTATE procedure, to rotate the robot 
# param[in]    $a1, An angle between 0 and 359 
#                   0 : North (up) 
#                   90: East  (right) 
#                  180: South (down) 
#                  270: West  (left) 
#-----------------------------------------------------------  
ROTATE: li    $at, HEADING    # change HEADING port 
        sw    $a1, 0($at)     # to rotate robot 
        nop 
        jr    $ra 
        nop 
