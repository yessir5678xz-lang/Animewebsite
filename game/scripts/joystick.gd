extends Control
func _draw() -> void:
	draw_circle(Vector2.ZERO,65,Color(.06,.12,.17,.5))
	draw_arc(Vector2.ZERO,65,0,TAU,64,Color(.8,.74,.5,.65),2,true)
	draw_circle(Vector2.ZERO,22,Color(.75,.8,.75,.35))
	for dir in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		draw_line(dir*39,dir*50,Color(.8,.8,.7,.6),3,true)
