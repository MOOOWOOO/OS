#include "bootpack.h"

/**
 * 初始化缓冲区
 */
void fifo8_init(struct FIFO8 *fifo, int size, unsigned char *data) {
	fifo->size = size;
	fifo->data = data;
	fifo->frees = size;		// 缓冲区大小
	fifo->flags = 0;
	fifo->next_r = 0;		// next read addr
	fifo->next_w = 0;		// next write addr
	return ;
}


/**
 * 向 FIFO 传送数据并保存
 */
#define FLAGS_OVERRUN		0x0001

int fifo8_put(struct FIFO8 *fifo, unsigned char data) {
	if (fifo->frees == 0) {		// 无空余位置，溢出
		fifo->flags |= FLAGS_OVERRUN;
		return -1;
	}
	fifo->data[fifo->next_w] = data;
	fifo->next_w++;
	if (fifo->next_w == fifo->size) {
		fifo->next_w = 0;
	}
	fifo->frees--;
	return 0;
}

/**
 * 从 FIFO 取得一个数据
 */
int fifo8_get(struct FIFO8 *fifo) {
	int data;
	if (fifo->frees == fifo->size) {	// 缓冲区为空
		return -1;
	}
	data = fifo->data[fifo->next_r];
	fifo->next_r++;
	if (fifo->next_r == fifo->size) {
		fifo->next_r = 0;
	}
	fifo->frees++;
	return data;
}

/**
 * 获取积攒的数据量
 */
int fifo8_status(struct FIFO8 *fifo) {
	return fifo->size - fifo->frees;
}
