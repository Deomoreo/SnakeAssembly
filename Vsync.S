.org $8000

start:
    LDX #$FF
    TXS
    LDA seed
    STA $17
    LDA #60
    STA $01

    
    LDA #$00
    STA $00
    LDA #$02
    STA $01
    LDY #$00
    LDX #$01

    

ClearZeroPage:
    LDA $FF
    STA $0202,X
    INX
    BNE ClearZeroPage

loopBig:
    ;JSR random_test
    STA $04
    LDX $05

    loop:
        LDY $06
        STA $0200,Y
        LDA $06
        ADC #16
        STA $06 
        BNE loop

    INX
    STX $05
    LDA #16
    CMP $05
    BNE loopBig 
    LDX #0

Game_loop:
    JMP Game_loop

nmi:
    DEC $01

    BEQ reset_vsync
    RTI
reset_vsync:
    LDA #60
    STA $02
    LDA $0200,X   ; load the current pixel
    EOR #$FF      ; invert it
    STA $0200,X   ; store it again
    INX
    BNE reset_vsync
    RTI


random_test:

    rand_8:
        LDA    $17       ;this is the seed location
        AND    #$B8        ; mask non feedback bits
                           ; for maximal length run with 8 bits we need
                           ; taps at b7, b5, b4 and b3
        LDX    #$05        ; bit count (shift top 5 bits)
        LDY    #$00        ; clear feedback count

    F_loop:
        ASL    A            ; shift bit into carry
        BCC    bit_clr      ; branch if bit = 0

        INY                 ; increment feedback count (b0 is XOR all the
                            ; shifted bits from A)

    bit_clr:
        DEX                 ; decrement count
        BNE    F_loop       ; loop if not all done

    no_clr:
        TYA                 ; copy feedback count
        LSR    A            ; bit 0 into Cb
        LDA    $17        ; get seed back
        ROL    A            ; rotate carry into byte
        STA    $17        ; save number as next seed
        RTS                 ; done


seed:
    .db    $1               ; prng seed byte (must not be zero)


.goto $FFFA
.dw nmi   ; non maskable
.dw start ; reset  
.dw start ; interrupt  