extends Node3D
const ArtFactory = preload("res://scripts/art.gd")
var lands:Array
var world:Node3D
var hero:Node3D
var ally:Node3D
var camera:Camera3D
var sun:DirectionalLight3D
var environment:WorldEnvironment
var hud:CanvasLayer
var stats:Label
var objective:Label
var notice:Label
var panel:PanelContainer
var body:VBoxContainer
var music:AudioStreamPlayer
var effects:AudioStreamPlayer
var enemies:Array = []
var pickups:Array = []
var hp := 100.0
var stamina := 100.0
var mana := 100.0
var cooldown := 0.0
var invulnerable := 0.0
var blocking := false
var block_time := 0.0
var direction := Vector3(0,0,-1)
var stick := Vector2.ZERO
var stick_id := -1
var stick_start := Vector2.ZERO
var time := 0.0
var auto_timer := 0.0
var combo := 0
var message_timer := 0.0
var map_open := false
var touch_buttons:Array = []
func _ready() -> void:
	lands=JSON.parse_string(FileAccess.get_file_as_string("res://data/lands.json"))
	State.load_game()
	get_tree().auto_accept_quit=false
	setup_ui()
	music=AudioStreamPlayer.new();add_child(music)
	effects=AudioStreamPlayer.new();add_child(effects)
	load_land(State.land)
	intro()
func button(text:String,call:Callable,parent:Node=null) -> Button:
	if parent == null: parent = body
	var b=Button.new();b.text=text;b.custom_minimum_size=Vector2(0,44);b.pressed.connect(call);parent.add_child(b)
	return b
func setup_ui() -> void:
	hud=CanvasLayer.new();add_child(hud)
	var root=Control.new();root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.mouse_filter=Control.MOUSE_FILTER_IGNORE;hud.add_child(root)
	var theme=Theme.new();theme.default_font_size=19
	var style=StyleBoxFlat.new();style.bg_color=Color("14232eee");style.border_color=Color("b9a273");style.set_border_width_all(1);style.set_corner_radius_all(8);style.content_margin_left=16;style.content_margin_right=16;style.content_margin_top=8;style.content_margin_bottom=8
	theme.set_stylebox("normal","Button",style);theme.set_stylebox("panel","PanelContainer",style)
	var hover=style.duplicate();hover.bg_color=Color("35545a");theme.set_stylebox("hover","Button",hover);theme.set_stylebox("pressed","Button",hover)
	root.theme=theme
	stats=Label.new();stats.position=Vector2(26,18);root.add_child(stats)
	objective=Label.new();objective.position=Vector2(26,78);root.add_child(objective)
	notice=Label.new();notice.position=Vector2(320,600);notice.size=Vector2(650,60);notice.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;root.add_child(notice)
	var menu=HBoxContainer.new();menu.position=Vector2(815,18);root.add_child(menu)
	button("JOURNAL",journal,menu);button("PACK",inventory,menu);button("ATLAS",atlas,menu);button("☰",settings,menu)
	var movement=Label.new();movement.text="WASD / drag left side to move\nJ attack · K heavy · L spell · Space evade\nB block · E interact · H heal";movement.position=Vector2(26,610);root.add_child(movement)
	var actions=GridContainer.new();actions.columns=3;actions.position=Vector2(880,530);root.add_child(actions)
	for entry in [["STRIKE",func(): attack(false)],["HEAVY",func(): attack(true)],["SPELL",spell],["EVADE",dodge],["SPEAK",interact],["HEAL",heal]]:
		var b=button(entry[0],entry[1],actions);b.custom_minimum_size=Vector2(115,57);touch_buttons.append(b)
	var guard=button("HOLD GUARD",func(): pass,actions);guard.button_down.connect(func(): blocking=true;block_time=0);guard.button_up.connect(func(): blocking=false)
	var pad=Control.new();pad.set_script(load("res://scripts/joystick.gd"));pad.position=Vector2(150,500);pad.mouse_filter=Control.MOUSE_FILTER_IGNORE;root.add_child(pad)
	panel=PanelContainer.new();panel.position=Vector2(280,100);panel.size=Vector2(720,510);root.add_child(panel)
	var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(700,500);panel.add_child(scroll)
	body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(body)
func open_panel(title:String,text:String) -> void:
	for child in body.get_children(): body.remove_child(child);child.queue_free()
	panel.show();stick=Vector2.ZERO;blocking=false
	var heading=Label.new();heading.text=title;heading.add_theme_font_size_override("font_size",28);body.add_child(heading)
	var label=Label.new();label.text=text;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.custom_minimum_size.x=650;body.add_child(label)
func close() -> void: panel.hide()
func intro() -> void:
	open_panel("3LANDS\nDEATH, BEAUTY & PROSPERITY","THE BROKEN COVENANT · Chapter One\n\nThree kingdoms. One stolen future. You are the Wayfarer, the only soul whose name the Covenant cannot erase. Find each keeper, defeat the three wardens, and decide who inherits their power.\n\nExplore the frontier. Speak to the keeper by the turquoise lantern. Collect ore and defeat wanderers to strengthen your blade. Red circles warn of incoming attacks; dodge or time your guard.")
	button("CONTINUE THE JOURNEY",close)
func load_land(index:int) -> void:
	State.land=index
	if is_instance_valid(world): remove_child(world);world.queue_free()
	enemies.clear();pickups.clear()
	world=Node3D.new();add_child(world)
	var data=lands[index];var base=Color(data.color);var accent=Color(data.accent)
	environment=WorldEnvironment.new();world.add_child(environment)
	var env=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color(data.sky);env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("a2b4cb");env.ambient_light_energy=.65;env.fog_enabled=true;env.fog_light_color=Color(data.sky);env.fog_density=.009;environment.environment=env
	sun=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-55,-30,0);sun.light_color=Color("ffe5b2");sun.shadow_enabled=State.quality>0;world.add_child(sun)
	var ground=ArtFactory.box(world,Vector3(0,-.6,0),Vector3(190,1,190),base.darkened(.25))
	ground.material_override=load("res://assets/terrain.tres")
	ground.material_override=ground.material_override.duplicate()
	ground.material_override.set_shader_parameter("tint",base.darkened(.18))
	ArtFactory.box(world,Vector3(0,-.05,-26),Vector3(7,.15,125),base.lightened(.22))
	ArtFactory.box(world,Vector3(0,-.04,0),Vector3(45,.16,5),base.lightened(.18))
	var rng=RandomNumberGenerator.new();rng.seed=9128+index*100
	for i in range(210):
		var p=Vector3(rng.randf_range(-90,90),0,rng.randf_range(-90,90))
		if absf(p.x)<7 or p.length()<14: continue
		var h=rng.randf_range(3,9)
		if index==2:
			ArtFactory.box(world,p+Vector3(0,h/2,0),Vector3(3,h,3),base.lightened(rng.randf_range(.0,.3)))
			ArtFactory.cone(world,p+Vector3(0,h+1,0),2.5,2,accent.darkened(.4))
		else:
			ArtFactory.box(world,p+Vector3(0,h/3,0),Vector3(.6,h/1.5,.6),Color("433c4a"))
			ArtFactory.cone(world,p+Vector3(0,h*.7,0),rng.randf_range(1.5,3),h,accent.darkened(.55))
	for i in range(12):
		var angle=i*TAU/12
		var p=Vector3(sin(angle)*11,0,-65+cos(angle)*11)
		ArtFactory.box(world,p+Vector3(0,3,0),Vector3(1.2,6,1.2),base.lightened(.25))
	ArtFactory.label(world,data.boss,Vector3(0,7,-65),accent)
	var npc=ArtFactory.person(world,accent);npc.position=Vector3(-6,0,-4)
	ArtFactory.label(world,data.keeper+"\nSPEAK / E",Vector3(-6,3,-4),accent)
	for x in [-10,10]:
		ArtFactory.box(world,Vector3(x,2,4),Vector3(5,4,5),base.lightened(.25));ArtFactory.cone(world,Vector3(x,5,4),4,3,accent.darkened(.3))
	ArtFactory.label(world,"WAYFARER'S CAMP\nTrade & forge near the keeper",Vector3(0,5,6))
	hero=ArtFactory.person(world,Color("e2d4a4"));hero.position=Vector3(0,0,4)
	ally=ArtFactory.person(world,Color("75d4dd"));ally.visible=State.companion
	camera=Camera3D.new();world.add_child(camera);camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=30;camera.current=true
	for i in range(18):
		var pos=Vector3(rng.randf_range(-35,35),0,rng.randf_range(-80,-15))
		spawn_enemy(pos,false)
	if State.quests[index]<2: spawn_enemy(Vector3(0,0,-65),true)
	for i in range(24):
		var pos=Vector3(rng.randf_range(-45,45),.4,rng.randf_range(-85,25))
		var item=ArtFactory.cone(world,pos,.55,1.1,accent)
		pickups.append(item)
	hp=100+State.level*10;mana=100;stamina=100
	music.stop()
	music.stream=load("res://assets/audio/land%d.wav"%index);music.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;music.stream.loop_end=int(music.stream.get_length()*music.stream.mix_rate)
	music.volume_db=linear_to_db(maxf(.001,State.volume));music.play()
	decorate(index,base,accent)
	State.save_game()
func spawn_enemy(pos:Vector3,boss:bool) -> void:
	var node=ArtFactory.person(world,Color(lands[State.land].accent).darkened(.25),2.2 if boss else 1.0);node.position=pos
	var health=260.0+State.land*90 if boss else 45.0+State.land*15
	var ring=ArtFactory.cone(node,Vector3(0,.08,0),2.0,.08,Color("ef514d"));ring.visible=false
	enemies.append({"node":node,"hp":health,"max":health,"boss":boss,"clock":0.0,"windup":0.0,"ring":ring,"label":ArtFactory.label(node,"",Vector3(0,3,0))})
func _process(delta:float) -> void:
	if panel.visible: return
	time+=delta;State.elapsed+=delta;auto_timer+=delta;message_timer-=delta
	if message_timer<0: notice.text=""
	if auto_timer>25: auto_timer=0;State.save_game()
	cooldown=maxf(0,cooldown-delta);invulnerable=maxf(0,invulnerable-delta);block_time+=delta
	stamina=minf(100,stamina+delta*19);mana=minf(100,mana+delta*7)
	var move=stick
	if Input.is_physical_key_pressed(KEY_W): move.y-=1
	if Input.is_physical_key_pressed(KEY_S): move.y+=1
	if Input.is_physical_key_pressed(KEY_A): move.x-=1
	if Input.is_physical_key_pressed(KEY_D): move.x+=1
	if move.length()>1: move=move.normalized()
	var motion=Vector3(move.x,0,move.y)
	if motion.length()>.1:
		direction=motion.normalized();hero.position+=motion*delta*(3.0 if blocking else 7.0);hero.rotation.y=atan2(direction.x,direction.z)
		hero.position.y=abs(sin(time*12))*.08
	hero.position.x=clampf(hero.position.x,-88,88);hero.position.z=clampf(hero.position.z,-88,88)
	camera.position=hero.position+Vector3(0,23,19);camera.look_at(hero.position)
	sun.light_energy=.65+.35*sin(State.elapsed/90)
	ally.visible=State.companion
	if State.companion: ally.position=ally.position.lerp(hero.position+Vector3(-2,0,2),delta*3)
	for item in pickups.duplicate():
		item.rotation.y+=delta
		if item.position.distance_to(hero.position)<1.6:
			State.ore+=1;item.queue_free();pickups.erase(item);say("Covenant ore +1")
	for e in enemies.duplicate():
		var n:Node3D=e.node
		var dist=n.position.distance_to(hero.position)
		e.clock+=delta
		e.label.text=("WARDEN " if e.boss else "")+str(maxi(0,int(e.hp)))
		if dist>26: continue
		if e.windup>0:
			e.windup-=delta
			if e.windup<=0:
				e.ring.visible=false
				if dist<(5.5 if e.boss else 2.8): hurt(28 if e.boss else 12)
		elif dist>(4.5 if e.boss else 2):
			n.position+=n.position.direction_to(hero.position)*delta*(2.7 if e.boss else 3.5)
		elif e.clock>(1.5 if e.hp<e.max/2 else 2.5):
			e.clock=0;e.windup=.65;e.ring.visible=true
		if State.companion and e.clock<delta and dist<7: damage(e,8)
	stats.text="%s\nHP %d/%d    STAMINA %d    AETHER %d    LV %d    GOLD %d"%[lands[State.land].region,hp,100+State.level*10,stamina,mana,State.level,State.gold]
	objective.text="COVENANT %d / 3   •   %s"%[State.quests.count(2),"Speak to the keeper at camp" if State.quests[State.land]==0 else ("Defeat the warden • north along the road" if State.quests[State.land]==1 else "Shard reclaimed • travel using the Atlas")]
func say(text:String) -> void: notice.text=text;message_timer=4
func nearest(max_distance:float) -> Dictionary:
	var target:Dictionary={};var best=max_distance
	for e in enemies:
		var d=e.node.position.distance_to(hero.position)
		if d<best: best=d;target=e
	return target
func attack(heavy:bool) -> void:
	if panel.visible or cooldown>0 or stamina<(25 if heavy else 10): return
	stamina-=25 if heavy else 10;cooldown=.8 if heavy else .3;combo=(combo+1)%3
	var target=nearest(4.5 if heavy else 3.5)
	var tween=create_tween();tween.tween_property(hero,"rotation:y",hero.rotation.y+TAU,.25)
	if not target.is_empty(): damage(target,(28 if heavy else 12)+State.rank*5+State.level*2+combo*3)
func damage(e:Dictionary,amount:float) -> void:
	if not enemies.has(e): return
	effects.stream=load("res://assets/audio/impact.wav");effects.play()
	e.hp-=amount
	if e.hp<=0:
		State.gold+=55 if e.boss else 8;State.reward(100 if e.boss else 18);State.kills+=1
		if e.boss:
			State.quests[State.land]=2;State.ore+=5;say("WARDEN FALLEN • Covenant shard reclaimed");State.save_game()
		else: say("+8 gold · +18 experience")
		e.node.queue_free();enemies.erase(e)
func spell() -> void:
	if panel.visible or mana<30 or cooldown>0: return
	mana-=30;cooldown=.7
	var orb=ArtFactory.cone(world,hero.position+Vector3(0,.15,0),7,.2,Color("78e7e1"));var tween=create_tween();tween.tween_property(orb,"scale",Vector3.ZERO,.5);tween.tween_callback(orb.queue_free)
	for e in enemies.duplicate():
		if e.node.position.distance_to(hero.position)<8: damage(e,30+State.level*4)
func dodge() -> void:
	if panel.visible or stamina<22: return
	stamina-=22;invulnerable=.5;hero.position+=direction*4
func hurt(amount:float) -> void:
	if invulnerable>0:return
	if blocking and stamina>15:
		stamina-=15
		if block_time<.3:
			say("PERFECT PARRY");var e=nearest(6)
			if not e.is_empty(): damage(e,22)
			return
		amount*=.2
	hp-=amount;invulnerable=.45
	if hp<=0:
		State.gold=maxi(0,State.gold-15);hero.position=Vector3(0,0,4);hp=100+State.level*10;say("Returned to camp • 15 gold lost")
func heal() -> void:
	if panel.visible or State.potions<=0:return
	State.potions-=1;hp=minf(100+State.level*10,hp+65);say("Restored 65 health")
func interact() -> void:
	if hero.position.distance_to(Vector3(-6,0,-4))>9: say("Find the keeper at the camp lantern");return
	var data=lands[State.land]
	open_panel(data.keeper,data.story+"\n\n"+(data.epilogue if State.quests[State.land]==2 else "The warden waits at the end of the northern road."))
	if State.decisions[State.land]==0:
		button(data.choice_a,func(): choose(1));button(data.choice_b,func(): choose(2))
	button("Trade and forge",inventory)
	if not State.companion: button("Recruit the wandering sentinel • 30 gold",func():
		if State.gold>=30: State.gold-=30;State.companion=true;close();say("Sentinel joined your journey")
		else: say("You need 30 gold"))
	button("Leave",close)
func choose(value:int) -> void:
	State.decisions[State.land]=value
	if value==1:State.mercy+=1
	else:State.dominion+=1
	State.quests[State.land]=maxi(1,State.quests[State.land]);State.save_game();close()
func inventory() -> void:
	open_panel("WAYFARER'S PACK","Covenant blade +%d\nOre %d · Gold %d · Healing draughts %d\nLevel %d · Experience %d / %d\n\nTrade and forging are available within camp."%[State.rank,State.ore,State.gold,State.potions,State.level,State.xp,State.level*60])
	if hero.position.length()<15:
		button("Buy healing draught • 12 gold",func():
			if State.gold>=12:State.gold-=12;State.potions+=1;inventory())
		button("Forge blade • 3 ore + 25 gold",func():
			if State.ore>=3 and State.gold>=25:State.ore-=3;State.gold-=25;State.rank+=1;inventory())
		button("Rest at camp • restore health and aether",func(): hp=100+State.level*10;mana=100;State.save_game();close())
	button("Return",close)
func journal() -> void:
	var text="THE BROKEN COVENANT\n"
	for i in range(3):text+="\n"+lands[i].region+" — "+["Meet the keeper","Defeat the warden","Shard reclaimed"][State.quests[i]]
	text+="\n\nMercy %d · Dominion %d · Enemies defeated %d"%[State.mercy,State.dominion,State.kills]
	if State.quests.count(2)==3:
		text+="\n\n"+("DAWN OF THE FREE: You dissolve the Covenant. The kingdoms must learn to flourish without stealing each other's futures." if State.mercy>State.dominion else "THE FOURTH CROWN: You take the Covenant's throne. For the first time, all three lands kneel to one mortal will.")
	open_panel("CHRONICLE",text);button("Return",close)
func atlas() -> void:
	open_panel("ATLAS OF THE THREE LANDS","The old roads bind every kingdom. Travel returns you to the local camp. The wardens and your choices persist; frontier enemies and ore replenish.")
	for i in range(3): button(lands[i].name+"  /  "+lands[i].region,func():load_land(i);close())
	button("Return",close)
func settings() -> void:
	open_panel("SYSTEM","Manual saves and autosaves use the device's private app storage. A backup is kept for recovery.\nGraphics presets change shadow rendering; touch sizing changes action buttons.")
	button("Save journey",func():say("Journey saved" if State.save_game() else "Save failed");close())
	button("Load saved journey",func():State.load_game();load_land(State.land);close())
	button("Shadows: "+("ON" if State.quality else "OFF"),func():State.quality=1-State.quality;sun.shadow_enabled=State.quality>0;settings())
	button("Music: "+("ON" if State.volume>0 else "OFF"),func():State.volume=0.0 if State.volume>0 else .45;music.volume_db=linear_to_db(maxf(.001,State.volume));settings())
	button("Credits and licenses",credits)
	button("Touch controls: "+("LARGE" if State.touch_scale>1 else "NORMAL"), resize_controls)
	button("Return",close)
func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE: close() if panel.visible else settings()
			KEY_J: attack(false)
			KEY_K: attack(true)
			KEY_L: spell()
			KEY_SPACE: dodge()
			KEY_E: interact()
			KEY_H: heal()
			KEY_B: blocking=true;block_time=0
	if event is InputEventKey and not event.pressed and event.physical_keycode==KEY_B: blocking=false
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x<450 and not panel.visible:stick_id=event.index;stick_start=event.position
		elif not event.pressed and event.index==stick_id:stick_id=-1;stick=Vector2.ZERO
	if event is InputEventScreenDrag and event.index==stick_id:stick=(event.position-stick_start).limit_length(70)/70
func _notification(what:int) -> void:
	if what==NOTIFICATION_WM_GO_BACK_REQUEST: settings()
	if what==NOTIFICATION_WM_CLOSE_REQUEST: State.save_game();get_tree().quit()

func resize_controls() -> void:
	State.touch_scale=1.2 if State.touch_scale==1 else 1.0
	for b in touch_buttons:
		b.custom_minimum_size=Vector2(105,48)*State.touch_scale
	settings()

func decorate(index:int,base:Color,accent:Color) -> void:
	for x in [-10,10]:
		for z in [2.0,4.0,6.0]:
			ArtFactory.box(world,Vector3(x-2.52,2,z),Vector3(.1,.9,.55),accent.lightened(.2))
			ArtFactory.box(world,Vector3(x+2.52,2,z),Vector3(.1,.9,.55),accent.lightened(.2))
		ArtFactory.box(world,Vector3(x,1.1,1.47),Vector3(1.2,2.2,.12),base.darkened(.65))
		ArtFactory.box(world,Vector3(x,4.1,4),Vector3(5.5,.3,5.5),accent.darkened(.2))
	for z in range(-80,10,8):
		for x in [-4.5,4.5]:
			ArtFactory.box(world,Vector3(x,1,z),Vector3(.25,2,.25),base.darkened(.4))
			ArtFactory.cone(world,Vector3(x,2.1,z),.45,.7,accent)
			var light=OmniLight3D.new();light.position=Vector3(x,2,z);light.light_color=accent;light.omni_range=4;light.light_energy=.7;world.add_child(light)
	if index==1:
		var lake=ArtFactory.box(world,Vector3(24,-.03,-28),Vector3(20,.1,30),Color("248da1"))
		lake.material_override=load("res://assets/water.tres")
		for i in range(9):ArtFactory.cone(world,Vector3(16+i*2,1.5,-42),.8,3.0,Color("a2e5e4"))
	elif index==0:
		for i in range(25):
			var p=Vector3(-30+(i%5)*3,0,-25-(i/5)*4)
			ArtFactory.box(world,p+Vector3(0,.8,0),Vector3(.5,1.6,.4),Color("aaa3b0"))
			ArtFactory.box(world,p+Vector3(0,1.2,0),Vector3(1.3,.3,.4),Color("aaa3b0"))
	else:
		for i in range(7):
			ArtFactory.box(world,Vector3(-30+i*4,1.7,-20),Vector3(3.5,3.4,1),base.lightened(.3))
			ArtFactory.box(world,Vector3(-30+i*4,3.7,-20),Vector3(1.7,.6,1.2),accent)

func _exit_tree() -> void:
	if is_instance_valid(music): music.stop()
	if is_instance_valid(effects): effects.stop()

func credits() -> void:
	open_panel("CREDITS", "3LANDS OF DEATH, BEAUTY & PROSPERITY\nOriginal procedural assets, narrative, and synthesized music.\nBuilt with Godot 4.7.2 (MIT).\n\n" + FileAccess.get_file_as_string("res://data/GODOT_LICENSE.txt") + "\n" + FileAccess.get_file_as_string("res://data/GODOT_COPYRIGHT.txt"))
	button("Return", settings)
