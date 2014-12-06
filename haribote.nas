; haribote-os
; TAB=4

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
fin:
	HLT
	JMP fin