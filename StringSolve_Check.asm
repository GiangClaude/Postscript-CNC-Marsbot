.data
	script0: .asciiz "20,1,2000,31,2,1000,54,3,2100"
	script4: .asciiz "20,1,2000,31,2,1c00,54,3,2100"
	script8: .asciiz "20,1,2000,31,2,1000,54,"
	String0wrong: .asciiz "Postscript so 0 sai do "
	String4wrong: .asciiz "Postscript so 4 sai do "
	String8wrong: .asciiz "Postscript so 8 sai do "
	Reasonwrong1:	.asciiz "xuat hien chu hoac ky tu khac ','"
	Reasonwrong2:	.asciiz "khong du bo so"
.text
main:		jal StringCheck

end_of_main:	li $v0, 10
		syscall
		
#------------------------------
#StringCheck: Kiem tra du lieu dau vao
#a0: dia chi cac chuoi
#t7, t8, t9: giu gia tri 1 neu chuoi 0, 4, 8 sai
#a1: bit gia tri dung sai
#------------------------------
StringCheck:
InSR:	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        sw    $ra,0($sp)  
	addi  $sp,$sp,4    # Save $a0 because we may change it later 
        sw    $a0,0($sp)  
        addi  $sp,$sp,4    # Save $a1 because we may change it later 
        sw    $a1,0($sp) 
        addi  $sp,$sp,4    # Save $a2 because we may change it later 
        sw    $a2,0($sp)   
        addi  $sp,$sp,4    # Save $a2 because we may change it later 
        sw    $a3,0($sp) 
        addi  $sp,$sp,4    # Save $a2 because we may change it later 
        sw    $v0,0($sp) 
mainStringCheck:	la $a0, script0
        		jal Check
        		addi $t7, $a1, 0 #t7 = gia tri dung/sai cua chuoi 0
        		la $a0, String0wrong #Gan a0 = message khi chuoi 0 sai
        		beq $t7, 0, Check_script4
        		nop
        		jal WrongMessage
Check_script4:      	la $a0, script4
        		jal Check
        		addi $t8, $a1, 0 #t8 = gia tri dung/sai cua chuoi 4
        		la $a0, String4wrong #Gan a0 = message khi chuoi 0 sai
        		beq $t8, 0, Check_script8
        		nop
        		jal WrongMessage
Check_script8:    	la $a0, script8
        		jal Check
        		addi $t9, $a1, 0 #t9 = gia tri dung/sai cua chuoi 8
        		la $a0, String8wrong #Gan a0 = message khi chuoi 0 sai
        		beq $t9, 0, ResSR
        		nop
        		jal WrongMessage
ResSR:	lw      $v0, 0($sp)     # Restore the registers from stack 
        addi    $sp,$sp,-4 
	lw      $a3, 0($sp)     # Restore the registers from stack 
        addi    $sp,$sp,-4 
	lw      $a2, 0($sp)     # Restore the registers from stack 
        addi    $sp,$sp,-4 
        lw      $a1, 0($sp)     # Restore the registers from stack 
        addi    $sp,$sp,-4 
        lw      $a0, 0($sp)     # Restore the registers from stack 
        addi    $sp,$sp,-4 
	lw      $ra, 0($sp)     # Restore the registers from stack 
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
		li $a1, 0 #a1 = 0 => chuoi dung
		jr $ra 
#------------------
WrongMessage:	li $v0, 59
		beq $a1, 2, Reason2
		la $a1, Reasonwrong1
		j call
Reason2:	la $a1,Reasonwrong2
call:		syscall
		jr $ra
#-----------------
