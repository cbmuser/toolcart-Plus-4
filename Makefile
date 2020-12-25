SHELL=/bin/bash
all:
	acme toolcart_hi.asm
	acme toolcart_lo.asm   
run:
	xplus4 -c1lo bin/toolcart_lo.bin -c1hi bin/toolcart_hi.bin
clean:
	rm bin/*.bin
    
    
