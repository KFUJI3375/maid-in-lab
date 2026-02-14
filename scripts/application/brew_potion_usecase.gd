class_name BrewPotionUseCase
extends RefCounted

signal state_changed(state: String)

var _process: AlchemyProcess = null

func _init() -> void:
	_process = AlchemyProcess.new(SoluteList.new([Solute.CreateHerb(1)]))

# 生成中のSolutionを取り出す
func get_and_clear_solution() -> String: # ここでは仮に溶液の状態を文字列で返す
	var solution = _process.get_solution()
	_process = null # 生成中のプロセスをクリア
	return solution

func update(delta: float) -> void:
	if _process:
		_process.update(delta)
		emit_signal("state_changed", "成分: %s" % _process)
