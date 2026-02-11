class_name AlchemyProcess
extends RefCounted

signal progress_updated(percentage: float)
signal completed(potion: Potion)
signal solution_updated(solution: Solution)
signal evaporation_warning(remaining_volume: float)
signal fiber_breakdown_updated(percentage: float) # 新規

var herb: Herb
var temperature: Temperature
var solution: Solution
var fiber_breakdown: float = 0.0 # 繊維破壊度（0-100）
var is_active: bool = false

func _init(p_herb: Herb, p_solvent: Solvent = null):
	herb = p_herb
	temperature = Temperature.new()

	# 溶媒を指定（デフォルトは水）
	var solvent = p_solvent if p_solvent else Solvent.create_water()
	solution = Solution.new(solvent)
	solution.add_herb(herb)

	# 溶液のシグナルを転送
	solution.color_changed.connect(_on_solution_color_changed)
	solution.volume_changed.connect(_on_volume_changed)

func start_heating() -> void:
	is_active = true

func stop_heating() -> void:
	is_active = false

func update(delta: float, heating_rate: float, cooling_rate: float) -> void:
	# 温度更新
	if is_active:
		temperature.increase(heating_rate * delta)
	else:
		temperature.decrease(cooling_rate * delta)

	# 溶液の温度も更新
	solution.temperature = temperature.value

	# 蒸発処理
	solution.process_evaporation(delta)

	# 繊維破壊プロセス
	if temperature.value >= 60.0:
		# 繊維破壊の効率を計算
		var efficiency = calculate_breakdown_efficiency()

		# 繊維破壊の進行速度（0-100の進捗）
		# fiber_strength に応じて調整
		var breakdown_rate = efficiency * delta * 100.0 / herb.plant_structure.fiber_strength

		fiber_breakdown += breakdown_rate
		fiber_breakdown = min(fiber_breakdown, 100.0)

		# 繊維破壊度に応じて成分を抽出
		solution.extract_ingredients(fiber_breakdown, delta)

		# 進捗通知
		progress_updated.emit(fiber_breakdown)
		fiber_breakdown_updated.emit(fiber_breakdown)

		# 溶液の状態を通知
		solution_updated.emit(solution)

		# 繊維が完全に破壊されたら完成
		if fiber_breakdown >= 100.0:
			var potion = create_potion()
			completed.emit(potion)

# 繊維破壊の効率を計算（温度依存）
func calculate_breakdown_efficiency() -> float:
	return herb.plant_structure.calculate_decomposition_efficiency(temperature.value)

func create_potion() -> Potion:
	var quality = determine_quality()
	return solution.create_potion(quality)

func determine_quality() -> Potion.Quality:
	# 温度管理と成分効力の両方で評価
	var temp_quality = calculate_temperature_quality()
	var potency_quality = calculate_potency_quality()

	# 低い方の品質を採用（両方の要件を満たす必要がある）
	return min(temp_quality, potency_quality) as Potion.Quality

func calculate_temperature_quality() -> Potion.Quality:
	var optimal_temp = herb.plant_structure.optimal_decomposition_temp

	if temperature.is_optimal_for(optimal_temp, 5.0):
		return Potion.Quality.EXCELLENT
	elif temperature.is_optimal_for(optimal_temp, 10.0):
		return Potion.Quality.GOOD
	elif temperature.is_optimal_for(optimal_temp, 20.0):
		return Potion.Quality.NORMAL
	else:
		return Potion.Quality.POOR

func calculate_potency_quality() -> Potion.Quality:
	# 成分の有効効力に基づく品質
	var total_potency = solution.get_total_effective_potency()
	var max_possible = 0.0

	# 最大可能効力を計算
	for ingredient in herb.active_ingredients:
		max_possible += ingredient.concentration

	if max_possible <= 0:
		return Potion.Quality.POOR

	var efficiency = total_potency / max_possible

	if efficiency >= 0.9:
		return Potion.Quality.EXCELLENT
	elif efficiency >= 0.7:
		return Potion.Quality.GOOD
	elif efficiency >= 0.5:
		return Potion.Quality.NORMAL
	else:
		return Potion.Quality.POOR

func _on_solution_color_changed(new_color: Color) -> void:
	# 溶液の色変化を上位レイヤーに��知
	pass

func _on_volume_changed(new_volume: float) -> void:
	# 蒸発による体積減少を警告
	if new_volume < 30.0:
		evaporation_warning.emit(new_volume)
