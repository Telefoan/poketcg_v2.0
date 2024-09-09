AIActionTable_RockCrusher:
	dw AIMainTurnLogic                ; .do_turn (unused)
	dw AIMainTurnLogic                ; .do_turn
	dw .start_duel
	dw AIDecideBenchPokemonToSwitchTo ; .forced_switch
	dw AIDecideBenchPokemonToSwitchTo ; .ko_switch
	dw AIPickPrizeCards               ; .take_prize

.start_duel
	call InitAIDuelVars
	call .store_list_pointers
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	jp AIPlayInitialBasicCards

.list_arena
	dw RHYHORN
	dw ONIX
	dw GEODUDE
	dw DIGLETT
	dw NULL

.list_bench
	dw DIGLETT
	dw GEODUDE
	dw RHYHORN
	dw ONIX
	dw NULL

.list_retreat
	ai_retreat DIGLETT, -1
	dw NULL

.list_energy
	ai_energy DIGLETT,  3, +1
	ai_energy DUGTRIO,  4, +0
	ai_energy GEODUDE,  2, +1
	ai_energy GRAVELER, 3, +0
	ai_energy GOLEM,    4, +0
	ai_energy ONIX,     2, -1
	ai_energy RHYHORN,  3, +0
	dw NULL

.list_prize
	dw ENERGY_REMOVAL
	dw RHYHORN
	dw NULL

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret
