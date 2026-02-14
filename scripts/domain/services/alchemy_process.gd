class_name AlchemyProcess
extends RefCounted

var _solutes: SoluteList

func _init(solutes: SoluteList) -> void:
	_solutes = solutes
	print("新しい醸造プロセスを開始しました。溶質: %s" % solutes)

func update(delta: float) -> void:
	# ここで醸造プロセスのロジックを更新する
	if _solutes == null: return
	_solutes = _solutes.dissolve(delta)

# 生成中のSolutionを取り出す
func get_solution() -> String:
	# ここでは仮に溶液の状態を文字列で返す
	var solution = "生成中の溶液: 未実装"
	return solution

func _to_string() -> String:
	return str(_solutes)
