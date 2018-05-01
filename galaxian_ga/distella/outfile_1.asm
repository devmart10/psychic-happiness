; Disassembly of ./galaxian_1.bin
; Disassembled Mon Apr 23 23:51:40 2018
; Using DiStella v3.01a
;
; Command Line: ./DiStella ./galaxian_1.bin 
;

VSYNC   =  $00
VBLANK  =  $01
WSYNC   =  $02
AUDC0   =  $15
AUDC1   =  $16
AUDF0   =  $17
AUDF1   =  $18
AUDV0   =  $19
AUDV1   =  $1A
INPT4   =  $3C
SWCHA   =  $0280
SWCHB   =  $0282
INTIM   =  $0284
TIM64T  =  $0296
LD520   =   $D520

       ORG $D000
LD000: LDY    $B4     
       LDX    LDEA7,Y 
       STX    $B4     
       LDA    $B0     
       CMP    #$05    
       BCS    LD015   
       LSR    A       
       BCS    LD015   
       STX    $8A     
       JMP    LD13E   
LD015: BIT    $8A     
       BVC    LD053   
       LDA    #$08    
       STA    $E1     
       LDA    $A4     
       LSR    A       
       STA    $85     
       LDA    $BC     
       SEC            
       SBC    #$0B    
       SBC    $85     
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       STA    $86     
       TAX            
       LDA    $85     
       CLC            
       ADC    LDF79,X 
       STA    $BD     
       LDA    $8B     
       LSR    A       
       LSR    A       
       TAY            
       LDX    LDE07,Y 
       STX    $BE     
       LDA    $A6,X   
       LDY    $86     
       AND    LDF98,Y 
       STA    $A6,X   
       LDA    LDFA4,X 
       LDY    #$00    
       JSR    LDD7C   
LD053: LDA    $B1     
       BNE    LD05A   
       JMP    LD100   
LD05A: LDA    $BC     
       SEC            
       SBC    #$0D    
       STA    $F2     
       SBC    #$F8    
       STA    $F3     
       LDA    $DD     
       SBC    #$FD    
       STA    $F5     
       AND    #$0F    
       TAY            
       LDA    $F5     
       CPY    #$07    
       BEQ    LD077   
       CLC            
       ADC    #$04    
LD077: SEC            
       SBC    #$10    
       STA    $F4     
LD07C: LDX    #$04    
       LDA    $D6     
       AND    #$07    
       STA    $82     
LD084: LDA    $CF,X   
       AND    #$40    
       BNE    LD0FD   
       LDA    $C5,X   
       BEQ    LD0FD   
       CMP    $F4     
       BCC    LD0FD   
       CMP    $F5     
       BCS    LD0FD   
       CPX    $82     
       BNE    LD0D0   
       LDY    #$03    
LD09C: DEY            
       BMI    LD0FD   
       LDA    $B7     
       AND    LDF5F,Y 
       BEQ    LD09C   
       LDA    $C0,X   
       CLC            
       ADC    LDE3E,Y 
       CMP    $F2     
       BCC    LD09C   
       CMP    $F3     
       BCS    LD09C   
       LDA    LDF5F,Y 
       EOR    #$FF    
       AND    $B7     
       STA    $B7     
       STY    $88     
       LDA    $D5     
       AND    #$E0    
       ORA    $88     
       STA    $D5     
       LDA    $D6     
       AND    #$E7    
       STA    $D6     
       JMP    LD0DE   
LD0D0: LDA    $C0,X   
       CMP    $F2     
       BCC    LD0FD   
       CMP    $F3     
       BCS    LD0FD   
       LDA    #$00    
       STA    $CA,X   
LD0DE: LDA    #$08    
       STA    $E1     
       LDA    #$40    
       STA    $8A     
       ORA    $CF,X   
       STA    $CF,X   
       STX    $89     
       AND    #$07    
       BEQ    LD122   
LD0F0: TAX            
       LDA    LDFC9,X 
       TAY            
       LDA    LDF9F,X 
LD0F8: JSR    LDD7C   
       LDX    $89     
LD0FD: DEX            
       BPL    LD084   
LD100: LDA    $B2     
       CMP    #$80    
       BNE    LD13E   
       INC    $B2     
       LDA    #$3F    
       STA    $E5     
       LDA    $E4     
       CLC            
       ADC    #$09    
       STA    $F3     
       ADC    #$F0    
       STA    $F2     
       LDA    #$D2    
       STA    $F4     
       LDA    #$E8    
       STA    $F5     
       JMP    LD07C   
LD122: LDA    #$11    
       STA    $E1     
       LDY    #$02    
       LDA    $D5     
       AND    #$60    
       BEQ    LD0F0   
       AND    #$20    
       BNE    LD13A   
       LDY    #$08    
       LDA    $B7     
       BEQ    LD0F8   
       LDY    #$03    
LD13A: LDA    #$00    
       BEQ    LD0F8   
LD13E: INC    $DC     
       LDA    #$00    
       BIT    $BF     
       BMI    LD170   
       LDA    $E5     
       BMI    LD154   
       DEC    $E5     
       LDY    #$1F    
       LSR    A       
       LSR    A       
       LDX    #$08    
       BNE    LD16C   
LD154: LDY    $EF     
       DEY            
       BNE    LD15B   
       LDY    #$14    
LD15B: STY    $EF     
       LDX    #$0A    
       LDA    $EE     
       BEQ    LD16A   
       DEC    $EE     
       TAY            
       LDA    #$01    
       LDX    #$08    
LD16A: ADC    #$02    
LD16C: STX    AUDC1   
       STY    AUDF1   
LD170: STA    AUDV1   
       LDA    $B0     
       AND    #$01    
       BNE    LD1AB   
       BIT    $BF     
       BMI    LD1A6   
       LDA    $E0     
       AND    #$1F    
       TAX            
       BEQ    LD18B   
       LDA    $B0     
       AND    #$02    
       BEQ    LD18B   
       INC    $E0     
LD18B: LDY    $E1     
       LDA    LDDF5,Y 
       BNE    LD199   
       TXA            
       BEQ    LD1A6   
       ORA    #$60    
       BNE    LD19B   
LD199: DEC    $E1     
LD19B: LDY    #$0D    
       STY    AUDC0   
       STA    AUDF0   
       CLC            
       ROL    A       
       ROL    A       
       ROL    A       
       ROL    A       
LD1A6: STA    AUDV0   
       JMP    LD48C   
LD1AB: LDA    $B0     
       LSR    A       
       LSR    A       
       BCC    LD1BA   
       LSR    A       
       BCC    LD1B7   
       JMP    LD272   
LD1B7: JMP    LD36E   
LD1BA: LSR    A       
       BCC    LD1C0   
       JMP    LD48C   
LD1C0: LDA    $DC     
       BNE    LD1E0   
       STA    $F0     
       BIT    $DE     
       BVS    LD1D2   
       LDA    $DE     
       AND    #$F8    
       ADC    #$08    
       STA    $F0     
LD1D2: LDA    $DE     
       AND    #$07    
       CMP    #$05    
       BCS    LD1DC   
       ADC    #$01    
LD1DC: ORA    $F0     
       STA    $DE     
LD1E0: BIT    $A5     
       BPL    LD1F1   
       LDA    $A4     
       BEQ    LD1ED   
       DEC    $A4     
       JMP    LD202   
LD1ED: LDA    #$00    
       BPL    LD200   
LD1F1: LDY    $B6     
       LDA    LDF71,Y 
       CMP    $A4     
       BEQ    LD1FE   
       INC    $A4     
       BNE    LD202   
LD1FE: LDA    #$80    
LD200: STA    $A5     
LD202: JSR    LDDE6   
       LDA    $A4     
       SBC    LDFAD,Y 
       STA    $84     
       LSR    A       
       TAX            
       LDA    LDE07,X 
       ASL    A       
       ASL    A       
       STA    $A3     
       LDA    $84     
       AND    #$07    
       STA    $86     
       LDA    $84     
       LSR    A       
       LSR    A       
       LSR    A       
       TAX            
       LDA    LDE19,X 
       ASL    A       
       ASL    A       
       ASL    A       
       ADC    $86     
       LSR    A       
       TAX            
       LDA    LDE19,X 
       ORA    $A3     
       STA    $A3     
       LDX    $B5     
       STX    $87     
LD236: JSR    LDD56   
       DEX            
       BPL    LD236   
       INC    $87     
       LDA    $A3     
       AND    #$03    
       ASL    A       
       ASL    A       
       ADC    #$DE    
       STA    $84     
       LDA    #$DF    
       STA    $85     
       LDY    #$05    
       STY    $86     
       LDA    $A4     
       AND    #$0F    
       TAX            
LD255: LDA    LDFD8,Y 
       CMP    $87     
       BCS    LD268   
       LDY    LDFB4,X 
       STX    $A1     
       TAX            
       LDA    ($84),Y 
       STA    $93,X   
       LDX    $A1     
LD268: INX            
       INX            
       DEC    $86     
       LDY    $86     
       BPL    LD255   
       BMI    LD2DC   
LD272: LDA    $BE     
       BMI    LD27A   
       SBC    #$E0    
       STA    $BE     
LD27A: LDA    $D6     
       CMP    #$87    
       BNE    LD2DC   
       LDA    #$00    
       STA    $80     
       STA    $81     
       LDX    $B5     
LD288: LDA    $A6,X   
       AND    #$7F    
       BEQ    LD299   
       ORA    $80     
       STA    $80     
       LDA    LDF5B,X 
       ORA    $81     
       STA    $81     
LD299: DEX            
       BPL    LD288   
       LDA    $BE     
       BMI    LD2AA   
       AND    #$07    
       TAY            
       LDA    LDF5B,Y 
       ORA    $81     
       STA    $81     
LD2AA: LDX    #$04    
LD2AC: LDA    $C5,X   
       BEQ    LD2CB   
       LDA    $CF,X   
       AND    #$07    
       TAY            
       LDA    LDF5B,Y 
       ORA    $81     
       STA    $81     
       LDA    $CF,X   
       LSR    A       
       LSR    A       
       LSR    A       
       AND    #$07    
       TAY            
       LDA    LDF5B,Y 
       ORA    $80     
       STA    $80     
LD2CB: DEX            
       BPL    LD2AC   
       LDA    $80     
       BNE    LD2DF   
       LDA    $A7     
       BMI    LD2DC   
       LDA    #$80    
       STA    $CF     
       STA    $A7     
LD2DC: JMP    LD462   
LD2DF: LDA    $B6     
       EOR    #$FF    
       CLC            
       ADC    #$07    
       TAX            
       LDY    #$00    
LD2E9: LDA    LDF5B,X 
       AND    $80     
       BNE    LD2F4   
       INY            
       DEX            
       BPL    LD2E9   
LD2F4: STY    $88     
       TAY            
       SEC            
       SBC    $B6     
       BEQ    LD332   
       LDY    #$00    
       LDX    #$00    
LD300: LDA    LDF5B,X 
       AND    $80     
       BNE    LD30D   
       INY            
       INX            
       CPX    #$08    
       BNE    LD300   
LD30D: STY    $84     
       LDA    $A4     
       CLC            
       ADC    LDFAD,X 
       STA    $A4     
       LDX    $B5     
LD319: LDA    $A6,X   
       AND    #$80    
       STA    $85     
       LDA    $A6,X   
       LDY    $84     
       BEQ    LD329   
LD325: ASL    A       
       DEY            
       BNE    LD325   
LD329: AND    #$7F    
       ORA    $85     
       STA    $A6,X   
       DEX            
       BPL    LD319   
LD332: LDA    $B6     
       CLC            
       ADC    $88     
       ADC    $84     
       AND    #$07    
       STA    $B6     
       LDX    $B5     
LD33F: LDA    $81     
       AND    LDF5B,X 
       BNE    LD34F   
       LDA    #$00    
       STA    $93,X   
       DEX            
       BPL    LD33F   
       LDX    #$00    
LD34F: STX    $B5     
       LDX    #$04    
       LDA    $84     
       ASL    A       
       ASL    A       
       ASL    A       
       STA    $84     
LD35A: LDA    $C5,X   
       BEQ    LD365   
       LDA    $CF,X   
       SEC            
       SBC    $84     
       STA    $CF,X   
LD365: DEX            
       BPL    LD35A   
       JSR    LDDE6   
       JMP    LD462   
LD36E: LDA    $AF     
       CMP    #$03    
       BCC    LD384   
       CMP    #$21    
       BCC    LD388   
       CMP    #$31    
       BCC    LD380   
       CMP    #$41    
       BCC    LD38C   
LD380: LDA    #$0C    
       BNE    LD38E   
LD384: LDA    #$05    
       BNE    LD38E   
LD388: LDA    #$08    
       BNE    LD38E   
LD38C: LDA    #$0A    
LD38E: STA    $A2     
       LDA    $E3     
       AND    #$0F    
       CMP    #$08    
       BEQ    LD3C8   
       LDA    $B5     
       ADC    #$02    
       ASL    A       
       ASL    A       
       ASL    A       
       ASL    A       
       STA    $84     
       LDA    $D6     
       AND    #$07    
       STA    $A1     
       CMP    #$07    
       BEQ    LD3B7   
       TAX            
       LDA    $C5,X   
       ADC    #$FF    
       CMP    $84     
       BCC    LD3B7   
       STA    $84     
LD3B7: LDA    $B0     
       AND    #$08    
       LSR    A       
       LSR    A       
       LSR    A       
       TAX            
       LDY    $D8,X   
       LDX    LDFD2,Y 
       STX    $80     
       BPL    LD3D4   
LD3C8: JMP    LD462   
LD3CB: LDY    $81     
       LDX    LDFD2,Y 
       CPX    $80     
       BEQ    LD3C8   
LD3D4: STX    $81     
       LDA    $CF,X   
       AND    #$40    
       BNE    LD3CB   
       LDA    $C0,X   
       CMP    #$88    
       BCS    LD3CB   
       LDA    $C5,X   
       BEQ    LD3CB   
       CMP    #$A0    
       BCS    LD3CB   
       CMP    $84     
       BCC    LD3C8   
       TAY            
       AND    #$0F    
       CPX    $A1     
       BEQ    LD3FB   
       CMP    $A2     
       BCS    LD3CB   
       BCC    LD3FF   
LD3FB: CMP    #$08    
       BCS    LD3CB   
LD3FF: TYA            
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       CPX    $A1     
       BNE    LD411   
       TAX            
       LDY    $B7     
       LDA    LDE3F,Y 
       JMP    LD415   
LD411: TAX            
       DEX            
       LDA    #$00    
LD415: STA    $A2     
       LDA    $93,X   
       AND    #$07    
       BNE    LD3CB   
       LDA    $93,X   
       ORA    #$02    
       STA    $93,X   
       STX    $89     
       LDA    #$FF    
       STA    $88     
       LDX    $B5     
       CLC            
       BPL    LD43A   
LD42E: LDA    $93,X   
       AND    #$07    
       TAY            
       LDA    LDF53,Y 
       ADC    $88     
       STA    $88     
LD43A: INX            
       CPX    $89     
       BNE    LD42E   
       LDA    $E3     
       AND    #$0F    
       TAX            
       TAY            
       BPL    LD44D   
LD447: LDA    $E6,X   
       STA    $00E6,Y 
       DEY            
LD44D: DEX            
       CPX    $88     
       BNE    LD447   
       LDX    $81     
       CLC            
       LDA    $C0,X   
       ADC    $A2     
       ADC    #$01    
       LDX    $88     
       INX            
       STA    $E6,X   
       INC    $E3     
LD462: LDA    $A0     
       AND    #$0F    
       LSR    A       
       BCC    LD46B   
       DEC    $E3     
LD46B: STA    $89     
       LDX    #$0C    
LD46F: LDA    $93,X   
       AND    #$0F    
       LSR    A       
       TAY            
       LDA    $89     
       BCC    LD47B   
       ORA    #$04    
LD47B: INX            
       STA    $93,X   
       DEX            
       STY    $89     
       DEX            
       CPX    $B5     
       BNE    LD46F   
       INX            
       STY    $93,X   
LD489: JMP    LD943   
LD48C: LDA    $DB     
       BMI    LD492   
       DEC    $DB     
LD492: LDA    #$02    
       STA    $92     
       BNE    LD49C   
LD498: LDY    $92     
       STX    $D8,Y   
LD49C: LDA    $F1     
       STA    $F2     
       LDA    $82     
       STA    $F3     
       DEC    $92     
       BMI    LD489   
       LDX    $92     
       LDA    $D8,X   
       STA    $82     
       STA    $83     
       INX            
       INX            
       STX    $F6     
       STX    $89     
       TAX            
       LDA    #$80    
       STA    $F1     
       JMP    LD73F   
LD4BE: LDX    $92     
       LDX    $83     
       LDA    LDFD2,X 
       STA    $83     
       LDY    $F6     
LD4C9: BEQ    LD4D6   
       LDA    #$00    
       STA    $C5,X   
       LDA    LDEA7,X 
       TAX            
       DEY            
       BNE    LD4C9   
LD4D6: LDY    LDFD2,X 
       STY    $82     
       LDX    $83     
       LDA    $C5,X   
       BEQ    LD4F3   
       CMP    #$F0    
       BEQ    LD525   
       CMP    #$EB    
       BCS    LD515   
       LDA    $C0,X   
       CMP    #$88    
       BEQ    LD515   
       LDA    $F6     
       BEQ    LD49C   
LD4F3: LDA    $DB     
       BPL    LD49C   
       LDA    $DE     
       AND    #$07    
       CMP    $D7     
       BEQ    LD49C   
       LDA    $A9     
       BMI    LD49C   
       LDX    $92     
       LDA    INTIM   
       CMP    #$23    
       BCS    LD49C   
       CMP    LD513,X 
       BCS    LD57B   
       BCC    LD49C   
LD513: BPL    LD520   
LD515: LDA    #$F0    
       STA    $C5,X   
       BIT    $F4     
       BPL    LD525   
       LDA    $D6     
       AND    #$07    
       ORA    #$80    
       STA    $D6     
LD525: LDA    $F1     
       AND    #$40    
       BNE    LD582   
       LDA    $CF,X   
       AND    #$07    
       TAY            
       LDA    $B0     
       AND    #$07    
       CMP    LDEAC,Y 
       BNE    LD582   
       LDY    $83     
       LDX    $82     
       LDA    #$00    
       STA    $00C5,Y 
       BIT    $F4     
       BPL    LD54B   
       TXA            
       ORA    #$80    
       STA    $D6     
LD54B: LDA    $00CF,Y 
       LDY    LDFD2,X 
       STY    $82     
       AND    #$7F    
       STA    $CF,X   
       AND    #$07    
       TAY            
       LDA    LDE95,Y 
       ORA    #$80    
       STA    $CA,X   
       LDA    $CF,X   
       LSR    A       
       LSR    A       
       LSR    A       
       TAY            
       LDA    $A4     
       LSR    A       
       CLC            
       ADC    LDF79,Y 
       STA    $C0,X   
       LDA    #$FF    
       STA    $F1     
       LDA    #$01    
       STA    $C5,X   
       JMP    LD498   
LD57B: LDY    #$06    
       LDX    $DA     
LD57F: DEY            
       BPL    LD585   
LD582: JMP    LD49C   
LD585: LDA    LDE5D,X 
       TAX            
       BNE    LD5C2   
       LDA    $A6     
       AND    #$7F    
       BEQ    LD57F   
       DEY            
       LDX    $B6     
       LDA    $A4     
       CMP    LDE46,X 
       LDX    #$01    
       BCS    LD57F   
       BIT    $F1     
       BVS    LD57F   
       LDA    $92     
       BNE    LD57F   
       BIT    $D5     
       BMI    LD57F   
       LDA    $D6     
       CMP    #$87    
       BNE    LD57F   
       LDX    $F3     
       LDA    $C5,X   
       LDX    #$01    
       CMP    #$00    
       BNE    LD57F   
       LDA    $F2     
       AND    #$10    
       BNE    LD57F   
       JMP    LD656   
LD5C2: LDA    $F1     
       AND    LDF5C,X 
       BNE    LD57F   
       LDA    $A6,X   
       AND    #$7F    
       BEQ    LD57F   
       STA    $88     
       STX    $DA     
       STX    $E0     
       LDA    LDE4F,X 
       ORA    $F1     
       STA    $F1     
       LDA    LDE9B,X 
       LDX    $82     
       LDY    LDFD2,X 
       STY    $82     
       STA    $C5,X   
       LDY    $B6     
       LDA    $A4     
       CMP    LDE46,Y 
       BCS    LD607   
       CMP    #$13    
       BCC    LD5FB   
       LDA    $B0     
       AND    #$02    
       BEQ    LD607   
LD5FB: LDY    #$07    
       LDA    $88     
LD5FF: DEY            
       ROR    A       
       BCC    LD5FF   
       LDA    #$40    
       BNE    LD611   
LD607: LDY    #$FF    
       LDA    $88     
LD60B: INY            
       ROL    A       
       BPL    LD60B   
       LDA    #$00    
LD611: STA    $CA,X   
       LDA    $A4     
       LSR    A       
       CLC            
       ADC    LDF79,Y 
       STA    $C0,X   
       TYA            
       ASL    A       
       ASL    A       
       ASL    A       
       ORA    $DA     
       ORA    #$80    
       STA    $CF,X   
       INC    $D7     
       STX    $88     
       LDX    $DA     
       LDA    LDF5B,Y 
       EOR    #$FF    
       AND    $A6,X   
       STA    $A6,X   
       JSR    LDD56   
       LDA    $AF     
       AND    #$0F    
       TAX            
       LDY    $B0     
       LDA    LD656,Y 
       AND    LD64C,X 
       STA    $DB     
       LDX    $88     
       JMP    LD498   
LD64C: .byte $00,$7F,$70,$62,$54,$46,$38,$2A,$1C,$0E
LD656: STX    $E0     
       STX    $DA     
       LDA    $A6     
       AND    #$7F    
       LDY    #$07    
LD660: DEY            
       ROR    A       
       BCC    LD660   
       LDX    $82     
       STX    $D8     
       LDA    $B0     
       AND    #$40    
       STA    $CA,X   
       STA    $80     
       LDA    $A4     
       LSR    A       
       CLC            
       ADC    LDF79,Y 
       STA    $C0,X   
       STA    $84     
       LDA    LDF5B,Y 
       EOR    #$FF    
       AND    $A6     
       STA    $A6     
       TYA            
       ASL    A       
       ASL    A       
       ASL    A       
       ORA    #$80    
       STA    $CF,X   
       STA    $81     
       LDA    #$0B    
       STA    $C5,X   
       INC    $D7     
       STY    $88     
       LDX    #$00    
       STX    $89     
       STX    $B7     
       JSR    LDD56   
       LDY    $88     
       INY            
       LDX    #$02    
       STX    $88     
       CPY    #$07    
       BCC    LD6B0   
LD6AA: DEX            
       BMI    LD6C6   
       DEY            
       BMI    LD6C6   
LD6B0: LDA    LDF5B,Y 
       AND    $A7     
       BEQ    LD6AA   
       ORA    $89     
       STA    $89     
       LDA    LDF5F,X 
       ORA    $B7     
       STA    $B7     
       DEC    $88     
       BNE    LD6AA   
LD6C6: LDA    $89     
       BEQ    LD6F9   
       EOR    #$FF    
       AND    $A7     
       STA    $A7     
       LDX    #$01    
       JSR    LDD56   
       LDY    $B7     
       LDA    LDE62,Y 
       STA    $D5     
       LDX    $F3     
       STX    $D9     
       STX    $D6     
       LDA    $84     
       STA    $C0,X   
       LDA    #$1B    
       STA    $C5,X   
       LDA    $80     
       STA    $CA,X   
       LDA    $81     
       ORA    #$01    
       STA    $CF,X   
       INC    $D7     
LD6F6: JMP    LD943   
LD6F9: LDA    #$80    
       STA    $D5     
       BNE    LD6F6   
LD6FF: LDX    $83     
       STA    $C5,X   
       BEQ    LD715   
LD705: LDX    $83     
       STA    $C5,X   
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       TAY            
       LDA    LDE4E,Y 
       ORA    $F1     
       STA    $F1     
LD715: BIT    $F4     
       BPL    LD721   
       LDA    $D6     
       AND    #$F8    
       ORA    $83     
       STA    $D6     
LD721: LDA    $86     
       STA    $CF,X   
       LDA    $87     
       STA    $CA,X   
       LDA    $84     
       STA    $C0,X   
       LDA    LDEA7,X 
       STA    $83     
       DEC    $F6     
LD734: DEC    $89     
       BEQ    LD743   
       LDY    $82     
       LDX    LDEA7,Y 
       STX    $82     
LD73F: LDA    $C5,X   
       BNE    LD746   
LD743: JMP    LD4BE   
LD746: STA    $85     
       LDA    $D6     
       AND    #$07    
       STA    $88     
       CPX    $88     
       BNE    LD754   
       LDA    #$80    
LD754: STA    $F4     
       LDA    $C0,X   
       STA    $84     
       LDA    $CA,X   
       STA    $87     
       LDA    $CF,X   
       STA    $86     
       BIT    $86     
       BVS    LD7A0   
       AND    #$07    
       BNE    LD78E   
       BIT    $D6     
       BMI    LD78E   
       LDX    $88     
       LDA    $C0,X   
       STA    $84     
       LDA    $CA,X   
       STA    $87     
       LDA    $86     
       LDY    $CF,X   
       BPL    LD782   
       ORA    #$80    
       BMI    LD784   
LD782: AND    #$7F    
LD784: STA    $86     
       LDA    $C5,X   
       SEC            
       SBC    #$10    
LD78B: JMP    LD705   
LD78E: LDA    $85     
       CMP    #$F0    
       BNE    LD797   
       JMP    LD6FF   
LD797: LDX    $84     
       LDA    $87     
       BPL    LD7E2   
       JMP    LD82A   
LD7A0: BIT    $F4     
       BPL    LD7C5   
       LDA    $D6     
       CLC            
       ADC    #$08    
       STA    $D6     
       BIT    $D6     
       BVC    LD797   
       AND    #$87    
       STA    $D6     
       LDA    $86     
       AND    #$BF    
       STA    $86     
       LDA    $B7     
       BNE    LD797   
       STA    $F4     
       LDA    #$87    
       STA    $D6     
       BNE    LD7DD   
LD7C5: INC    $87     
       LDA    $87     
       CMP    #$10    
       BCS    LD7D1   
       LDA    $85     
       BCC    LD78B   
LD7D1: LDA    $86     
       AND    #$07    
       BNE    LD7DD   
       LDA    $D5     
       AND    #$7F    
       STA    $D5     
LD7DD: DEC    $D7     
       JMP    LD734   
LD7E2: AND    #$3F    
       CMP    #$13    
       BNE    LD7F1   
       LDA    $87     
       AND    #$40    
       ORA    #$80    
       JMP    LD87D   
LD7F1: TAY            
       INC    $87     
       LDA    LDF0B,Y 
       AND    #$0F    
       TAX            
       LDA    $84     
       BIT    $87     
       BVC    LD806   
       CLC            
       ADC    LDF4B,X 
       BCC    LD80A   
LD806: SEC            
       SBC    LDF4B,X 
LD80A: STA    $84     
       LDA    $85     
       AND    #$0F    
       TAX            
       LDA    LDF2B,Y 
       AND    #$04    
       BNE    LD821   
       LDA    $85     
       CLC            
       ADC    LDE6A,X 
       JMP    LD705   
LD821: LDA    $85     
       SEC            
       SBC    LDE69,X 
       JMP    LD705   
LD82A: LDY    $86     
       BMI    LD831   
       JMP    LD8E7   
LD831: CLC            
       ADC    #$01    
       BNE    LD838   
       LDA    #$80    
LD838: STA    $87     
       AND    #$3F    
       TAY            
       CPX    #$88    
       BNE    LD844   
       JMP    LD8D9   
LD844: LDA    $F4     
       BPL    LD869   
       CPY    #$10    
       BCC    LD850   
       CPY    #$2F    
       BCC    LD882   
LD850: LDA    $87     
       ASL    A       
       EOR    $87     
       AND    #$40    
       BNE    LD861   
       CPX    #$60    
       BCC    LD869   
       LDA    #$90    
       BNE    LD87D   
LD861: CPX    #$28    
       BCS    LD869   
       LDA    #$D0    
       BNE    LD87D   
LD869: BIT    $87     
       CPY    #$0F    
       BNE    LD882   
       CPX    $E4     
       BCS    LD879   
       BVS    LD882   
       LDA    #$80    
       BNE    LD87D   
LD879: BVC    LD882   
       LDA    #$C0    
LD87D: STA    $87     
       AND    #$3F    
       TAY            
LD882: BIT    $DE     
       LDA    $86     
       AND    #$07    
       CMP    #$03    
       BCC    LD8A5   
       BVS    LD89D   
       LDA    LDECB,Y 
       AND    #$03    
       CMP    #$03    
       BNE    LD8BE   
       LDA    #$07    
       BNE    LD8BE   
LD89B: BVS    LD8B5   
LD89D: LDA    LDECB,Y 
       LSR    A       
       LSR    A       
       JMP    LD8BC   
LD8A5: CMP    #$02    
       BNE    LD89B   
       BVC    LD8B5   
       LDA    LDF0B,Y 
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       JMP    LD8BE   
LD8B5: LDA    LDECB,Y 
       ROL    A       
       ROL    A       
       ROL    A       
       ROL    A       
LD8BC: AND    #$07    
LD8BE: TAY            
       TXA            
       BIT    $87     
       BVS    LD8CB   
       CLC            
       ADC    LDF4B,Y 
       JMP    LD8CF   
LD8CB: SEC            
       SBC    LDF4B,Y 
LD8CF: BEQ    LD8D5   
       CMP    #$88    
       BCC    LD8D7   
LD8D5: LDA    #$88    
LD8D7: STA    $84     
LD8D9: LDA    $85     
       AND    #$0F    
       TAX            
       LDA    $85     
       CLC            
       ADC    LDE6A,X 
       JMP    LD705   
LD8E7: TYA            
       AND    #$07    
       TAX            
       LDA    LDEA1,X 
       CMP    $85     
       BNE    LD92C   
       TXA            
       BEQ    LD915   
       BIT    $F4     
       BPL    LD91B   
       TYA            
       LSR    A       
       LSR    A       
       LSR    A       
       AND    #$07    
       TAX            
       LDA    $B7     
       JMP    LD907   
LD905: INX            
       ASL    A       
LD907: CPX    #$05    
       BCC    LD905   
       ORA    $A7     
       STA    $A7     
       LDA    #$87    
       STA    $D6     
       BNE    LD927   
LD915: LDA    $D5     
       AND    #$7F    
       STA    $D5     
LD91B: TYA            
       LSR    A       
       LSR    A       
       LSR    A       
       TAY            
       LDA    $A6,X   
       ORA    LDF5B,Y 
       STA    $A6,X   
LD927: DEC    $D7     
       JMP    LD734   
LD92C: LDA    $B0     
       AND    #$0F    
       BNE    LD940   
       LDX    $84     
       BIT    $A5     
       BPL    LD93D   
       DEX            
       STX    $84     
       BNE    LD940   
LD93D: INX            
       STX    $84     
LD940: JMP    LD8D9   
LD943: LDA    INTIM   
       BEQ    LD94C   
       CMP    #$25    
       BCC    LD943   
LD94C: STA    WSYNC   
       LDA    #$02    
       STA    VSYNC   
       STA    VBLANK  
       LDY    #$00    
       STY    $B8     
       STY    $89     
       LDX    #$0D    
LD95C: LDA    $93,X   
       AND    #$0F    
       STA    $93,X   
       DEX            
       BPL    LD95C   
       STY    VSYNC   
       TXS            
       LDA    #$2C    
       STA    TIM64T  
       BIT    $BF     
       BVC    LD974   
       JMP    LDCE1   
LD974: STY    $92     
       STY    $A2     
       STY    $87     
       STY    $F8     
       BIT    $BF     
       BPL    LD990   
       LDA    $B0     
       AND    #$1F    
       BNE    LD988   
       INC    $E2     
LD988: LDX    $E2     
       LDA    LD43A,X 
       JMP    LD996   
LD990: LDA    SWCHA   
       ROL    A       
       ROL    A       
       ROL    A       
LD996: AND    #$03    
       TAY            
       LDA    $E4     
       BIT    $A9     
       BMI    LD9D3   
       CLC            
       ADC    LDFAA,Y 
       CMP    #$08    
       BCS    LD9AB   
       LDA    #$08    
       BNE    LD9B1   
LD9AB: CMP    #$80    
       BCC    LD9B1   
       LDA    #$80    
LD9B1: STA    $E4     
       CLC            
       ADC    #$03    
       TAY            
       AND    #$0F    
       STA    $84     
       TYA            
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       TAX            
       CLC            
       ADC    $84     
       TAY            
       ADC    #$F1    
       BMI    LD9CB   
       TAY            
       INX            
LD9CB: LDA    LDE80,Y 
       ORA    LDE76,X 
       STA    $BB     
LD9D3: BIT    $8A     
       BVS    LDA36   
       LDA    $B0     
       LSR    A       
       BCC    LD9E8   
       AND    #$03    
       CMP    #$02    
       BEQ    LD9E8   
       LDA    $B1     
       BNE    LDA4F   
       BEQ    LDA36   
LD9E8: LDA    $B1     
       BNE    LDA17   
       BIT    $A9     
       BMI    LDA4F   
       BIT    $BF     
       BMI    LDA0F   
       BIT    SWCHB   
       BVC    LDA0B   
       LDA    INPT4   
       BPL    LDA03   
       LDX    #$00    
       STX    $DF     
       BEQ    LDA36   
LDA03: LDX    $DF     
       BMI    LDA36   
       DEC    $DF     
       BNE    LDA0F   
LDA0B: LDA    INPT4   
       BMI    LDA36   
LDA0F: LDA    #$1F    
       STA    $B1     
       STA    $EE     
       BNE    LDA4F   
LDA17: LDA    $8B     
       CMP    #$01    
       BEQ    LDA36   
       SBC    #$06    
       STA    $8B     
       LDA    $DD     
       AND    #$0F    
       TAX            
       LDA    $DD     
       SBC    LDFCD,X 
       STA    $DD     
       JMP    LDA4F   
LDA30: LDA    #$FF    
       STA    $8B     
       BNE    LDA4F   
LDA36: LDA    #$00    
       STA    $B1     
       STA    $EE     
       BIT    $A9     
       BMI    LDA30   
       LDA    #$97    
       STA    $8B     
       LDA    #$D4    
       STA    $DD     
       LDA    $E4     
       CLC            
       ADC    #$09    
       STA    $BC     
LDA4F: LDA    #$80    
       STA    $FD     
       LDY    $BE     
       BMI    LDA5B   
       INY            
       TYA            
       AND    #$07    
LDA5B: STA    $F6     
       LDA    $B5     
       ASL    A       
       ASL    A       
       ASL    A       
       ASL    A       
       ADC    #$23    
       STA    $84     
       LDA    $B0     
       AND    #$01    
       STA    $F7     
       EOR    #$01    
       STA    $F9     
       LDX    #$01    
LDA73: LDY    $D8,X   
       JSR    LDDB4   
       DEX            
       BPL    LDA73   
LDA7B: LDA    $FA     
       CMP    $84     
       BCC    LDA89   
       CMP    #$FF    
       BEQ    LDAC4   
       CMP    #$B3    
       BCC    LDAA6   
LDA89: LDA    #$80    
       STA    $FC     
       LDX    $F9     
       LDA    $85,X   
       CMP    $87     
       BCC    LDB0D   
       CMP    #$0E    
       BEQ    LDA9C   
       CLC            
       ADC    #$01    
LDA9C: LDX    $F7     
       CMP    $85,X   
       BCS    LDAD6   
       LDX    $F9     
       BPL    LDAD6   
LDAA6: LDA    $86     
       CMP    $85     
       BCC    LDAB6   
       BEQ    LDAB6   
       LDX    #$00    
       LDA    #$20    
       STA    $FC     
       BNE    LDAD6   
LDAB6: LDX    #$01    
       LDY    $FC     
       CPY    #$80    
       BNE    LDAD6   
       CMP    $87     
       BCS    LDAD6   
       BCC    LDB0D   
LDAC4: LDA    $86     
       CMP    #$0F    
       BEQ    LDAE2   
       LDX    #$01    
       LDY    $FC     
       CPY    #$20    
       BEQ    LDAD6   
       CMP    $87     
       BCC    LDB0D   
LDAD6: LDA    $89     
       CMP    #$05    
       BNE    LDAE5   
       LDA    $F7     
       BNE    LDAE5   
       INC    $89     
LDAE2: JMP    LDB8A   
LDAE5: LDY    $85,X   
       LDA    $FC,X   
       ORA    $0092,Y 
       STA    $0092,Y 
       CPY    $F6     
       BEQ    LDB19   
LDAF3: INY            
       LDA    $FC,X   
       LSR    A       
       ORA    $0092,Y 
       STA    $0092,Y 
       CPY    $F6     
       BCS    LDB13   
LDB01: INY            
       STY    $87     
       LDA    $82,X   
       LDY    $89     
       INC    $89     
       STA    $00F0,Y 
LDB0D: JSR    LDDAA   
       JMP    LDA7B   
LDB13: BNE    LDB6A   
       LDA    #$80    
       BNE    LDB1B   
LDB19: LDA    #$00    
LDB1B: STA    $A2     
       TXA            
       EOR    #$01    
       TAY            
       LDA    $0085,Y 
       TAY            
       CPY    $F6     
       BEQ    LDB2E   
       INY            
       CPY    $F6     
       BNE    LDB5A   
LDB2E: LDA    $B4     
       BNE    LDB5E   
LDB32: LDY    $F6     
       INY            
       STY    $87     
       LDA    $A2     
       BPL    LDB4D   
       DEY            
       ORA    $0092,Y 
       AND    #$8F    
       STA    $0092,Y 
       DEY            
       LDA    $0092,Y 
       AND    #$3F    
       STA    $0092,Y 
LDB4D: LDY    $89     
       INC    $89     
       LDA    #$80    
       STA    $F6     
       STA    $00F0,Y 
       BNE    LDB0D   
LDB5A: CPX    $F7     
       BNE    LDB32   
LDB5E: LDY    $F6     
       LDA    #$80    
       BIT    $A2     
       STA    $F6     
       BMI    LDB01   
       BPL    LDAF3   
LDB6A: STY    $88     
       LDY    $F6     
       LDA    #$80    
       STA    $F6     
       ORA    $0092,Y 
       STA    $0092,Y 
       STY    $A2     
       LDY    $89     
       STY    $F8     
       INC    $89     
       LDA    #$80    
       STA    $00F0,Y 
       LDY    $88     
       JMP    LDB01   
LDB8A: LDA    $D6     
       AND    #$07    
       STA    $80     
       LDA    $A0     
       ORA    #$10    
       STA    $A0     
       LDA    $92     
       BPL    LDB9E   
       LDA    #$80    
       STA    $B8     
LDB9E: LDA    $F6     
       BMI    LDBB0   
       LDX    $89     
       INC    $89     
       LDA    #$80    
       STA    $F0,X   
       LDX    $F6     
       ORA    $92,X   
       BMI    LDBCA   
LDBB0: LDA    $89     
       CMP    #$06    
       BNE    LDBCC   
       LDA    $F7     
       BNE    LDBBE   
       DEC    $89     
       BPL    LDBCC   
LDBBE: LDX    $F8     
       LDA    #$87    
       STA    $F0,X   
       LDX    $A2     
       LDA    $92,X   
       AND    #$0F    
LDBCA: STA    $92,X   
LDBCC: DEC    $89     
       BPL    LDBD3   
       JMP    LDCE1   
LDBD3: LDX    $89     
       LDA    #$00    
       STA    $8A     
       STA    $81     
       LDA    $F0,X   
       BPL    LDC1D   
       AND    #$0F    
       BNE    LDBCC   
       LDA    $BE     
       TAX            
       AND    #$07    
       TAY            
       LDA    LDE95,Y 
       STA    $85     
       LDA    $BD     
       TAY            
       TXA            
       LSR    A       
       LSR    A       
       BPL    LDC07   
LDBF6: LDA    $D5     
       AND    #$03    
       TAY            
       LDA    $C0,X   
       CLC            
       ADC    LDE3E,Y 
       TAY            
       LDA    $D6     
       AND    #$30    
       LSR    A       
LDC07: LSR    A       
LDC08: LSR    A       
       LSR    A       
       TAX            
       LDA    LDEC2,X 
       SEC            
       SBC    $85     
       STA    $85     
       LDA    #$07    
       SBC    $8A     
       ORA    LDFCD,X 
       JMP    LDCBB   
LDC1D: TAX            
       LDA    $C5,X   
       CMP    #$09    
       BCS    LDC28   
       LDY    #$FF    
       STY    $8A     
LDC28: AND    #$0F    
       STA    $88     
       LDA    $C5,X   
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       TAY            
       LDA    LDF62,Y 
       CLC            
       ADC    $88     
       STA    $85     
       LDA    $CA,X   
       STA    $87     
       LDA    $CF,X   
       STA    $86     
       BIT    $86     
       LDA    $C0,X   
       CPX    $80     
       BNE    LDC67   
       BVC    LDC59   
       LDA    $B7     
       BEQ    LDBF6   
       LDA    $AA     
       EOR    #$80    
       STA    $AA     
       BPL    LDBF6   
LDC59: LDY    $B7     
       LDA    LDE37,Y 
       STA    $81     
       LDA    $C0,X   
       CLC            
       ADC    LDE3F,Y 
       CLV            
LDC67: TAY            
       LDA    $87     
       BMI    LDC82   
       BVS    LDC08   
       AND    #$3F    
       LSR    A       
       LSR    A       
       BIT    $87     
       BVS    LDC7B   
       EOR    #$FF    
       CLC            
       ADC    #$08    
LDC7B: TAX            
       LDA    LDEBA,X 
       JMP    LDCA4   
LDC82: BIT    $86     
       BMI    LDC9A   
       AND    #$3F    
       LDX    #$04    
       SEC            
       SBC    $85     
       CMP    #$10    
       BCS    LDC94   
       LSR    A       
       LSR    A       
       TAX            
LDC94: LDA    LDEC6,X 
       JMP    LDCA4   
LDC9A: AND    #$7F    
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       TAX            
       LDA    LDEB2,X 
LDCA4: SEC            
       SBC    $85     
       STA    $85     
       LDA    #$06    
       SBC    $8A     
       STA    $87     
       LDA    $86     
       AND    #$07    
       TAX            
       LDA    LDE8F,X 
       ORA    $87     
       ORA    $81     
LDCBB: PHA            
       INY            
       INY            
       INY            
       TYA            
       AND    #$0F    
       STA    $84     
       TYA            
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       TAX            
       CLC            
       ADC    $84     
       TAY            
       ADC    #$F1    
       BMI    LDCD4   
       TAY            
       INX            
LDCD4: LDA    LDE80,Y 
       ORA    LDE76,X 
       PHA            
       LDA    $85     
       PHA            
       JMP    LDBCC   
LDCE1: BIT    $BF     
       BVC    LDCE9   
       LDA    #$FD    
       BNE    LDCEB   
LDCE9: LDA    #$FF    
LDCEB: STA    $81     
       STA    $83     
       STA    $85     
       STA    $87     
       STA    $89     
       STA    $A2     
       LDA    #$60    
       AND    $BF     
       BNE    LDD53   
       LDY    #$50    
       SEC            
       LDA    $AC     
       AND    #$F0    
       BNE    LDD0A   
       STY    $80     
       BEQ    LDD0D   
LDD0A: LSR    A       
       STA    $80     
LDD0D: LDA    $AC     
       AND    #$0F    
       BCC    LDD19   
       BNE    LDD19   
       STY    $82     
       BEQ    LDD1E   
LDD19: ASL    A       
       ASL    A       
       ASL    A       
       STA    $82     
LDD1E: LDA    $AD     
       AND    #$F0    
       BCC    LDD2A   
       BNE    LDD2A   
       STY    $88     
       BEQ    LDD2D   
LDD2A: LSR    A       
       STA    $88     
LDD2D: LDA    $AD     
       AND    #$0F    
       BCC    LDD39   
       BNE    LDD39   
       STY    $84     
       BEQ    LDD3E   
LDD39: ASL    A       
       ASL    A       
       ASL    A       
       STA    $84     
LDD3E: LDA    $AE     
       AND    #$F0    
       BCC    LDD4A   
       BNE    LDD4A   
       STY    $86     
       BEQ    LDD4D   
LDD4A: LSR    A       
       STA    $86     
LDD4D: LDA    #$00    
       STA    $A1     
       LDX    #$FC    
LDD53: JMP    LDFF2   
LDD56: LDA    $A6,X   
       AND    #$7F    
       LDY    $BA     
       BEQ    LDD62   
LDD5E: LSR    A       
       DEY            
       BNE    LDD5E   
LDD62: STA    $86     
       AND    #$07    
       TAY            
       LDA    LDF90,Y 
       STA    $8C,X   
       LDA    $86     
       LSR    A       
       LSR    A       
       LSR    A       
       AND    #$0F    
       TAY            
       LDA    LDF80,Y 
       ORA    $8C,X   
       STA    $8C,X   
       RTS            

LDD7C: BIT    $BF     
       BMI    LDDA9   
       SED            
       CLC            
       ADC    $AE     
       STA    $AE     
       LDA    $AD     
       AND    #$F0    
       STA    $A1     
       TYA            
       ADC    $AD     
       STA    $AD     
       AND    #$F0    
       TAY            
       LDA    #$00    
       ADC    $AC     
       STA    $AC     
       CLD            
       BNE    LDDA9   
       CPY    #$70    
       BNE    LDDA9   
       LDA    $A1     
       CMP    #$60    
       BNE    LDDA9   
       INC    $B9     
LDDA9: RTS            

LDDAA: LDY    $82,X   
       LDA    LDEA7,Y 
       CMP    $D8,X   
       BEQ    LDDDD   
       TAY            
LDDB4: STY    $82,X   
       LDA    $00C5,Y 
       BEQ    LDDDD   
       CMP    #$F0    
       BEQ    LDDAA   
       STA    $FA,X   
       LSR    A       
       LSR    A       
       LSR    A       
       LSR    A       
       TAY            
       CPX    #$00    
       BNE    LDDE3   
       LDA    $FA     
       CMP    $84     
       BCC    LDDE3   
       CMP    #$B3    
       BCS    LDDE3   
       AND    #$0F    
       ADC    #$FD    
       BPL    LDDE3   
       DEY            
       BPL    LDDE3   
LDDDD: LDY    #$FF    
       STY    $FA,X   
       LDY    #$0F    
LDDE3: STY    $85,X   
       RTS            

LDDE6: LDY    #$00    
       BEQ    LDDEB   
LDDEA: INY            
LDDEB: LDX    LDF71,Y 
       CPX    $A4     
       BCC    LDDEA   
       STY    $BA     
       RTS            

LDDF5: .byte $00,$C2,$C3,$A5,$B2,$85,$89,$6D,$72,$00,$C4,$C6,$A7,$A6,$87,$89
       .byte $67,$69
LDE07: .byte $00,$00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05
       .byte $05,$05
LDE19: .byte $00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00
       .byte $01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02
LDE37: .byte $00,$00,$00,$08,$00,$10,$08
LDE3E: .byte $F0
LDE3F: .byte $00,$10,$00,$00,$F0,$F0,$F0
LDE46: .byte $0F,$2F,$4F,$6F,$8F,$AF,$CF,$CF
LDE4E: .byte $7F
LDE4F: .byte $7F,$7F,$3F,$1F,$0F,$07,$01,$00,$00,$00,$00,$00,$40,$60
LDE5D: .byte $01,$02,$03,$04,$05
LDE62: .byte $00,$A0,$A0,$C0,$A0,$C0,$C0
LDE69: .byte $05
LDE6A: .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$05
LDE76: .byte $03,$05,$07,$09,$0B,$02,$04,$06,$08,$0A
LDE80: .byte $70,$60,$50,$40,$30,$20,$10,$00,$F0,$E0,$D0,$C0,$B0,$A0,$90
LDE8F: .byte $00,$20,$40,$60,$60,$60
LDE95: .byte $03,$0F,$1B,$27,$33,$3F
LDE9B: .byte $0B,$1B,$2B,$3B,$4B,$5B
LDEA1: .byte $10,$20,$30,$40,$50,$60
LDEA7: .byte $01,$02,$00,$04,$03
LDEAC: .byte $04,$00,$05,$02,$06,$04
LDEB2: .byte $7C,$92,$92,$A8,$A8,$92,$92,$7C
LDEBA: .byte $D4,$50,$66,$7C,$92,$A8,$BE,$EA
LDEC2: .byte $BF,$A9,$BF,$D5
LDEC6: .byte $D4,$EA,$BE,$A8,$92
LDECB: .byte $44,$45,$49,$44,$49,$65,$49,$44,$45,$49,$44,$45,$24,$49,$45,$24
       .byte $45,$24,$45,$20,$24,$25,$20,$20,$25,$20,$04,$20,$01,$00,$00,$00
       .byte $00,$00,$00,$03,$E0,$1C,$E0,$FF,$E0,$FC,$FF,$FC,$E0,$DF,$FC,$DF
       .byte $FC,$DF,$DB,$FC,$DF,$DC,$DB,$DF,$DC,$D9,$BF,$DB,$DC,$DB,$DF,$DC
LDF0B: .byte $20,$30,$31,$31,$31,$31,$31,$21,$31,$31,$21,$31,$21,$30,$20,$20
       .byte $20,$20,$27,$17,$27,$17,$27,$17,$17,$17,$17,$07,$17,$00,$00,$00
LDF2B: .byte $07,$07,$07,$77,$07,$77,$70,$70,$70,$61,$71,$61,$71,$61,$61,$61
       .byte $61,$61,$51,$61,$51,$61,$50,$50,$60,$57,$57,$57,$57,$57,$57,$67
LDF4B: .byte $00,$01,$02,$03,$0A,$FD,$FE,$FF
LDF53: .byte $00,$01,$01,$02,$01,$02,$02,$03
LDF5B: .byte $40
LDF5C: .byte $20,$10,$08
LDF5F: .byte $04,$02,$01
LDF62: .byte $F7,$03,$0F,$1B,$27,$33,$3F,$4B,$57,$63,$6F,$7B,$87,$93,$9F
LDF71: .byte $22,$42,$62,$82,$A2,$C2,$E2,$E2
LDF79: .byte $0B,$1C,$2C,$3D,$4D,$5E,$6E
LDF80: .byte $00,$02,$01,$03,$08,$0A,$09,$0B,$04,$06,$05,$07,$0C,$0E,$0D,$0F
LDF90: .byte $00,$10,$40,$50,$20,$30,$60,$70
LDF98: .byte $BF,$DF,$EF,$F7,$FB,$FD,$FE
LDF9F: .byte $50,$00,$80,$60,$60
LDFA4: .byte $60,$50,$40,$30,$30,$30
LDFAA: .byte $00,$01,$FF
LDFAD: .byte $00,$20,$40,$60,$80,$A0,$C0
LDFB4: .byte $00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$02,$02,$02,$02,$00
       .byte $00,$00,$00,$01,$01
LDFC9: .byte $01,$01,$00,$00
LDFCD: .byte $00,$00,$80,$20,$0A
LDFD2: .byte $02,$00,$01,$04,$03,$06
LDFD8: .byte $00,$04,$02,$05,$03,$01,$00,$03,$06,$00,$01,$04,$07,$00,$02,$05
       .byte $08,$5A,$0F,$10

START:
       STA    $FFF9   
       JMP    LD1C0   
LDFF2: STA    $FFF9   
       JMP    LD000   
LDFF8: .byte $00
LDFF9: .byte $00,$00,$00,$EC,$DF,$EE,$FF
