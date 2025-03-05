INCLUDE "data/auto_deck_card_lists.asm"
INCLUDE "data/auto_deck_machines.asm"

; writes to sAutoDecks all the deck configurations
; from the Auto Deck Machine in wCurAutoDeckMachine
ReadAutoDeckConfiguration:
	call EnableSRAM
	ld a, [wCurAutoDeckMachine]
	ld l, a
	ld h, 6 * NUM_DECK_MACHINE_SLOTS
	call HtimesL
	ld bc, AutoDeckMachineEntries
	add hl, bc
	ld b, 0 ; initial index (first deck)
.loop_decks
	push hl
	ld l, b
	ld h, DECK_STRUCT_SIZE
	call HtimesL
	ld de, sAutoDecks
	add hl, de
	ld d, h
	ld e, l
	pop hl
	; de = pointer for sAutoDecksX, where X is b + 1
	; hl = card list pointer from AutoDeckMachineEntries

; write the deck configuration in SRAM by reading the given deck list
	push hl
	push bc
	push de
	push de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	; de = initial card list address from AutoDeckMachineEntries
	; hl = pointer for sAutoDecksX, where X is b + 1
	ld bc, DECK_NAME_SIZE
	add hl, bc


; outputs in de the saved deck with index b
.GetPointerToSRAMAutoDeck
	push hl
	ld l, b
	ld h, DECK_COMPRESSED_STRUCT_SIZE
	call HtimesL
	ld de, sAutoDecks
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ret

; writes the deck configuration in SRAM
; by reading the given deck card list
.ReadDeckConfiguration
	push hl
	push bc
	push de
	push de
	ld e, [hl]
	inc hl
	ld d, [hl]
	
	ld hl, wCurDeckCards
.loop_create_deck
	ld a, [de]
	inc de
	ld b, a ; card count
	or a
	jr z, .done_create_deck
	ld a, [de]
	inc de
	ld c, a ; card ID
	ld a, [de]
	inc de
.loop_card_count
	ld [hl], c
	inc hl
	ld [hli], a
	dec b
	jr nz, .loop_card_count
	jr .loop_create_deck

.done_create_deck
	xor a
	ld [hli], a
	ld [hl], a

	pop hl
	ld de, DECK_NAME_SIZE
	add hl, de
	; hl = destination
	ld de, wCurDeckCards
	call CompressDeckToSRAM
	pop de
	pop bc
	pop hl
	inc hl
	inc hl
	ret

.ReadDeckName
	push hl
	push bc
	push de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wDismantledDeckName
	call CopyText
	pop hl
	ld de, wDismantledDeckName
.loop_copy_name
	ld a, [de]
	ld [hli], a
	or a
	jr z, .done_copy_name
	inc de
	jr .loop_copy_name
.done_copy_name
	pop bc
	pop hl
	inc hl
	inc hl
	ret
