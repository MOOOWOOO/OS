TOOLPATH = ../tolset/z_tools/
MAKE	 = $(TOOLPATH)make.exe -r
NASK 	 = $(TOOLPATH)nask.exe
EDIMG	 = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY	 = copy
DEL		 = del

default :
	$(MAKE) img

ipl.bin : ipl.nas Makefile
	$(NASK) ipl.nas ipl.bin ipl.lst

helloos.img : ipl.bin Makefile
	$(EDIMG) imgin:$(TOOLPATH)fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 imgout:helloos.img

img :
	$(MAKE) helloos.img

asm :
	$(MAKE) ipl.bin

run :
	$(MAKE) img
	$(COPY) helloos.img ..\tolset\z_tools\qemu\fdimage0.bin
	$(MAKE) -C $(TOOLPATH)qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: helloos.img

clean :
	-$(DEL) ipl.bin
	-$(DEL) ipl.lst

src_only :
	$(MAKE) clean
	-$(DEL) helloos.img