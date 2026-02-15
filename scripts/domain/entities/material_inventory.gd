class_name MaterialInventory
extends RefCounted
var _materials: Dictionary[String, int] = {}

signal inventory_changed(materials: Dictionary[String, int])

func _init(materials: Dictionary[String, int] = {}) -> void:
	# 初期状態では空の材料在庫
	_materials = materials.duplicate()

func append(material: MaterialItem, quantity: int) -> void:
	var name = material.name
	if _materials.has(name):
		_materials[name] += quantity
	else:
		_materials[name] = quantity
	emit_signal("inventory_changed", _materials.duplicate())

func get_materials() -> Dictionary:
	# 在庫のコピーを返す（外部から直接変更されないように）
	return _materials.duplicate()
