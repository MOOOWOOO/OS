; hello-os
; TAB=4

	ORG		0X7C00			; 指明程序的装载地址
; 以下这段是标准 FAT12 格式软盘专用的代码
	JMP		entry
	DB		0X90

	DB		0XEB, 0X4E, 0X90
	DB		"HELLOIPL"		; 启动扇区名称，可以是任意字符串（8 字节）
	DW		512				; 每个扇区（sector）的大小（必须为 512 字节）
	DB		1				; 簇（cluster）的大小（必须为 1个 扇区）
	DW		1 				; FAT 的起始位置（一般从第一个扇区开始）
	DB		2				; FAT 的个数（必须为 2）
	DW		224				; 根目录大小（一般设置为 224 项）
	DW		2880			; 该磁盘的大小（必须是 2880 扇区）
	DB		0XF0			; 磁盘的种类（必须是 0XF0）
	DW		9				; FAT 的长度（必须是 9个 扇区）
	DW		18				; 1个 磁道（track）有几个扇区（必须是 18）
	DW		2 				; 磁头数（必须是 2）
	DD		0 				; 不使用分区，必须是 0
	DD		2880			; 重写一次磁盘大小
	DB		0,0,0X29		; 意义不明，固定
	DD		0XFFFFFFFF		; （可能是）卷标好吗
	DB		"HELLO-OS   "	; 磁盘的名称（11 字节），空格为3个，必须补满否则报错
	DB		"FAT12   "		; 磁盘格式名称（8 字节），空格为3个，必须补满否则报错
	RESB	18 			; 空出 18 字节
; 程序主体
entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0X7C00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SI + 1
		CMP		AL,0
		JE		fin
		MOV		AH,0X0E			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0X10			; 调用显卡 BIOS
		JMP		putloop
fin:
		HLT						; 让 CPU 停止，等待指令
		JMP		fin				; 无限循环

msg:
; 信息显示部分
	DB		0X0A, 0X0A		; 2个 换行
	DB		"hello, world"	; 打印到屏幕上的内容，可任意修改
	DB		0X0A			; 换行
	DB		0

	RESB	0X7DFE-$		; 填写 0X00，直到 0X001FE
	DB		0X55, 0XAA