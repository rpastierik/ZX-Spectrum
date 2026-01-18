; Program na tlač jednoduchého pohybujúceho sa znaku pomocou UDG (User Defined Graphics)
;
ENTRY_POINT equ 32768    ; Definice vstupního bodu na adrese 32768 (0x8000)

    org ENTRY_POINT          ; Nastavenie počiatku kódu na adresu 32768

    ld hl,ugds               ; Načítanie adresy UDG dát
    ld (23675),hl            ; Nastavenie systémovej premennej pre UDG na túto adresu

    ld a,0        ; 0=black, 1=blue, 2 = red, 3=magenta, 4=green, 5=cyan, 6=yellow, 7=white
    call 8859     ; Volanie ROM rutiny na nastavenie farby obrazovky

    ld a,2                   ; Nastavenie kanálu 2 pre výstup
    call 0xdaf               ; Volanie ROM rutiny na vymazanie obrazovky a otvorenie kanálu 2
    
    ld a,21                  ; Nastavenie počiatočnej X súradnice na 21 (pravá strana obrazovky)
    ld (xcoord),a            ; Uloženie do premennej xcoord


loop:                        ; Hlavná slučka programu
    call setxy               ; Volanie podprogramu na nastavenie pozície kurzora
    ld a,144                 ; Načítanie kódu UDG znaku (144 = prvý UDG)
    rst 16                   ; Vytlačenie znaku na obrazovku
    call delay               ; Volanie podprogramu na oneskorenie
    call setxy               ; Znovu nastavenie pozície kurzora
    ld a,32                  ; Načítanie ASCII kódu medzery (32)
    rst 16                   ; Vymazanie znaku medzerou
    call setxy               ; Nastavenie pozície pre ďalší pohyb
    ld hl,xcoord             ; Načítanie adresy premennej xcoord
    dec (hl)                 ; Zníženie X súradnice o 1 (pohyb hore)
    call print_coord         ; Výpis súradníc v ľavom hornom rohu
    ld a,(xcoord)            ; Načítanie aktuálnej X súradnice
    cp 255                   ; Porovnanie s 255 (ak prešla cez 0, skončí)
    jr nz,loop               ; Ak nie je 255, pokračuj v slučke
    ret                      ; Návrat z programu

print_coord:                 ; Podprogram na výpis súradníc v ľavom hornom rohu
    ld a,22                  ; AT kód
    rst 16
    ld a,0                   ; Y = 0
    rst 16
    ld a,0                   ; X = 0
    rst 16
    ld a,(xcoord)            ; Načítanie X súradnice
    call print_byte          ; Výpis X ako čísla
    ld a,','                 ; Čiarka
    rst 16
    ld a,(ycoord)            ; Načítanie Y súradnice
    call print_byte          ; Výpis Y ako čísla
    ret

print_byte:                  ; Podprogram na výpis bajtu ako dekadického čísla
    ld c,a                   ; Uloženie hodnoty do C
    ld b,0                   ; Počítadlo stoviek
hundreds:
    ld a,c
    cp 100
    jr c, print_h
    sub 100
    ld c,a
    inc b
    jr hundreds
print_h:
    ld a,b
    add a,'0'                ; Prevod na ASCII
    rst 16                   ; Výpis stoviek
    ld b,0                   ; Počítadlo desiatok
tens:
    ld a,c
    cp 10
    jr c, print_t
    sub 10
    ld c,a
    inc b
    jr tens
print_t:
    ld a,b
    add a,'0'                ; Prevod na ASCII
    rst 16                   ; Výpis desiatok
    ld a,c
    add a,'0'                ; Prevod jednotiek na ASCII
    rst 16                   ; Výpis jednotiek
    ret                      ; Návrat

delay:                       ; Podprogram na oneskorenie
    ld b,10                  ; Nastavenie počtu cyklov (10 framov)

delay0: 
    halt                     ; Čakanie na jeden frame
    djnz delay0              ; Opakovanie cyklu
    ret                      ; Návrat z podprogramu

setxy:                       ; Podprogram na nastavenie pozície kurzora
    ld a,22                  ; Načítanie riadiaceho kódu pre nastavenie pozície (22)
    rst 16                   ; Odoslanie riadiaceho kódu
    ld a,(xcoord)            ; Načítanie X súradnice
    rst 16                   ; Odoslanie X súradnice
    ld a,(ycoord)            ; Načítanie Y súradnice
    rst 16                   ; Odoslanie Y súradnice
    ret                      ; Návrat z podprogramu

xcoord  DEFB 0               ; Premenná pre X súradnicu kurzora (inicializovaná na 0)
ycoord  DEFB 15              ; Premenná pre Y súradnicu kurzora (riadok 15)

ugds    DEFB    60,126,219,153 ; Dáta pre UDG znak (8 bajtov pre 8x8 pixelov)
        DEFB    255,255,219,219 ; Druhý riadok UDG

    end ENTRY_POINT          ; Koniec programu