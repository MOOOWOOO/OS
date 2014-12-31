; haribote-os
; TAB=4

BOTPAK	EQU		0x00280000		; bootpackのロード先
DSKCAC	EQU		0x00100000		; ディスクキャッシュの場所
DSKCAC0	EQU		0x00008000		; ディスクキャッシュの場所（リアルモード）
; 有关的 BOOT_INFO
	CYLS	EQU		0X0FF0		; 设定启动区
	LEDS	EQU		0X0FF1
	VMODE	EQU		0X0FF2		; 颜色的位数
	SCRNX	EQU		0X0FF4		; 图像分辨率的 X
	SCRNY	EQU		0X0FF6		; 图像分辨率的 Y
	VRAM	EQU		0X0FF8		; 图像缓冲区的开始地址 VIDEO_RAM

	ORG		0XC200				; 程序被装载到的内存目标地址：启动区 0X8000 + 磁盘 0X4200 = 0X200

	MOV		AL, 0X13			; VGA 显卡，320 * 200 * 8 位彩色
	MOV		AH, 0X00
	INT		0X10

	MOV		BYTE	[VMODE], 8	; 记录画面模式
	MOV		WORD	[SCRNX], 320
	MOV		WORD	[SCRNY], 200
	MOV		DWORD	[VRAM], 0X000A0000

; 用 BIOS 取得键盘上各种 LED 指示灯的状态
	MOV		AH, 0X02
	INT		0X16				; KEYBOARD BIOS
	MOV		[LEDS], AL

; PIC 关闭一切中断
;	根据 AT 兼容机的规格，如果要初始化 PIC
;	必须在 CLI 之前进行，否则有时会挂起
;	随后进行 PIC 的初始化

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; 如果连续执行 OUT 指令，有些机种会无法正常运行
		OUT		0xa1,AL

		CLI						; 禁止 CPU 级别的中断

; 为了让 CPU 能够访问 1MB 以上的内存空间，设定 A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; 切换到保护模式

[INSTRSET "i486p"]				; 声明要使用 486 指令

		LGDT	[GDTR0]			; 暫定设定 GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; 设定 bit31 为0（为了禁止分页）
		OR		EAX,0x00000001	; 设定 bit0 为 1（为了切换到保护模式）
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  可以读写的段 32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack 传送

		MOV		ESI,bootpack	; 转送源
		MOV		EDI,BOTPAK		; 转送目的地
		MOV		ECX,512*1024/4
		CALL	memcpy

; 磁盘数据最终转送到他本来的位置去

; 首先从启动扇区开始

		MOV		ESI,0x7c00		; 转送源
		MOV		EDI,DSKCAC		; 转送目的地
		MOV		ECX,512/4
		CALL	memcpy

; 所有剩下的

		MOV		ESI,DSKCAC0+512	; 转送源
		MOV		EDI,DSKCAC+512	; 转送目的地
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 从住面熟变为字节数/4
		SUB		ECX,512/4		; 减去 IPL
		CALL	memcpy

; 必须由 asmhead 完成的，至此全部完毕
;	后续交由 bootpack 完成

; bootpack 启动

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 没有要转送的
		MOV		ESI,[EBX+20]	; 转送源
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; 转送目的地
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; 栈初始值
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		IN 		 AL,0X60 		; 空读（为了清空数据接收缓冲区中的垃圾数据）
		JNZ		waitkbdout		; AND 的结果如果不是 0，就跳到 waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; 减法运算的结果如果不是 0，就跳转到 memcpy
		RET
; memcpyはアドレスサイズプリフィクスを入れ忘れなければ、ストリング命令でも書ける

		ALIGNB	16
GDT0:
		RESB	8				; NULL selector
		DW		0xffff,0x0000,0x9200,0x00cf	; 可读写的段（segment）32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; 可执行的段（segment）32bit（bootpack用）

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
