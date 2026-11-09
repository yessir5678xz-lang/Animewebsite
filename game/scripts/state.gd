extends Node
var land := 0
var gold := 35
var level := 1
var xp := 0
var potions := 4
var ore := 0
var rank := 0
var mercy := 0
var dominion := 0
var companion := false
var quests := [0, 0, 0]
var decisions := [0, 0, 0]
var volume := 0.45
var quality := 1
var touch_scale := 1.0
var elapsed := 0.0
var kills := 0
var save_path = "user://covenant.json"
func snapshot() -> Dictionary:
	return {"schema":1,"land":land,"gold":gold,"level":level,"xp":xp,"potions":potions,"ore":ore,"rank":rank,"mercy":mercy,"dominion":dominion,"companion":companion,"quests":quests,"decisions":decisions,"volume":volume,"quality":quality,"touch_scale":touch_scale,"elapsed":elapsed,"kills":kills}
func save_game() -> bool:
	var f = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if not f: return false
	f.store_string(JSON.stringify(snapshot()))
	f.flush()
	f.close()
	if FileAccess.file_exists(save_path):
		var previous = JSON.new()
		if previous.parse(FileAccess.get_file_as_string(save_path)) == OK and previous.data is Dictionary and previous.data.get("schema") == 1:
			DirAccess.copy_absolute(save_path, save_path + ".bak")
	return DirAccess.rename_absolute(save_path + ".tmp", save_path) == OK
func load_game() -> bool:
	for path in [save_path, save_path + ".bak"]:
		if not FileAccess.file_exists(path): continue
		var parser = JSON.new()
		if parser.parse(FileAccess.get_file_as_string(path)) != OK: continue
		var d = parser.data
		if not d is Dictionary or d.get("schema") != 1: continue
		if not d.get("quests") is Array or d.quests.size() != 3: continue
		if not d.get("decisions") is Array or d.decisions.size() != 3: continue
		if not valid_save(d): continue
		for key in snapshot():
			if key != "schema" and d.has(key): set(key, d[key])
		land = clampi(land, 0, 2)
		return true
	return false
func reward(amount:int) -> void:
	xp += amount
	while xp >= level * 60:
		xp -= level * 60
		level += 1
func _notification(what:int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED: save_game()

func valid_save(d:Dictionary) -> bool:
	for key in ["land","gold","level","xp","potions","ore","rank","mercy","dominion","quality","elapsed","kills","volume","touch_scale"]:
		if not d.has(key) or not (d[key] is float or d[key] is int) or not is_finite(float(d[key])) or d[key]<0: return false
	if d.level<1 or d.land>2 or d.quality>1 or d.volume>1 or d.touch_scale<1 or d.touch_scale>1.2: return false
	if not d.get("companion") is bool: return false
	for list in [d.quests,d.decisions]:
		for entry in list:
			if not (entry is float or entry is int) or entry < 0 or entry > 2 or entry != floor(entry): return false
	return true
