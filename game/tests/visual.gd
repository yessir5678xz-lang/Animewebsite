extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.get_node("State").save_path="user://visual-covenant.json"
	var game=load("res://scenes/main.tscn").instantiate();root.add_child(game)
	await create_timer(1).timeout
	game.close()
	for i in range(3):
		game.load_land(i)
		await create_timer(1).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/three-lands-%d.png"%i)
	game.expansion.enrichment.stop_audio();game.music.stop()
	game.effects.stop()
	game.expansion.battle.stop()
	game.expansion.foot.stop()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	quit()
