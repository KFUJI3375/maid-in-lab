class_name Solute
extends RefCounted

var _name: String
var name: String:
	get: return _name
var _mass: float
var mass: float:
	get: return _mass


var _dissolution_rate: float # 溶解速度 rate/s
var dissolution_rate: float:
	get: return _dissolution_rate

func _init(p_name: String, p_mass: float, p_dissolution_rate: float) -> void:
	_name = p_name
	_mass = p_mass
	_dissolution_rate = p_dissolution_rate

func _to_string() -> String:
	return "%s: %.5f g" % [_name, _mass]

func duplicate() -> Solute:
	return Solute.new(_name, _mass, _dissolution_rate)


func dissolve(delta: float) -> SoluteList:
	# 反応した質量を計算
	var dissolved_mass = _dissolution_rate * _mass * delta
	var new_mass = max(0, _mass - dissolved_mass)
	# 新たに生成された物質
	var new_solute = Solute.CreateHealingIngredient(dissolved_mass)
	return SoluteList.new([
		Solute.new(_name, new_mass, _dissolution_rate),
		new_solute])

static func CreateHerb(p_mass: float) -> Solute:
	return Solute.new("Mystic Herb", p_mass, 0.1)

static func CreateHealingIngredient(p_mass: float) -> Solute:
	return Solute.new("Healing Ingredient", p_mass, 0.0)
