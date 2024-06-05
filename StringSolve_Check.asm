.eqv  HEADING    0xffff8010    # Integer: An angle between 0 and 359 
                               # 0 : North (up) 
                               # 90: East (right) 
                               # 180: South (down) 
                               # 270: West  (left) 
.eqv  MOVING     0xffff8050    # Boolean: whether or not to move 
.eqv  LEAVETRACK 0xffff8020    # Boolean (0 or non-0): 
                               #    whether or not to leave a track 
.data
	script0: .asciiz "0,0,8820,90,0,2000,180,1,8820,90,1,2666,0,0,4410,270,1,2666,0,0,4410,90,1,2666"
	script4: .asciiz "165,0,,10000,71,1,1700,37,1,1700,17,1,1700,0,1,1700,341,1,1700,320,1,1700,295,1,1700,180,1,8820,90,0,7000,270,1,2300,345,1,4520,15,1,4000,75,1,2500,90,0,2000,180,1,8820,90,1,2666,0,0,4410,270,1,2666,0,0,4410,90,1,2666"
	script8: .asciiz "90,0,8000,270,2300,345,1,4520,15,1,4000,75,1,2500"
	String0wrong: .asciiz "Postscript so 0 sai do "
	String4wrong: .asciiz "Postscript so 4 sai do "
	String8wrong: .asciiz "Postscript so 8 sai do "
	StringAllwrong: .asciiz "Tat ca Postscript deu sai"
	Reasonwrong1:	.asciiz "loi cu phap"
	Reasonwrong2:	.asciiz "thieu bo so   "
	EndofProgram: .asciiz "Chuong trinh ket thuc!"
	ChooseScript:	.asciiz "Nhap vao so nguyen: "
	Array: .word
	
.text
main:		la $k0, Array
		jal StringCheck
		jal Choose
		
		
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
        	jal WrongMessage
        	nop
Check_script4: 	la $a0, script4
        	jal Check
        	addi $t8, $a0, 0 #t8 = gia tri dung/sai cua chuoi 4
        	la $a0, String4wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
       		nop
Check_script8:	la $a0, script8
        	jal Check
        	addi $t9, $a0, 0 #t9 = gia tri dung/sai cua chuoi 8
        	la $a0, String8wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
       		nop
       		blt $s0, 3, SC_ResSR
       		li $a1, 3
       		la $a0, StringAllwrong
       		jal WrongMessage
       		j end_of_main
SC_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_StringCheck: 	jr $ra      
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
		jr $ra #Quay ve ctr con goc
wrong2: 	li $a1, 2 #a1= 2, day sai do thieu bo so
		jr $ra
end_string:	beq $v0, 0x2C, wrong1 #Neu ky tu cuoi cung cua chuoi la , => sai
		addi $a3, $a3, -2
		li $a2, 3 #gan a2 = 3
		div $a3, $a2 #a3/3 
		mfhi $a2 #a2 = a3 mod 3 = so dau phay mod 3
		bnez $a2, wrong2 #neu a2 != 0 => so dau phay khong chia 3 du 2 => khong du bo so
		addi $a0, $k0, 0 #a1 = k0 => Chuoi dung va a0 chua dia chi mang cua chuoi dang xet
		addi $a3, $a3, 4 #a3= a3 + 3 = so cac so + 2 (de pt cuoi cung cua mang mang gia tri -1)
		sll $a3, $a3, 2 #a3= a3*4
		add $k0, $k0, $a3 #k0 chi den dia chi moi de nhan vao chuoi tiep theo neu chuoi dung
		li $a2, -1
		sw $a2, -4($k0)
		li $a1, 0
		jr $ra 
#------------------
WrongMessage:	li $v0, 59
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
#------------------------
#Choose: Ham lua chon
Choose:		addi $sp, $sp, 4
		sw $ra, 0($sp)
Choose_main:	li $v0, 51
		la $a0, ChooseScript
		syscall
		beq $a0, 1, end_of_choose
		beq $a0, 4, Choose4
		beq $a0, 8, Choose8
		la $a0, script0
		addi $a1, $t7, 0
		jal StringSolve
		addi $s0, $t7, 0
		jal MarsbotControl
		j Choose_onemore
Choose4:	la $a0, script4
		addi $a1, $t8, 0
		jal StringSolve
		addi $s0, $t8, 0
		jal MarsbotControl
		j Choose_onemore
Choose8:	la $a0, script8
		addi $a1, $t9, 0
		jal StringSolve
		addi $s0, $t9, 0
		jal MarsbotControl
Choose_onemore:		j Choose_main
end_of_choose:		lw $ra, 0($sp)
			addi $sp, $sp, -4
			jr $ra



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
MarsbotControl: li $k1, 0
		li $s1, -1
MB_InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $ra,0($sp) 
TakeData:	lw $a1, 0($s0) #Load goc xoay
		addi $s0, $s0, 4
		beq $a1, $s1, MB_EndScript #Neu gia tri load duoc = -1 => ket thuc
		lw $a2, 0($s0) #load bit track/untrack
		addi $s0, $s0, 4
		lw $a0, 0($s0) # Load tg chay
		addi $s0, $s0, 4
MB_Run:		jal ROTATE
		nop
		bne $a2, 0, Leave
NotLeave:	jal     UNTRACK           # draw track line 
        	nop 
        	jal     GO 
        	nop 
		addi    $v0,$zero,32   
                syscall  
        	nop 
        	jal TRACK
		j MB_nextData
Leave:		jal     TRACK           # and draw new track line 
        	nop  
		addi    $v0,$zero,32    # Keep running by sleeping in 2000 ms        
        	syscall 	#a0 la tham so tg quay
       		jal     UNTRACK         # keep old track 
        	nop 
        	jal     TRACK           # and draw new track line 
        	nop 
MB_nextData:  	j TakeData  
MB_EndScript:	jal STOP
MB_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_MarsbotControl:	jr $ra		
				
#-------------------------------
#Moving khong vet: can tham so a0 - quy dinh huong di chuyen
#-----------------------------
Move_Non:
	addi $k1, $ra, 0 #luu dia chi tro ve	
	jal     UNTRACK           # draw track line 
        nop 
        jal     ROTATE 
        nop 
        jal     GO 
        nop 
	addi    $v0,$zero,32    # Keep running by sleeping in 1000 ms 
        	#Cho Mars Bot cach ra mot doan cho de nhin
                syscall  
        nop 
        jal TRACK
	addi $ra, $k1, 0
	jr $ra 
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









