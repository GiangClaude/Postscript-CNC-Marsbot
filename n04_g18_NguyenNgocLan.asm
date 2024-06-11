.eqv HEADING    0xffff8010	# Integer: An angle between 0 and 359 
				# 0 : North (up) 
				# 90: East (right) 
				# 180: South (down) 
				# 270: West  (left) 
.eqv MOVING     0xffff8050	# Boolean: whether or not to move 
.eqv LEAVETRACK 0xffff8020	# Boolean (0 or non-0): whether or not to leave a track 
.eqv IN_ADDRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD	0xFFFF0014
.eqv MASK_CAUSE_KEYMATRIX 0x00000800 # Bit 11: Key matrix interrupt 
.data
	script0: .asciiz "71,1,1700,37,1,1700,17,1,1700,0,1,1700,341,1,1700,320,1,1700,295,1,1700,180,1,8820,90,0,7000,270,1,2300,345,1,4520,15,1,4000,75,1,2500,90,0,2000,180,1,8820,90,1,2666,0,0,4410,270,1,2666,0,0,4410,90,1,2666"
	script4: .asciiz "315,1,2000,270,1,2000,225,1,2000,180,1,2000,135,1,2000,90,1,2000,135,1,2000,180,1,2000,225,1,2000,270,1,2000,315,1,2000,90,0,6000,135,1,2000,90,1,2000,45,1,2000,0,1,6800,315,1,2000,270,1,2000,225,1,2000,180,1,6800,90,0,6000,180,0,1650,0,1,10000,90,0,6000,255,1,4000,195,1,4500,165,1,4500,90,1,4000,90,0,4000,180,0,100,0,1,10000,270,0,3000,90,1,6000"
	script8: .asciiz "90,1,12000,180,1,8000,270,1,12000,0,1,8000,90,0,5800,180,0,2200,162,1,1200,90,1,1200,234,1,1200,162,1,1200,306,1,1200,234,1,1200,18,1,1200,306,1,1200,90,1,1200,18,1,1200"
	StringWrong: .asciiz "Postscript "
	StringAllwrong:	.asciiz "Tat ca Postscript deu sai"
	Reasonwrong1: .asciiz "sai do loi cu phap\n"
	Reasonwrong2: .asciiz "sai do thieu bo so\n"
	EndofProgram: .asciiz "Ket thuc chuong trinh!"
	checkNOTdone: .asciiz "Chua check xong xin hay doi mot lat"
	Done: .asciiz "Da cat xong!"
	Choose:	.asciiz "----------------------MENU-----------------------\nVui long chon phim tren Digital Lab Sim\n0: DCE\n4: SOICT\n8: Co Viet Nam\nC: Thoat chuong trinh"
	NotNormal: .asciiz "Xay ra loi bat thuong! Vui long thu lai chuong trinh!"
	Array: .word
	
.text
main:	li $v0, 55 #Thông báo MENU ra màn hình
	la $a0, Choose
	li $a1, 1
	syscall
	li $t1, IN_ADDRESS_HEXA_KEYBOARD
	li $t2, OUT_ADDRESS_HEXA_KEYBOARD
	li $t3, 0x80 		#bit 7 = 1 để bật ngắt
	sb $t3, 0($t1)
	la $k0, Array
	li $s0, 4
	div $k0, $s0
	mfhi $s1 		#Gán s1 = địa chỉ mảng % 4 
	beqz $s1, StrChk 	#Nếu địa chỉ mảng chia hết cho 4 rồi thì thôi, nếu không thì cộng thêm để chia hết cho 4
	sub $s0, $s0, $s1 	#Gán s0 = 4 - (địa chỉ mảng % 4)
	add $k0, $k0, $s0 	#Gán địa chỉ mảng mới = địa chỉ mảng cũ +  4 - (địa chỉ mảng % 4)
StrChk:	jal StringCheck
	
Loop: 	nop
	addi $v0, $zero, 32
	li $a0, 200
	syscall
	nop
	nop
	b Loop 			#Đợi người dùng nhấn phím trên Digital Lab Sim
	b Loop
			
exit:	li $v0, 55
	la $a0, EndofProgram
	li $a1, 1
	syscall
	li $v0, 10
	syscall
endMain:

#----------------------------------------------------------- 
#StringCheck: Kiểm tra dữ liệu đầu vào
#Input: Địa chỉ các chuỗi 0, 4, 8
#Output: Thông báo ra màn hình nếu chuỗi sai (Kết thúc chương trình nếu tất cả các chuỗi đều sai)
#Các thanh ghi sử dụng:
#	a0: - chứa địa chỉ các chuỗi ban đầu
#	    - sau khi chạy hàm check thì = 1 hoặc 2 nếu chuỗi sai, = địa chỉ mảng nếu chuỗi đúng
#	a1: chứa giá trị đúng/sai của chuỗi (0: đúng, 1: lỗi cú pháp, 2: lỗi thiếu bộ số, 3: tất cả các chuỗi đều sai)
#	t7, t8, t9: bằng 1 hoặc 2 nếu chuỗi 0, 4, 8 sai (tùy lỗi); là địa chỉ của mảng số nếu chuỗi đúng
#	s0: đếm số chuỗi sai
#	k1: Chứa chuỗi sai (0, 4 hoặc 8)
#----------------------------------------------------------- 
StringCheck:	li $s0, 0
		addi $sp, $sp, 4 		#Lưu $ra vào stack để dùng sau
        	sw $ra, 0($sp)  
Check_script0:	la $a0, script0
        	jal Check
        	add $t7, $a0, $zero 		#t7 = 1 hoặc 2 nếu chuỗi sai, = địa chỉ mảng nếu chuỗi đúng
        	beqz $a1, Check_script4 	#Nếu chuỗi không sai thì tiếp tục kiểm tra chuỗi tiếp theo
        	addi $k1, $zero, 0
        	jal WrongMessage
Check_script4:	la $a0, script4
        	jal Check
        	addi $t8, $a0, 0 		#t8 = 1 hoặc 2 nếu chuỗi sai, = địa chỉ mảng nếu chuỗi đúng
        	beqz $a1, Check_script8 	#Nếu chuỗi không sai thì tiếp tục kiểm tra chuỗi tiếp theo
        	addi $k1, $zero, 4
        	jal WrongMessage
Check_script8:	la $a0, script8
        	jal Check
        	addi $t9, $a0, 0 		#t9 = 1 hoặc 2 nếu chuỗi sai, = địa chỉ mảng nếu chuỗi đúng
        	beqz $a1, restoreRA 		#Nếu chuỗi không sai thì khôi phục $ra và kết thúc kiểm tra
        	addi $k1, $zero, 8
        	jal WrongMessage
AllWrong:	bne $s0, 3, restoreRA 		#Nếu tất cả các chuỗi đêu sai thì thông báo ra màn hình và kết thúc chương trình
		addi $a1, $zero, 3
		jal WrongMessage
		j exit
restoreRA:	lw $ra, 0($sp) 			#Khôi phục $ra
        	addi $sp, $sp, -4 
end_of_StringCheck: 	addi $t6, $t6, 1 	#Gán t6 = 1 --> Check xong
			jr $ra    
#----------------------------------------------------------- 
#WrongMessage: Thông báo lỗi sai
#Input: Chuỗi sai (k1) + Lỗi sai của chuỗi đó (a1)
#Output: Thông báo chuỗi sai và lỗi sai ra màn hình 
#Các thanh ghi sử dụng:
#	k1: Chứa chuỗi sai (0, 4 hoặc 8)
#	a1: Chứa giá trị sai của chuỗi (1: lỗi cú pháp, 2: lỗi thiếu bộ số, 3: tất cả các chuỗi đều sai)
#----------------------------------------------------------- 
WrongMessage:	beq $a1, 3, Reason3 	#Nếu a1 = 3 thì thông báo tất cả các chuỗi đêu sai
		li $v0, 4 		#In chuỗi sai
		la $a0, StringWrong 
		syscall
		li $v0, 1
		add $a0, $k1, $zero 
		syscall
		li $v0, 11
		addi $a0, $zero, 0x20 	#print space
		syscall
		beq $a1, 1, Reason1 	#Nếu a1 = 1 thì thông báo lỗi do cú pháp
		beq $a1, 2, Reason2 	#Nếu a1 = 2 thì thông báo lỗi do thiếu bộ số
Reason1:	li $v0, 4 
		la $a0, Reasonwrong1 	#Sai do lỗi cú pháp
		syscall
		j endWM
Reason2:	li $v0, 4 
		la $a0, Reasonwrong2 	#Sai do lỗi thiếu bộ số
		syscall
		j endWM
Reason3:	li $v0, 55
		la $a0, StringAllwrong
		li $a1, 0
		syscall
endWM:		jr $ra  
#----------------------------------------------------------- 
#Check: Kiểm tra 1 chuỗi có hợp lệ hay không
#Input: Địa chỉ chuỗi (a0)
#Output: a0: (chuỗi đúng) là địa chỉ mảng của chuỗi đang xét; (chuỗi sai) bằng 1 hoặc 2
#        a1: (chuỗi đúng) bằng 0; (chuỗi sai) bằng 1 hoặc 2
#Các thanh ghi sử dụng:
#	a0: địa chỉ ban đầu của script, gọi là s
#	a1: 0: chuỗi đúng; 1: lỗi cú pháp; 2: lỗi thiếu bộ số
#	a2: giá trị đang xét trên script, gọi là s[i]
#	v0: giữ giá trị trước của a2, gọi là s[i-1]
#	a3: đếm số dấu phẩy
#	s0: đếm số chuỗi sai
#	k0: địa chỉ mảng của chuỗi tiếp theo (nếu chuỗi đang xét đúng)
#----------------------------------------------------------- 
Check:		li $a3, 0 			#Khởi tạo số dấu phẩy = 0
		lb $a2, 0($a0) 			#a2 = s[0]
		beq $a2, 0x2C, wrong1  		#Nếu ký tự đầu tiên là phẩy --> Lỗi cú pháp 
loop_Check:	lb $a2, 0($a0) 			#a2 = s[i]
		beq $a2, 0x2C, is_comma 	#Nếu s[i] = ',' thì nhảy đến is_comma
		beq $a2, 0x20, continue 	#Nếu s[i] = ' ' thì bỏ qua nhảy đến continue
		beq $a2, 0x00, end_Check 	#Nếu s[i] = '\0' thì nhảy đến end_Check
		blt $a2, 0x30, wrong1 		#Nếu s[i] không thuộc ['0', '9'] --> Lỗi cú pháp
		bgt $a2, 0x39, wrong1 
		j continue
is_comma:	beq $v0, 0x2C, wrong1 		#Nếu có 2 dấu phẩy liên tiếp --> Lỗi cú pháp
		addi $a3, $a3, 1 		#Không thì tăng số dấu phẩy lên 1
continue:	addi $v0, $a2, 0 		#v0 = s[i-1]
		addi $a0, $a0, 1 		#Nếu không có lỗi nào thì chuyển sang s[i+1]
j loop_Check
wrong1:		li $a1, 1 			#a1 = 1, lỗi cú pháp
		li $a0, 1 
		addi $s0, $s0, 1 		#Tăng số chuỗi sai lên 1
		jr $ra
wrong2: 	li $a1, 2 			#a1 = 2, lỗi thiếu bộ số
		li $a0, 2 
		addi $s0, $s0, 1 		#Tăng số chuỗi sai lên 1
		jr $ra
end_Check:	beq $v0, 0x2C, wrong1 		#Nếu ký tự cuối cùng là ',' --> Lỗi cú pháp
		li $a2, 3			#Gán a2 = 3
		div $a3, $a2
		mfhi $a2 			#a2 = a3 % 3 = số dấu phẩy % 3
		bne $a2, 2, wrong2 		#Nếu a2 % 3 != 2 --> Lỗi không đủ bộ số
		li $a1, 0 			#Nếu không gặp lỗi nào ở trên thì chuỗi đúng --> Gán a1 = 0 và
		addi $a0, $k0, 0 		#Gán a0 = địa chỉ mảng của chuỗi đang xét
		addi $a3, $a3, 3 		#Gán a3 = số phần tử của mảng = Số dấu phẩy + 3(+1 --> số chữ số, dành 1 ô đầu tiên đánh dấu chuỗi đã chuyển thành mảng hay chưa, dành 1 ô cuối cùng lưu ký tự đánh dấu kết thúc chuỗi)
		sll $a3, $a3, 2 		#a3*4
		add $k0, $k0, $a3 		#k0 = địa chỉ mảng của chuỗi tiếp theo
		li $a2, -1 			#Ký tự đánh dấu kết thúc chuỗi
		sw $a2, -4($k0)
		jr $ra 

#Chương trình xử lý ngắt
.ktext 0x80000180
Check_Cause:	mfc0 $t4, $13 
		li $t3, MASK_CAUSE_KEYMATRIX 
        	and $at, $t4, $t3 
        	bne $at, $t3, Unusual 	#Nếu không phải ngắt do nhấn phím trên Digital Lab Sim thì nhảy đến Unusual
        	bne $t6, 1, notDone 	#Nếu chưa check xong thì thông báo ra màn hình	
		j Keymatrix_Intr
Unusual:       	li $v0, 55 		#Thông báo ra màn hình là 
      		la $a0, NotNormal 	#lỗi bất thường
        	li $a1, 0
        	syscall
       		li $v0, 10 		#exit 
       		syscall
notDone:	addi $sp, $sp, 4 	#Lưu v0 của chương trình chính vào stack
        	sw $v0, 0($sp)  
		addi $sp, $sp, 4 	#Lưu a0 của chương trình chính vào stack
        	sw $a0, 0($sp) 
        	addi $sp, $sp, 4 	#Lưu a1 của chương trình chính vào stack
        	sw $a1, 0($sp) 
		li $v0, 55
		la $a0, checkNOTdone 	#Chưa check xong
		li $a1, 1 
		syscall
		lw $a1, 0($sp) 
		addi $sp, $sp, -4 	#Khôi phục a1
        	lw $a0, 0($sp)
		addi $sp, $sp, -4 	#Khôi phục a0
        	lw $v0, 0($sp)
        	addi $sp, $sp, -4 	#Khôi phục v0
		j return
#----------------------------------------------------------- 
#s0: là địa chỉ mảng (nếu có gọi là s); là 1 hoặc 2 nếu lỗi
#s7: địa chỉ chuỗi 
#k1: Tên postscript đang xét
#----------------------------------------------------------- 
Keymatrix_Intr:	li $t3, 0x81 		#Kiểm tra xem có phải phím ở hàng 1 0, 1, 2, 3 được nhấn không
		sb $t3, 0($t1) 
		lb $a0, 0($t2) 
		bne $a0, 0x11, Row2 	#Nếu 0 không được nhấn thì kiểm tra hàng tiếp theo
		add $s0, $t7, $zero 	#s0 = địa chỉ mảng script 0 (nếu có)
		addi $k1, $zero, 0
		la $s7, script0
		jal runScript 		#Nếu 0 được nhấn thì chạy script 0
		j next_pc
Row2:		li $t3, 0x82 		#Kiểm tra xem có phải phím ở hàng 2 4, 5, 6, 7 được nhấn không
		sb $t3, 0($t1) 
		lb $a0, 0($t2) 
		bne $a0, 0x12, Row3 	#Nếu 4 không được nhấn thì kiểm tra hàng tiếp theo
		add $s0, $t8, $zero 	#s0 = địa chỉ mảng script 4 (nếu có)
		addi $k1, $zero, 4
		la $s7, script4
		jal runScript		#Nếu 4 được nhấn thì chạy script 4
		j next_pc
Row3:		li $t3, 0x84 		#Kiểm tra xem có phải phím ở hàng 3 8, 9, A, B được nhấn không
		sb $t3, 0($t1) 
		lb $a0, 0($t2) 
		bne $a0, 0x14, Row4 	#Nếu 8 không được nhấn thì kiểm tra hàng tiếp theo
		add $s0, $t9, $zero 	#s0 = địa chỉ mảng script 8 (nếu có)
		addi $k1, $zero, 8
		la $s7, script8
		jal runScript 		#Nếu 8 được nhấn thì chạy script 8
		j next_pc
Row4:		li $t3, 0x88 		#Kiểm tra xem có phải phím ở hàng 4 C, D, E, F được nhấn không
		sb $t3, 0($t1) 
		lb $a0, 0($t2) 
		beq $a0, 0x18, exit 	#Nếu C được nhấn thì kết thúc chương trình
next_pc: 	mfc0 $at, $14 		#$at <= Coproc0.$14 = Coproc0.epc
		addi $at, $at, 4 	#$at = $at + 4 (lệnh tiếp theo)
		mtc0 $at, $14 		#Coproc0.$14 = Coproc0.epc <= $at
return: 	eret 			#Quay về chương trình chính
#----------------------------------------------------------- 
#runScript: Chạy Script
#Input:	s0: địa chỉ mảng (nếu có gọi là a); 1 hoặc 2 nếu lỗi
#	s7: địa chỉ chuỗi muốn chạy
#Output: 	Hình được cắt xong (Nếu chuỗi chưa chuyển thành mảng thì chuyển) 
#		hoặc 
#		Thông báo chuỗi sai
#Các thanh ghi sử dụng:
#	s1: giá trị phần tử của mảng, gọi là a[i]
#	s2: biến chạy, gọi là i
#----------------------------------------------------------- 
runScript: 	beq $s0, 1, Wrong 
		beq $s0, 2, Wrong 
		lw $s1, 0($s0)
		beq $s1, 1, run 		#Nếu chuỗi đã chuyển thành mảng số thì chạy script
		addi $sp, $sp, 4 		#Lưu $ra vào stack để dùng sau
        	sw $ra, 0($sp) 
        	add $s4, $s0, $zero 		#Truyền địa chỉ mảng 
        	add $t5, $s7, $zero 		#và địa chỉ chuỗi vào hàm StringSolve
		jal StringSolve 		#Nếu chưa chuyển thì nhảy đến hàm chuyển
run: 		add $s2, $zero, $zero 		#Gán s2 = i = 0
		add $s3, $zero, $zero 		#Gán s3 = địa chỉ (a[i]) = 0
		li $a0, 135 			#Quay Marsbot 135* và bắt đầu chạy
		jal ROTATE 
		jal GO 
		addi $v0, $zero, 32 		#Trong 14000ms
		li $a0, 14000
		syscall
DRAW: 		jal getVALUE 			#Lấy góc
		beq $s1, -1, endDRAW 		#Nếu s1 = -1 thì kết thúc vẽ 
		add $a0, $zero, $s1 		#Quay Marsbot
		jal ROTATE
		jal getVALUE 			#Bật TRACK hoặc không
		beq $s1, $zero, KeepRunning 	#Nếu s1 = 0 thì không bật TRACK
		jal TRACK
KeepRunning: 	jal getVALUE 			#Lấy thời gian
		addi $v0, $zero, 32 		#Tiếp tục chạy trong (s1)ms
		add $a0, $zero, $s1 
		syscall
		jal UNTRACK 			#Nếu không bật track thì tắt track cũng không sao
		j DRAW
endDRAW: 	jal STOP
		li $v0, 55 			#Thông báo đã cắt hình xong ra màn hình
		la $a0, Done
		li $a1, 1
		syscall
		j resRA
Wrong: 		li $v0, 59
		la $a0, StringWrong
		beq $s0, 2, error2 		#Nếu s0 = 1 hoặc 2 thì chuỗi sai và thông báo ra màn hình
error1:		la $a1, Reasonwrong1
		syscall
		j endRun
error2:		la $a1, Reasonwrong2
		syscall 
		j endRun
resRA:		lw $ra, 0($sp) 			#Khôi phục $ra
        	addi $sp, $sp, -4 
endRun:		jr $ra
#----------------------------------------------------------- 
#StringSolve: Biến chuỗi thành mảng số
#Input:	Địa chỉ chuỗi cần chuyển ($t5)
#	Địa chỉ mảng của chuỗi đó ($s4)
#Output: Mảng đã chuyển xong (phần tử đầu tiên từ 0 thành 1 (mảng đã chuyển))
#Các thanh ghi sử dụng:
#	t5: Địa chỉ chuỗi, gọi là s
#	s4: Địa chỉ mảng 
#	s6: Giá trị của chuỗi, gọi là s[i]
#	s1: Đếm số chữ số của 1 số
#	s2: Giá trị số (từ chuỗi chuyển sang)
#	s3: 10
#	s5: 10^k (bắt đầu từ 10^0 rồi tăng dần lên)
#----------------------------------------------------------- 
StringSolve:	addi $sp, $sp, 4 
		addi $s3, $zero, 1 
		sw $s3, 0($s4)			#Lưu 1 vào phần tử đầu tiên của mảng để xác nhận chuỗi đã chuyển
		addi $s4, $s4, 4 		#Lưu giá trị vào mảng từ vị trí thứ 2
		li $s3, 10 
mainSS:		li $s2, 0 
		li $s1, 0 			#Đếm số chữ số (khởi tạo = 0)
		li $s5, 1 			#Lưu giá trị 10^k (khởi tạo = 10^0 = 1)
SS_loop:	lb $s6, 0($t5) 			#Lấy s[i]
		beq $s6, 0x20, SS_next 		#Nếu s[i] = ' ' thì bỏ qua 
		beq $s6, 0x2C, String2Array 	#Nếu s[i] = ',' 
		beq $s6, 0x00, String2Array 	#hoặc s[i] = '\0' thì chuyển chuỗi số trước đó thành số
		addi $sp, $sp, 1 
		sb $s6, 0($sp) 			#Lưu s[i] vào stack 
		addi $s1, $s1, 1 		#Tăng số chữ số lên 1 
SS_next:	addi $t5, $t5, 1 		#Tăng địa chỉ trỏ đến phần tử s[i+1] 
		j SS_loop
String2Array:	add $v0, $s6, $zero 		#Gán v0 = s[i-1]
str2a_loop:	ble $s1, $zero, Save2Array 	#Lặp lại việc chuyển chuỗi thành số cho đến khi số chữ số = 0
		lb $s6, 0($sp) 			#Lấy các chữ số ra khỏi stack --> lấy từ hàng đơn vị trở lên gán cho s6
		addi $sp, $sp, -1
		addi $s6, $s6, -48 		#s[i] = s[i] - '0' (chuyển ký tự số --> số)
		mult $s6, $s5 
		mflo $s6 			#s[i] = s[i]*(10^k) (ban đầu là 10^0 = 1 rồi tăng dần)			
		add $s2, $s6, $s2 		#s2 = s2 + s[i]*(10^k)
		mult $s5, $s3 
		mflo $s5 			#Gán s5 = (10^k)*10 = 10^(k+1)
		addi $s1, $s1, -1 		#Giảm số chữ số đi 1 và tiếp tục vòng lặp
		j str2a_loop
Save2Array:	sw $s2, 0($s4) 			#Lưu số đã chuyển xong vào mảng
		add $s4, $s4, 4		 	#Tăng địa chỉ mảng lên 1, trỏ đến ô nhớ tiếp theo
		addi $t5, $t5, 1 		#Tăng địa chỉ chuỗi lên 1, trở đến phần tử tiếp theo
		beq $v0, 0, end_of_StringSolve	#Nếu s[i-1] = '\0' thì kết thúc hàm chuyển
		j mainSS
end_of_StringSolve: 	addi $sp, $sp, -4
			jr $ra  	

#----------------------------------------------------------- 
#getVALUE: Lấy giá trị từ mảng 
#Input: s2: Vị trí trong mảng
#	s0: Địa chỉ gốc của mảng
#Output: s1: Giá trị phần tử tại vị trí a[i]
#----------------------------------------------------------- 
getVALUE: 	addi $s2, $s2, 1 	#i++
		sll $s4, $s2, 2 	#Gán s4 = 4i
		add $s3, $s4, $s0 	#s3 = 4i + địa chỉ mảng a = địa chỉ cùa a[i]
		lw $s1, 0($s3) 		#s1 = a[i]
		jr $ra

GO:     	li    $at, MOVING     	# change MOVING port 
        	addi  $k0, $zero, 1    # to  logic 1, 
        	sb    $k0, 0($at)     	# to start running 
        	nop         
        	jr    $ra 
        	nop 

STOP:   	li    $at, MOVING     	# change MOVING port to 0 
        	sb    $zero, 0($at)   	# to stop 
        	nop 
        	jr    $ra 
        	nop 

TRACK:  	li    $at, LEAVETRACK 	# change LEAVETRACK port 
        	addi  $k0, $zero, 1   	# to  logic 1, 
        	sb    $k0, 0($at)     	# to start tracking 
        	nop 
        	jr    $ra 
        	nop         

UNTRACK:	li    $at, LEAVETRACK 	# change LEAVETRACK port to 0 
        	sb    $zero, 0($at)   	# to stop drawing tail 
        	nop 
        	jr    $ra 
        	nop 
#----------------------------------------------------------- 
#ROTATE: Quay Marsbot
#Input: a0: Góc quay từ 0 đến 359
#	0 : North (up) 
#	90: East  (right) 
#	180: South (down) 
#	270: West  (left) 
#----------------------------------------------------------- 
ROTATE: 	li    $at, HEADING    	# change HEADING port 
        	sw    $a0, 0($at)     	# to rotate robot 
        	nop 
        	jr    $ra 
        	nop 
