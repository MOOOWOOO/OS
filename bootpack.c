/* 启动杂项 */
#include <stdio.h>
#include "bootpack.h"

extern struct KEYBUF keybuf;

void HariMain(void)
{
	struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;	// asmhead.nas 中 BOOT_INFO 部分
	char s[40], mcursor[256];
	int mx, my, i, j;

	init_gdtidt();
	init_pic();
	io_sti();

	io_out8(PIC0_IMR, 0xf9);
	io_out8(PIC1_IMR, 0xef);

	init_palette();	// 设定调色板
	init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
	mx = (binfo->scrnx - 16) / 2; /* 鼠标置于屏幕中部 */
	my = (binfo->scrny - 28 - 16) / 2;
	init_mouse_cursor8(mcursor, COL8_008484);
	putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

	sprintf(s, "(%d, %d)", mx, my);
	putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

	while (1) {
		io_cli();
		if (keybuf.len == 0){
			io_stihlt();
		} else {
			i = keybuf.data[0];
			keybuf.len--;
			keybuf.next_r++;
			if (keybuf.next_r == 32) {
				keybuf.next_r = 0;
			}
			io_sti();
			sprintf(s, "%02X", i);
			boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 16, 15, 31);
			putfonts8_asc(binfo->vram, binfo->scrnx, 0, 16, COL8_FFFFFF, s);
		}
	}
}
