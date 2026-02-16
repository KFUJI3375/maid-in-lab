class_name Efficacy
extends RefCounted

# 効能を表すクラス
var description: String
var name: String

func _init(p_name: String, p_description: String) -> void:
	name = p_name
	description = p_description

func _to_string() -> String:
	return description

static func CreateByName(p_name: String) -> Efficacy:
	match p_name:
		"Healing":
			return Efficacy.new("Healing", "HP回復")
		_:
			return Efficacy.new("Undefined", "未定義の効果")
