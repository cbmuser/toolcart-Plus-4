!to"bin/toolcart_lo.bin",plain
;--------------------------------------------------
; Commodore 16 and Plus/4 Gamecartridge 
;
; uses 1070 Bytes 
;--------------------------------------------------
screen       = $0d90
get          = $ffe4
tapebuf      = $0332
tedback      = $ff15  
tedcol1      = $ff16  
tedcol2      = $ff17  
tedcol3      = $ff18  
tedborder    = $ff19
row          = $8e
s_lo         = $9f
s_hi         = $a0
t_lo         = $a1
t_hi         = $a2 
blocks       = $a3
*=$8000
 jmp $800b
 jmp $800b
!by $01,$43,$42,$4d     ; module-nr., "CBM"
*=$800b
                 sei
                 lda $fb
                 pha
                 ldx #$02       ; cartrige 1 lo, kernal
                 sta $fdd0,x
                 jsr $ff84      ; Initialize I/O devices
                 jsr $ff87      ; RAM Test
                 pla
                 sta $fb
                 jsr $ff8a      ; Restore vectors to initial values
                 jsr $ff81      ; Initialize screen editor
                 lda #<cartrige ; cartridge jump in
                 sta $02fe
                 lda #>cartrige
                 sta $02ff
                 lda #$f1       ; irq -> banking-routines
                 sta $0314
                 lda #$fc
                 sta $0315
                 cli
                 jmp *
cartrige:
;--------------------------------------------------
; build screen and setups
;--------------------------------------------------
                 lda #$ff               
                 sta $ff0c
                 sta $ff0d           ; hide cursor
                 and #$00
                 sta tedback
                 sta tedborder
                 sta row
                 tax
                 tay
-                lda head,x          ; build screen
                 sta $0c00,x
                 inx
                 cpx #$78
                 bne -                  
                 ldx #$00
-                lda menu,x
                 sta $0d90,x
                 inx
                 cpx #$a0
                 bne - 
                 ldx #$00
-                lda foot,x
                 sta $0f20,x
                 inx
                 cpx #$c8
                 bne - 
                 ldx #$00
-                lda screen+4,x
                 ora #$80
                 sta screen+4,x 
                 inx
                 cpx #$20
                 bne -  
                 lda #$0d
                 sta t_hi
                 lda #$94
                 sta t_lo    
                 lda #$71
                 ldx #$00
-                sta $07ff,x   
                 sta $08ff,x
                 sta $09ff,x
                 sta $0aff,x
                 inx
                 bne -   
                 ldy #$28 
                 lda #$4d
                 sta $083c
                 lda #$4f
                 sta $083d
                 lda #$77
                 sta $083e
                 lda #$42
                 sta $083f

 
;--------------------------------------------------
; keyboard-scanner
;--------------------------------------------------
keys:
-                lda #$1f
                 sta $fd30
                 sta $ff08 
                 lda $ff08
                 and #$20              ; c= to select
                 bne +
                 jmp select
+                lda #$7f
                 sta $fd30
                 sta $ff08 
                 lda $ff08
                 and #$10              ; space to move
                 beq down
                 jmp keys
;--------------------------------------------------
; move down
;--------------------------------------------------
down:           inc row
                lda row
                cmp #$03
                bne ++
;----wrap  
+               clc
                ldy #$00    
-               lda (t_lo),y
                and #$7f
                sta (t_lo),y
                iny
                bcc +
                inc s_hi
+               cpy #$20
                bne -  
                lda #$0d
                sta t_hi
                lda #$94
                sta t_lo    
                ldy #$00    
-               lda (t_lo),y
                ora #$80
                sta (t_lo),y
                iny
                bcc +
                inc s_hi
+               cpy #$20
                bne -  
                lda #$00
                sta row  
                jmp delay 
;----move  
++              clc
                ldy #$00    
-               lda (t_lo),y
                and #$7f
                sta (t_lo),y
                iny
                bcc +
                inc t_hi
+               cpy #$20
                bne -  
                clc
                lda t_lo
                adc #$28
                sta t_lo 
                bcc +
                inc t_hi
+               clc
                ldy #$00    
-               lda (t_lo),y
                ora #$80
                sta (t_lo),y
                iny
                bcc +
                inc s_hi
+               cpy #$20
                bne -  
delay:          ldx #$00
                ldy #$00
-               inx
                bne - 
                iny
                cpy #$80
                bne -                    
                jmp keys                  
head:
!scr " UCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCI "                
!scr " G commodore plus/4 "
!by $a0,$a0,$a0,$a0
!scr "  32k toolbox H "
!scr " JCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCK "               
menu:
!scr "             dracopy                    "                 
!scr "             dir-browser                "                 
!scr "             file-copier                "                 
!scr "                                        "                 
foot:
!scr "    CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC     "                 
!scr "    space to select and c= to start     "                 
!scr "    CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC     "                 
!scr "                                        "                 
!scr "      xmas 2020 by cbmhardware.de       "                 
;---select by row
select:          lda row
                 cmp #$00
                 beq drcopy
                 cmp #$01
                 beq dirbw_cpy
                 cmp #$02
                 beq fcopier_cpy
                 jmp keys
drcopy:          jmp rom1_dracopy 
fcopier_cpy:     lda #>filecopier
                 sta s_hi  
                 lda #<filecopier
                 sta s_lo  
                 lda #$1e
                 sta blocks 
                 jsr copy  
;---copy from rom lo
dirbw_cpy:       lda #>dirbrowser
                 sta s_hi  
                 lda #<dirbrowser
                 sta s_lo  
                 lda #$17
                 sta blocks 
copy:            
                 lda $FF06         ; switch blank: 2 Mhz
                 and #$EF
                 sta $FF06
                 lda #$10
                 sta t_hi  
                 lda #$01
                 sta t_lo  
                 ldy #$00         ; copy 
                 ldx #$00
-                lda (s_lo),y     ; copy game or tool to ram 
                 sta (t_lo),y
                 iny
                 bne -   
                 inc s_hi
                 inc t_hi
                 inx          
                 cpx $a3
                 bne -
;--- copy trampoline-code to tape-buffer
trampolin_cpy:   ldx #$63         ; copy trampoline-code
-                lda trampolin,x
                 sta tapebuf,x
                 dex
                 bpl -      
                 jmp tapebuf
;--- trampoline-code
trampolin:       
                 sei 
                 lda #$00
                 sta $02fe       
                 sta $02ff
                 lda #$a4         ;  nativ irq 
                 sta $0314
                 lda #$f2
                 sta $0315
                 lda #$00         ; basic , kernal
                 sta $fdd0        ; function rom off
                 sta $fb
                 lda $fb  
                 jsr $ff84        ; Initialize I/O devices 
;--- reset values and restart ROMs
                 jsr $ff8a        ; Restore vectors to initial values
                 jsr $8117        ; restore vectors !
                 jsr $ff81        ; Initialize screen editor  
                 cli
                 jsr $802e        ; init Basic RAM
                 jsr $8818        ; prg link
                 jsr $8bbe        ; prg mode  
                 lda #$03         ; hide cursor
                 sta $ff0c
                 ora #$ff
                 sta $ff0d      
                 ldy #$00
                 lda $FF06         
                 ora #$10
                 sta $FF06
--               ldx #$00         ; wait ..
-                inx              ; .. long ..    
                 bne -            ; ..time .. 
                 iny              ; .. for .. 
                 bne --           ; .. drive reset
                 jsr $8bea        ; start prg          
                 rts   
;--- copy from rom hi
rom1_dracopy:
                 lda #$10
                 sta t_hi  
                 lda #$01
                 sta t_lo  
                 lda #$c0
                 sta s_hi  
                 lda #$00
                 sta s_lo  
                 lda #$31
                 sta blocks 
                 ldx #$00 
                 ldy #$00  
;--- copy trampoline-code for rom hi
rom1_tcopy:
-                lda rom1_trampolin,x
                 sta tapebuf,x
                 inx     
                 cpx #$1a
                 bne -      
-                lda trampolin,y
                 sta tapebuf,x
                 inx
                 iny
                 cpx #$59+18
                 bne -      
                 jmp tapebuf
;--- switch rom hi and copy prg to ram
rom1_trampolin:
                 sei
                 ldx #$08
                 sta $fdd0,x      ; cartrige 1 hi, basic
                 ldx #$00
                 ldy #$00
rom1copy:        lda (s_lo),y     ; copy game or tool to ram 
                 sta (t_lo),y
                 iny
                 bne rom1copy
                 inc s_hi
                 inc t_hi
                 inx          
                 cpx blocks
                 bne rom1copy  
dirbrowser:
!bin "tools/directory_browser_v1_2.prg",,2                                  
filecopier:
!bin "tools/file_copier.prg",,2
*=$bfff
!by $00                 














