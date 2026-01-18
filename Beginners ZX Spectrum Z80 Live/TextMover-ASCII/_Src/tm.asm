ENTRY_POINT equ 32768    ; Definice vstupního bodu na adrese 32768 (0x8000)

    org ENTRY_POINT          ; Nastavení počáteční adresy kódu
    ld a,2                   ; Nastavení kanálu 2 pro výstup
    call 0xdaf               ; Volání ROM rutiny pro vymazání obrazovky a otevření kanálu 2
    ld a, r                  ; Načtení hodnoty z registru R
    ld (seed), a             ; Inicializace seed náhodným číslem
    call randomize_background ; Volání podprogramu pro nastavení náhodného pozadí

forever:                     ; Nekonečná smyčka hlavního programu
    
    call setposition         ; Volání podprogramu pro nastavení pozice kurzoru
    call displaysprite       ; Volání podprogramu pro zobrazení sprite hráče    
    ld b,10                  ; Nastavení počtu opakování pro zpomalení (5 framů)
delayloop:
    halt                     ; Zastavení CPU na jeden frame
    djnz delayloop           ; Opakování smyčky
    call setposition         ; Opětovné nastavení pozice kurzoru
    call deletesprite        ; Volání podprogramu pro smazání sprite hráče
    call moveright           ; Volání podprogramu pro pohyb doprava
    

    jp forever               ; Skok zpět na začátek smyčky

displaysprite:
    ld a,(playersprite)      ; Načtení hodnoty sprite hráče do registr
    rst 16                   ; Vytisknutí znaku na obrazovku
    ret                      ; Návrat z podprogramu

deletesprite:
    ld a,ASCII_SPACE         ; Načtení ASCII kódu mezery do registru A
    rst 16                   ; Vytisknutí mezery na obrazovku       
    ret                      ; Návrat z podprogramu

setposition:                 ; Podprogram pro nastavení pozice kurzoru
    ld a,ASCII_AT            ; Načtení ASCII kódu '@' pro nastavení pozice
    rst 16                   ; Odeslání příkazu pro nastavení pozice
    ld a,(ypos)              ; Načtení y-pozice do registru A
    rst 16                   ; Odeslání y-pozice
    ld a,(xpos)              ; Načtení x-pozice do registru A
    rst 16                   ; Odeslání x-pozice
    ret                      ; Návrat z podprogramu

moveright:
    ld a,(xpos)              ; Načtení aktuální x-pozice do registru A
    inc a                    ; Zvýšení x-pozice o 1
    cp 32                    ; Porovnání s 32 (konec obrazovky)
    jr nz, noreset           ; Pokud není 32, pokračuj
    ld a,0                   ; Reset na 0
noreset:
    ld (xpos),a              ; Uložení nové x-pozice
    ret                      ; Návrat z podprogramu

xpos db 0                    ; Proměnná pro x-pozici kurzoru (inicializováno na 0)
ypos db 0                    ; Proměnná pro y-pozici kurzoru (inicializováno na 0)
seed dw 0x1234               ; Seed pro generátor náhodných čísel

playersprite db  0x2a        ; Sprite hráče (smiley face '☺')
ASCII_SPACE  equ 0x20        ; Konstanta pro ASCII mezeru
ASCII_AT     equ 0x16        ; Konstanta pro ASCII '@' (příkaz pro nastavení pozice)

get_random:                  ; Podprogram pro generování náhodného čísla
    ld a, (seed)             ; Načtení seed
    ld b, a                  ; Uložení do B
    rrca                     ; Rotace doprava
    rrca                     ; Rotace doprava
    rrca                     ; Rotace doprava
    xor b                    ; XOR s pôvodným
    and 1                    ; Mask na LSB
    ld c, a                  ; Uložení do C
    ld a, (seed)             ; Načtení seed
    add a, a                 ; *2
    or c                     ; Pridanie bitu
    ld (seed), a             ; Uložení nového seed
    ret                      ; Návrat

randomize_background:        ; Podprogram pro nastavení náhodného pozadí
    ld d, 0                  ; Počáteční hodnota pro h
random_outer_loop:
    ld h, 0x58               ; Základní adresa
    ld a, d                  ; d = 0,1,2
    add a, h                 ; h = 0x58 + d
    ld h, a
    ld e, 0                  ; Vnitřní počítadlo 0-255
random_inner_loop:
    call get_random          ; Náhodný bajt pro l
    ld l, a                  ; L = náhodný bajt (0-255)
    call get_random          ; Náhodná hodnota pro ink
    and 0x07                 ; Mask na 0-7
    ld b, a                  ; Uložení ink
    ld a, 0x38               ; Paper 7 (white), bright 0, flash 0
    or b                     ; Přidání ink
    ld (hl), a               ; Nastavenie atribútu
    inc e                    ; Zvýšenie vnútorého počítadla
    jr nz, random_inner_loop ; Opakuj pre 256 pozícií
    inc d                    ; Zvýšenie d
    ld a, d                  ; Kontrola, či d < 3
    cp 3
    jr nz, random_outer_loop ; Opakuj pre 3 skupiny
    ; Nastavenie bitmapy na náhodné hodnoty pre náhodné pixely
    ld hl, 0x4000            ; Adresa začiatku bitmapovej paměti
    ld bc, 0x1800            ; Počet bajtů (6144 = 0x1800)
bitmap_loop:
    call get_random          ; Náhodná hodnota
    ld (hl), a               ; Nastavenie náhodnej hodnoty do bitmapy
    inc hl                   ; Posun na ďalší bajt
    dec bc                   ; Zníženie počítadla
    ld a, b                  ; Kontrola
    or c
    jr nz, bitmap_loop       ; Ak nie, pokračuj
    ret                      ; Návrat z podprogramu

    end ENTRY_POINT          ; Konec programu