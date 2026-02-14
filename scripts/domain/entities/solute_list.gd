class_name SoluteList
extends RefCounted

var _solutes: Array[Solute]

func _init(solutes: Array[Solute]) -> void:
	_solutes = solutes.duplicate() # 配列を複製して保持する

func _to_string() -> String:
	return str(_solutes)

# 新しい溶質を追加した新しいSoluteListを返す
func append(solute: Solute) -> SoluteList:
	var current_solutes: Array[Solute] = _solutes.duplicate()
	var new_solutes: Array[Solute] = []
	# _solutesに同名の溶質が存在する場合は、量を加算する
	var has_same_name = false
	for existing_solute in current_solutes:
		if existing_solute.name == solute.name:
			new_solutes.append(Solute.new(existing_solute.name, existing_solute.mass + solute.mass, existing_solute.dissolution_rate))
			has_same_name = true
		else:
			new_solutes.append(existing_solute.duplicate())
	# 同名の溶質が存在しない場合は、新しい溶質を追加する
	if not has_same_name:
		new_solutes.append(solute.duplicate())
	return SoluteList.new(new_solutes)

# 他のSoluteListを結合した新しいSoluteListを返す
func append_list(others: SoluteList) -> SoluteList:
	var result = self ;
	for solute in others.to_array():
		result = result.append(solute)
	return result

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
