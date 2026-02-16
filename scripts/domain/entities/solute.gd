class_name Solute
extends RefCounted

# 残りを全部溶解させるための絶対的な最小値
const MINIMUM_MASS: float = 1e-4

var _mass: float
var _resource: SoluteResource

func _init(resource: SoluteResource, p_mass: float) -> void:
	_mass = p_mass
	_resource = resource.duplicate()

func _to_string() -> String:
	return "%s: %.5f g" % [_resource.name, _mass]

func duplicate() -> Solute:
	return Solute.new(_resource, _mass)

func combine(other: Solute) -> Solute:
	if not is_same_name(other):
		assert(false, "同名の溶質同士しか結合できません (%s と %s)" % [_resource.name, other._resource.name])
	return Solute.new(_resource, _mass + other._mass)

func is_same_name(other: Solute) -> bool:
	return _resource.name == other._resource.name

func dissolve(delta: float) -> SoluteList:
	# 反応した質量を計算
	var dissolved_mass = _resource.dissolution_rate * _mass * delta
	var new_mass = _mass - dissolved_mass
	if new_mass <= MINIMUM_MASS:
		# 閾値以下なら残りをすべて溶解させて0にする（質量保存）
		dissolved_mass = _mass
		new_mass = 0.0
	else:
		new_mass = max(0.0, new_mass)

	# 新たに生成された物質
	var new_solutes = SoluteList.new(_resource.get_inner_solutes(dissolved_mass))
	# 自分自身も残るなら新しいSoluteとして追加する
	if new_mass > MINIMUM_MASS:
		new_solutes = new_solutes.append(Solute.new(_resource, new_mass))
	return new_solutes
