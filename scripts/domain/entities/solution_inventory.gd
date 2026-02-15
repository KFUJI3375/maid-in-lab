class_name SolutionInventory
extends RefCounted
signal solution_added(solution: Solution)
var _solutions: Array[Solution] = []

func _init(solutions: Array[Solution] = []) -> void:
	# 初期状態では空の製品在庫
	_solutions = solutions.duplicate()

func append(solution: Solution) -> void:
	_solutions.append(solution.duplicate())
	emit_signal("solution_added", solution)

func _to_string() -> String:
	return "製品インベントリ: %s" % _solutions
