class_name AlchemyProcess
extends RefCounted

signal progress_updated(percentage: float)
signal completed(potion: Potion)

# Constants
const CELL_BREAK_TEMP: float = 60.0
const PROGRESS_RATE: float = 10.0

# Efficiency thresholds
const OPTIMAL_TOLERANCE: float = 5.0
const GOOD_TOLERANCE: float = 15.0
const EFFICIENCY_OPTIMAL: float = 2.0
const EFFICIENCY_NORMAL: float = 1.0
const EFFICIENCY_POOR: float = 0.5

# Potency calculation
const BASE_POTENCY: float = 50.0
const TEMP_BONUS_RANGE: float = 50.0
const MIN_POTENCY: float = 10.0
const MAX_POTENCY: float = 100.0

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
	if temperature.value >= CELL_BREAK_TEMP and not is_completed:
		var efficiency = calculate_efficiency()
		progress += efficiency * delta * PROGRESS_RATE
		progress = min(progress, 100.0)
		progress_updated.emit(progress)
		
		if progress >= 100.0:
			is_completed = true
			var potion = create_potion()
			completed.emit(potion)

func calculate_efficiency() -> float:
	# 最適温度に近いほど効率が良い
	var temp_diff = abs(temperature.value - herb.optimal_temperature)
	if temp_diff <= OPTIMAL_TOLERANCE:
		return EFFICIENCY_OPTIMAL  # 最適温度なら2倍速
	elif temp_diff <= GOOD_TOLERANCE:
		return EFFICIENCY_NORMAL  # 普通
	else:
		return EFFICIENCY_POOR  # 温度が離れすぎていると遅い

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
	var base_potency = BASE_POTENCY
	var temp_bonus = TEMP_BONUS_RANGE - abs(temperature.value - herb.optimal_temperature)
	return clamp(base_potency + temp_bonus, MIN_POTENCY, MAX_POTENCY)

func determine_color(quality: Potion.Quality) -> Color:
	match quality:
		Potion.Quality.EXCELLENT: return Color(1.0, 0.2, 0.2)  # 濃い赤
		Potion.Quality.GOOD: return Color(1.0, 0.5, 0.5)       # 赤
		Potion.Quality.NORMAL: return Color(1.0, 0.7, 0.7)     # 薄い赤
		Potion.Quality.POOR: return Color(0.6, 0.4, 0.4)       # 茶色っぽい
		_: return Color.WHITE
