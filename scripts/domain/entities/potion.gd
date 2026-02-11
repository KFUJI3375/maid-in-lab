class_name Potion
extends RefCounted

enum Quality { POOR, NORMAL, GOOD, EXCELLENT }

var name: String
var quality: Quality
var potency: float  # 効果の強さ (0-100)
var color: Color

func _init(p_name: String, p_quality: Quality, p_potency: float, p_color: Color):
	name = p_name
	quality = p_quality
	potency = p_potency
	color = p_color

func get_quality_text() -> String:
	match quality:
		Quality.POOR: return "失敗作"
		Quality.NORMAL: return "普通"
		Quality.GOOD: return "良質"
		Quality.EXCELLENT: return "最高品質"
		_: return "不明"
