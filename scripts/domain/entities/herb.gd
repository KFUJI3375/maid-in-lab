class_name Herb
extends RefCounted

var name: String
var plant_structure: PlantStructure  # 植物構造
var active_ingredients: Array[ActiveIngredient]  # 有効成分
var color: Color

func _init(p_name: String, p_structure: PlantStructure, p_ingredients: Array[ActiveIngredient], p_color: Color):
	name = p_name
	plant_structure = p_structure
	active_ingredients = p_ingredients
	color = p_color

# 成分タイプごとの総含有量を計算
func get_total_concentration_by_type(component_type: ActiveIngredient.ComponentType) -> float:
	var total = 0.0
	for ingredient in active_ingredients:
		if ingredient.component_type == component_type:
			total += ingredient.concentration
	return total

# 効果別の成分を取得
func get_ingredients_by_effect(effect: ActiveIngredient.Effect) -> Array[ActiveIngredient]:
	var result: Array[ActiveIngredient] = []
	for ingredient in active_ingredients:
		if ingredient.effect == effect:
			result.append(ingredient)
	return result

# 後方互換性のため維持（新モデルに対応）
static func create_healing_herb() -> Herb:
	var structure = PlantStructure.create_normal_plant()
	var ingredients: Array[ActiveIngredient] = [
		ActiveIngredient.create_healing_compound(),
		ActiveIngredient.create_essential_oil()
	]
	return Herb.new("回復薬草", structure, ingredients, Color(0.6, 0.8, 0.6))
