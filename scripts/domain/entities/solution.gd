class_name Solution
extends RefCounted

signal color_changed(new_color: Color)
signal concentration_changed(concentration: float)

# 溶液の成分
class Component extends RefCounted:
	var name: String
	var concentration: float # 濃度 (0-100%)

	func _init(p_name: String, p_concentration: float = 0.0):
		name = p_name
		concentration = p_concentration

# 溶液の状態
var components: Array[Component] = []
var color: Color = Color(0.8, 0.8, 1.0, 0.3) # 初期は透明に近い
var volume: float = 100.0 # ml
var temperature: float = 20.0

func _init():
	pass

# 薬草を追加
func add_herb(herb: Herb) -> void:
	var component = Component.new(herb.name, 0.0)
	components.append(component)
	update_color()

# 成分を抽出（加熱による）
func extract_component(component_name: String, amount: float) -> void:
	for component in components:
		if component.name == component_name:
			component.concentration += amount
			component.concentration = min(component.concentration, 100.0)
			concentration_changed.emit(component.concentration)
			update_color()
			break

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
