class_name AlchemyProcess
extends RefCounted

signal progress_updated(percentage: float)
signal completed(potion: Potion)

var herb: Herb
var temperature: Temperature
var progress: float = 0.0  # 0-100
var is_active: bool = false
var is_completed: bool = false

func _init(p_herb: Herb):
	herb = p_herb
	temperature = Temperature.new()

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
	
	# 細胞壁破壊プロセス
	if temperature.value >= 60.0 and not is_completed:
		var efficiency = calculate_efficiency()
		progress += efficiency * delta * 10.0
		progress = min(progress, 100.0)
		progress_updated.emit(progress)
		
		if progress >= 100.0:
			is_completed = true
			var potion = create_potion()
			completed.emit(potion)

func calculate_efficiency() -> float:
	# 最適温度に近いほど効率が良い
	var temp_diff = abs(temperature.value - herb.optimal_temperature)
	if temp_diff <= 5.0:
		return 2.0  # 最適温度なら2倍速
	elif temp_diff <= 15.0:
		return 1.0  # 普通
	else:
		return 0.5  # 温度が離れすぎていると遅い

func create_potion() -> Potion:
	var quality = determine_quality()
	var potency = calculate_potency()
	var color = determine_color(quality)
	return Potion.new("回復薬", quality, potency, color)

func determine_quality() -> Potion.Quality:
	if temperature.is_optimal_for(herb.optimal_temperature, 5.0):
		return Potion.Quality.EXCELLENT
	elif temperature.is_optimal_for(herb.optimal_temperature, 10.0):
		return Potion.Quality.GOOD
	elif temperature.is_optimal_for(herb.optimal_temperature, 20.0):
		return Potion.Quality.NORMAL
	else:
		return Potion.Quality.POOR

func calculate_potency() -> float:
	var base_potency = 50.0
	var temp_bonus = 50.0 - abs(temperature.value - herb.optimal_temperature)
	return clamp(base_potency + temp_bonus, 10.0, 100.0)

func determine_color(quality: Potion.Quality) -> Color:
	match quality:
		Potion.Quality.EXCELLENT: return Color(1.0, 0.2, 0.2)  # 濃い赤
		Potion.Quality.GOOD: return Color(1.0, 0.5, 0.5)       # 赤
		Potion.Quality.NORMAL: return Color(1.0, 0.7, 0.7)     # 薄い赤
		Potion.Quality.POOR: return Color(0.6, 0.4, 0.4)       # 茶色っぽい
		_: return Color.WHITE
