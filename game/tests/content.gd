extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var state=root.get_node("State");var library=root.get_node("Library")
	state.save_path="user://content-test.json"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(state.save_path+suffix)
	var model_count=0;var clips=0
	for entry in library.catalog.models:
		assert(ResourceLoader.exists(entry.path),entry.path)
		var model=library.model(entry.id);assert(model is Node3D);model.free();model_count+=1;clips+=entry.animations.size()
	assert(model_count>=791);assert(clips>=400)
	for id in ["blocky-characters/character-a","graveyard-kit/character-skeleton","graveyard-kit/character-ghost","mini-dungeon/character-orc"]:
		var actor=Node3D.new();actor.set_script(load("res://scripts/animated_actor.gd"));root.add_child(actor);actor.build(id)
		assert(is_equal_approx(actor.model_bounds(actor.get_node("Model"),Transform3D.IDENTITY).size.y,2.2))
		actor.queue_free()

	assert(library.surfaces.size()==42)
	for surface in library.surfaces:
		for map in surface.maps:assert(ResourceLoader.exists(map.path),map.path)
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.close()
	var ex=game.expansion;ex.set_process(false);ex.streaming.set_process(false);var en=ex.enrichment;en.set_process(false)
	assert(en.regions.size()==45)
	ex.projectile(Vector3.ZERO,Vector3.FORWARD,true,1,Color.WHITE)
	var reused=ex.bolts[-1].node;ex.release_projectile(ex.bolts[-1])
	ex.projectile(Vector3.ONE,Vector3.FORWARD,true,1,Color.RED);assert(ex.bolts[-1].node==reused)
	var invalid_enemy=state.snapshot().duplicate(true);invalid_enemy.rpg.chunks["0:1:1"]=[{"pos":[1,1],"hp":10,"style":123}];assert(not state.valid_save(invalid_enemy))
	var before=state.gold;assert(en.resolve_site("0:0",1));assert(state.gold>before);before=state.gold;assert(not en.resolve_site("0:0",2));assert(state.gold==before)
	assert(not en.resolve_site("0:6",1))
	var r=en.regions[6];game.hero.position=Vector3((r.cell[0]+.5)*96,0,(r.cell[1]+.5)*96);ex.streaming._process(.1)
	en.start_trial(r);var trial_count=0
	for e in game.enemies:
		if e.get("trial")==r.id:trial_count+=1
	assert(trial_count==3)
	ex.streaming.capture();var c=Vector2i(r.cell[0],r.cell[1]);ex.streaming.unload_chunk(c);ex.streaming.load_chunk(c)
	trial_count=0
	for e in game.enemies.duplicate():
		if e.get("trial")==r.id:trial_count+=1;game.damage(e,10000)
	assert(trial_count==3);assert(en.progress().trials.has(r.id));assert(en.resolve_site(r.id,1))
	assert(state.save_game());assert(state.load_game());assert(state.rpg.enrichment.choices["0:0"]==1)
	var old=state.snapshot().duplicate(true);old.rpg.erase("enrichment");assert(state.valid_save(old))
	var f=FileAccess.open(state.save_path,FileAccess.WRITE);f.store_string(JSON.stringify(old));f.close();assert(state.load_game());assert(state.rpg.enrichment.choices.is_empty())
	var bad=state.snapshot().duplicate(true);bad.rpg.enrichment.choices["999:1"]=1;assert(not state.valid_save(bad))
	for p in range(5):state.rpg.preset=p;ex.apply_quality();assert(state.valid_save(state.snapshot()))
	state.rpg.preset=1
	for land in range(3):
		game.load_land(land);game.close();en.set_process(false)
		for region in en.regions:
			if int(region.land)!=land:continue
			var cell=Vector2i(region.cell[0],region.cell[1]);assert(en.region_at(cell).id==region.id)
			var chunk=Node3D.new();game.world.add_child(chunk)
			var ground=MeshInstance3D.new();ground.mesh=BoxMesh.new();chunk.add_child(ground)
			en.decorate_chunk(chunk,Vector3.ZERO,cell,ground)
			assert(chunk.has_meta("obstacles"));chunk.queue_free();await process_frame
		game.hero.position=Vector3.ZERO
		for style in ["ranger","hexer","charger"]:
			game.spawn_enemy(Vector3(0,0,10),false,style);var e=game.enemies[-1];e.clock=4
			assert(en.enemy_action(e,.1,10));assert(e.clock==0)
		game.hero.animate_attack("slash");assert(game.hero.player.has_animation("attack-melee-right"));game.hero.gesture("sit");assert(game.hero.current=="sit")
	game.expansion.enrichment.stop_audio();game.music.stop();game.effects.stop();ex.battle.stop();ex.foot.stop();en.score.stop();en.atmosphere.stop()
	await create_timer(.3).timeout
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(state.save_path+suffix)
	print("PASS: 791 models, imported clips, 42 surfaces, 45 region compositions, one-time choices, trial save/streaming, v0.2 migration, five presets, enemy archetypes")
	quit()
