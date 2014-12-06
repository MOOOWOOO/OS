void io_hlt(void);
void HariMain(void)
{
fin:	// 代替 asmhead.nas 原来的 haribote.nas 中的 fin 部分。
	io_hlt();	// 执行 naskfunc.nas 中的 _io_hlt
	goto fin;
}