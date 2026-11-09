extends SceneTree
func _initialize() -> void:call_deferred("run")
func shot(name:String) -> void:
	await create_timer(.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/3lands-v02-"+name+".png")
func run() -> void:
	root.get_node("State").save_path="user://visual-v02.json"
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	await create_timer(.5).timeout
	game.close();await shot("world")
	game.hero.position=Vector3(-6,0,-3);game.interact();await shot("portrait")
	game.atlas();await shot("atlas")
	game.expansion.skills();await shot("skills")
	game.close();game.hero.position=Vector3(-140,0,-140);await shot("streaming")
	game.expansion.enter_dungeon();await shot("dungeon")
	game.expansion.enrichment.stop_audio();game.music.stop();game.effects.stop();game.expansion.battle.stop();game.expansion.foot.stop();await create_timer(.2).timeout
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://visual-v02.json"+suffix)
	quit()
