extends Node
var _materials: Dictionary[String, MaterialItem] = {}
var _solutes: Dictionary[String, Solute] = {}

func _ready():
	# あとでフォルダ内のリソースファイルから素材を読み込む処理を追加する
	# とりあえずはコード内で直接素材を登録しておく
	var herb_material = MaterialItem.new()
	herb_material.name = "Herb"
	herb_material.solutes = {"Herb": 1.0} # ハーブは「Herb」という溶質を1.0g含むとする
	_materials["Herb"] = herb_material
	var herb_solute = Solute.new("Herb", 1.0, 0.5, []) # ハーブの溶質も登録しておく

func get_material(p_name: String) -> MaterialItem:
	# 保持している素材の中から名前で検索して返す
	# 存在しない場合はnullを返す
	if _materials.has(p_name):
		var item = _materials[p_name].duplicate()
		return item
	return null

func get_solute(p_name: String) -> Solute:
	# 素材から溶質を取得するためのユーティリティ関数
	var material = get_material(p_name)
	if material:
		var solutes = material.get_solutes()
		if solutes.size() > 0:
			return solutes[0] # ここでは単純に最初の溶質を返す
	return null
