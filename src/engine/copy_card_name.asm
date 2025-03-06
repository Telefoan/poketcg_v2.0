; copies the name and level of the card at wLoadedCard1 to wDefaultText
; preserves bc and de
; input:
;	a = length in number of tiles (the resulting string will be padded with spaces to match it)
;	[wLoadedCard1] = all of the card's data (card_data_struct)
; output:
;	hl = first empty space at the end of the text string that was stored in wDefaultText
_CopyCardNameAndLevel::
	push bc
	push de
	ld [wCardNameLength], a
	ld hl, wLoadedCard1Name
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wDefaultText
	push de
	call CopyText ; copy card name to wDefaultText
	pop hl ; hl = wDefaultText
	ld a, [hl]
	cp TX_HALFWIDTH
	jr z, _CopyCardNameAndLevel_HalfwidthText

; the name doesn't start with TX_HALFWIDTH
; this doesn't appear to ever be the case (unless caller manipulates wLoadedCard1Name)
	call GetTextLengthInTiles
	ld a, [wCardNameLength]
	sub b ; number of tiles used by the card's name
	ld b, a
	ld h, d
	ld l, e
	; hl = byte immediately after the end of the last character from the card's name in wDefaultText
	
.level_done
	push hl
	ld a, FW_SPACE
.fill_spaces_loop
	ld [hli], a
	dec b
	jr nz, .fill_spaces_loop
	ld [hl], TX_END
	pop hl
	pop de
	pop bc
	ret

; the name starts with TX_HALFWIDTH
; input:
;	hl = wDefaultText (with card name already stored)
_CopyCardNameAndLevel_HalfwidthText:
	ld a, [wCardNameLength]
	inc a ; +1 (because of the control characters)
	add a ; *2 (because each tile holds 2 characters)
	ld b, a
.find_end_text_loop
	dec b
	ld a, [hli]
	or a ; TX_END
	jr nz, .find_end_text_loop
	dec hl
	
	push hl
	ld a, " "
.fill_spaces_loop
	ld [hli], a
	dec b
	jr nz, .fill_spaces_loop
	ld [hl], TX_END
	pop hl
	pop de
	pop bc
	ret
