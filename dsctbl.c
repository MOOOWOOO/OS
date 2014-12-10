/* GDT IDT 处理 */
#include "bootpack.h"

void init_gdtidt(void)
{
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) ADR_GDT;
	struct GATE_DESCRIPTOR    *idt = (struct GATE_DESCRIPTOR    *) ADR_IDT;
	int i;

	/* GDT初始化，8192 为段的最大号数，因为CPU的设计原因，段寄存器的低3位不能使用 */
	for (i = 0; i <= LIMIT_GDT / 8; i++) {
		set_segmdesc(gdt + i, 0, 0, 0);
	}
	set_segmdesc(gdt + 1, 0xffffffff, 0x00000000, AR_DATA32_RW);	// 段号 1，上限 4GB，起始位置 0，属性 0x4092，这个段是 CPU 所能管理的段本身。
	set_segmdesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER);	// 段号 2，上限 512KB，地址 0x00280000，为 bootpack.hrb 准备的。
	load_gdtr(LIMIT_GDT, ADR_GDT);

	/* IDT初始化 */
	for (i = 0; i <= LIMIT_IDT / 8; i++) {
		set_gatedesc(idt + i, 0, 0, 0);
	}
	load_idtr(LIMIT_IDT, ADR_IDT);

	return;
}

/*
 * Param:
 * struct SEGMENT_DESCRIPTOR*	: 段号(segment descriptor)
 * unsigned int 				: 上限(limit)
 * int 							: 基址(base)
 * int 							: 属性(attribute)
 */
void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar)
{
	if (limit > 0xfffff) {
		ar |= 0x8000; /* G_bit = 1 */
		limit /= 0x1000;
	}
	sd->limit_low    = limit & LIMIT_GDT;
	sd->limit_high   = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
	
	sd->base_low     = base & LIMIT_GDT;
	sd->base_mid     = (base >> 16) & 0xff;
	sd->base_high    = (base >> 24) & 0xff;

	sd->access_right = ar & 0xff;
		
	return;
}

/*
 * Params:
 * struct GATE_DESCRIPTOR*	: 
 * int 						: 偏移量(offset)
 * int 						: 
 * int 						: 属性(attribute)
 */
void set_gatedesc(struct GATE_DESCRIPTOR *gd, int offset, int selector, int ar)
{
	gd->offset_low   = offset & LIMIT_GDT;
	gd->selector     = selector;
	gd->dw_count     = (ar >> 8) & 0xff;
	gd->access_right = ar & 0xff;
	gd->offset_high  = (offset >> 16) & LIMIT_GDT;
	return;
}
