.INCLUDE "header.inc"
.INCLUDE "InitSNES.asm"
.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"
SpriteData:
  .INCBIN "main.vram"
ColorData:
  .INCBIN "main.pal"
Start:
  InitSNES
  ; STZ $2121
  ; LDA #%00011111
  ; STA $2122
  ; STZ $2122
  ; LDA #$0F ; Enable screen in full brightness
  ; STA $2100
  STZ $2116
  STZ $2117
  LDA #$80
  STA $2115
  LDX #$00
  LDA # (256 / 2 - 8)
  STA $00
  LDA # (224 / 2 - 8)
  STA $01
  STZ $02
  STZ $03
  JMP VRAMLoop
.16BIT
VRAMLoop:
  LDA SpriteData, X
  STA $2118
  INX
  LDA SpriteData, X
  STA $2119
  INX
  CPX #$80
  BCC VRAMLoop
  LDA #$80
  STA $2121
  LDX #$00
CGRAMLoop:
  LDA ColorData, X
  STA $2122
  INX
  LDA ColorData, X
  STA $2122
  INX
  CPX #$20
  BCC CGRAMLoop
  ; OAM Data Setup
  ; STZ $2102
  ; STZ $2103
  ; OAM Data for first sprite
  ; LDA # (256 / 2 - 8) ; Horizontal Position
  ; STA $2104
  ; LDA # (224 / 2 - 8) ; Vertical Position
  ; STA $2104
  ; LDA #$00 ; Sprite Name
  ; STA $2104
  ; STZ $2104 ; Sprite Name
  ; STZ $2104 ; No Flip, Prio 0, Palette 0
  ; OAM Data for second sprite
  ; STZ $2104 ; Horizontal Position
  ; STZ $2104 ; Vertical Position
  ; LDA #$01 ; Sprite Name
  ; STA $2104
  ; STZ $2104 ; No Flip, Prio 0, Palette 0
  ; Make objects visible
  LDA #$10
  STA $212C
  ; Enable screen in full brightness
  LDA #$0F
  STA $2100
  ; Enable NMI VBlank
  ; LDA #$80
  ; STA $4200
  ; Enable NMI VBlank and auto-joypad read
  LDA #$81
  STA $4200
.8BIT
GameLoop:
  WAI
  ; To know which bit, go to https://www.chibiakumas.com/6502/platform2.php#LessonP15 and scroll down to "The SNES Hardware" and look at JOY1H.
  LDA $4219
  AND #%00000001
  BNE IncreasePlayerX
GameLoopAfterCheckedIncreasePlayerX:
  LDA $4219
  AND #%00000010
  BNE DecreasePlayerX
GameLoopAfterCheckedDecreasePlayerX:
  LDA $4219
  AND #%00001000
  BNE DecreasePlayerY
GameLoopAfterCheckedDecreasePlayerY:
  LDA $4219
  AND #%00000100
  BNE IncreasePlayerY
GameLoopAfterCheckedIncreasePlayerY:
  LDA $02
  CMP $00
  BEQ GameLoopContinueToEnemyY
  BCC IncreaseEnemyX
  BCS DecreaseEnemyX
GameLoopContinueToEnemyY:
  LDA $03
  CMP $01
  BEQ GameLoopContinueAfterEnemyY
  BCC IncreaseEnemyY
  BCS DecreaseEnemyY
GameLoopContinueAfterEnemyY:
  JMP GameLoop
IncreasePlayerX:
  INC $00
  JMP GameLoopAfterCheckedIncreasePlayerX
DecreasePlayerX:
  DEC $00
  JMP GameLoopAfterCheckedDecreasePlayerX
DecreasePlayerY:
  DEC $01
  JMP GameLoopAfterCheckedDecreasePlayerY
IncreasePlayerY:
  INC $01
  JMP GameLoopAfterCheckedIncreasePlayerY
IncreaseEnemyX:
  INC $02
  JMP GameLoop
DecreaseEnemyX:
  DEC $02
  JMP GameLoop
DecreaseEnemyY:
  DEC $03
  JMP GameLoop
IncreaseEnemyY:
  INC $03
  JMP GameLoop
NMIHandler:
  LDA $4210 ; NMI Status
  PHP
  SEP #$20
  STZ $2102
  STZ $2103
  LDA $00
  STA $2104
  LDA $01
  STA $2104
  STZ $2104
  STZ $2104
  STZ $2104
  STA $2102
  LDA $02
  STA $2104
  LDA $03
  STA $2104
  LDA #$01
  STA $2104
  STZ $2104
  STZ $2104
  PLP
  RTI
.ENDS
