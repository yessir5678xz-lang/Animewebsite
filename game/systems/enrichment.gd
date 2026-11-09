extends Node
## Regional composition, persistent vignettes, encounter ecology and presentation.
const Art=preload("res://scripts/art.gd")
var game:Node3D
var expansion:Node
var regions:Array=[]
var residents:Array=[]
var cinematic=0.0
var cinematic_center=Vector3.ZERO
var cinematic_title=""
var score:AudioStreamPlayer
var outgoing:AudioStreamPlayer
var music_fade:Tween
var atmosphere:AudioStreamPlayer
var score_name=""
var environment_name=""
var last_cell=Vector2i(99999,99999)
var surface_targets:Array=[]
var survey_label:Label
var audio_clock=0.0
func _ready() -> void:
	expansion=get_parent();game=expansion.game
	regions=JSON.parse_string(FileAccess.get_file_as_string("res://data/regions.json")).regions
	score=AudioStreamPlayer.new();add_child(score);score.volume_db=-60
	outgoing=AudioStreamPlayer.new();add_child(outgoing)
	score_name="main";score.stream=load("res://assets/enrichment/audio/main.ogg");score.stream.loop=true;score.volume_db=-13 if State.volume>0 else -60;score.play()
	atmosphere=AudioStreamPlayer.new();add_child(atmosphere);atmosphere.volume_db=-22
	survey_label=Label.new();survey_label.position=Vector2(365,150);survey_label.size=Vector2(550,90);survey_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;survey_label.add_theme_font_size_override("font_size",26);game.hud.add_child(survey_label);survey_label.hide()
func progress() -> Dictionary:return State.rpg.enrichment
func reset() -> void:
	residents.clear();surface_targets.clear();last_cell=Vector2i(99999,99999);cinematic=0;survey_label.hide()
func region_at(cell:Vector2i) -> Dictionary:
	for r in regions:
		if int(r.land)==State.land and cell==Vector2i(r.cell[0],r.cell[1]):return r
	return {}
func decorate_camp() -> void:
	reset()
	var root=Node3D.new();root.name="LivingCamp";game.world.add_child(root)
	# Keep the original camp collision footprint while upgrading its visible architecture.
	for old in game.world.get_children():
		if old is MeshInstance3D and absf(absf(old.position.x)-10)<3 and absf(old.position.z-4)<3 and old.position.y>.5:old.hide()
	for x in [-10,10]:
		var house=Node3D.new();root.add_child(house);house.position=Vector3(x,0,4);house.scale=Vector3.ONE*.625
		building(house,Vector3.ZERO,State.land,"village")
	for old in game.world.get_children():
		if old is MeshInstance3D and old.mesh is BoxMesh and old.mesh.size.y<.2 and old.mesh.size.x>5 and old.name!="Terrain":Library.surface(old,"PavingStones070",false,.4)
	Library.place(root,"survival-kit/workbench-anvil",Vector3(7,0,0),2)
	Library.place(root,"survival-kit/campfire-pit",Vector3(-3,0,5),1.5)
	Library.place(root,"survival-kit/tent",Vector3(16,0,7),2)
	for i in range(5):Library.place(root,"survival-kit/box",Vector3(14+i*.8,0,11),1)
	resident(root,Vector3(5,0,0),"Quartermaster","Trade fairly, and the roads will remember your name.","trade",State.land*5)
	resident(root,Vector3(-15,0,6),"Roadwarden","Landmarks beyond the frontier carry records of the Covenant. Follow the survey markers on your local atlas.","guide",State.land*5+1)
	for i in range(3):
		var t=Node3D.new();root.add_child(t);t.position=Vector3(-25+i*25,0,-20)
		scatter(t,Vector3.ZERO,Vector2i(i,State.land),true)
	var ground=game.world.get_node("Terrain")
	if ground is MeshInstance3D:apply_surface(ground,["Ground037","Grass001","PavingStones070"][State.land],Vector2i.ZERO)
	positional(root,Vector3(-3,1,5),"fire",14)
func scatter(root:Node3D,center:Vector3,cell:Vector2i,camp:bool=false) -> void:
	var rng=RandomNumberGenerator.new();rng.seed=abs(cell.x*7919+cell.y*104729+State.land*2309)+441
	var vegetation=Library.pool("nature-kit","vegetation")
	var count=3 if camp else 8
	for i in range(count):
		var index=posmod(cell.x*11+cell.y*7+State.land*31+i*13,vegetation.size())
		var id=vegetation[index];var instances=[]
		for j in range(5 if camp else 10):
			var p=center+Vector3(rng.randf_range(-40,40),0,rng.randf_range(-40,40))
			if absf(p.x-center.x)<10 or absf(p.z-center.z)<9:continue
			if camp and p.length()<20:continue
			var size=rng.randf_range(1.2,2.8)
			instances.append(Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*size),p))
		if not instances.is_empty():Library.instanced(root,id,instances)
	if camp:return
	var kit=["graveyard-kit","nature-kit","survival-kit"][State.land]
	var props=Library.pool(kit,"props")
	for i in range(12):
		var p=center+Vector3(rng.randf_range(-40,40),0,rng.randf_range(-40,40))
		if absf(p.x-center.x)<8:continue
		Library.place(root,props[posmod(cell.x*23+cell.y*19+i,props.size())],p,1.5,rng.randf()*TAU)
func decorate_chunk(root:Node3D,center:Vector3,cell:Vector2i,ground:MeshInstance3D) -> void:
	scatter(root,center,cell)
	var r=region_at(cell)
	var fallback=["Ground048","Grass004","PavingStones128"][State.land]
	apply_surface(ground,r.get("surface",fallback),cell)
	if r.is_empty():return
	var site=Node3D.new();site.name="Landmark";root.add_child(site);site.position=center
	Art.label(site,r.name,Vector3(0,7,0),Color(game.lands[State.land].accent))
	var obstacle_list=[]
	var kind=String(r.kind)
	if kind in ["city","village","market","palace","library","estate","industrial","port","farm"]:
		for i in range(4):
			var p=Vector3(-18 if i%2==0 else 18,0,-18+int(i/2)*30)
			building(site,p,int(r.index)+i,kind)
			obstacle_list.append({"pos":center+p+Vector3(0,2,0),"size":Vector3(10,5,10)})
		for i in range(3):resident(site,Vector3(-5+i*5,0,5),["Resident","Merchant","Guard"][i],r.lore,"trade" if i==1 else "story",int(r.index)+i)
	elif kind in ["fortress","temple","ruins","arena","battlefield","crypt","vault","underground"]:
		for i in range(8):
			var angle=i*TAU/8;var p=Vector3(sin(angle)*22,0,cos(angle)*22)
			Library.place(site,"castle-kit/tower-square-base",p,3,angle)
			Library.place(site,"castle-kit/tower-square-top",p+Vector3(0,5.4,0),3,angle)
			obstacle_list.append({"pos":center+p,"size":Vector3(5,8,5)})
		Library.place(site,"graveyard-kit/altar-stone",Vector3(0,0,-9),3)
	elif kind in ["water","waterfall","bridge","sky"]:
		var lake=Art.box(site,Vector3(19,-.02,0),Vector3(22,.12,65),Color("4d8d9d"));lake.material_override=load("res://assets/water.tres")
		Library.place(site,"nature-kit/bridge_wood",Vector3(18,.25,0),5,PI/2)
		if kind=="waterfall":
			var falls=Art.box(site,Vector3(30,7,-25),Vector3(8,14,.5),Color("6cdde0"));falls.material_override=load("res://assets/water.tres")
		positional(site,Vector3(18,1,0),"water",35)
	elif kind in ["cave","mountain","volcano"]:
		for i in range(7):Library.place(site,"nature-kit/cliff_block_rock",Vector3(-28+i*9,-1,-24),6+float(i%3),float(i))
		if kind=="volcano":particles(site,Vector3(0,1,-14),Color("ff622f"),true)
	else:
		Library.place(site,"nature-kit/tree_detailed",Vector3(0,0,-16),8)
		particles(site,Vector3(0,2,0),Color("74f5cd"),false)
		if State.land==1:positional(site,Vector3(0,5,-16),"birds",35)
	root.set_meta("obstacles",obstacle_list)
	var altar=Library.place(site,"graveyard-kit/altar-wood",Vector3(0,0,0),2)
	altar.set_meta("region",r.id);altar.add_to_group("regional_sites")
	Art.label(altar,"RECORD OF THE COVENANT • E / SPEAK",Vector3(0,2,0),Color("f1d695"))
	resident(site,Vector3(-4,0,-3),"Witness of "+r.name,r.lore,"story",int(r.index)+State.land*3)
func building(parent:Node3D,pos:Vector3,index:int,kind:String) -> void:
	var house=Node3D.new();parent.add_child(house);house.position=pos
	var stone=[Color("655663"),Color("6a8a7c"),Color("b6a083")][State.land]
	var shell=Art.box(house,Vector3(0,2,0),Vector3(8,4,8),stone)
	var surface=["Bricks059","Rock058","Bricks084"][State.land]
	Library.surface(shell,surface,false,.35)
	for side in range(4):
		for j in range(3):
			var p=Vector3(4,(0.0),(j-1)*2.5).rotated(Vector3.UP,side*PI/2)
			var facade="wall-window-stone" if (j+index)%2==0 else "wall-window-shutters"
			if side==2 and j==1:facade="wall-door"
			Library.place(house,"fantasy-town-kit/"+facade,p,2.5,side*PI/2)
	# Four pitched roof quadrants form a complete canopy over the shell.
	for side in range(4):
		var p=Vector3(2,4,0).rotated(Vector3.UP,side*PI/2)
		var roof=Library.place(house,"fantasy-town-kit/roof-high",p,4,side*PI/2)
		roof.scale.z=8
	Library.place(house,"fantasy-town-kit/chimney",Vector3(1,5,1),3)
	var props=Library.pool("fantasy-town-kit","props")
	for i in range(3):Library.place(house,props[posmod(index*5+i,props.size())],Vector3(-3+i*3,0,-7),2)
	if kind=="industrial":Library.place(house,"survival-kit/workbench",Vector3(0,0,-7),2)
func resident(parent:Node3D,pos:Vector3,title:String,lore:String,role:String,index:int) -> void:
	var n=Art.animated(parent,"blocky-characters/character-"+String.chr(97+posmod(index,18)));n.position=pos
	n.set_meta("home",pos);n.set_meta("title",title);n.set_meta("lore",lore);n.set_meta("role",role);n.set_meta("seed",index)
	residents.append(weakref(n));Art.label(n,title,Vector3(0,2.7,0),Color("efddac"))
func apply_surface(target:MeshInstance3D,id:String,cell:Vector2i) -> void:
	var current=Vector2i(floor(game.hero.position.x/96),floor(game.hero.position.z/96))
	var high=int(State.rpg.preset)>=3 and cell==current
	target.set_meta("surface_tint",[Color("917080"),Color("b5eddb"),Color("e3cba4")][State.land])
	Library.surface(target,id,high)
	surface_targets.append({"node":weakref(target),"id":id,"cell":cell,"high":high})
func refresh_surfaces() -> void:
	var current=Vector2i(floor(game.hero.position.x/96),floor(game.hero.position.z/96))
	for target in surface_targets.duplicate():
		var n=target.node.get_ref()
		if not is_instance_valid(n):surface_targets.erase(target);continue
		var high=int(State.rpg.preset)>=3 and target.cell==current
		if high!=target.high:target.high=high;Library.surface(n,target.id,high)
func positional(parent:Node3D,pos:Vector3,id:String,distance:float) -> void:
	var sound=AudioStreamPlayer3D.new();parent.add_child(sound);sound.add_to_group("world_ambience");sound.position=pos;sound.max_distance=distance;sound.unit_size=5;sound.volume_db=-16
	sound.stream=load("res://assets/enrichment/audio/"+id+".ogg");sound.stream.loop=true;sound.play()
func particles(parent:Node3D,pos:Vector3,color:Color,fire:bool) -> void:
	var n=CPUParticles3D.new();parent.add_child(n);n.position=pos;n.set_meta("scalable_particles",true);n.amount=[12,24,40,60,80][int(State.rpg.preset)];n.lifetime=4;n.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX;n.emission_box_extents=Vector3(9,1,9);n.gravity=Vector3(0,.3,0);n.initial_velocity_min=.2;n.initial_velocity_max=1
	var mesh=SphereMesh.new();mesh.radius=.08;mesh.height=.16;mesh.radial_segments=6;mesh.rings=3;n.mesh=mesh
	var m=StandardMaterial3D.new();m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;m.albedo_color=color;m.emission_enabled=true;m.emission=color;m.emission_energy_multiplier=2;n.material_override=m
	if fire:positional(parent,pos,"fire",25)
func _process(delta:float) -> void:
	if not is_instance_valid(game.hero):return
	if cinematic>0:
		cinematic-=delta
		var t=1.0-cinematic/3.0
		game.camera.position=cinematic_center+Vector3(sin(t)*24,18,cos(t)*24);game.camera.look_at(cinematic_center);survey_label.text=cinematic_title+"\nE / SPEAK to skip"
		if cinematic<=0:survey_label.hide()
	if game.panel.visible:return
	var cell=Vector2i(floor(game.hero.position.x/96),floor(game.hero.position.z/96))
	if cell!=last_cell and not expansion.dungeon:
		last_cell=cell;refresh_surfaces()
		var r=region_at(cell)
		if not r.is_empty() and not progress().seen.has(r.id):
			progress().seen.append(r.id);cinematic=3;cinematic_center=Vector3((cell.x+.5)*96,0,(cell.y+.5)*96);cinematic_title=r.name;survey_label.show()
	for ref in residents.duplicate():
		var n=ref.get_ref()
		if not is_instance_valid(n):residents.erase(ref);continue
		if n.global_position.distance_to(game.hero.global_position)>55:continue
		var hour=fmod(State.elapsed/10,24)
		var target:Vector3=n.get_meta("home")
		if hour>7 and hour<20:target+=Vector3(sin(State.elapsed*.09+n.get_meta("seed"))*2,0,cos(State.elapsed*.09)*2)
		var movement=n.position.direction_to(target)
		if movement.length()>.1:n.position=n.position.move_toward(target,delta*.6);n.rotation.y=atan2(movement.x,movement.z)
		if hour<6:n.gesture("sit",.5)
	audio_clock+=delta
	if audio_clock>1:audio_clock=0;update_audio()
	var gain=-13.0 if State.volume>0 else -60.0
	score.volume_db=move_toward(score.volume_db,gain,delta*8)
	atmosphere.volume_db=-25 if State.volume>0 else -60
	game.music.volume_db=-60;expansion.battle.volume_db=-60
func update_audio() -> void:
	var nearby=game.nearest(20)
	var desired=["death","beauty","prosperity"][State.land]
	if expansion.dungeon:desired="dungeon"
	if not nearby.is_empty():desired="boss" if nearby.boss else "combat"
	elif cinematic>0:desired="story"
	else:
		var r=region_at(last_cell)
		if not r.is_empty() and r.kind in ["city","market","village"]:desired="village"
		elif int(State.elapsed/96)%3==2:desired="explore"
	if score_name!=desired:
		if music_fade and music_fade.is_valid():music_fade.kill()
		outgoing.stop();outgoing.stream=score.stream;outgoing.volume_db=score.volume_db;outgoing.play(score.get_playback_position())
		music_fade=create_tween();music_fade.tween_property(outgoing,"volume_db",-60.0,1.5);music_fade.tween_callback(outgoing.stop)
		score_name=desired;score.stream=load("res://assets/enrichment/audio/"+desired+".ogg");score.stream.loop=true;score.volume_db=-40;score.play()
	var ambience="dungeon_ambience" if expansion.dungeon else ["wind","forest","village_ambience"][State.land]
	if int(State.elapsed/100)%3>0:ambience="rain"
	if environment_name!=ambience:environment_name=ambience;atmosphere.stream=load("res://assets/enrichment/audio/"+ambience+".ogg");atmosphere.stream.loop=true;atmosphere.play()
func interact() -> bool:
	if cinematic>0:cinematic=0;survey_label.hide();return true
	for site in get_tree().get_nodes_in_group("regional_sites"):
		if site.is_inside_tree() and site.global_position.distance_to(game.hero.global_position)<5:
			show_site(site.get_meta("region"));return true
	for ref in residents:
		var n=ref.get_ref()
		if is_instance_valid(n) and n.global_position.distance_to(game.hero.global_position)<4:
			n.gesture("emote-yes")
			game.open_panel(n.get_meta("title"),n.get_meta("lore"))
			if n.get_meta("role")=="trade":
				game.button("Exchange 2 ore for 30 gold",func():
					if State.ore>=2:State.ore-=2;State.gold+=30;game.say("Exchange completed");game.close())
				game.button("Buy draught • 12 gold",func():
					if State.gold>=12:State.gold-=12;State.potions+=1;game.say("Draught purchased");game.close())
			game.button("Leave",game.close);return true
	return false
func show_site(id:String) -> void:
	var r:Dictionary={}
	for candidate in regions:
		if candidate.id==id:r=candidate;break
	if r.is_empty():return
	game.open_panel(r.name,r.lore)
	if progress().choices.has(id):
		game.button("Recorded: "+r.choices[int(progress().choices[id])-1],func():game.say("Your decision is part of the local record"))
	elif r.activity=="trial" and not progress().trials.has(id):
		game.button("Undertake the guardian trial",func():start_trial(r);game.close())
	else:
		for i in range(2):game.button(r.choices[i]+(" • +10 reputation" if i==0 else " • +3 ore"),func():resolve_site(id,i+1);show_site(id))
	game.button("Leave",game.close)
func resolve_site(id:String,choice:int) -> bool:
	if choice not in [1,2] or progress().choices.has(id):return false
	for r in regions:
		if r.id!=id:continue
		if r.activity=="trial" and not progress().trials.has(id):return false
		progress().choices[id]=choice;State.gold+=int(r.reward);State.reward(int(r.reward))
		if choice==1:State.rpg.reputation[["Bellkeepers","Verdant Court","Free Guilds"][int(r.land)]]=minf(1000,State.rpg.reputation[["Bellkeepers","Verdant Court","Free Guilds"][int(r.land)]]+10)
		else:State.ore+=3
		State.save_game();return true
	return false
func start_trial(r:Dictionary) -> void:
	for e in game.enemies:
		if e.get("trial")==r.id:game.say("Defeat the remaining trial guardians");return
	var center=Vector3((r.cell[0]+.5)*96,0,(r.cell[1]+.5)*96)
	for i in range(3):
		game.spawn_enemy(center+Vector3(-4+i*4,0,-9),false,["ranger","charger","hexer"][i]);game.enemies[-1].trial=r.id;game.enemies[-1].chunk=Vector2i(r.cell[0],r.cell[1])
func on_kill(e:Dictionary) -> void:
	if not e.has("trial"):return
	for other in game.enemies:
		if other!=e and other.get("trial")==e.trial:return
	if not progress().trials.has(e.trial):progress().trials.append(e.trial)
	game.say("TRIAL COMPLETE • Return to the record to decide its future")
func enemy_action(e:Dictionary,delta:float,distance:float) -> bool:
	if e.boss or e.get("style","soldier")=="soldier":return false
	if e.stagger>0:return true
	var dir=e.node.position.direction_to(game.hero.position);e.node.rotation.y=atan2(dir.x,dir.z)
	if e.style in ["ranger","hexer"]:
		if distance>13:e.node.position+=dir*delta*2.5
		elif distance<7:e.node.position-=dir*delta*2
		if e.clock>3 and distance<22:
			e.clock=0;e.node.animate_attack("arcane");expansion.projectile(e.node.position+Vector3(0,1,0),dir,false,14 if e.style=="ranger" else 20,Color("dba567") if e.style=="ranger" else Color("b27de4"))
		return true
	if e.style=="charger":
		if e.windup>0:
			e.windup-=delta;e.ring.visible=true
			if e.windup<=0:e.ring.visible=false;e.charge=.6;e.charge_dir=dir
		elif e.get("charge",0)>0:
			e.charge-=delta;var next=e.node.position+e.charge_dir*delta*14
			if expansion.valid_position(next):e.node.position=next
			if distance<2.5:game.hurt(22)
		elif e.clock>3.5:e.clock=0;e.windup=.8
		elif distance>5:e.node.position+=dir*delta*2
		return true
	return false
func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_PAUSED:
		if is_instance_valid(score):score.stream_paused=true;outgoing.stream_paused=true;atmosphere.stream_paused=true
	if what==NOTIFICATION_APPLICATION_RESUMED:
		if is_instance_valid(score):score.stream_paused=false;outgoing.stream_paused=false;atmosphere.stream_paused=false
func _exit_tree() -> void:
	if is_instance_valid(score):score.stop();outgoing.stop();atmosphere.stop()
func stop_audio() -> void:
	set_process(false);score.stop();outgoing.stop();atmosphere.stop()
	for sound in get_tree().get_nodes_in_group("world_ambience"):sound.stop()

func decorate_dungeon(anchor:Vector3) -> void:
	var decor=Node3D.new();game.world.add_child(decor)
	for i in range(5):
		var center=anchor+Vector3(0,0,-10-i*16)
		var floor_mesh=Art.box(decor,center+Vector3(0,.08,0),Vector3(17,.1,15),Color.WHITE)
		Library.surface(floor_mesh,["Bricks066","Moss002","Marble012"][State.land],false,.4)
		for side in [-1,1]:
			Library.place(decor,"mini-dungeon/column",center+Vector3(side*7,0,0),4)
			Library.place(decor,["graveyard-kit/coffin","nature-kit/mushroom_redTall","survival-kit/chest"][State.land],center+Vector3(side*6,0,-5),2)
			Library.place(decor,"graveyard-kit/candle-multiple",center+Vector3(side*7,1,0),2)
			var light=OmniLight3D.new();decor.add_child(light);light.position=center+Vector3(side*7,3,0);light.light_color=Color(game.lands[State.land].accent);light.omni_range=9;light.light_energy=.8;light.visible=int(State.rpg.preset)>0
	positional(decor,anchor,"dungeon_ambience",50)

func quality_tree(node:Node) -> void:
	if node is CPUParticles3D and node.has_meta("scalable_particles"):node.amount=[12,24,40,60,80][int(State.rpg.preset)]
	for child in node.get_children():quality_tree(child)
