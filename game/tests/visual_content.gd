extends SceneTree
func _initialize() -> void:call_deferred("run")
func shot(name:String) -> void:
	await create_timer(3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/3lands-v03-"+name+".png")
	print("CAPTURE ",name," memory_static=",Performance.get_monitor(Performance.MEMORY_STATIC)," draw_calls=",Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)," objects=",Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
func run() -> void:
	var state=root.get_node("State");state.save_path="user://visual-v03.json"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(state.save_path+suffix)
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame;game.close()
	state.elapsed=90;state.rpg.adaptive=false;state.rpg.preset=2;game.expansion.apply_quality()
	for land in range(3):
		game.load_land(land);game.close();await shot("camp"+str(land))
		game.hero.position=Vector3(-144,0,-144);game.expansion.streaming._process(.1);game.expansion.enrichment.cinematic=0;game.expansion.enrichment.survey_label.hide();game.expansion.enrichment.progress().seen.append(str(land)+":0")
		await shot("region"+str(land))
		game.expansion.enrichment.show_site(str(land)+":0");await shot("story"+str(land));game.close()
	game.load_land(1);state.rpg.preset=4;game.expansion.apply_quality();await shot("maximum")
	game.expansion.enter_dungeon();await shot("dungeon")
	game.expansion.enrichment.stop_audio();game.music.stop();game.effects.stop();game.expansion.battle.stop();game.expansion.foot.stop();await create_timer(.3).timeout
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(state.save_path+suffix)
	quit()
