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
func get_solution() -> Solution:
	if _solutes == null: return null
	return Solution.new(_solutes)

func _to_string() -> String:
	return str(_solutes)
