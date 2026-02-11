class_name Temperature
extends RefCounted

const MIN_TEMP: float = 20.0
const MAX_TEMP: float = 100.0

var value: float

func _init(initial_value: float = MIN_TEMP):
	value = clamp(initial_value, MIN_TEMP, MAX_TEMP)

func increase(amount: float) -> void:
	value = clamp(value + amount, MIN_TEMP, MAX_TEMP)

func decrease(amount: float) -> void:
	value = clamp(value - amount, MIN_TEMP, MAX_TEMP)

func is_optimal_for(target_temp: float, tolerance: float = 10.0) -> bool:
	return abs(value - target_temp) <= tolerance
