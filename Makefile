TOOLPATH = D:/Projects/others/tolset/z_tools/
MAKE	 = $(TOOLPATH)make.exe
MAKER	 = $(MAKE) -r
NASK 	 = $(TOOLPATH)nask.exe
EDIMG	 = $(TOOLPATH)edimg.exe
COPY	 = copy
DEL		 = del

ipl.bin : ipl.nas Makefile
	$(NASK) ipl.nas ipl.bin ipl.lst

helloos.img : ipl.bin Makefile
	$(EDIMG) imgin:$(TOOLPATH)fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 imgout:helloos.img

img :
	$(MAKER) helloos.img

asm :
	$(MAKER) ipl.bin

run :
	$(MAKER) img
	$(COPY) helloos.img D:\Projects\others\tolset\z_tools\qemu\fdimage0.bin
	$(MAKE) -C $(TOOLPATH)qemu

install :
	$(MAKE) img
	$(TOOLPATH)imgtol.com w a: helloos.img