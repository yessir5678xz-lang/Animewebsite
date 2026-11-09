extends Node
const Art=preload("res://scripts/art.gd")
const SIZE=96.0
var game:Node3D
var expansion:Node
var chunks:Dictionary={}
var last_cell=Vector2i(99999,99999)
var current_land=-1
const REGIONS=[["Mournwatch", "The Cinder Cathedral", "Hollowmere", "Blackbell Citadel", "Embergrave", "The Unnamed City", "Redwater Crypts", "Widow's Reach", "The Broken Muster", "Caves of the Ninth Bell", "The Ossuary Exchange", "Sanctuary of Last Breath", "The Ashen Crown", "Ravenfall Pass", "Vesper Below"], ["Moonfall Gardens", "The Skyroot Temple", "Glasswater", "Starbough Haven", "The Silver Cascade", "Dreamless Refuge", "Everspring Ruins", "Celestial Reach", "The Luminous Heart", "Prismspine Mountains", "Orchid Sea", "The Sunken Conservatory", "Grotto of Quiet Stars", "The Wild Court", "The Dawn Observatory"], ["Coppergate", "The Golden Harbor", "Ironwake", "The Merchant's Crown", "Aureate Palace", "Freeguild Market", "The Clockwork Vault", "The Last Mint", "Library of Open Ledgers", "The Hall of Petitions", "The Amber Granaries", "Bridge of Nine Charters", "Estate of Borrowed Summers", "The Concord Bastion", "Arena of the Uncrowned"]]
const CELLS=[Vector2i(-2,-2),Vector2i(2,-2),Vector2i(-3,1),Vector2i(3,1),Vector2i(-1,-4),Vector2i(1,-4),Vector2i(-4,-3),Vector2i(4,-3),Vector2i(-5,0),Vector2i(5,0),Vector2i(-3,-5),Vector2i(3,-5),Vector2i(-6,-4),Vector2i(6,-4),Vector2i(0,-6)]
func _ready() -> void:
	expansion=get_parent();game=expansion.game
func reset() -> void:
	chunks.clear();last_cell=Vector2i(99999,99999);current_land=State.land
func _process(_delta:float) -> void:
	if not is_instance_valid(game.hero) or game.panel.visible or expansion.dungeon:return
	if current_land!=State.land:reset()
	var p=game.hero.position
	var cell=Vector2i(floor(p.x/SIZE),floor(p.z/SIZE))
	if cell==last_cell:return
	last_cell=cell
	var needed=[]
	for x in range(cell.x-1,cell.x+2):
		for y in range(cell.y-1,cell.y+2):needed.append(Vector2i(x,y))
	for c in chunks.keys():
		if not needed.has(c):unload_chunk(c)
	for c in needed:
		if not chunks.has(c):load_chunk(c)
	var index=CELLS.find(cell)
	if index>=0:
		var key="%d:%d"%[State.land,index]
		if not State.rpg.discoveries.has(key):State.rpg.discoveries.append(key);State.reward(35);game.say("DISCOVERED • "+REGIONS[State.land][index])
func store_chunk(c:Vector2i) -> void:
	var list=[]
	for e in game.enemies:
		if e.get("chunk")==c:list.append({"pos":[e.node.position.x,e.node.position.z],"hp":e.hp,"style":e.get("style","soldier"),"trial":e.get("trial","")})
	State.rpg.chunks["%d:%d:%d"%[State.land,c.x,c.y]]=list
func unload_chunk(c:Vector2i) -> void:
	store_chunk(c)
	for e in game.enemies.duplicate():
		if e.get("chunk")==c:e.node.queue_free();game.enemies.erase(e)
	if is_instance_valid(chunks[c]):chunks[c].queue_free()
	chunks.erase(c)
func capture() -> void:
	for c in chunks:store_chunk(c)
func load_chunk(c:Vector2i) -> void:
	var root=Node3D.new();game.world.add_child(root);chunks[c]=root
	var center=Vector3((c.x+.5)*SIZE,0,(c.y+.5)*SIZE)
	var base=Color(game.lands[State.land].color);var accent=Color(game.lands[State.land].accent)
	if abs(center.x)<96 and abs(center.z)<96:return
	var ground=Art.box(root,center+Vector3(0,-.6,0),Vector3(SIZE,1,SIZE),base)
	ground.material_override=load("res://assets/terrain.tres").duplicate();ground.material_override.set_shader_parameter("tint",base.darkened(.2))
	var rng=RandomNumberGenerator.new();rng.seed=abs(c.x*7919+c.y*104729+State.land*2309)
	expansion.enrichment.decorate_chunk(root,center,c,ground)
	var key="%d:%d:%d"%[State.land,c.x,c.y]
	if State.rpg.chunks.has(key):
		for record in State.rpg.chunks[key]:
			game.spawn_enemy(Vector3(record.pos[0],0,record.pos[1]),false,record.get("style","soldier"));game.enemies[-1].hp=record.hp;game.enemies[-1].chunk=c
			if not record.get("trial","").is_empty():game.enemies[-1].trial=record.trial
	else:
		for i in range(3):game.spawn_enemy(center+Vector3(rng.randf_range(-30,30),0,rng.randf_range(-30,30)),false);game.enemies[-1].chunk=c
func travel(index:int) -> void:
	game.hero.position=Vector3((CELLS[index].x+.5)*SIZE,0,(CELLS[index].y+.5)*SIZE)
	game.close()
