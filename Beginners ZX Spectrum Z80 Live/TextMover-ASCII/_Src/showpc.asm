; ZX Spectrum Sprite Display Routine
; Displays 32x32 sprite (4x4 chars) at screen position (0,0)
; Assembles at address 32768

        ORG     32768

START:
        LD      HL,SPRITE_DATA  ; Source data
        LD      B,4             ; 4 rows of chars (Y)
        LD      C,0             ; Start Y position

CHAR_ROW_LOOP:
        PUSH    BC
        LD      D,4             ; 4 columns of chars (X)
        LD      E,0             ; Start X position
        
CHAR_COL_LOOP:
        PUSH    DE
        PUSH    BC
        
        ; Calculate screen address for char at (E,C)
        ; Screen is at Y*32 + X, but complex layout
        LD      A,C             ; Y char position
        AND     24              ; Isolate bits for third
        OR      64              ; Add screen base (010xxxxx)
        LD      H,A
        LD      A,C
        AND     7               ; Get scan line within char
        RRCA
        RRCA
        RRCA
        OR      E               ; Add X position
        LD      L,A
        
        ; Now HL points to start of character
        ; Copy 8 scan lines
        LD      B,8
        
SCAN_LINE_LOOP:
        LD      A,(HL)
        LD      (HL),A          ; Dummy - we need to copy from sprite data
        ; Actually copy from sprite buffer
        PUSH    HL
        LD      HL,SPRITE_DATA
        POP     HL
        
        INC     H               ; Next scan line
        DJNZ    SCAN_LINE_LOOP
        
        POP     BC
        POP     DE
        INC     E               ; Next X position
        DEC     D
        JR      NZ,CHAR_COL_LOOP
        
        POP     BC
        INC     C               ; Next Y position
        DJNZ    CHAR_ROW_LOOP
        
        ; Copy attributes
        LD      HL,ATTR_DATA
        LD      DE,22528
        LD      BC,16
        LDIR
        
        RET

; Better version - simpler approach
; Copy sprite data directly, handling screen layout properly

START2:
        LD      IX,SPRITE_DATA
        LD      C,0             ; Y char (0-3)
        
Y_LOOP:
        LD      B,0             ; X char (0-3)
        
X_LOOP:
        ; Calculate screen address for char at B,C
        PUSH    BC
        
        LD      A,C
        AND     24
        OR      64
        LD      H,A
        LD      A,C
        AND     7
        RRCA
        RRCA
        RRCA
        OR      B               ; Add X position
        LD      L,A
        
        ; Copy 8 bytes from IX to screen
        LD      B,8
        
COPY_BYTE:
        LD      A,(IX+0)
        LD      (HL),A
        INC     IX
        INC     H
        DJNZ    COPY_BYTE
        
        POP     BC
        INC     B
        LD      A,B
        CP      4
        JR      NZ,X_LOOP
        
        INC     C
        LD      A,C
        CP      4
        JR      NZ,Y_LOOP
        
        ; Copy attributes  
        LD      HL,ATTR_DATA
        LD      DE,22528
        LD      B,4
        
ATTR_ROW:
        PUSH    BC
        LD      BC,4
        LDIR
        LD      BC,28
        EX      DE,HL
        ADD     HL,BC
        EX      DE,HL
        POP     BC
        DJNZ    ATTR_ROW
        
        RET

; Sprite data (128 bytes)
SPRITE_DATA:
        DEFB    0,  0,  0,  0,  0,  0,  0,  0
        DEFB    0,  0,  0,  0,  0,  0,  0,  0
        DEFB    239,193,224,112,107,251,131,208
        DEFB     58,127, 30, 16, 62,255,248, 16
        DEFB     47,191,176, 24, 47,253,224,  8
        DEFB     63,243,248, 12, 31,255,255,  4
        DEFB     27,255,253,204, 31,255,255, 95
        DEFB     15,254,255,252, 15,255,255,252
        DEFB     11,255,253,248, 11,255, 63,240
        DEFB     13,255,255,252, 12,253,175,236
        DEFB     28,255,255,254, 31,179,255, 32
        DEFB     28,159,158, 32, 15,159,252, 48
        DEFB      5,255,248, 16,  4, 28, 15, 49
        DEFB      6,119,201,225, 23,192,103, 63
        DEFB      7,254, 60,  3,  0,  3,224,  4
        DEFB      0,  0,  0,  0,  0,  0,  0,  0

; Attribute data (16 bytes)
ATTR_DATA:
        DEFB     32, 32, 40, 10, 29, 50, 50, 10
        DEFB     32, 10, 10, 24, 24, 32, 50, 24

        END     START2