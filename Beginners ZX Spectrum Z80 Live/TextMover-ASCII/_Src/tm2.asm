ENTRY_POINT equ 32768    ; Definice vstupního bodu na adrese 32768 (0x8000)

    org ENTRY_POINT          ; Nastavení počáteční adresy kódu
    
    ; Lepší inicializace seed - použití R registru a FRAMES
    ld a, r                  ; Načtení hodnoty z registru R
    ld h, a
    ld a, r                  ; Znovu načtení (jiná hodnota)
    ld l, a
    ld de, (23672)           ; FRAMES system variable
    add hl, de               ; Kombinace R + FRAMES
    ld (seed), hl            ; Uložení 16-bit seed
    
    call randomize_background ; Volání podprogramu pro nastavení náhodného pozadí

forever:                     ; Nekonečná smyčka hlavního programu
    
    call draw_star           ; Nakreslit hvězdu
    ld b,1                  ; Nastavení počtu opakování pro zpomalení (10 framů)
delayloop:
    halt                     ; Zastavení CPU na jeden frame
    djnz delayloop           ; Opakování smyčky
    call erase_star          ; Vymazat hvězdu
    call moveright           ; Volání podprogramu pro pohyb doprava
    
    ; Kontrola, či sme na konci
    ld a,(ypos)
    cp 24
    jp nz, forever
    ld a,(xpos)
    cp 0
    jp nz, forever
    
    ; Regenerácia farieb
    ld a, r
    ld h, a
    ld a, r
    ld l, a
    ld de, (23672)
    add hl, de
    ld (seed), hl
    call randomize_background
    
    jp forever               ; Skok zpět na začátek smyčky

draw_star:
    ; Nastaviť atribút na pozícii x,y na biele na čiernom
    call get_attr_address    ; HL = adresa atribútu
    ld (hl), 0x47            ; BRIGHT 1, PAPER 0 (čierna), INK 7 (biela)
    ret

erase_star:
    ; Obnoviť pôvodný náhodný atribút
    call get_attr_address    ; HL = adresa atribútu
    ld a, (hl)               ; Načítať aktuálny atribút
    and 0xF8                 ; Zachovať PAPER a BRIGHT
    ld (hl), a               ; Uložiť (INK = 0, takže čierna hviezda = neviditeľná)
    ret

get_attr_address:
    ; Vypočítať adresu atribútu pre xpos, ypos
    ; adresa = 0x5800 + (ypos * 32) + xpos
    ld a, (ypos)
    ld l, a
    ld h, 0
    add hl, hl               ; * 2
    add hl, hl               ; * 4
    add hl, hl               ; * 8
    add hl, hl               ; * 16
    add hl, hl               ; * 32
    ld a, (xpos)
    ld e, a
    ld d, 0
    add hl, de               ; + xpos
    ld de, 0x5800
    add hl, de               ; + začátek atribútov
    ret

moveright:
    ld a,(xpos)              ; Načtení aktuální x-pozice
    inc a                    ; Zvýšení x-pozice o 1
    cp 32                    ; Porovnání s 32 (konec řádku)
    jr nz, noreset           ; Pokud není 32, pokračuj
    xor a                    ; Reset x na 0
    ld (xpos),a              ; Uložení x-pozice
    ld a,(ypos)              ; Načtení y-pozice
    inc a                    ; Zvýšení y-pozice o 1
    ld (ypos),a              ; Uložení y-pozice
    ret
noreset:
    ld (xpos),a              ; Uložení nové x-pozice
    ret

xpos db 0                    ; Proměnná pro x-pozici kurzoru (inicializováno na 0)
ypos db 0                    ; Proměnná pro y-pozici kurzoru (inicializováno na 0)
seed dw 0x1234               ; Seed pro generátor náhodných čísel (16-bit)

get_random:                  ; Vylepšený 16-bit LFSR generátor
    push bc
    push de
    push hl
    ld hl, (seed)            ; Načtení 16-bit seed
    
    ; Galois LFSR s polynomem x^16 + x^14 + x^13 + x^11 + 1
    ld a, h
    ld b, l
    add hl, hl               ; Posun vlevo
    jr nc, no_xor            ; Pokud nedošlo k přenosu
    ld a, h
    xor 0x2D                 ; XOR s polynomem (vyšší bajt)
    ld h, a
    ld a, l
    xor 0x01                 ; XOR s polynomem (nižší bajt)
    ld l, a
no_xor:
    ld (seed), hl            ; Uložení nového seed
    ld a, l                  ; Vrátit nižší bajt jako náhodné číslo
    
    pop hl
    pop de
    pop bc
    ret                      ; Návrat

randomize_background:        ; Podprogram pro nastavení náhodného pozadí
    ; Vymazání celé bitmapy na 0x00 (žádné pixely)
    ld hl, 0x4000            ; Adresa začátku bitmapové paměti
    ld de, 0x4001            ; Cílová adresa
    ld bc, 0x17FF            ; Počet bajtů - 1
    ld (hl), 0x00            ; První bajt na 0
    ldir                     ; Zkopírování 0x00 do celé bitmapy
    
    ; Nastavení náhodných atribútů - každý blok má INK = PAPER (plná farba)
    ld hl, 0x5800            ; Začátek atribútové paměti
    ld bc, 768               ; 32×24 = 768 pozic
attr_loop:
    call get_random          ; Náhodná hodnota pro farbu
    and 0x07                 ; Mask na 0-7 (farba 0-7)
    ld d, a                  ; Uložení farby do D
    
    ; Nastavení INK = PAPER = stejná farba
    rlca                     ; Posun do bitů 3-5 (PAPER)
    rlca
    rlca
    or d                     ; Spojení: INK = PAPER = stejná farba
    or 0x40                  ; Nastavení BRIGHT 1 pro živější farby
    
    ld (hl), a               ; Nastavení atribútu
    inc hl                   ; Posun na další atribút
    dec bc                   ; Snížení počítadla
    ld a, b                  ; Kontrola
    or c
    jr nz, attr_loop         ; Pokud není 0, pokračuj
    ret                      ; Návrat z podprogramu

    end ENTRY_POINT          ; Konec programu