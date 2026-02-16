class_name MaterialInventory
extends RefCounted
var _materials: Dictionary[String, int] = {}

signal inventory_changed(materials: Dictionary[String, int])

func _init(materials: Dictionary[String, int] = {}) -> void:
	# 初期状態では空の材料在庫
	_materials = materials.duplicate()

func append(material: MaterialResource, quantity: int) -> void:
	var name = material.name
	if _materials.has(name):
		_materials[name] += quantity
	else:
		_materials[name] = quantity
	emit_signal("inventory_changed", _materials.duplicate())

func get_materials() -> Dictionary:
	# 在庫のコピーを返す（外部から直接変更されないように）
	return _materials.duplicate()

# 指定した素材を在庫から引き出す。引き出せない場合はnullを返す。
func pull(material_name: String, quantity: int) -> Array[MaterialResource]:
	if not _materials.has(material_name):
		print("素材が在庫に存在しません: %s" % material_name)
		return []
	if _materials[material_name] < quantity:
		print("素材の在庫が不足しています: %s (必要: %d, 在庫: %d)" % [material_name, quantity, _materials[material_name]])
		return []
	# 在庫から引き出す
	_materials[material_name] -= quantity
	if _materials[material_name] <= 0:
		_materials.erase(material_name)
	emit_signal("inventory_changed", _materials.duplicate())
	var material_resource = ResourceManager.get_material(material_name)
	var result: Array[MaterialResource] = []
	for i in range(quantity):
		if material_resource:
			var pulled_material = material_resource.duplicate()
			result.append(pulled_material)
		else:
			print("素材リソースが見つかりません: %s" % material_name)
	return result
