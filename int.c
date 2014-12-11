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