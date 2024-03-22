assume cs:code,ss:stack,ds:data;by Peng Yijun

data segment
	buf db 50,0,50 dup('$');缓冲区
;学生数据
	stu_name db 'Zhang San  ','$','Li Si      ','$','Wang Wu    ','$','Ma Zi      ','$','Lao wu     ','$','Xiao Liu   ','$'
			 db	'Peng qi    ','$','Zhao ba    ','$','Sun jiu    ','$','He Shi     ','$','Tang Shiyi ','$','Huang Shier','$',100 dup('$');姓名(不超过11个字符一个姓名占12字节)
    stu_id dw 0001,0002,0003,1234,5555,6461,7744,8421,9876,3214,3225,3368, 100 dup(?);学号(4位数字)
 	stu_grade db 88,89,91,95,94,96,97,80,86,95,94,92,99,100,100,100,98,96;成绩1
			  db 78,87,81,85,94,90,90,100,100,95,94,92,99,88,92,96,90,90;成绩2
			  db 100,87,91,85,97,100,90,100,100,95,94,92,99,100,92,96,100,97;成绩3
			  db 100,100,100,100,97,100,90,100,100,95,94,100,99,100,100,96,100,99;4
			  db 90,80,85,88,90,89,93,100,95,95,94,100,99,100,100,96,95,94;5
			  db 90,97,95,98,100,90,98,100,95,95,94,100,99,100,100,96,92,93;6
			  db 90,88,85,88,100,100,98,82,92,95,94,91,98,90,96,96,96,94;7
			  db 100,100,100,100,100,100,98,100,100,95,94,100,98,100,96,100,99,98;8
			  db 100,100,100,98,95,97,98,95,96,95,94,100,98,100,96,100,96,96;9
			  db 90,90,90,90,90,90,85,85,86,88,95,84,88,89,87,80,85,86;10
			  db 80,80,80,80,80,88,75,72,70,70,70,71,73,70,70,79,71,72;11
			  db 90,75,75,75,75,75,75,75,65,67,65,65,70,60,68,66,40,52;12
			  db 100 dup(?);成绩(18*2位数字)
	stu_rank db 3,99,7,98,2,97,0,96,8,96,4,94,6,94,5,93,1,90,9,86,10,72,11,52, 48 dup('$');排名按分数从低到高,所在位置暗示排名,如第4位学生第1名:3,7,2,0,8,4,6,5,1,9,10,11
	
;其他数据
	count db 12;学生数量
	count1 db 4,2;计数
	count2 dw 10;输入*10
	count3 db 0;功能3排序用
	count4 db 0,0,100,0,0,0,0;用于保存功能4中的计数：平均分，最高分，最低分，分数段90-100，80-89,60-79,0-59
	
;函数位
	fun dw f0,f1,f2,f3,f4
	
;显示字符串
	smenu db "Please enter a number(0-5) to choose function.",0ah,0dh
			  db "------------------------------------------------------------------",0dh,0ah
			  db "| Function0:display menu                                         |",0dh,0ah
			  db "| Function1:input one stu name(<=11 chars) id(0000) and grade(00)|",0dh,0ah
			  db "| Function2:inquire grade                                        |",0dh,0ah
			  db "| Function3:grade sorting                                        |",0dh,0ah
			  db "| Function4:class grade distribution                             |",0dh,0ah
			  db "| Function5:quit                                                 |",0dh,0ah
			  db "------------------------------------------------------------------",0dh,0ah,'$';菜单
	sc db 'Please enter your choice:','$';提示输入选项
	sinsert db 'Name  (<12) ',0dh,0ah,' ID ',' Grade ','03 ','04 ','05 ','06 ','07 ','08 ','09 ','10 ','11 ','12 '
			db '13 ','14 ','15 ','16 ','fproject ','fgrade(No Input)',0dh,0ah,'$';功能1或info提示词
	sblank	db ' ','$';空格
	ssearch db "Enter 0 to search by name, 1 to search by ID.",0dh,0ah,'$';功能2提示词
	swrong db "Name or ID is wrong, please enter again.",0dh,0ah,'$';查询失败
	sinp_name db "Please input name:",'$';请输入姓名
	sinp_ID db "Please input ID:",'$';请输入ID
	spause db "Press any key to continue.",'$';功能3暂停
	sahl db "The average, highest and lowest score is: ",'$';功能4提示词
	sf41 db "90-100:",'$'
	sf42 db "80-89:",'$'
	sf43 db "60-79:",'$'
	sf44 db "0-59:",'$'
	
data ends

stack segment stack'stack'
	dw 100h dup(?)
stack ends

code segment

;宏
change_line macro;换行
	mov dl,0dh
	mov ah,2
	int 21h
	mov dl,0ah
	int 21h
endm

print macro y;输出字符串
	lea dx,y
	mov ah,9
	int 21h
endm

subpro_enter macro;子程序寄存器入栈
	push ax
	push bx
	push cx
	push dx
	push di
	push si
endm

subpro_end macro;出栈
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
endm

;子程序
refresh:;刷新缓冲区
	push cx
	push si
	
	mov si,offset buf+1
	mov byte ptr [si],0
	mov cx,48
	inc si
	refreshp:
		mov byte ptr [si],'$'
		inc si
		loop refreshp
	pop si
	pop cx
	ret

menu:;菜单
	change_line
	print smenu
	ret

f0:;重新显示菜单
	call menu
	ret

input_name:;输入姓名
	subpro_enter
	call refresh

	mov dx,offset buf
	mov ah,0ah
	int 21h
	mov si,offset buf+1
	mov bh,0
	mov bl,[si];统计姓名字符数保存至bx
	
	mov di,offset stu_name
	inc si

	mov al,count[0]
	mov cl,12
	mul cl
	add di,ax;获得姓名最新位置偏移位
	push di
	
	add di,bx
	mov cx,11
	sub cx,bx
	jz name_blank_end
	name_blank:;填补空白，对齐数据
		mov byte ptr [di],' '
		inc di
		loop name_blank
		
	name_blank_end:nop
	pop di
	mov cx,bx
	cld
	rep movsb;复制字符ds:si->es:di
	
	subpro_end
	ret
	
input_id:;输入4位ID
	subpro_enter
	call refresh

	mov bx,0
	mov ch,0
	mov cl,count[0]
	shl cx,1
	add cx,offset stu_id
	mov si,cx;获取最新学号内存位置偏移量
	mov cl,count1[0]
	mov ch,0
	mov dx,0
	push cx
	
	input_id_num1: 
		mov ah,1;输入一位字符至al
		int 21h	
		sub al,30h;将输入数字的ascii码转换为十进制数字
		jl input_id_num1_exit1 
		cmp al,9
		jg input_id_num1_exit1;输入非数字退出
		cbw
		xchg ax,bx
		mul count2[0]
		xchg ax,bx
		add bx,ax
		dec cx;输入4位
		cmp cx,0
		ja input_id_num1;输入为数字时跳至num继续输入
		mov [si],bx
	input_id_num1_exit1:
		pop cx

	
	subpro_end
	ret
	
input_grade:;输入16+1个成绩
	subpro_enter
	call refresh
	
	mov al,count[0]
	mov ah,0
	mov cx,18
	mul cl
	mov si,offset stu_grade
	add si,ax;获取最新成绩偏移位
	dec cx
	input_grade_1:;循环17次，输入17个成绩
		push cx
		mov cx,2
		mov ax,0
		mov bx,0
		input_grade_num1: 
			mov ah,1;输入一位字符至al
			int 21h	
			sub al,30h;将输入数字的ascii码转换为十进制数字
			jl input_grade_num1_exit1 
			cmp al,9
			jg input_grade_num1_exit1;输入非数字退出
			cbw
			xchg ax,bx
			mul count2[0]
			xchg ax,bx
			add bx,ax
			cmp bx,10
			je input_grade_100
			input_grade_100_e:
				dec cx;输入2位
				cmp cx,0
				ja input_grade_num1;输入为数字时跳至num继续输入
				mov [si],bl
				jmp input_grade_num1_exit1
			input_grade_100:
				mov ah,1;输入一位字符至al
				int 21h	
				mov bl,100
				jmp input_grade_100_e
		input_grade_num1_exit1:
			print sblank
		
		pop cx
		inc si
		loop input_grade_1
		change_line
		
	subpro_end
	ret

compute_grade:
	subpro_enter
	
	mov al,count[0]
	mov ah,0
	mov cx,18
	mul cl
	mov si,offset stu_grade
	add si,ax;获取最新成绩偏移位

	mov ax,0
	mov bx,0
	mov cx,16
	compute_gpa:
		mov ax,0
		mov al,[si]
		add bx,ax;累加到bx中
		inc si
		loop compute_gpa
		
		mov dx,0
		mov ax,bx
		mov cl,16
		div cl
		mov ah,0
		mov cl,4
		mul cl
		mov cl,10
		div cl
		mov bx,ax;bx保存16次平时作业成绩和的加权平均值(1+2+...+16)/16*0.4
		mov ax,0
		mov al,[si]
		mov cl,6
		mul cl;大作业成绩17*0.6
		mov cl,10
		div cl
		mov ah,0
		add al,bl;最终成绩
		
	inc si;最终成绩地址
	mov [si],al

	subpro_end
	ret
	
ranking:;加入排名
	subpro_enter
	
	mov ax,0
	mov cx,0
	mov al,18
	mov cl,count[0]
	inc cx
	mul cl
	lea si,stu_grade
	dec ax
	add si,ax;获取最终成绩偏移位
	mov al,[si]
	dec cx
	mov di,cx
	shl di,1
	mov stu_rank[di+1],al
	mov stu_rank[di],cl
	
	subpro_end
	ret

f1:;插入学生数据
	subpro_enter
	
	print sinsert;显示提示信息
	call input_name;输入姓名
	change_line
	call input_id;输入ID
	print sblank
	call input_grade;输入成绩
	call compute_grade;计算最终成绩
	call ranking;插入排名
	
	inc byte ptr count[0];每插入一组数据，学生计数+1
	subpro_end
	ret
	
info_2num:;输出2位数字，以dl为输出目标
	subpro_enter
	
	mov al,dl
	mov ah,0
	mov dl,10
	div dl
	mov dh,ah
	mov dl,al
	add dl,30h
	mov ah,2
	int 21h;显示十位
	mov dl,dh
	add dl,30h
	int 21h;显示个位
	
	subpro_end
	ret

info:;显示一名学生全部信息(以bx为第几位学生, bx=0第0位)（不包括排名）
	subpro_enter
	print sinsert
	;输出名字
	push bx
	mov ax,12
	mov bh,0
	mul bl
	mov dx,ax
	add dx,offset stu_name;ds:dx要输出的字符串起始位置
	mov ah,9
	int 21h
	change_line
	pop bx
	;输出ID
	push bx
	shl bx,1
	add bx,offset stu_id
	mov ax,[bx]
	mov cl,100
	div cl
	mov dl,al
	mov dh,ah
	call info_2num;输出前2位
	mov dl,dh
	call info_2num;输出后2位
	mov ah,2
	mov dl,20h
	int 21h;空格
	pop bx
	;输出所有成绩
	push bx
	mov cx,18
	mov ax,18
	mov bh,0
	mul bl
	mov dx,ax
	add dx,offset stu_grade
	mov si,dx;si获取输出成绩起始地址偏移量
	info_grade:
		mov dl,[si]
		cmp dl,100
		je info_100
		call info_2num
		mov ah,2
		mov dl,20h;空格
		int 21h
		jmp info_100_end
		info_100:;输出100
			mov dl,31h
			mov ah,2
			int 21h
			mov dl,30h
			int 21h
			int 21h
		info_100_end:nop
		inc si
		loop info_grade
	
	change_line
	pop bx
	subpro_end
	ret

f2_name:;按姓名查询成绩
	subpro_enter
	print sinp_name
	call refresh
	lea dx,buf;int 21h 0ah号例程,ds:dx
	mov ah,0ah
	int 21h
	change_line
	mov bx,0
	mov ch,0
	mov cl,buf[1];实际输入字符数数值，用于对照姓名
	mov si,offset buf+2;缓冲区字符地址
	lea di,stu_name

	
	mov ax,12;用于地址偏移
	f2_name_check:;姓名检索
		mov dl,[si]
		cmp dl,[di];比较字符是否一致
		jne f2_name_check_f
		inc si
		inc di
		loop f2_name_check
		cmp byte ptr [di],'$'
		je f2_name_pass
		inc di
		cmp byte ptr [di],' '
		je f2_name_pass
		f2_name_check_f:;匹配失败
			mov ch,0
			mov cl,buf[1]
			mov ax,12
			inc bx
			cmp bl,count[0]
			je f2_name_f
			mul bl
			lea di,stu_name
			mov si,offset buf+2;恢复起始位
			add di,ax;从第一个姓名开始往后一一比较，不相等则向后一位比较
			jmp f2_name_check

	f2_name_f:;查询失败
		print swrong
		subpro_end
		ret
	
	f2_name_pass:;匹配成功(以bx为偏移基准)
		dec di
		call info

	subpro_end
	ret

f2_ID:;按学号查询成绩
	subpro_enter
	print sinp_ID
	mov bx,0
	mov cx,0
	lea si,stu_id;ID查询起始地址
	mov cl,count1[0]
	
	f2_ID_input: ;输入学号保存至bx
		mov ah,1;输入一位字符至al
		int 21h	
		sub al,30h;将输入数字的ascii码转换为十进制数字
		jl f2_ID_exit 
		cmp al,9
		jg f2_ID_exit;输入非数字退出
		cbw
		xchg ax,bx
		mul count2[0]
		xchg ax,bx
		add bx,ax
		dec cx;输入4位
		cmp cx,0
		ja f2_ID_input;输入为数字时跳至num继续输入
	
		change_line
		mov cx,0
		mov cl,count[0]
	f2_ID_check:;查询
		cmp bx,[si]
		je f2_ID_pass;查询成功
		add si,2
		loop f2_ID_check
		jmp f2_ID_f;查询次数超过学生个数，查询失败
		
	f2_ID_pass:;查询成功
		sub si,offset stu_id
		shr si,1
		mov bx,si;bx保存查询到的第几位学生
		call info
		jmp f2_ID_exit
	f2_ID_f:;查询失败
		print swrong
	f2_ID_exit:nop
	subpro_end
	ret

f2:;按姓名或学号查询成绩
	subpro_enter
	print ssearch;提示信息
	
	mov ah,1
	int 21h
	cmp al,30h;若输入数字0
	je f2_name_enter;输入0则按姓名查询
	
	change_line
	call f2_ID;否则按ID查询
	jmp f2_quit
	f2_name_enter:
		change_line
		call f2_name

	f2_quit:nop
	subpro_end
	ret
	
f3:;进行成绩排名
	subpro_enter
	
	mov cx,0
	;冒泡排序
	mov cl,count[0]
	dec cx;执行n-1次循环
	l1: 					;最外层循环
		mov si,0			;设置si为零			
		cmp cx,0			;判断循环是否结束
		je exit
		dec cx				;cx-1
		mov bx,cx
		add bx,cx			;将bx置为cx的2倍，用来判断si结束时的大小
							
	l2:
		mov al,stu_rank[si+1]	;不能直接比较内存中的数字，所以我们需要将其中一个数字放到寄存器ax中
		cmp al,stu_rank[si+3]	;比较两个数
		jle l3				;小于等于的话，则直接跳到下一对数据的比较
		xchg al,stu_rank[si+3]	;若大于，则通过两个xchg语句，交换两内存中的数字和排名
		xchg al,stu_rank[si+1]
		push ax
		mov al,stu_rank[si]
		xchg al,stu_rank[si+2]
		xchg al,stu_rank[si]
		pop ax
							;内层循环结束时跳到外层循环
	l3:
		cmp si,bx
		je l1
		add si,2			;si+2，开始下一对数的比较
		jmp l2
	exit:
		nop
		
	f3_output:;输出所有排名
		mov bx,0
		mov cx,0
		mov cl,count[0]
		lea di,stu_rank
		f3_output_s:
			mov dl,cl
			call info_2num;dl输出
			mov ah,2
			mov dl,':'
			int 21h
			change_line
			mov bl,[di]
			add di,2
			call info
			print spause;按任意键继续以防止信息冲刷
			mov ah,1
			int 21h
			change_line
			loop f3_output_s
		
	subpro_end
	ret

f4_max_min:;最大值，最小值更新
	cmp al,count4[1];最大值
	ja f4_count41_new
	jmp f4_max_min_mid
	f4_count41_new:
		mov count4[1],al
		jmp f4_max_min_end
	f4_max_min_mid:
		cmp al,count4[2];最小值
		jb f4_count42_new
		jmp f4_max_min_end
		f4_count42_new:
			mov count4[2],al
		
	f4_max_min_end:nop
	ret
	
f4_output:;功能4子程序输出成绩以count4[bx]为偏移地址
	subpro_enter

	mov dl,count4[bx]
	cmp dl,100
	je f4_output_100
	call info_2num

	jmp f4_output_100_end
	f4_output_100:;输出100
		mov dl,31h
		mov ah,2
		int 21h
		mov dl,30h
		int 21h
		int 21h
	f4_output_100_end:
	mov ah,2
	mov dl,',';逗号
	int 21h
	
	subpro_end
	ret

f4:;成绩分布
	subpro_enter
	print sahl
	
	mov ax,0
	mov bx,0
	mov cx,0
	mov cl,count[0];统计次数
	mov si,offset stu_grade+17
	f4_sub:;成绩分布统计
		mov al,[si]
		call f4_max_min
		cbw
		add bx,ax;累加到bx中
		cmp al,90
		jb f4_sub1
		inc count4[3];>=90
		jmp f4_sube
		f4_sub1:
			cmp al,80
			jb f4_sub2
			inc count4[4];80<=x<=89
			jmp f4_sube
			f4_sub2:
				cmp al,60
				jb f4_sub3
				inc count4[5];60<=x<=79
				jmp f4_sube
				f4_sub3:
					inc count4[6];<60
		f4_sube:add si,18
		loop f4_sub
		
	mov cl,count[0]
	mov ax,bx
	div cl
	mov count4[0],al;平均分
	
	mov bx,0
	mov cx,3
	f4_output3:;bx保存输出数据地址,输出前三个数据
		call f4_output
		inc bx
		loop f4_output3
	
	change_line
	f4_output4:;输出成绩分布
		print sf41
		call f4_output
		change_line
		inc bx
		print sf42
		call f4_output
		change_line
		inc bx
		print sf43
		call f4_output
		change_line
		inc bx
		print sf44
		call f4_output
		
	mov al,0;重置为初始状态
	mov count4[0],al
	mov count4[1],al
	mov count4[3],al
	mov count4[4],al
	mov count4[5],al
	mov count4[6],al
	mov al,100
	mov count4[2],al
	
	subpro_end
	ret

;主程序
start:
	mov ax,data
	mov ds,ax
	mov es,ax
	call menu
start1:
	mov ax,0
	mov dx,0
	change_line
	print sc
    mov ah,1
    int 21h;输入选项（0-5）
    sub al,30h
    cmp al,0
    jb start1
    cmp al,5
	je start_end;输入5退出
    ja start1;输入非0-5，程序重新运行
    mov ah,0
	shl al,1
    mov bx,ax
    change_line
    call fun[bx];调用各个功能程序
    jmp start1
	
start_end:
	mov ax,4c00h
	int 21h
code ends
end start