class_name Solvent
extends RefCounted

# 溶媒の基本プロパティ
var name: String
var boiling_point: float
var evaporation_rate: float # 蒸発速度（将来の拡張用）

# 成分タイプごとの抽出効率（0.0-2.0）
var extraction_efficiency: Dictionary = {
	"water_soluble": 1.0,
	"oil_soluble": 1.0,
	"volatile": 1.0
}

func _init(p_name: String, p_boiling_point: float):
	name = p_name
	boiling_point = p_boiling_point
	evaporation_rate = 0.1

# ファクトリーメソッド：水
static func create_water() -> Solvent:
	var solvent = Solvent.new("水", 100.0)
	solvent.extraction_efficiency = {
		"water_soluble": 1.0, # 水溶性成分は普通に抽出
		"oil_soluble": 0.1, # 脂溶性成分はほとんど抽出できない
		"volatile": 0.5 # 揮発性成分は半分程度（加熱で失われる）
	}
	solvent.evaporation_rate = 0.05 # 水は蒸発しにくい
	return solvent

# 将来の拡張：エタノール（コメントアウト）
# static func create_alcohol() -> Solvent:
# 	var solvent = Solvent.new("エタノール", 78.4)
# 	solvent.extraction_efficiency = {
# 		"water_soluble": 0.5,
# 		"oil_soluble": 1.5,
# 		"volatile": 1.2
# 	}
# 	solvent.evaporation_rate = 0.15  # エタノールは蒸発しやすい
# 	return solvent

# 将来の拡張：混合溶媒
# static func create_mixed(water_ratio: float, alcohol_ratio: float) -> Solvent:
# 	var total = water_ratio + alcohol_ratio
# 	var w = water_ratio / total
# 	var a = alcohol_ratio / total
#
# 	var solvent = Solvent.new("混合溶媒(%d:%d)" % [water_ratio, alcohol_ratio],
# 	                          100.0 * w + 78.4 * a)
# 	# ... 効率の計算
# 	return solvent

# 特定の成分タイプの抽出効率を取得
func get_efficiency(component_type: String) -> float:
	return extraction_efficiency.get(component_type, 0.5)

# 沸騰しているか
func is_boiling(current_temperature: float) -> bool:
	return current_temperature >= boiling_point

# 蒸発量を計算
func calculate_evaporation(temperature: float, delta: float) -> float:
	if temperature >= boiling_point:
		return evaporation_rate * delta * 10.0 # 沸騰すると急激に蒸発
	elif temperature >= boiling_point - 20.0:
		return evaporation_rate * delta * 2.0 # 沸点に近いと少し蒸発
	return 0.0
