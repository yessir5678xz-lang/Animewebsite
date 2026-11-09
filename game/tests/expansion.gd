extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var state=root.get_node("State")
	state.save_path="user://expansion-test.json"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(state.save_path+suffix)
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	await process_frame
	game.set_process(false);game.close()
	var ex=game.expansion;ex.set_process(false);ex.streaming.set_process(false)
	var r=ex.rules
	state.level=3
	assert(r.learn("vigor"));assert(r.max_health()==155)
	assert(not r.learn("invalid"))
	state.gold=0;assert(not r.purchase("bow"))
	state.gold=5000
	for id in r.data.weapons:
		if id!="sword":assert(r.purchase(id))
		state.rpg.weapon=id;ex.apply_appearance()
		game.cooldown=0;game.stamina=100;game.panel.hide()
		var e=game.enemies[0];game.hero.position=e.node.position+Vector3(1,0,0)
		ex.strike(false)
		assert(game.cooldown>0)
	assert(not r.purchase("bow"))
	assert(r.accept("mara_ore"));state.ore=4;assert(not r.claim("mara_ore"))
	state.ore=5;assert(r.claim("mara_ore"));assert(state.ore==0);assert(not r.claim("mara_ore"))
	assert(r.accept("bell_names"));state.rpg.progress.kill_1+=100;assert(not r.claim("bell_names"))
	state.rpg.progress.kill_0+=6;assert(r.claim("bell_names"))
	state.ore=30;assert(r.building("mine"));assert(not r.building("invalid"))
	state.elapsed=240;r.economy_tick();var treasury=state.rpg.settlement.treasury;assert(treasury==8);r.economy_tick();assert(state.rpg.settlement.treasury==treasury)
	game.hero.position=Vector3(8,0,-10);game.hp=87;game.mana=61
	ex.capture();assert(state.save_game());assert(state.load_game())
	game.hero.position=Vector3.ZERO;ex.restore_resume();assert(game.hero.position.x==8);assert(game.hp==87)
	# Recovered data must retain the new RPG fields and reject corrupt nested values.
	var bad=state.snapshot().duplicate(true);bad.rpg.skills.vigor="broken";assert(not state.valid_save(bad))
	var legacy=state.snapshot().duplicate(true);legacy.erase("rpg");assert(state.valid_save(legacy))
	var f=FileAccess.open(state.save_path,FileAccess.WRITE);f.store_string(JSON.stringify(legacy));f.close();assert(state.load_game());assert(state.rpg.weapon=="sword")
	game.hero.position=Vector3(250,0,-250);game.close();ex.streaming._process(.1)
	assert(ex.streaming.chunks.size()==9)
	var loaded=ex.streaming.chunks.values()[0]
	game.hero.position=Vector3(-450,0,150);ex.streaming._process(.1);assert(ex.streaming.chunks.size()==9)
	assert(not loaded in ex.streaming.chunks.values())
	ex.enter_dungeon();assert(ex.dungeon);assert(game.hero.position.x==3500)
	for e in game.enemies.duplicate():game.damage(e,10000)
	assert(state.rpg.progress.dungeon_0==1)
	ex.leave_dungeon();assert(not ex.dungeon);assert(game.hero.position.x==20)
	game.credits();game.graphics_settings();ex.hub();ex.equipment();ex.skills();ex.contracts();ex.companions();ex.settlement();ex.appearance();ex.local_map();game.close()
	game.music.stop();game.effects.stop();game.expansion.battle.stop();game.expansion.foot.stop()
	await create_timer(.2).timeout
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(state.save_path+suffix)
	print("PASS: ten weapon types, skill points, transactions, local faction contracts, settlement income, full saves, legacy migration, streamed chunks, dungeon completion, RPG UI")
	quit()
