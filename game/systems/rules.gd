class_name RPGRules
extends RefCounted
var data:Dictionary
func _init() -> void:
	data=JSON.parse_string(FileAccess.get_file_as_string("res://data/rpg.json"))
func defaults() -> Dictionary:
	return {"weapon":"sword","weapons":["sword"],"armor":0,"enchantment":"none","skills":{},"spent":0,"mastery":{},"reputation":{"Bellkeepers":0,"Verdant Court":0,"Free Guilds":0},"contracts":{},"progress":{"kill":0,"dungeon":0,"testimony":0,"kill_0":0,"kill_1":0,"kill_2":0,"dungeon_0":0,"dungeon_1":0,"dungeon_2":0,"testimony_0":0,"testimony_1":0,"testimony_2":0},"relation":0,"companion_order":"follow","settlement":{"mine":0,"market":0,"fort":0,"treasury":0,"last_day":0},"commodities":0,"skin":0,"weather":0,"camera":0.0,"discoveries":[],"chests":[],"dungeons":[],"worlds":{},"chunks":{},"resume":{},"preset":1,"adaptive":true,"controls":"standard","spell":"fire","enrichment":{"choices":{},"trials":[],"seen":[]}}
func rank(id:String) -> int:
	return int(State.rpg.skills.get(id,0))
func max_health() -> float: return 100+State.level*10+rank("vigor")*25
func weapon() -> Dictionary: return data.weapons[State.rpg.weapon]
func skill_points() -> int: return maxi(0,State.level*2-int(State.rpg.spent))
func learn(id:String) -> bool:
	for skill in data.skills:
		if skill.id==id and rank(id)<5 and skill_points()>=skill.cost:
			State.rpg.skills[id]=rank(id)+1;State.rpg.spent+=int(skill.cost);return true
	return false
func price(amount:int) -> int:
	var faction=["Bellkeepers","Verdant Court","Free Guilds"][State.land]
	return maxi(1,int(amount*(1.0-rank("bargain")*.08-clampf(State.rpg.reputation[faction]*.001,-.2,.15))))
func purchase(id:String) -> bool:
	if not data.weapons.has(id) or State.rpg.weapons.has(id):return false
	var cost=price(data.weapons[id].cost)
	if State.gold<cost:return false
	State.gold-=cost;State.rpg.weapons.append(id);return true
func accept(id:String) -> bool:
	if State.rpg.contracts.has(id):return false
	for q in data.quests:
		if q.id==id:
			State.rpg.contracts[id]={"status":"active","start":int(State.rpg.progress.get(q.kind+"_"+str(int(q.land)),0))};return true
	return false
func contract_progress(q:Dictionary) -> int:
	if not State.rpg.contracts.has(q.id):return 0
	if q.kind=="ore":return State.ore
	return int(State.rpg.progress.get(q.kind+"_"+str(int(q.land)),0))-int(State.rpg.contracts[q.id].start)
func claim(id:String) -> bool:
	for q in data.quests:
		if q.id!=id or not State.rpg.contracts.has(id):continue
		if State.rpg.contracts[id].status!="active" or contract_progress(q)<q.goal:return false
		if q.kind=="ore":State.ore-=int(q.goal)
		State.gold+=int(q.gold);State.reward(int(q.gold));State.rpg.reputation[q.faction]+=10
		State.rpg.contracts[id].status="complete";return true
	return false
func building(kind:String) -> bool:
	if not kind in ["mine","market","fort"]:return false
	var cost=60+int(State.rpg.settlement[kind])*40
	if State.gold<cost or State.ore<3:return false
	State.gold-=cost;State.ore-=3;State.rpg.settlement[kind]+=1;return true
func economy_tick() -> void:
	var day=int(State.elapsed/240)
	var count=day-int(State.rpg.settlement.last_day)
	if count<=0:return
	State.rpg.settlement.last_day=day
	State.rpg.settlement.treasury+=count*(State.rpg.settlement.mine*8+State.rpg.settlement.market*12)
func validate(d:Dictionary) -> bool:
	var base=defaults()
	for key in base:
		if key=="enrichment" and not d.has(key):continue
		if not d.has(key) or typeof(d[key])!=typeof(base[key]):
			# JSON numbers parse as floats; allow only the numeric conversion.
			if not d.has(key) or not ((base[key] is int or base[key] is float) and (d[key] is int or d[key] is float)):return false
	if not data.weapons.has(d.weapon) or not d.weapons.has(d.weapon):return false
	for id in d.weapons:
		if not id is String or not data.weapons.has(id):return false
	for id in d.mastery:
		if not data.weapons.has(id) or not numeric(d.mastery[id],0,1000000):return false
	for id in d.skills:
		if not id in ["vigor","force","focus","siphon","shadow","precision","bargain","ward"] or not numeric(d.skills[id],0,5):return false
	for f in base.reputation:
		if not d.reputation.has(f) or not numeric(d.reputation[f],-100,1000):return false
	for p in base.progress:
		if not d.progress.has(p) or not numeric(d.progress[p],0,10000000):return false
	for b in base.settlement:
		if not d.settlement.has(b) or not numeric(d.settlement[b],0,100000000):return false
	for k in ["armor","spent","relation","commodities","skin","weather","preset"]:
		if not numeric(d[k],0,1000000):return false
	if not d.controls in ["standard","raised"] or not d.spell in ["fire","frost","poison"]:return false
	if d.preset>4 or d.preset!=floor(d.preset) or d.skin>3 or not d.enchantment in ["none","fire","frost","poison"] or not d.companion_order in ["follow","guard","stay"]:return false
	for id in d.worlds:
		var w=d.worlds[id]
		if not w is Dictionary or not w.get("enemies") is Array or not w.get("ore") is Array:return false
		for e in w.enemies:
			if not e is Dictionary or not valid_enemy_extra(e):return false
			if not e is Dictionary or not valid_point(e.get("pos")) or not numeric(e.get("hp"),1,1000000) or not e.get("boss") is bool:return false
		for point in w.ore:
			if not valid_point(point):return false
	for key in d.chunks:
		if not d.chunks[key] is Array:return false
		for e in d.chunks[key]:
			if not e is Dictionary or not valid_enemy_extra(e):return false
			if not e is Dictionary or not valid_point(e.get("pos")) or not numeric(e.get("hp"),1,1000000):return false
	if not d.resume.is_empty():
		if not numeric(d.resume.get("land"),0,2) or not numeric(d.resume.get("x"),-10000000,10000000) or not numeric(d.resume.get("z"),-10000000,10000000) or not numeric(d.resume.get("hp"),0,1000000) or not numeric(d.resume.get("mana"),0,100) or not d.resume.get("dungeon") is bool:return false
	for id in d.contracts:
		var valid=false
		for q in data.quests:
			if q.id==id:valid=true
		if not valid or not d.contracts[id] is Dictionary:return false
		if not d.contracts[id].get("status") in ["active","complete"] or not numeric(d.contracts[id].get("start"),0,10000000):return false
	if d.has("enrichment"):
		var e=d.enrichment
		if not e is Dictionary or not e.get("choices") is Dictionary or not e.get("trials") is Array or not e.get("seen") is Array:return false
		var valid_ids=[]
		for r in JSON.parse_string(FileAccess.get_file_as_string("res://data/regions.json")).regions:valid_ids.append(r.id)
		for id in e.choices:
			if not id in valid_ids or not numeric(e.choices[id],1,2) or e.choices[id]!=floor(e.choices[id]):return false
		for id in e.trials+e.seen:
			if not id in valid_ids:return false
	return true
func numeric(value:Variant,low:float,high:float) -> bool:
	return (value is float or value is int) and is_finite(value) and value>=low and value<=high

func valid_point(p:Variant) -> bool:
	return p is Array and p.size()==2 and numeric(p[0],-10000000,10000000) and numeric(p[1],-10000000,10000000)

func valid_enemy_extra(e:Dictionary) -> bool:
	if e.has("style") and not e.style in ["soldier","ranger","hexer","charger"]:return false
	if e.has("trial"):
		if not e.trial is String:return false
		if not e.trial.is_empty():
			var known=false
			for r in JSON.parse_string(FileAccess.get_file_as_string("res://data/regions.json")).regions:
				if r.id==e.trial and r.activity=="trial":known=true
			if not known:return false
	return true
