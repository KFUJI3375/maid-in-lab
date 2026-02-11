class_name Herb
extends RefCounted

var name: String
var cell_wall_strength: float  # 細胞壁の強度
var optimal_temperature: float  # 最適温度
var color: Color

func _init(p_name: String, p_strength: float, p_temp: float, p_color: Color):
	name = p_name
	cell_wall_strength = p_strength
	optimal_temperature = p_temp
	color = p_color

static func create_healing_herb() -> Herb:
	return Herb.new("回復薬草", 100.0, 80.0, Color(0.6, 0.8, 0.6))
