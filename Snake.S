.org $8000

.define Player_X $06
.define Player_Y $07
.define PlayerPosition $08
.define QueueIndex $09
.define NMI_TimeMove $0A
.define CanMove $0B
.define Points $10
.define FruitColor $11
.define NextPosition $12
.define FruitPosition $13
Random_Seed:
    .db	$7		
Nmi_Move:
    .db	$12
start:
    LDX #$FF    
    TXS         
    JSR ClearCrt
    JSR ClearZeroPage
    LDA #01 ; snake color    
    STA $05    
    LDA Nmi_Move
    STA NMI_TimeMove  
    LDA #10 ; fruit color
    STA FruitColor  
    LDA Random_Seed
    STA $0701
    JSR LoadFruit

    LDX #0  ; start X
    STX $06 
    LDX #0  ; start Y
    STX $07 
    LDX #1  ; up   
    STX $00 
    LDX #2  ; down   
    STX $01 
    LDX #4  ; left   
    STX $02 
    LDX #8  ; right   
    STX $03 
    LDA #04    
    STA $04 
    
    JMP GameLoop

ClearZeroPage:
    STA $06,X
    INX
    BNE ClearZeroPage
    RTS
NMI:
    NmiCheck:
        DEC NMI_TimeMove
        BNE end_NMI

        NMI_Move_Expired:
            LDA #1
            STA CanMove
            LDA Nmi_Move
            STA NMI_TimeMove
    end_NMI:
        RTI
        
ClearCrt:
    LDX #0
    LDA #0
    loop_clear:
        STA $0200,X
        INX
        BNE loop_clear
    RTS

DrawFruit:
    LDX FruitPosition
    LDA FruitColor
    STA $0200,X
    RTS

LoadFruit:
    JSR Random
    STA FruitPosition
    TAX 
    LDA FruitColor
    STA $0200,X
    RTS

GameLoop:
    LDA CanMove
    CMP #1
    BNE GameLoop
    LDA $4000
    CMP $00
    BEQ MoveUp
    LDA $4000
    CMP $01
    BEQ MoveDown
    LDA $4000
    CMP $02
    BEQ MoveLeft
    LDA $4000
    CMP $03
    BEQ MoveRight

ColorSnake:
    JSR ClearCrt
    JSR DrawFruit
    LDA #0
    STA CanMove
    LDA $05 
    LDX PlayerPosition
    STA $0200,X
    LDX Points
    CPX #0
    BEQ End_ColorSnake
    LDX #0
        LoopColor:
            LDY $0300,X
            STA $0200,Y
            INX
            CPX Points
            BNE LoopColor
    End_ColorSnake:
        JMP GameLoop

Position_XY:
    CLC     
    LDX PlayerPosition
    LDA #0  
    ADC Player_Y
    ASL A
    ASL A
    ASL A
    ASL A
    ADC Player_X
    STA PlayerPosition    
    RTS

MoveUp:
    JSR RecordPositionInQueue
    SEC
    LDA Player_Y
    SBC #1
    JSR ClearLeftHalfByte
    STA Player_Y
    JSR Position_XY
    JSR CheckFruit
    CLC
    JMP ColorSnake

MoveDown:
    JSR RecordPositionInQueue
    CLC
    LDA Player_Y
    ADC #1
    JSR ClearLeftHalfByte
    STA Player_Y
    JSR Position_XY
    STA NextPosition
    JSR CheckFruit
    JMP ColorSnake
    

MoveLeft:
    JSR RecordPositionInQueue
    SEC
    LDA Player_X
    SBC #1
    JSR ClearLeftHalfByte
    STA Player_X
    JSR Position_XY
    JSR CheckFruit
    CLC
    JMP ColorSnake

MoveRight:
    JSR RecordPositionInQueue
    CLC
    LDA Player_X
    ADC #1
    JSR ClearLeftHalfByte
    STA Player_X
    JSR Position_XY
    STA NextPosition
    JSR CheckFruit
    JMP ColorSnake

ClearLeftHalfByte:        
    ASL A
    ASL A
    ASL A
    ASL A
    LSR A
    LSR A
    LSR A
    LSR A
    RTS

CheckFruit:
    LDX PlayerPosition
    LDA $0200,X
    CMP FruitColor
    BEQ OnFruitPickUp
    RTS

OnFruitPickUp:
    INC Points
    JSR LoadFruit
    RTS

RecordPositionInQueue:
    LDX QueueIndex
    CPX Points
    BEQ END_Record
    LDA PlayerPosition
    STA $0300,X
    INX
    STX QueueIndex
    CPX Points
    BEQ ResetIndex
    JMP END_Record
        ResetIndex:
            LDX #0 
            STX QueueIndex
    END_Record:
        RTS
Random:
    rand_8:
        LDA $0701 
        AND	#$B8
        LDX	#$05
        LDY	#$00

    F_loop:
        ASL	A		    
        BCC	bit_clr		

        INY			    
                        

    bit_clr:
        DEX			    
        BNE	F_loop		

    no_clr:
        TYA			   
        LSR	A		   
        LDA	$0701		
        ROL	A		    
        STA	$0701		
        RTS			    

.goto $FFFA
.dw NMI   ; non maskable
.dw start ; reset
.dw start ; interrupt 
 