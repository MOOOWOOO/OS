#include "bootpack.h"

void init_pic(void) {
	io_out8(PIC0_IMR, 0XFF);	// 禁止所有中断
	io_out8(PIC1_IMR, 0XFF);	// 禁止所有中断
	
	io_out8(PIC0_ICW1, 0X11);	// 边沿触发模式(edge trigger mode)
	io_out8(PIC0_ICW2, 0X20);	// IRQ0-7 由 INT20-27 接收
	io_out8(PIC0_ICW3, 1 << 2);	// PIC1 由 IRQ2 连接
	io_out8(PIC0_ICW4, 0X01);	// 无缓冲区模式

	io_out8(PIC1_ICW1, 0X11);	// 边沿触发模式(edge trigger mode)
	io_out8(PIC1_ICW2, 0X28);	// IRQ0-7 由 INT20-27 接收
	io_out8(PIC1_ICW3, 2);		// PIC1 由 IRQ2 连接
	io_out8(PIC1_ICW4, 0X01);	// 无缓冲区模式

	io_out8(PIC0_IMR, 0XFB);	// 1111 1011 PIC1 以外全部禁止
	io_out8(PIC1_IMR, 0XFF);	// 1111 1111 禁止所有中断

	return ;
}

/*
 * Params:
 * int*		:
 */
void inthandler21(int *esp) {
	struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
	boxfill8(binfo->vram, binfo->scrnx, COL8_000000,  0, 0, 32 * 8 -  1, 15);
	putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, "INT 21 (IRQ-1) : PS/2 Keyboard.");
	while(1) {
		io_hlt();
	}
}

void inthandler2c(int *esp) {
	struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
	boxfill8(binfo->vram, binfo->scrnx, COL8_000000, 0, 0, 32 * 8 - 1, 15);
	putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, "INT 2C (IRQ-12) : PS/2 mouse");
	for (;;) {
		io_hlt();
	}
}

void inthandler27(int *esp) {
	io_out8(PIC0_OCW2, 0x67); 
	return;
}
