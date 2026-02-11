class_name AlchemyProcess
extends RefCounted

signal progress_updated(percentage: float)
signal completed(potion: Potion)
signal solution_updated(solution: Solution) # 新規：溶液の状態変化
signal fiber_breakdown_info(breakdown: float)  # 新規：繊維破壊度の情報

var herb: Herb
var temperature: Temperature
var solution: Solution # 新規：溶液オブジェクト
var progress: float = 0.0 # 0-100
var fiber_breakdown: float = 0.0  # 新規：繊維破壊度 (0-100)
var is_active: bool = false

func _init(p_herb: Herb):
	herb = p_herb
	temperature = Temperature.new()
	solution = Solution.new() # 溶液を生成
	solution.add_herb(herb) # 薬草を溶液に追加

	# 溶液のシグナルを転送
	solution.color_changed.connect(_on_solution_color_changed)

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

	# 繊維破壊プロセス
	if temperature.value >= 60.0:
		# 植物構造の分解効率を計算
		var decomposition_efficiency = herb.plant_structure.calculate_decomposition_efficiency(temperature.value)
		
		# 繊維破壊速度（繊維強度に基づく）
		var breakdown_rate = decomposition_efficiency * delta * 100.0 / herb.plant_structure.fiber_strength
		fiber_breakdown += breakdown_rate
		fiber_breakdown = min(fiber_breakdown, 100.0)
		
		# 繊維破壊度を通知
		fiber_breakdown_info.emit(fiber_breakdown)
		
		# 繊維破壊度に応じた成分抽出
		solution.extract_ingredients(fiber_breakdown, delta)
		
		# 進捗は総効力に基づく
		progress = solution.get_total_effective_potency()
		progress = min(progress, 100.0)
		progress_updated.emit(progress)

		# 溶液の状態を通知
		solution_updated.emit(solution)

		if progress >= 100.0:
			var potion = create_potion()
			completed.emit(potion)

func calculate_efficiency() -> float:
	# 後方互換性のため維持（現在は使用されていない）
	return herb.plant_structure.calculate_decomposition_efficiency(temperature.value)

func create_potion() -> Potion:
	var quality = determine_quality()
	return solution.create_potion(quality) # 溶液からポーションを生成

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
	for ingredient in self.herb.active_ingredients:
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
	# 溶液の色変化を上位レイヤーに通知
	pass
