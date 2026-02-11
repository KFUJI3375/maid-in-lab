class_name Herb
extends RefCounted

var name: String
var plant_structure: PlantStructure
var active_ingredients: Array[ActiveIngredient] = []

# 後方互換性のため（削除予定）
var components: Dictionary = {}
var cell_wall_strength: float
var optimal_temperature: float
var color: Color

func _init(p_name: String, p_structure: PlantStructure, p_ingredients: Array[ActiveIngredient]):
	name = p_name
	plant_structure = p_structure
	active_ingredients = p_ingredients

	# 後方互換性のための値設定
	cell_wall_strength = p_structure.fiber_strength
	optimal_temperature = p_structure.optimal_decomposition_temp
	color = Color(0.6, 0.8, 0.6)

	# componentsも互換性のため空で初期化
	components = {
		"water_soluble": 0.0,
		"oil_soluble": 0.0,
		"volatile": 0.0
	}

# 表示名を取得
func get_display_name() -> String:
	return name

# 特定の効果を持つ成分を取得
func get_ingredients_by_effect(effect: ActiveIngredient.Effect) -> Array[ActiveIngredient]:
	var result: Array[ActiveIngredient] = []
	for ingredient in active_ingredients:
		if ingredient.effect == effect:
			result.append(ingredient)
	return result

# 総有効成分量
func get_total_ingredient_amount() -> float:
	var total = 0.0
	for ingredient in active_ingredients:
		total += ingredient.concentration
	return total

# ファクトリーメソッド：回復薬草
static func create_healing_herb() -> Herb:
	var structure = PlantStructure.create_normal_plant()

	var ingredients: Array[ActiveIngredient] = [
		ActiveIngredient.create_healing_compound(),
		ActiveIngredient.create_essential_oil()
	]

	return Herb.new("回復薬草", structure, ingredients)
