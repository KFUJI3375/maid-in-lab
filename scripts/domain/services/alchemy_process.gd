class_name AlchemyProcess
extends RefCounted

signal progress_updated(percentage: float)
signal completed(potion: Potion)
signal solution_updated(solution: Solution) # 新規：溶液の状態変化

var herb: Herb
var temperature: Temperature
var solution: Solution # 新規：溶液オブジェクト
var progress: float = 0.0 # 0-100
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

	# 細胞壁破壊プロセス
	if temperature.value >= 60.0:
		var efficiency = calculate_efficiency()
		var extraction_rate = efficiency * delta * 10.0

		# 成分を抽出
		solution.extract_component(herb.name, extraction_rate)

		progress += extraction_rate
		progress = min(progress, 100.0)
		progress_updated.emit(progress)

		# 溶液の状態を通知
		solution_updated.emit(solution)

		if progress >= 100.0:
			var potion = create_potion()
			completed.emit(potion)

func calculate_efficiency() -> float:
	var temp_diff = abs(temperature.value - herb.optimal_temperature)
	if temp_diff <= 5.0:
		return 2.0 # 最適温度なら2倍速
	elif temp_diff <= 15.0:
		return 1.0 # 普通
	else:
		return 0.5 # 温度が離れすぎていると遅い

func create_potion() -> Potion:
	var quality = determine_quality()
	return solution.create_potion(quality) # 溶液からポーションを生成

func determine_quality() -> Potion.Quality:
	if temperature.is_optimal_for(herb.optimal_temperature, 5.0):
		return Potion.Quality.EXCELLENT
	elif temperature.is_optimal_for(herb.optimal_temperature, 10.0):
		return Potion.Quality.GOOD
	elif temperature.is_optimal_for(herb.optimal_temperature, 20.0):
		return Potion.Quality.NORMAL
	else:
		return Potion.Quality.POOR

func _on_solution_color_changed(new_color: Color) -> void:
	# 溶液の色変化を上位レイヤーに通知
	pass
