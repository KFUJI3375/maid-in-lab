class_name BrewPotionUseCase
extends RefCounted

signal state_changed(state: String)

var _process: AlchemyProcess = null

func _init(solutes: SoluteList) -> void:
	_process = AlchemyProcess.new(solutes)

# 生成中のSolutionを取り出す
func get_solution_inventory() -> void:
	var solution = _process.get_solution()
	GlobalData.solution_inventory.append(solution)

func update(delta: float) -> void:
	if _process:
		_process.update(delta)
		emit_signal("state_changed", "成分: %s" % _process)
