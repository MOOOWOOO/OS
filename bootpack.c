void io_hlt(void);
void HariMain(void)
{
	int i;		// i 是 32位 整数
	char *p;	// BYTE型 地址
	
	for (i = 0xa0000; i <= 0xaffff; i++) {
		// 替代原本的 write_mem8 函数
		p = (char *) i;
		*p = i & 0x0f;
	}

	while (1) {
		io_hlt();
	}
}
