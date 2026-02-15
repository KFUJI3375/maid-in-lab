class_name Solute
extends RefCounted

# 残りを全部溶解させるための絶対的な最小値
const MINIMUM_MASS: float = 1e-4

var _name: String
var _mass: float
var _efficacys: Array[Efficacy]


var _dissolution_rate: float # 溶解速度 rate/s

func _init(p_name: String, p_mass: float, p_dissolution_rate: float, p_efficacys: Array[Efficacy]) -> void:
	_name = p_name
	_mass = p_mass
	_dissolution_rate = p_dissolution_rate
	_efficacys = p_efficacys

func _to_string() -> String:
	return "%s: %.5f g 効果: %s" % [_name, _mass, _efficacys]

func duplicate() -> Solute:
	return Solute.new(_name, _mass, _dissolution_rate, _efficacys.duplicate())

func combine(other: Solute) -> Solute:
	if not is_same_name(other):
		assert(false, "同名の溶質同士しか結合できません (%s と %s)" % [_name, other._name])
	return Solute.new(_name, _mass + other._mass, _dissolution_rate, _efficacys.duplicate())

func is_same_name(other: Solute) -> bool:
	return _name == other._name

func dissolve(delta: float) -> SoluteList:
	# 反応した質量を計算
	var dissolved_mass = _dissolution_rate * _mass * delta
	var new_mass = _mass - dissolved_mass
	if new_mass <= MINIMUM_MASS:
		# 閾値以下なら残りをすべて溶解させて0にする（質量保存）
		dissolved_mass = _mass
		new_mass = 0.0
	else:
		new_mass = max(0.0, new_mass)

	# 新たに生成された物質
	var new_solute = Solute.CreateHealingIngredient(dissolved_mass)
	return SoluteList.new([
		Solute.new(_name, new_mass, _dissolution_rate, _efficacys.duplicate()),
		new_solute])

static func CreateHerb(p_mass: float) -> Solute:
	return Solute.new("Mystic Herb", p_mass, 0.5, [])
static func CreateHealingIngredient(p_mass: float) -> Solute:
	return Solute.new("Healing Ingredient", p_mass, 0.0, [Efficacy.CreateHealing()])
