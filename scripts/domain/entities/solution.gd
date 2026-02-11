class_name Solution
extends RefCounted

signal color_changed(new_color: Color)
signal concentration_changed(concentration: float)
signal volume_changed(new_volume: float) # 新規：蒸発検知

# 溶液の成分
class Component extends RefCounted:
	var name: String
	var type: String # 新規：成分タイプ（water_soluble, oil_soluble, volatile）
	var concentration: float # 濃度 (0-100%)

	func _init(p_name: String, p_type: String, p_concentration: float = 0.0):
		name = p_name
		type = p_type
		concentration = p_concentration

# 溶液の状態
var solvent: Solvent # 新規：溶媒
var components: Array[Component] = []
var color: Color = Color(0.8, 0.8, 1.0, 0.3)
var volume: float = 100.0 # ml
var temperature: float = 20.0

func _init(p_solvent: Solvent = null):
	# デフォルトは水
	solvent = p_solvent if p_solvent else Solvent.create_water()
	update_color()

# 薬草を追加
func add_herb(herb: Herb) -> void:
	# 各成分タイプごとにComponentを作成
	for component_type in herb.components:
		var component_name = "%s(%s)" % [herb.name, component_type]
		var component = Component.new(component_name, component_type, 0.0)
		components.append(component)

	update_color()

# 成分を抽出（加熱による）
func extract_component(herb: Herb, amount: float) -> void:
	for component in components:
		# この成分が薬草由来か確認
		if component.name.begins_with(herb.name):
			# 溶媒の抽出効率を考慮
			var efficiency = solvent.get_efficiency(component.type)
			var extraction_amount = amount * efficiency

			component.concentration += extraction_amount
			component.concentration = min(component.concentration, 100.0)

			concentration_changed.emit(component.concentration)
			update_color()

# 蒸発処理（新規）
func process_evaporation(delta: float) -> void:
	var evaporation = solvent.calculate_evaporation(temperature, delta)
	if evaporation > 0:
		volume -= evaporation
		volume = max(volume, 10.0) # 最低10ml残る
		volume_changed.emit(volume)

		# 体積が減ると濃度が上がる
		update_concentration_by_volume()

func update_concentration_by_volume() -> void:
	# 蒸発による濃縮効果
	var concentration_factor = 100.0 / volume
	for component in components:
		component.concentration = min(component.concentration * concentration_factor, 100.0)

# 最も高濃度の成分を取得
func get_primary_component() -> Component:
	if components.is_empty():
		return null

	var primary = components[0]
	for component in components:
		if component.concentration > primary.concentration:
			primary = component
	return primary

# 総濃度を取得
func get_total_concentration() -> float:
	var total = 0.0
	for component in components:
		total += component.concentration
	return total

# 溶液の色を更新
func update_color() -> void:
	var total = get_total_concentration()

	if total <= 0:
		# 透明
		color = Color(0.8, 0.8, 1.0, 0.3)
	elif total < 30:
		# 薄い緑
		var alpha = total / 30.0
		color = Color(0.6, 0.8, 0.6, 0.3 + alpha * 0.4)
	elif total < 70:
		# 緑から黄色へ
		var progress = (total - 30.0) / 40.0
		color = Color(
			0.6 + progress * 0.3,
			0.8,
			0.6 - progress * 0.1,
			0.7 + progress * 0.2
		)
	else:
		# 濃い赤（完成）
		var progress = (total - 70.0) / 30.0
		color = Color(
			0.9 + progress * 0.1,
			0.8 - progress * 0.6,
			0.5 - progress * 0.3,
			0.9 + progress * 0.1
		)

	color_changed.emit(color)

# 溶液から完成したポーションを生成
func create_potion(quality: Potion.Quality) -> Potion:
	var primary = get_primary_component()
	var potion_name = "回復薬" if primary else "不明な薬"
	var potency = get_total_concentration()

	return Potion.new(potion_name, quality, potency, color)
