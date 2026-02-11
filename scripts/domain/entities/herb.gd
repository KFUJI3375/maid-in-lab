class_name Herb
extends RefCounted

var name: String
var cell_wall_strength: float
var optimal_temperature: float
var color: Color

# 新規：成分タイプとその含有量
var components: Dictionary = {
	"water_soluble": 0.0,
	"oil_soluble": 0.0,
	"volatile": 0.0
}

func _init(p_name: String, p_strength: float, p_optimal_temp: float, p_color: Color, p_components: Dictionary = {}):
	name = p_name
	cell_wall_strength = p_strength
	optimal_temperature = p_optimal_temp
	color = p_color

	# デフォルト値を設定
	if p_components.is_empty():
		components = {
			"water_soluble": 60.0, # デフォルトは水溶性が多い
			"oil_soluble": 20.0,
			"volatile": 20.0
		}
	else:
		components = p_components

# ファクトリーメソッド更新
static func create_healing_herb() -> Herb:
	return Herb.new(
		"回復薬草",
		100.0,
		80.0,
		Color(0.6, 0.8, 0.6),
		{
			"water_soluble": 60.0, # 水に溶けやすい成分が多い
			"oil_soluble": 25.0,
			"volatile": 15.0
		}
	)

# 将来の拡張：芳香薬草（揮発性成分が多い）
# static func create_aromatic_herb() -> Herb:
# 	return Herb.new(
# 		"芳香薬草",
# 		80.0,
# 		70.0,
# 		Color(0.8, 0.7, 0.9),
# 		{
# 			"water_soluble": 20.0,
# 			"oil_soluble": 30.0,
# 			"volatile": 50.0  # 精油が豊富
# 		}
# 	)

# 総成分量を取得
func get_total_component_amount() -> float:
	var total = 0.0
	for amount in components.values():
		total += amount
	return total
