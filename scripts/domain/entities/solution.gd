class_name Solution
extends RefCounted

signal color_changed(new_color: Color)
signal concentration_changed(concentration: float)
signal volume_changed(new_volume: float)

# 抽出された成分
class ExtractedIngredient extends RefCounted:
	var original: ActiveIngredient
	var extracted_amount: float
	var degraded_amount: float

	func _init(p_original: ActiveIngredient):
		original = p_original
		extracted_amount = 0.0
		degraded_amount = 0.0

	# 有効な効力を計算
	func get_effective_potency() -> float:
		return max(0.0, extracted_amount - degraded_amount)

# 溶液の成分（後方互換性のため維持）
class Component extends RefCounted:
	var name: String
	var type: String
	var concentration: float

	func _init(p_name: String, p_type: String, p_concentration: float = 0.0):
		name = p_name
		type = p_type
		concentration = p_concentration

# 溶液の状態
var solvent: Solvent
var components: Array[Component] = []
var extracted_ingredients: Array[ExtractedIngredient] = [] # ← 追加
var color: Color = Color(0.8, 0.8, 1.0, 0.3)
var volume: float = 100.0
var temperature: float = 20.0
var herb: Herb # 追加された薬草の参照

func _init(p_solvent: Solvent = null):
	# デフォルトは水
	solvent = p_solvent if p_solvent else Solvent.create_water()

# 薬草を追加（新規実装）
func add_herb(p_herb: Herb) -> void:
	herb = p_herb

	# 有効成分から ExtractedIngredient を作成
	for ingredient in herb.active_ingredients:
		var extracted = ExtractedIngredient.new(ingredient)
		extracted_ingredients.append(extracted)

	# 後方互換性のために Component も作成
	var component = Component.new(herb.name, "healing", 0.0)
	components.append(component)

	update_color()

# 蒸発処理
func process_evaporation(delta: float) -> void:
	var evaporation = solvent.calculate_evaporation(temperature, delta)

	if evaporation > 0:
		volume -= evaporation
		volume = max(volume, 10.0)
		volume_changed.emit(volume)

# 体積変化による濃度調整
func update_concentration_by_volume() -> void:
	# 体積が減少すると濃度が上がる
	var concentration_factor = 100.0 / volume
	for component in components:
		component.concentration = min(component.concentration * concentration_factor, 100.0)

# 新規：繊維破壊度に応じた成分抽出
func extract_ingredients(fiber_breakdown: float, delta: float) -> void:
	if not herb:
		push_warning("Solution.extract_ingredients: 薬草が追加されていません")
		return

	# 繊維破壊度に応じた抽出速度（0-100%）
	var extraction_rate = fiber_breakdown / 100.0

	for extracted in extracted_ingredients:
		var ingredient = extracted.original

		# 溶媒による抽出効率（現在は水のみ）
		var solvent_efficiency = get_solvent_efficiency(ingredient.component_type)

		# 抽出可能な残り量
		var remaining = ingredient.concentration - extracted.extracted_amount
		if remaining > 0:
			# 抽出速度係数: 5.0 = 理想的な条件で1秒あたり最大5%抽出
			var extract_amount = extraction_rate * solvent_efficiency * delta * 5.0
			extract_amount = min(extract_amount, remaining)
			extracted.extracted_amount += extract_amount

		# 高温による分解
		var degradation = ingredient.calculate_degradation(temperature, delta)
		extracted.degraded_amount += degradation
		extracted.degraded_amount = min(extracted.degraded_amount, extracted.extracted_amount)

	# 後方互換性のためcomponentsも更新
	update_legacy_components()
	update_color()

# 溶媒による抽出効率（水の場合）
func get_solvent_efficiency(component_type: ActiveIngredient.ComponentType) -> float:
	match component_type:
		ActiveIngredient.ComponentType.WATER_SOLUBLE:
			return 1.0 # 水溶性は100%
		ActiveIngredient.ComponentType.VOLATILE:
			return 0.8 # 揮発性は80%
		ActiveIngredient.ComponentType.FAT_SOLUBLE:
			return 0.1 # 脂溶性は10%のみ
		_:
			return 0.5

# 後方互換性のためcomponentsを更新
func update_legacy_components() -> void:
	if components.is_empty() or not herb:
		return

	var total_potency = get_total_effective_potency()
	components[0].concentration = min(total_potency, 100.0)
	concentration_changed.emit(components[0].concentration)

# 効果別の効力を計算
func get_potency_by_effect(effect: ActiveIngredient.Effect) -> float:
	var total = 0.0
	for extracted in extracted_ingredients:
		if extracted.original.effect == effect:
			total += extracted.get_effective_potency()
	return total

# 総効力を計算
func get_total_effective_potency() -> float:
	var total = 0.0
	for extracted in extracted_ingredients:
		total += extracted.get_effective_potency()
	return total

# 最も高濃度の成分を取得
func get_primary_component() -> Component:
	if components.is_empty():
		return null

	var primary = components[0]
	for component in components:
		if component.concentration > primary.concentration:
			primary = component
	return primary

# 総濃度を取得（後方互換性）
func get_total_concentration() -> float:
	var total = 0.0
	for component in components:
		total += component.concentration
	return total

# 溶液の色を更新
func update_color() -> void:
	var total = get_total_effective_potency()

	if total <= 0:
		# 透明
		color = Color(0.8, 0.8, 1.0, 0.3)
	elif total < 10:
		# 薄い色
		var alpha = total / 10.0
		color = Color(0.6, 0.8, 0.6, 0.3 + alpha * 0.2)
	elif total < 30:
		# 徐々に濃く
		var progress = (total - 10.0) / 20.0
		color = Color(
			0.6,
			0.8,
			0.6,
			0.5 + progress * 0.3
		)
	elif total < 70:
		# 中間色
		var progress = (total - 30.0) / 40.0
		color = Color(
			0.6 + progress * 0.3,
			0.8,
			0.6 - progress * 0.1,
			0.8 + progress * 0.1
		)
	else:
		# 濃い色
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
	# 効果から自動的にポーション名を決定
	var potion_name = determine_potion_name()
	var potency = get_total_effective_potency()

	return Potion.new(potion_name, quality, potency, color)

# 最も効力の高い効果からポーション名を決定
func determine_potion_name() -> String:
	var max_potency = 0.0
	var primary_effect = ActiveIngredient.Effect.HEALING

	# 各効果の効力を計算
	for effect in [
		ActiveIngredient.Effect.HEALING,
		ActiveIngredient.Effect.MANA_RECOVERY,
		ActiveIngredient.Effect.DETOXIFICATION,
		ActiveIngredient.Effect.STRENGTH,
		ActiveIngredient.Effect.AGILITY,
		ActiveIngredient.Effect.MAGIC_POWER
	]:
		var potency = get_potency_by_effect(effect)
		if potency > max_potency:
			max_potency = potency
			primary_effect = effect

	# 効果に応じた名前を返す
	match primary_effect:
		ActiveIngredient.Effect.HEALING:
			return "回復薬"
		ActiveIngredient.Effect.MANA_RECOVERY:
			return "マナ回復薬"
		ActiveIngredient.Effect.DETOXIFICATION:
			return "解毒薬"
		ActiveIngredient.Effect.STRENGTH:
			return "筋力強化薬"
		ActiveIngredient.Effect.AGILITY:
			return "敏捷性の秘薬"
		ActiveIngredient.Effect.MAGIC_POWER:
			return "魔力増強剤"
		_:
			return "不明な薬"
