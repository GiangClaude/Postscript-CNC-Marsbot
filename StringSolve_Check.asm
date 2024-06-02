.data
	script1: .asciiz "20,1,2000,31,2,1000,54,3,2100"
.text
main:		jal StringCheck

end_of_main:	li $v0, 10
		syscall
		
#------------------------------
#StringCheck: Kiem tra du lieu dau vao
#a0: dia chi cac chuoi
#t7, t8, t9: giu gia tri 1 neu chuoi 0, 4, 8 sai
#a1, a2: Dem và dem so chuoi bi sai
#------------------------------

