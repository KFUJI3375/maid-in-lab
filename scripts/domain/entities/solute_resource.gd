class_name SoluteResource
extends Resource

@export var name: String = "Undefined"
@export var efficacys: Array[String] = []
@export var dissolution_rate: float = 0.0 # 溶解速度 rate/s
@export var inner_solutes: Dictionary[String, float] = {} # 溶解して生成される物質の辞書 {"生成物の名前": 質量比}

func get_efficacys() -> Array[Efficacy]:
	var result = []
	for efficacy_name in efficacys:
		var efficacy = Efficacy.CreateByName(efficacy_name)
		result.append(efficacy)
	return result

func get_inner_solutes(mass: float) -> Array[Solute]:
	var result: Array[Solute] = []
	for solute_name in inner_solutes.keys():
		var ratio = inner_solutes[solute_name]
		var solute_mass = mass * ratio
		var solute_resource = ResourceManager.get_solute(solute_name)
		result.append(Solute.new(solute_resource, solute_mass))
	return result
