; naskfunc
; TAB=4

[FORMAT "WCOFF"]							; 制作目标文件的模式
[INSTRSET "i486p"]							; 表示为 486 使用
[BITS 32]									; 制作 32位模式 用的机器语言

; 制作目标文件的信息
[FILE "naskfunc.nas"]						; 源文件名信息
	GLOBAL	_io_hlt,			_io_cli,			_io_sti,	io_stihlt
	GLOBAL	_io_in8,			_io_in16,			_io_in32
	GLOBAL	_io_out8,			_io_out16,			_io_out32
	GLOBAL	_io_load_eflags,	_io_store_eflags
	GLOBAL	_load_gdtr, 		_load_idtr

; 以下是实际的函数
[SECTION .text]								; 目标文件中写了这些之后再写程序

_io_hlt:									; 对应 bootpack.c 中的函数 void io_hlt(void);
		HLT
		RET									; return;
_io_cli:
		CLI
		RET
_io_sti:
		STI
		RET
_io_stihlt:
		STI
		HLT
		RET
_io_in8:
		MOV		EDX, [ESP + 4]				; PORT
		MOV		EAX, 0
		IN 		AL, DX
		RET
_io_in16:
		MOV		EDX, [ESP + 4]
		MOV		EAX, 0
		IN 		AX, DX
		RET
_io_in32:
		MOV		EDX, [ESP + 4]
		IN 		EAX, DX
		RET
_io_out8:
		MOV		EDX, [ESP + 4]
		MOV		AL, [ESP + 8]				; DATA
		OUT 	DX, AL
		RET
_io_out16:
		MOV		EDX, [ESP + 4]
		MOV		EAX, [ESP + 8]
		OUT 	DX, AX
		RET
_io_out32:
		MOV		EDX, [ESP + 4]
		MOV		EAX, [ESP + 8]
		OUT 	DX, EAX
		RET
_io_load_eflags:
		PUSHFD								; PUSH EFLAGS
		POP 	EAX
		RET
_io_store_eflags:
		MOV		EAX, [ESP + 4]
		PUSH	EAX
		POPFD								; POP EFLAGS
		RET
_load_gdtr:
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LGDT	[ESP+6]
		RET

_load_idtr:
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET
