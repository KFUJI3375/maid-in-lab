class_name Efficacy
extends RefCounted

# 効能を表すクラス
var description: String

func _init(p_description: String) -> void:
	description = p_description

func _to_string() -> String:
	return description

static func CreateHealing() -> Efficacy:
	return Efficacy.new("HP回復")
