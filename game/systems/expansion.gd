extends Node
const Rules=preload("res://systems/rules.gd")
const Art=preload("res://scripts/art.gd")
var rules=Rules.new()
var streaming:Node
var enrichment:Node
var game:Node3D
var npcs:Array=[]
var bolts:Array=[]
var projectile_pool:Array=[]
var dungeon=false
var locked:Dictionary={}
var obstacles:Array=[]
var rain:CPUParticles3D
var low_fps_time=0.0
var boss_intro:Dictionary={}
var foot_timer=0.0
var foot:AudioStreamPlayer
var battle:AudioStreamPlayer
var battle_mix=-60.0
var last_position=Vector3.ZERO
var dungeon_anchor=Vector3.ZERO
var settings_controls:Control
func _ready() -> void:
	game=get_parent()
	foot=AudioStreamPlayer.new();add_child(foot);foot.stream=load("res://assets/audio/step.wav");foot.volume_db=-15
	battle=AudioStreamPlayer.new();add_child(battle);battle.stream=load("res://assets/audio/combat.wav");battle.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;battle.stream.loop_end=int(battle.stream.get_length()*battle.stream.mix_rate);battle.volume_db=-60;battle.play()
	enrichment=Node.new();enrichment.set_script(load("res://systems/enrichment.gd"));add_child(enrichment)
	streaming=Node.new();streaming.set_script(load("res://systems/streaming.gd"));add_child(streaming)
func state() -> Dictionary: return State.rpg
func land_ready() -> void:
	streaming.reset()
	npcs.clear();obstacles.clear();bolts.clear();projectile_pool.clear();locked={};boss_intro.clear();dungeon=false
	var data=rules.data.npcs[State.land]
	var npc=Art.person(game.world,Color("b7c8bb"));npc.position=Vector3(data.pos[0],0,data.pos[1]);npcs.append(npc)
	Art.label(game.world,data.name+" • E / SPEAK",npc.position+Vector3(0,3,0),Color("e5cda1"))
	Art.label(game.world,"ANCIENT DESCENT\nE / SPEAK to enter",Vector3(20,3,-50),Color("9fb6ef"))
	for i in range(5):Art.box(game.world,Vector3(20,-.05,-50-i),Vector3(5,.25,1),Color("777f9c"))
	for i in range(8):
		var barrel=Art.cone(game.world,Vector3(-18+i*2, .6, 14),.65,1.2,Color("9d7851"));barrel.set_meta("breakable",true)
	for p in [Vector3(-24,0,-48),Vector3(34,0,-72),Vector3(-42,0,18)]:
		var key="%d:%s"%[State.land,str(p)]
		if state().chests.has(key):continue
		var chest=Art.box(game.world,p+Vector3(0,.5,0),Vector3(1.4,1,1),Color("b59450"))
		chest.set_meta("chest",key)
		Art.label(chest,"TREASURE • E",Vector3(0,1.8,0),Color("f5d279"))
	for building in game.world.get_children():
		if building is MeshInstance3D and building.mesh is BoxMesh and building.mesh.size.y>=3 and building.position.y>0:
			obstacles.append({"pos":building.position,"size":building.mesh.size})
	apply_quality()
	apply_appearance()
	rain=CPUParticles3D.new();rain.amount=180;rain.lifetime=1.1;rain.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX;rain.emission_box_extents=Vector3(16,.5,16)
	rain.direction=Vector3(.2,-1,0);rain.initial_velocity_min=20;rain.initial_velocity_max=27;rain.gravity=Vector3(0,-12,0);rain.mesh=BoxMesh.new();rain.mesh.size=Vector3(.025,.45,.025)
	var mat=StandardMaterial3D.new();mat.albedo_color=Color(.6,.75,.9,.6);mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;rain.material_override=mat;game.world.add_child(rain)
	restore_world()
	enrichment.decorate_camp()
func capture() -> void:
	if not is_instance_valid(game.hero):return
	if not dungeon:streaming.capture()
	var survivors=[]
	for e in game.enemies:
		if is_instance_valid(e.node) and not e.has("chunk"):survivors.append({"pos":[e.node.position.x,e.node.position.z],"hp":e.hp,"boss":e.boss,"style":e.get("style","soldier")})
	var ore=[]
	for item in game.pickups:
		if is_instance_valid(item):ore.append([item.position.x,item.position.z])
	if not dungeon:state().worlds[str(State.land)]={"enemies":survivors,"ore":ore}
	state().resume={"land":State.land,"x":game.hero.position.x,"z":game.hero.position.z,"hp":game.hp,"mana":game.mana,"dungeon":dungeon}
func restore_world() -> void:
	var data=state().worlds.get(str(State.land),{})
	if not data.is_empty():
		for e in game.enemies:e.node.queue_free()
		game.enemies.clear()
		for e in data.enemies:
			game.spawn_enemy(Vector3(e.pos[0],0,e.pos[1]),e.boss,e.get("style","soldier"));game.enemies[-1].hp=e.hp
		for item in game.pickups:item.queue_free()
		game.pickups.clear()
		for p in data.ore:
			game.pickups.append(Art.cone(game.world,Vector3(p[0],.4,p[1]),.55,1.1,Color(game.lands[State.land].accent)))
func restore_resume() -> void:
	var d=state().resume
	if d.get("land",-1)==State.land and not d.get("dungeon",false):
		game.hero.position=Vector3(d.x,0,d.z);game.hp=clampf(d.hp,1,rules.max_health());game.mana=clampf(d.mana,0,100)
func _process(delta:float) -> void:
	if not is_instance_valid(game.hero) or game.panel.visible or enrichment.cinematic>0:return
	rules.economy_tick()
	foot_timer+=delta
	if game.hero.position.distance_to(last_position)>.02 and foot_timer>.3:foot_timer=0;foot.pitch_scale=randf_range(.9,1.1);foot.play()
	var fighting=not game.nearest(17).is_empty()
	battle_mix=move_toward(battle_mix,-9.0 if fighting and State.volume>0 else -60.0,delta*18)
	battle.volume_db=battle_mix
	game.music.volume_db=linear_to_db(maxf(.001,State.volume))-(7.0 if fighting else 0.0)
	var hour=fmod(State.elapsed/10,24)
	if not dungeon:
		game.sun.rotation_degrees.x=-15-hour*6
		game.sun.light_energy=maxf(.12,sin(hour/24*PI)*1.1)
		for i in range(npcs.size()):
			var n=npcs[i]
			if is_instance_valid(n):n.position=n.position.lerp(Vector3(12 if hour>6 and hour<20 else 8,0,-9 if hour>6 and hour<20 else 3),delta*.2)
		var weather=int(State.elapsed/100)%3
		rain.emitting=weather>0 and state().preset>0;rain.position=game.hero.position+Vector3(0,14,0)
		game.environment.environment.fog_density=.009 if weather==0 else (.018 if weather==1 else .03)
	for e in game.enemies.duplicate():
		if not game.enemies.has(e):continue
		if not e.has("stagger"):e.stagger=0.0;e.status="none";e.status_time=0.0;e.tick=0.0;e.phase_timer=0.0
		e.stagger=maxf(0,e.stagger-delta)
		if e.stagger>0:e.clock=0;e.windup=0;e.ring.visible=false
		if e.status_time>0:
			e.status_time-=delta;e.tick+=delta
			if e.tick>1:
				e.tick=0
				if e.status in ["fire","poison"]:game.damage(e,4+State.level)
				elif e.status=="frost":e.stagger=.4
		if not game.enemies.has(e):continue
		if e.boss:
			if e.node.position.distance_to(game.hero.position)<18 and not boss_intro.has(e.node.get_instance_id()):
				boss_intro[e.node.get_instance_id()]=true;game.say(game.lands[State.land].boss+" • The Covenant remembers you");game.effects.stream=load("res://assets/audio/boss.wav");game.effects.play()
			e.phase_timer+=delta
			if e.phase_timer>7 and e.node.position.distance_to(game.hero.position)<24:
				e.phase_timer=0
				match State.land:
					0:
						if game.enemies.size()<25:game.spawn_enemy(e.node.position+Vector3(3,0,2),false)
					1:
						for i in range(6):projectile(e.node.position+Vector3(0,1,0),Vector3(sin(i*TAU/6),0,cos(i*TAU/6)),false,18,Color("6be4c8"))
					2:
						var ring=Art.cone(game.world,e.node.position+Vector3(0,.1,0),9,.1,Color("dfac51"))
						var center=e.node.position
						game.get_tree().create_timer(1.2).timeout.connect(func():
							if is_instance_valid(ring):
								if game.hero.position.distance_to(center)<9 and not game.panel.visible:game.hurt(35)
								ring.queue_free())
	for b in bolts.duplicate():
		if not is_instance_valid(b.node):bolts.erase(b);continue
		b.life-=delta;b.node.position+=b.dir*delta*22
		if b.life<0:release_projectile(b);continue
		if b.friendly:
			for e in game.enemies.duplicate():
				if e.node.position.distance_to(b.node.position)<2.5:
					game.damage(e,b.damage);status(e,state().enchantment);release_projectile(b);break
		elif game.hero.position.distance_to(b.node.position)<2:game.hurt(b.damage);release_projectile(b)
	if State.companion and state().companion_order=="stay":game.ally.position=Vector3(-4,0,4)
	if not locked.is_empty() and (not game.enemies.has(locked) or not is_instance_valid(locked.node)):locked={}
	if not locked.is_empty():
		locked.label.text="[LOCK] "+str(maxi(0,int(locked.hp)))
		game.direction=game.hero.position.direction_to(locked.node.position);game.hero.rotation.y=atan2(game.direction.x,game.direction.z)
	var center=game.hero.position
	game.camera.position=center+Vector3(sin(state().camera)*24,23,cos(state().camera)*24);game.camera.look_at(center)
	game.camera.size=[34,32,30,28,27][int(state().preset)]
	game.hp=minf(game.hp,rules.max_health())
	var region="DUNGEON" if dungeon else ["Ashen March","Glasswater Wilds","Gilded Frontier"][State.land]
	game.objective.text+="\n%s • %02d:00 • %s • %s"%[region,hour,["Clear","Rain","Storm"][int(State.elapsed/100)%3],rules.weapon().name]
	if state().adaptive:
		low_fps_time=low_fps_time+delta if delta>.05 else maxf(0,low_fps_time-delta)
		if low_fps_time>10 and state().preset>0:state().preset-=1;low_fps_time=0;apply_quality();game.say("Adaptive graphics lowered visual preset")
	last_position=game.hero.position
func valid_position(pos:Vector3) -> bool:
	for chunk in streaming.chunks.values():
		if not is_instance_valid(chunk):continue
		for o in chunk.get_meta("obstacles",[]):
			if absf(pos.x-o.pos.x)<o.size.x/2+.35 and absf(pos.z-o.pos.z)<o.size.z/2+.35:return false
	for o in obstacles:
		if absf(pos.x-o.pos.x)<o.size.x/2+.35 and absf(pos.z-o.pos.z)<o.size.z/2+.35:return false
	return true
func strike(heavy:bool) -> void:
	if game.panel.visible or game.cooldown>0:return
	var w=rules.weapon();var cost=float(w.stamina)*(1.8 if heavy else 1.0)
	if game.stamina<cost:return
	game.stamina-=cost;game.cooldown=float(w.speed)*(1.4 if heavy else 1.0);game.combo=(game.combo+1)%3
	game.hero.animate_attack(w.effect)
	break_props()
	var amount=(float(w.damage)*(1.8 if heavy else 1.0)+State.rank*5+State.level*2+game.combo*2+minf(state().mastery.get(state().weapon,0)*.15,30))*(1+rules.rank("force")*.12)
	var target=game.nearest(w.reach+1)
	if w.effect in ["arrow","bolt","arcane"]:
		if not target.is_empty():game.direction=game.hero.position.direction_to(target.node.position)
		projectile(game.hero.position+Vector3(0,1,0),game.direction,true,amount*(1+rules.rank("focus")*.2 if w.effect=="arcane" else 1+rules.rank("precision")*.15),Color("dfce90"));return
	var arm=game.hero.find_child("WeaponPivot",true,false)
	if arm:
		var t=game.create_tween();arm.rotation.z=-1.0;t.tween_property(arm,"rotation:z",1.0,float(w.speed)*.6);t.tween_property(arm,"rotation:z",0.0,float(w.speed)*.4)
	if w.effect=="cleave" or heavy:
		for e in game.enemies.duplicate():
			if e.node.position.distance_to(game.hero.position)<w.reach:hit(e,amount,w.effect)
	elif not target.is_empty():
		hit(target,amount*(1.5 if w.effect=="dual" else 1.0),w.effect)
func hit(e:Dictionary,amount:float,effect:String) -> void:
	if not game.enemies.has(e):return
	if e.hp<e.max*.16 and amount>=e.hp:
		game.say("FINISHER • "+rules.weapon().name)
		var t=game.create_tween();t.tween_property(game.hero,"scale",Vector3.ONE*1.2,.12);t.tween_property(game.hero,"scale",Vector3.ONE,.18)
	game.damage(e,amount)
	if game.enemies.has(e):
		if effect=="stagger":e.stagger=1.5
		status(e,effect if effect in ["fire","poison"] else state().enchantment)
func status(e:Dictionary,element:String) -> void:
	if not game.enemies.has(e):return
	e.status=element;e.status_time=5.0;e.tick=0.0
	if element=="frost":e.stagger=.5
func projectile(pos:Vector3,dir:Vector3,friendly:bool,amount:float,color:Color) -> void:
	var n:MeshInstance3D
	while not projectile_pool.is_empty() and not is_instance_valid(projectile_pool[-1]):projectile_pool.pop_back()
	if projectile_pool.is_empty():n=Art.cone(game.world,pos,.22,.7,color)
	else:n=projectile_pool.pop_back();n.position=pos;n.material_override.albedo_color=color;n.show()
	n.rotation.x=PI/2
	bolts.append({"node":n,"dir":Vector3(dir.x,0,dir.z).normalized(),"friendly":friendly,"damage":amount,"life":1.4})
func on_kill(boss:bool) -> void:
	state().mastery[state().weapon]=int(state().mastery.get(state().weapon,0))+1
	state().progress.kill+=1
	state().progress["kill_"+str(State.land)]+=1
	game.hp=minf(rules.max_health(),game.hp+rules.rank("siphon")*3)
	if State.companion:state().relation+=1
	if dungeon and game.enemies.size()==1:
		state().progress.dungeon+=1
		state().progress["dungeon_"+str(State.land)]+=1
		var id=str(State.land)
		if not state().dungeons.has(id):state().dungeons.append(id);State.gold+=100;State.reward(100)
		game.say("DUNGEON CLEARED • Return through the southern door")
	if boss:state().reputation[["Bellkeepers","Verdant Court","Free Guilds"][State.land]]+=20
	if randf()<.15 and not boss:State.potions+=1
func interact() -> bool:
	if enrichment.interact():return true
	if dungeon:
		if game.hero.position.distance_to(dungeon_anchor)<5:leave_dungeon();return true
		return false
	if game.hero.position.distance_to(Vector3(20,0,-50))<5:enter_dungeon();return true
	for n in npcs:
		if is_instance_valid(n) and n.position.distance_to(game.hero.position)<5:npc_dialogue();return true
	for c in game.world.get_children():
		if c.has_meta("chest") and c.position.distance_to(game.hero.position)<3:
			state().chests.append(c.get_meta("chest"));c.queue_free();State.gold+=25;State.ore+=2;game.say("Treasure • 25 gold, 2 ore");return true
	return false
func npc_dialogue(secret:bool=false) -> void:
	var n=rules.data.npcs[State.land]
	game.open_panel(n.name,n.secret if secret else n.history)
	if not secret:
		game.button("Ask about the old Covenant",func():state().progress.testimony+=1;state().progress["testimony_"+str(State.land)]+=1;npc_dialogue(true))
	game.button("Offer aid to "+n.faction,contracts)
	game.button("Leave",game.close)
func contracts() -> void:
	game.open_panel("FACTION CONTRACTS","Accept contracts before making progress. Ore is handed over when you claim a delivery reward.")
	for q in rules.data.quests:
		if q.land!=State.land:continue
		var info=state().contracts.get(q.id,{})
		var label=q.name+" • "+q.description+" • "+str(q.gold)+" gold"
		if info.is_empty():game.button("ACCEPT: "+label,func():rules.accept(q.id);contracts())
		elif info.status=="active":game.button("CLAIM %d/%d: %s"%[rules.contract_progress(q),q.goal,q.name],func():if rules.claim(q.id):contracts())
		else:game.button("COMPLETE: "+q.name,func():game.say("This contract is complete"))
	game.button("Return",hub)
func hub() -> void:
	game.open_panel("WAYFARER'S CODEX","A living Covenant is built through deeds, alliances, and the choices made between battles.")
	for entry in [["Equipment and merchants",equipment],["Attributes and skill trees",skills],["Faction contracts",contracts],["Companion relationships",companions],["Settlement and trade",settlement],["Character appearance",appearance],["Local map and discoveries",local_map]]:game.button(entry[0],entry[1])
	game.button("Return",game.close)
func equipment() -> void:
	game.open_panel("EQUIPMENT","%d gold • %d ore\nEquipped: %s • Mastery %d\nArmor +%d (reduces damage) • Enchantment: %s"%[State.gold,State.ore,rules.weapon().name,state().mastery.get(state().weapon,0),state().armor,state().enchantment])
	for id in rules.data.weapons:
		var w=rules.data.weapons[id]
		if state().weapons.has(id):game.button("EQUIP "+w.name+" • "+w.rarity+" • "+w.effect,func():state().weapon=id;apply_appearance();equipment())
		elif game.hero.position.length()<18:game.button("BUY "+w.name+" • %d gold"%rules.price(w.cost),func():rules.purchase(id);equipment())
	if game.hero.position.length()<18:
		game.button("Craft armor • 4 ore + 35 gold",func():
			if State.ore>=4 and State.gold>=35:State.ore-=4;State.gold-=35;state().armor+=1;equipment())
		for element in ["fire","frost","poison"]:game.button("Enchant "+element+" • 3 ore + 20 gold",func():
			if State.ore>=3 and State.gold>=20:State.ore-=3;State.gold-=20;state().enchantment=element;equipment())
	game.button("Return",hub)
func skills() -> void:
	game.open_panel("ATTRIBUTES & SKILL TREES","Level %d • %d skill points\nVitality %d • Strength %.1f • Intellect %.1f\nTrees support warrior, assassin, ranger, mage and hybrid builds."%[State.level,rules.skill_points(),rules.max_health(),1+rules.rank("force")*.12,1+rules.rank("focus")*.2])
	for skill in rules.data.skills:game.button("%s / %s %d/5 • %s"%[skill.tree,skill.name,rules.rank(skill.id),skill.description],func():rules.learn(skill.id);skills())
	for element in ["fire","frost","poison"]:game.button("Attune active spell: "+element,func():state().spell=element;skills())
	game.button("Return",hub)
func companions() -> void:
	game.open_panel("THE WANDERING SENTINEL","The sentinel was forged by Ves from a name Mara refused to surrender. It follows the Wayfarer to learn whether duty can become love.\nBond: %d • %s"%[state().relation,"Trusted companion" if state().relation>=10 else "Cautious ally"])
	if State.companion:
		for order in ["follow","guard","stay"]:game.button("Order: "+order,func():state().companion_order=order;companions())
		game.button("Ask about the sentinel's past",func():game.open_panel("A NAME IN THE METAL","I remember a bell, and a girl who would not let them silence it. If we break the Covenant, will I still be here?\n\nYour deeds strengthen our bond. At bond 10 the sentinel fights more fiercely.");game.button("I will find a way",companions))
	else:game.button("Recruit at the keeper's camp",func():game.say("Speak to the keeper to recruit the sentinel"))
	game.button("Return",hub)
func settlement() -> void:
	var s=state().settlement
	game.open_panel("FREEHOLD COUNCIL","Mine %d • Market %d • Fort %d\nTreasury %d gold • Ore shipments %d\nEach 240-second world day generates income from mines and markets. Fortifications reduce incoming damage. Commodities sell at different rates in each land.\n\n"%[s.mine,s.market,s.fort,s.treasury,state().commodities]+str(state().reputation))
	if game.hero.position.length()<18:
		for kind in ["mine","market","fort"]:game.button("Build "+kind+" • %d gold + 3 ore"%(60+s[kind]*40),func():rules.building(kind);settlement())
		game.button("Collect treasury",func():State.gold+=int(s.treasury);s.treasury=0;settlement())
		game.button("Buy trade shipment • %d gold"%(15+State.land*7),func():
			if State.gold>=15+State.land*7:State.gold-=15+State.land*7;state().commodities+=1;settlement())
		game.button("Sell shipment • %d gold"%(18+State.land*10+rules.rank("bargain")*2),func():
			if state().commodities>0:state().commodities-=1;State.gold+=18+State.land*10+rules.rank("bargain")*2;settlement())
	game.button("Return",hub)
func appearance() -> void:
	game.open_panel("APPEARANCE","Choose a cloak and armor palette. Equipment changes the held weapon.")
	for i in range(4):game.button(["Ivory wayfarer","Crimson exile","Verdant pilgrim","Gilded envoy"][i],func():state().skin=i;apply_appearance();appearance())
	game.button("Return",hub)
func apply_appearance() -> void:
	if not is_instance_valid(game.hero):return
	tint_actor(game.hero)
	preload("res://systems/weapons.gd").equip(game.hero,state().weapon)
func local_map() -> void:
	var current=Vector2(game.hero.position.x,game.hero.position.z)
	game.open_panel("LOCAL ATLAS","Wayfarer: %.0f, %.0f\nCamp: 0, 4\nKeeper: -6, -4\nChronicler: 12, -9 (travels home at night)\nAncient descent: 20, -50\nWarden: 0, -65\n\nExplore away from the road for treasure. Q toggles lock-on. R rotates the camera."%[current.x,current.y])
	for p in [Vector3(-24,0,-48),Vector3(34,0,-72),Vector3(-42,0,18)]:
		if game.hero.position.distance_to(p)<15 and not state().discoveries.has(str(p)):state().discoveries.append(str(p))
	for i in range(streaming.CELLS.size()):
		if state().discoveries.has("%d:%d"%[State.land,i]):game.button("Travel: "+streaming.REGIONS[State.land][i],func():streaming.travel(i))
	for r in enrichment.regions:
		if int(r.land)==State.land and not state().discoveries.has(r.id):
			var x=(r.cell[0]+.5)*96;var z=(r.cell[1]+.5)*96
			game.button("Survey: %s • %.0f, %.0f"%[r.name,x,z],func():game.say("Follow the coordinates on the local atlas");game.close())
	game.button("Return",hub)
func apply_quality() -> void:
	var p=int(state().preset)
	State.quality=0 if p==0 else 1
	game.sun.shadow_enabled=p>0
	game.get_viewport().scaling_3d_scale=[.65,.8,1.0,1.0,1.0][p]
	game.get_viewport().msaa_3d=[Viewport.MSAA_DISABLED,Viewport.MSAA_DISABLED,Viewport.MSAA_2X,Viewport.MSAA_4X,Viewport.MSAA_4X][p]
	Engine.max_fps=30 if p==0 else 60
	enrichment.refresh_surfaces()
	enrichment.quality_tree(game.world)
	for node in game.world.get_children():
		if node is OmniLight3D:node.visible=p>=2
func enter_dungeon() -> void:
	capture();dungeon=true;obstacles.clear();boss_intro.clear()
	for e in game.enemies:e.node.queue_free()
	game.enemies.clear()
	for b in bolts:b.node.queue_free()
	bolts.clear()
	for item in game.pickups:item.queue_free()
	game.pickups.clear()
	dungeon_anchor=Vector3(3500,0,60);game.hero.position=dungeon_anchor
	Art.label(game.world,"RETURN TO THE SURFACE • E / SPEAK",dungeon_anchor+Vector3(0,3,0),Color("b9d6de"))
	for i in range(5):
		var center=Vector3(3500,0,50-i*16)
		Art.box(game.world,center+Vector3(0,-.03,0),Vector3(18,.2,16),Color("33394d"))
		for x in [-9,9]:
			var p=center+Vector3(x,2,0);Art.box(game.world,p,Vector3(1,4,16),Color("414960"));obstacles.append({"pos":p,"size":Vector3(1,4,16)})
		for j in range(3):game.spawn_enemy(center+Vector3(-4+j*4,0,-4),false)
	game.spawn_enemy(Vector3(3500,0,-20),false);game.enemies[-1].hp=350;game.enemies[-1].max=350
	game.environment.environment.fog_density=.035
	enrichment.decorate_dungeon(dungeon_anchor)
	game.say("THE UNDERCOVENANT • Defeat the vault guardians")
func leave_dungeon() -> void:
	game.load_land(State.land);game.hero.position=Vector3(20,0,-46)

func tint_actor(node:Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.material_override is StandardMaterial3D:
			child.material_override.albedo_color=[Color("ddd2af"),Color("a94459"),Color("458c76"),Color("c59b54")][int(state().skin)]
		tint_actor(child)

func break_props() -> void:
	for node in game.world.get_children():
		if node.has_meta("breakable") and node.position.distance_to(game.hero.position)<4:
			node.queue_free();State.ore+=1;game.say("Supply cache broken • +1 ore")

func _notification(what:int) -> void:
	if what==NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(battle):battle.stream_paused=true;foot.stop()
	if what==NOTIFICATION_APPLICATION_RESUMED and is_instance_valid(battle):battle.stream_paused=false
func _exit_tree() -> void:
	if is_instance_valid(battle):battle.stop()
	if is_instance_valid(foot):foot.stop()

func release_projectile(b:Dictionary) -> void:
	bolts.erase(b)
	if is_instance_valid(b.node):
		if projectile_pool.size()<64:b.node.hide();projectile_pool.append(b.node)
		else:b.node.queue_free()
