extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.remove_absolute("user://test-covenant.json")
	DirAccess.remove_absolute("user://test-covenant.json.bak")
	root.get_node("State").save_path="user://test-covenant.json"
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.close()
	game.set_process(false)
	var state=root.get_node("State")
	state.quests=[0,0,0];state.decisions=[0,0,0]
	game.choose(1)
	assert(state.quests[0]==1)
	var enemy=game.enemies[0]
	game.hero.position=enemy.node.position+Vector3(1,0,0)
	var before=enemy.hp
	game.attack(false)
	assert(enemy.hp<before)
	game.cooldown=0;game.spell()
	assert(game.mana==70)
	game.invulnerable=0;game.blocking=false
	var hp=game.hp;game.hurt(10);assert(game.hp<hp)
	game.dodge();hp=game.hp;game.hurt(10);assert(game.hp==hp)
	var touch=InputEventScreenTouch.new();touch.index=0;touch.position=Vector2(120,400);touch.pressed=true;game._input(touch)
	var drag=InputEventScreenDrag.new();drag.index=0;drag.position=Vector2(180,400);game._input(drag);assert(game.stick.x>0)
	touch.pressed=false;game._input(touch);assert(game.stick==Vector2.ZERO)
	state.gold=777;assert(state.save_game());state.gold=0;assert(state.load_game());assert(state.gold==777)
	assert(state.save_game())
	var f=FileAccess.open("user://test-covenant.json",FileAccess.WRITE);f.store_string("interrupted");f.close()
	assert(state.load_game());assert(state.gold==777)
	for i in range(3):
		game.load_land(i)
		await process_frame
		assert(game.enemies.size()>0)
		for e in game.enemies.duplicate():
			if e.boss:game.damage(e,10000)
		assert(state.quests[i]==2)
	game.journal();assert(game.panel.visible)
	print("PASS: startup, touch input, combat, magic, dodge, branching quest, save recovery, three lands, bosses, ending")
	for path in ["user://test-covenant.json","user://test-covenant.json.bak","user://test-covenant.json.tmp"]:DirAccess.remove_absolute(path)
	game.music.stop()
	game.effects.stop()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	quit()
