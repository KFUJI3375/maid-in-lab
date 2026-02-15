class_name MaterialItem
extends Resource

@export var name: String = ""
@export var solutes: Dictionary[String, float] = {} # 溶質の名前と量のペア

func get_solutes() -> SoluteList:
	var solute_list = SoluteList.new()
	for solute_name in solutes.keys():
		var mass = solutes[solute_name]
		var solute = Solute.new(solute_name, mass)
		solute_list = solute_list.append(solute)
	return solutes.duplicate()
