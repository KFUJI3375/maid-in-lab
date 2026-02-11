class_name ActiveIngredient
extends RefCounted

# 成分タイプ（溶解性）
enum ComponentType {
	WATER_SOLUBLE,   # 水溶性
	FAT_SOLUBLE,     # 脂溶性
	VOLATILE         # 揮発性
}

# 効果
enum Effect {
	HEALING,         # 回復
	MANA_RECOVERY,   # マナ回復
	DETOXIFICATION,  # 毒消し
	STRENGTH,        # 筋力強化
	AGILITY,         # 敏捷性向上
	MAGIC_POWER      # 魔力増強
}

var name: String
var component_type: ComponentType
var effect: Effect
var concentration: float  # 濃度 (0-100)
var heat_stability: float  # 熱安定性 (0-1, 高いほど安定)

func _init(
	p_name: String,
	p_type: ComponentType,
	p_effect: Effect,
	p_concentration: float,
	p_heat_stability: float
):
	name = p_name
	component_type = p_type
	effect = p_effect
	concentration = p_concentration
	heat_stability = p_heat_stability

# 高温での分解量を計算
# delta: 経過時間（秒）
func calculate_degradation(temperature: float, delta: float) -> float:
	if temperature < 80.0:
		return 0.0
	
	# 80度以上で分解開始
	var temp_factor = (temperature - 80.0) / 20.0  # 0-1 (80-100度)
	var degradation_rate = (1.0 - heat_stability) * temp_factor
	# 1秒あたり最大10%分解（heat_stability=0, temp_factor=1の場合）
	return degradation_rate * delta * 10.0

# ファクトリーメソッド：回復化合物（水溶性、熱に強い）
static func create_healing_compound() -> ActiveIngredient:
	return ActiveIngredient.new(
		"回復化合物",
		ComponentType.WATER_SOLUBLE,
		Effect.HEALING,
		30.0,  # 濃度
		0.8    # 熱安定性（高い）
	)

# ファクトリーメソッド：精油（揮発性、熱に弱い）
static func create_essential_oil() -> ActiveIngredient:
	return ActiveIngredient.new(
		"精油",
		ComponentType.VOLATILE,
		Effect.HEALING,
		20.0,  # 濃度
		0.2    # 熱安定性（低い）
	)

# ファクトリーメソッド：樹脂（脂溶性、熱に強い）
static func create_resin() -> ActiveIngredient:
	return ActiveIngredient.new(
		"樹脂",
		ComponentType.FAT_SOLUBLE,
		Effect.HEALING,
		15.0,  # 濃度
		0.9    # 熱安定性（非常に高い）
	)
