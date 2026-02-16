class_name MaterialResource
extends Resource

@export var name: String = ""
@export var solutes: Dictionary[String, float] = {} # 溶質の名前と比率のペア
@export var mass: float = 1.0 # このマテリアル1単位あたりの質量（g）

func get_solutes() -> Array[Solute]:
	var solute_list: Array[Solute] = []
	for solute_name in solutes.keys():
		var ratio = solutes[solute_name]
		var solute_mass = mass * ratio
		var solureResource = ResourceManager.get_solute(solute_name)
		var solute = Solute.new(solureResource, solute_mass)
		solute_list.append(solute)
	return solute_list
