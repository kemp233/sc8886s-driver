KERN_DIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
obj-m += sc8886s_charger.o

all:
	$(MAKE) -C $(KERN_DIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERN_DIR) M=$(PWD) clean

.PHONY: all clean
