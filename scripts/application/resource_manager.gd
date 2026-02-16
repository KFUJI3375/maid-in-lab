extends Node
var _materials: Dictionary[String, MaterialResource] = {}
var _solutes: Dictionary[String, SoluteResource] = {}

func _ready():
	# あとでフォルダ内のリソースファイルから素材を読み込む処理を追加する
	# とりあえずはコード内で直接素材を登録しておく
	# 回復成分溶質
	var healing_ingredient_solute = SoluteResource.new()
	healing_ingredient_solute.name = "HealingIngredient"
	var ing_efficacys: Array[String] = ["Healing"]
	healing_ingredient_solute.efficacys = ing_efficacys
	healing_ingredient_solute.dissolution_rate = 0.0
	# healing_ingredient_solute.inner_solutes = {} # 反応して生成される物質はないとする
	_solutes["HealingIngredient"] = healing_ingredient_solute

	# 薬草溶質
	var herb_solute_resource: SoluteResource = SoluteResource.new()
	herb_solute_resource.name = "Herb"
	var efficacys: Array[String] = ["Healing"]
	herb_solute_resource.efficacys = efficacys
	herb_solute_resource.dissolution_rate = 0.5
	var inner_solutes: Dictionary[String, float] = {"HealingIngredient": 1.0} # ハーブは完全に溶解すると回復成分を1.0g生成するとする
	herb_solute_resource.inner_solutes = inner_solutes
	_solutes["Herb"] = herb_solute_resource

	var herb_material = MaterialResource.new()
	herb_material.name = "Herb"
	var solute_dict: Dictionary[String, float] = {"Herb": 1.0}
	herb_material.solutes = solute_dict # ハーブは「Herb」という溶質を1.0g含むとする
	_materials["Herb"] = herb_material


func get_material(p_name: String) -> MaterialResource:
	# 保持している素材の中から名前で検索して返す
	# 存在しない場合はnullを返す
	if _materials.has(p_name):
		var item = _materials[p_name].duplicate()
		return item
	return null

func get_solute(p_name: String) -> SoluteResource:
	# 素材から溶質を取得するためのユーティリティ関数
	if _solutes.has(p_name):
		var item = _solutes[p_name].duplicate()
		return item
	return null
