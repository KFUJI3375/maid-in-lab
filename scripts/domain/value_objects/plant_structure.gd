class_name PlantStructure
extends RefCounted

var fiber_strength: float  # 繊維強度 (0-100)
var optimal_decomposition_temp: float  # 最適分解温度（℃）

func _init(p_fiber_strength: float, p_optimal_temp: float):
	fiber_strength = p_fiber_strength
	optimal_decomposition_temp = p_optimal_temp

# 分解効率を計算（温度に基づく）
func calculate_decomposition_efficiency(temperature: float) -> float:
	if temperature < 60.0:
		# 60度未満では分解が非常に遅い
		return 0.0
	
	# 最適温度との差を計算
	var temp_diff = abs(temperature - optimal_decomposition_temp)
	
	if temp_diff <= 5.0:
		# 最適温度なら2倍速
		return 2.0
	elif temp_diff <= 15.0:
		# 許容範囲内なら通常速度
		return 1.0
	else:
		# 温度が離れすぎていると遅い
		return 0.5

# ファクトリーメソッド：柔らかい植物（葉など）
static func create_soft_plant() -> PlantStructure:
	return PlantStructure.new(
		50.0,  # 繊維強度（低い）
		70.0   # 最適分解温度（低め）
	)

# ファクトリーメソッド：硬い植物（根、樹皮など）
static func create_hard_plant() -> PlantStructure:
	return PlantStructure.new(
		150.0,  # 繊維強度（高い）
		90.0    # 最適分解温度（高め）
	)

# ファクトリーメソッド：通常の植物
static func create_normal_plant() -> PlantStructure:
	return PlantStructure.new(
		100.0,  # 繊維強度（標準）
		80.0    # 最適分解温度（標準）
	)
