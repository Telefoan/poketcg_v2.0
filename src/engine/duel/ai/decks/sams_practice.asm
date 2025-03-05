; AI for Sam's practice duel, which handles his scripted actions.
; will act as a normal duelist AI after turn 7.
AIActionTable_SamPractice:
	dw AIDoTurn_SamsPractice              ; .do_turn (unused)
	dw AIDoTurn_SamsPractice              ; .do_turn
	dw SetSamsStartingPlayArea            ; .start_duel
	dw AIDecideForcedSwitch_SamsPractice  ; .forced_switch
	dw AIDecideSwitchAfterKO_SamsPractice ; .ko_switch
	dw AIPickPrizeCards                   ; .take_prize


; used to know whether Sam's AI is still doing scripted turns.
; preserves all registers except af
; output:
;	carry = set:  if the AI has taken at least 7 turns
IsAIPracticeScriptedTurn:
	ld a, [wDuelTurns]
	srl a
	cp 7
	ccf
	ret


; puts one Machop from the hand into the play area
; and sets the number of Prize cards to 2.
SetSamsStartingPlayArea:
	call CreateHandCardList
	ld hl, wDuelTempList
.loop_hand
	ld a, [hli]
	ldh [hTempCardIndex_ff98], a
	cp $ff
	ret z
	call _GetCardIDFromDeckIndex
	ld a, [wLoadedCard1ID + 0]
	ld e, a
	ld a, [wLoadedCard1ID + 1]
	ld d, a
	cp16 MACHOP
	jr nz, .loop_hand
	ldh a, [hTempCardIndex_ff98]
	call PutHandPokemonCardInPlayArea
	ld a, 2
	ld [wDuelInitialPrizes], a
	ret

; outputs in a Play Area location of Raticate or Rattata
; in the Bench. If neither is found, just output PLAY_AREA_BENCH_1.
GetPlayAreaLocationOfRaticateOrRattata:
	ld de, RATICATE
	ld b, PLAY_AREA_BENCH_1
	call LookForCardIDInPlayArea_Bank5
	cp $ff
	jr nz, .found
	ld de, RATTATA
	ld b, PLAY_AREA_BENCH_1
	call LookForCardIDInPlayArea_Bank5
	cp $ff
	jr nz, .found
	ld a, PLAY_AREA_BENCH_1
.found
	ldh [hTempPlayAreaLocation_ff9d], a
	ret

AIDoTurn_SamsPractice:
	call IsAIPracticeScriptedTurn
	jp c, AIMainTurnLogic ; use default logic if no longer scripted
;	fallthrough

; has AI execute some scripted actions depending on the current turn number.
AIPerformScriptedTurn:
	ld a, [wDuelTurns]
	srl a
	ld hl, .scripted_actions_list
	call JumpToFunctionInTable

; always attack with the Active Pokémon's first attack.
; if it's unusable, then end the turn without attacking.
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a ; PLAY_AREA_ARENA
	ld [wSelectedAttack], a ; FIRST_ATTACK_OR_PKMN_POWER
	call CheckIfSelectedAttackIsUnusable
	jp nc, AITryUseAttack
	; unusable
	ld a, OPPACTION_FINISH_NO_ATTACK
	bank1call AIMakeDecision
	ret

.scripted_actions_list
	dw .turn_1
	dw .turn_2
	dw .turn_3
	dw .turn_4
	dw .turn_5
	dw .turn_6
	dw .turn_7

.turn_1
	ld bc, MACHOP
	ld de, FIGHTING_ENERGY
	call AIAttachEnergyInHandToCardInPlayArea
	jp AIAttachEnergyInHandToCardInPlayArea

.turn_2
	ld de, RATTATA
	call LookForCardIDInHandList_Bank5
	ldh [hTemp_ffa0], a
	ld a, OPPACTION_PLAY_BASIC_PKMN
	bank1call AIMakeDecision
	ld bc, RATTATA
	ld de, FIGHTING_ENERGY
	jp AIAttachEnergyInHandToCardInPlayArea

.turn_3
	ld de, RATTATA
	ld b, PLAY_AREA_ARENA
	call LookForCardIDInPlayArea_Bank5
	ldh [hTempPlayAreaLocation_ffa1], a
	ld de, RATICATE
	call LookForCardIDInHandList_Bank5
	ldh [hTemp_ffa0], a
	ld a, OPPACTION_EVOLVE_PKMN
	bank1call AIMakeDecision
	ld bc, RATICATE
	ld de, LIGHTNING_ENERGY
	jp AIAttachEnergyInHandToCardInPlayArea

.turn_4
	ld bc, RATICATE
	ld de, LIGHTNING_ENERGY
	jp AIAttachEnergyInHandToCardInPlayArea

.turn_5
	ld de, MACHOP
	call LookForCardIDInHandList_Bank5
	ldh [hTemp_ffa0], a
	ld a, OPPACTION_PLAY_BASIC_PKMN
	bank1call AIMakeDecision
	ld bc, MACHOP
	ld de, FIGHTING_ENERGY
	call AIAttachEnergyInHandToCardInBench

	ld a, DUELVARS_ARENA_CARD
	get_turn_duelist_var
	call _GetCardIDFromDeckIndex
	cp16 MACHOP
	ld a, PLAY_AREA_BENCH_1
	jr nz, .retreat
	inc a ; PLAY_AREA_BENCH_2
.retreat
	jp AITryToRetreat

.turn_6
	ld bc, MACHOP
	ld de, FIGHTING_ENERGY
	jp AIAttachEnergyInHandToCardInPlayArea

.turn_7
	ld bc, MACHOP
	ld de, FIGHTING_ENERGY
	jp AIAttachEnergyInHandToCardInPlayArea


AIDecideForcedSwitch_SamsPractice:
	call IsAIPracticeScriptedTurn
	jp c, AIDecideBenchPokemonToSwitchTo ; use default logic if no longer scripted
;	fallthrough

AIDecideSwitchAfterKO_SamsPractice:
	call IsAIPracticeScriptedTurn
	jp c, AIDecideBenchPokemonToSwitchTo ; use default logic if no longer scripted
;	fallthrough

; preserves de
; output:
;	a = play area location offset of a Benched Raticate or Rattata
;	  = PLAY_AREA_BENCH_1:  if there are no Rattata or Raticate on the Bench
.GetPlayAreaLocationOfRaticateOrRattata
	ld a, RATICATE
	ld b, PLAY_AREA_BENCH_1
	call LookForCardIDInPlayArea_Bank5
	jr c, .found
	ld a, RATTATA
	ld b, PLAY_AREA_BENCH_1
	call LookForCardIDInPlayArea_Bank5
	jr c, .found
	ld a, PLAY_AREA_BENCH_1
.found
	ldh [hTempPlayAreaLocation_ff9d], a
	ret
