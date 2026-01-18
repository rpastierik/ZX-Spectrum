ENTRY_POINT equ 32768

    org ENTRY_POINT      

    ld a, 71              
    ld (23693),a          
    xor a 
    call 8859

    ld hl,blocks
    ld (23675),hl
   
    call 3503
 
    ld hl,21+15*256
    ld (plx),hl

    call basexy
    call splayr 

mloop: equ $

    call basexy
    call wspace

    ld bc,63486
    in a,(c)
    rra
    push af
    call nc, mpl 
    pop af
    rra
    push af
    call nc, mpr
    pop af
    rra
    push af
    call nc, mpd
    pop af
    rra
    call nc, mpu

    call basexy
    call splayr

    halt
    jp mloop

mpl:
    ld hl,ply
    ld a,(hl)
    and a
    ret z
    dec (hl)
    ret

mpr:
    ld hl,ply
    ld a,(hl)
    cp 31
    ret z
    inc (hl)
    ret

mpu:
    ld hl,plx
    ld a,(hl)
    cp 4
    ret z
    dec (hl)
    ret

mpd:
    ld hl,plx
    ld a,(hl)
    cp 21
    ret z
    inc (hl)
    ret

basexy:
    ld a,22
    rst 16
    ld a,(plx)
    rst 16 
    ld a,(ply)
    rst 16          ; Pridaný chýbajúci rst 16
    ret

splayr:
    ld a,69
    ld (23695),a
    ld a,144
    rst 16
    ret

wspace:
    ld a,71 
    ld (23695),a
    ld a,32     
    rst 16
    ret    

plx    DEFB 0
ply    DEFB 0

blocks: DEFB 16,16,56,56,124,124,254,254
    end ENTRY_POINT