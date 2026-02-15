class_name Solution
extends RefCounted
var _solutes: SoluteList

func _init(solutes: SoluteList) -> void:
	# SolutionはSoluteListを保持するだけのシンプルなクラス
	# 将来的に、色や粘度などの属性を追加することもできる
	_solutes = solutes.duplicate()

func _to_string() -> String:
	# Solutionの内容を文字列で表現するためのメソッド
	return "製品: %s" % _solutes

func duplicate() -> Solution:
	# Solutionを複製するためのメソッド
	return Solution.new(_solutes.duplicate())
