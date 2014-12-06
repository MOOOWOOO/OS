TOOLPATH = ../tolset/z_tools/
MAKE	 = $(TOOLPATH)make.exe -r
NASK 	 = $(TOOLPATH)nask.exe
EDIMG	 = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY	 = copy
DEL		 = del

default :
	$(MAKE) img

ipl10.bin : ipl10.nas Makefile
	$(NASK) ipl10.nas ipl10.bin ipl10.lst

haribote.sys : haribote.nas Makefile
	$(NASK) haribote.nas haribote.sys haribote.lst

haribote.img : ipl10.bin haribote.sys Makefile
	$(EDIMG) imgin:$(TOOLPATH)fdimg0at.tek \
		wbinimg src:ipl10.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

img :
	$(MAKE) haribote.img

asm :
	$(MAKE) ipl10.bin

run :
	$(MAKE) img
	$(COPY) haribote.img ..\tolset\z_tools\qemu\fdimage0.bin
	$(MAKE) -C $(TOOLPATH)qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: haribote.img

clean :
	-$(DEL) ipl10.bin
	-$(DEL) ipl10.lst
	-$(DEL) haribote.sys
	-$(DEL) haribote.lst

src :
	$(MAKE) clean
	-$(DEL) haribote.img