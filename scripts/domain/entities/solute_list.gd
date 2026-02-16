class_name SoluteList
extends RefCounted

var _solutes: Array[Solute]

func _init(solutes: Array[Solute] = []) -> void:
	_solutes = solutes.duplicate() # 配列を複製して保持する

func _to_string() -> String:
	return str(_solutes)

# 新しい溶質を追加した新しいSoluteListを返す
func append(solute: Solute) -> SoluteList:
	# 名前をキーにしたマップで既存の溶質を集約し、渡された溶質をマージする
	var map: Dictionary = {}
	for existing_solute in _solutes:
		var name = existing_solute._resource.name
		map[name] = existing_solute.duplicate()

	var in_name = solute._resource.name
	if map.has(in_name):
		# 既存のものと結合して新しいSoluteにする
		map[in_name] = solute.combine(map[in_name])
	else:
		map[in_name] = solute.duplicate()

	var result_array: Array[Solute] = []
	for s in map.values():
		result_array.append(s)
	return SoluteList.new(result_array)

# 他のSoluteListを結合した新しいSoluteListを返す
func append_list(others: SoluteList) -> SoluteList:
	# 現在のリストと渡されたリストを名前キーでまとめて一度にマージする
	var map: Dictionary = {}
	for existing_solute in _solutes:
		var name = existing_solute._resource.name
		map[name] = existing_solute.duplicate()

	for solute in others.to_array():
		var name = solute._resource.name
		if map.has(name):
			map[name] = solute.combine(map[name])
		else:
			map[name] = solute.duplicate()

	var result_array: Array[Solute] = []
	for s in map.values():
		result_array.append(s)
	return SoluteList.new(result_array)

# すべての溶質を反応させた新しいSoluteListを返す
func dissolve(delta: float) -> SoluteList:
	var new_solutes = SoluteList.new([])
	for solute in _solutes:
		var dissolved_solutes = solute.dissolve(delta)
		new_solutes = new_solutes.append_list(dissolved_solutes)
	return new_solutes

# 配列を複製して返す
func to_array() -> Array[Solute]:
	return _solutes.duplicate()

func duplicate() -> SoluteList:
	return SoluteList.new(_solutes.duplicate())
