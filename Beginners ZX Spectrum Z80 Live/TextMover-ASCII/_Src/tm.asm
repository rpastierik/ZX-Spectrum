ENTRY_POINT equ 32768    ; Definice vstupního bodu na adrese 32768 (0x8000)

    org ENTRY_POINT          ; Nastavení počáteční adresy kódu
    ld a,2                   ; Nastavení kanálu 2 pro výstup
    call 0xdaf               ; Volání ROM rutiny pro vymazání obrazovky a otevření kanálu 2

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

playersprite db  0x2a        ; Sprite hráče (smiley face '☺')
ASCII_SPACE  equ 0x20        ; Konstanta pro ASCII mezeru
ASCII_AT     equ 0x16        ; Konstanta pro ASCII '@' (příkaz pro nastavení pozice)

    end ENTRY_POINT          ; Konec programu