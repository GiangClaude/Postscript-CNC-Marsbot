.data
	script0: .asciiz "20,1,2000,31,2,1000,54,3,2100"
	script4: .asciiz "20,1,2000,31,2,1c00,54,3,2100"
	script8: .asciiz "20,1,2000,31,2,1000,54,3"
	String0wrong: .asciiz "Postscript so 0 sai do "
	String4wrong: .asciiz "Postscript so 4 sai do "
	String8wrong: .asciiz "Postscript so 8 sai do "
	Reasonwrong1:	.asciiz "xuat hien chu hoac ky tu khac ','"
	Reasonwrong2:	.asciiz "thieu bo so "
	Array0: .word
	
.text
main:		la $k0, Array0
		jal StringCheck
		la $a0, script0
		la $a1, Array0
		jal StringSolve
		
end_of_main:	li $v0, 10
		syscall
		
#------------------------------
#StringCheck: Kiem tra du lieu dau vao
#a0: dia chi cac chuoi
#t7, t8, t9: giu gia tri 1 neu chuoi 0, 4, 8 sai
#a1: bit gia tri dung sai
#k0: dia chi mang
#------------------------------
StringCheck:
SC_InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $ra,0($sp)  
mainSC:		la $a0, script0
        	jal Check
        	addi $t7, $a1, 0 #t7 = gia tri dung/sai cua chuoi 0
        	bgt $t7, 2, Check_script4
        	nop
       		la $a0, String0wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
Check_script4: 	la $a0, script4
        	jal Check
        	addi $t8, $a1, 0 #t8 = gia tri dung/sai cua chuoi 4
       		bgt $t8, 2, Check_script8
       		nop
       		la $a0, String4wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
Check_script8: 	la $a0, script8
        	jal Check
        	addi $t9, $a1, 0 #t9 = gia tri dung/sai cua chuoi 8
       		bgt $t9, 2, SS_ResSR
       		nop
       		la $a0, String8wrong #Gan a0 = message khi chuoi 0 sai
       		jal WrongMessage
SC_ResSR:	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_StringCheck: jr $ra        
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
		blt $a2, 0x30, wrong1
		bgt $a2, 0x39, wrong1
		j next_loop
is_comma:	addi $a3, $a3, 1 #so dau phay cong 1
next_loop:	addi $a0, $a0, 1 #Tang a0 + 1 => chi den byte tiep theo
		addi $v0, $a2, 0 #v0 giu byte truoc 
		j loop_Check
wrong1:		li $a1, 1 #gan a1 = 1, day sai do xuat hien chu hoac ky hieu
		jr $ra #Quay ve ctr con goc
wrong2: 	li $a1, 2 #a1= 2, day sai do thieu bo so
		jr $ra
end_string:	beq $v0, 0x2C, wrong2 #Neu ky tu cuoi cung cua chuoi la , => sai
		addi $a3, $a3, -2
		li $a2, 3 #gan a2 = 3
		div $a3, $a2 #a3/3 
		mfhi $a2 #a2 = a3 mod 3 = so dau phay mod 3
		bnez $a2, wrong2 #neu a2 != 0 => so dau phay khong chia 3 du 2 => khong du bo so
		addi $a1, $k0, 0 #a1 = k0 => Chuoi dung va a1 chua dia chi mang cua chuoi dang xet
		addi $a3, $a3, 4 #a3= a3 + 3 = so cac so + 1
		sll $a3, $a3, 2 #a3= a3*4
		add $k0, $k0, $a3 #k0 chi den dia chi moi de nhan vao chuoi tiep theo neu chuoi dung
		jr $ra 
#------------------
WrongMessage:	li $v0, 59
		beq $a1, 2, Reason2
		la $a1, Reasonwrong1 #sai do ly do 1
		j call
Reason2:	la $a1,Reasonwrong2 #sai do ly do 2
call:		syscall
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
StringSolve:	li $s0, 1 #Gan gia tri s0 khac 0 de bat dau ctr
SS_InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $ra,0($sp)  
        	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $a0,0($sp)  
        	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $a1,0($sp)  
        	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $s0,0($sp)  
        	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $s1,0($sp)  
        	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $s2,0($sp)
        	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        	sw    $s3,0($sp)  
mainSS:		li $s3, 10
		li $s2, 0
		li $s1, 1
		li $s5, 1
		beq $s0, 0x00, SS_ResSR
SS_loop:	lb $s0, 0($a0) #s0 = byte duoc xet
		beq $s0, 0x2C, Into_Array
		beq $s0, 0x00, Into_Array
		addi $sp, $sp, 1
		sb $s0, 0($sp) #luu byte vao stack
		addi $s1, $s1, 1 #dem so chu so cua so do
SS_nextbyte:	addi $a0, $a0, 1
		j SS_loop
Into_Array:	li $s4, 1
Into_loop:	beq $s4, $s1, SaveArray
		lb $s0, 0($sp)
		addi $sp, $sp, -1
		jal ChangeInt
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
		j mainSS
#______________
SS_ResSR:	lw      $s3, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
		lw      $s2, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
        	lw      $s1, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
 	       lw      $s0, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
        	lw      $a1, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
        	lw      $a0, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
        	lw      $ra, 0($sp)     # Restore the registers from stack 
        	addi    $sp,$sp,-4 
end_of_StringSolve: jr $ra  
#----------------------------
ChangeInt: 	addi $s0, $s0, -48
		jr $ra











