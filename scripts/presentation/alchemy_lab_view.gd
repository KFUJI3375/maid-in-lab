extends Control

# ノードの参照
@onready var beaker_rect = $BeakerRect
@onready var add_herb_button = $UIContainer/AddHerbButton
@onready var material_list = $UIContainer/MaterialList

# Use Case
var brew_use_case: BrewPotionUseCase = null

func _ready():
	# UIボタンのシグナル接続
	GlobalData.solution_inventory.connect("solution_added", _on_solution_added)
	# マテリアル在庫の変更を監視してリストを更新
	if GlobalData.material_inventory:
		GlobalData.material_inventory.connect("inventory_changed", _on_material_inventory_changed)
	if add_herb_button:
		add_herb_button.pressed.connect(_on_add_herb_pressed)


	# 初期表示
	if GlobalData.material_inventory:
		_on_material_inventory_changed(GlobalData.material_inventory.get_materials())
	# デバッグ用にインベントリにハーブを追加しておく
	var res = ResourceManager.get_material("Herb")
	if res:
		GlobalData.material_inventory.append(res, 1)

func _process(delta):
	if brew_use_case:
		brew_use_case.update(delta)

func _on_add_herb_pressed():
	if brew_use_case == null:
		# material_listから選択されたアイテムを取得
		var selected_index = material_list.get_selected_items()
		if selected_index.size() <= 0:
			print("アイテムが選択されていません")
			return
		var metadata = material_list.get_item_metadata(selected_index[0])
		if not metadata:
			print("アイテムのメタデータが見つかりません")
			return
		var item_name = metadata[0]
		var qty = metadata[1]
		print("選択されたアイテム: %s x%d" % [item_name, qty])
		var material_items = GlobalData.material_inventory.pull(item_name, 1) # インベントリから1つ減らす
		var solutes = SoluteList.new()
		for item in material_items:
			var material_solutes = SoluteList.new(item.get_solutes())
			solutes = solutes.append_list(material_solutes)
			print("素材 %s から溶質を抽出: %s" % [item.name, material_solutes])
			# ここで素材をビーカーに入れるアニメーションなどを再生してもいいかもしれない
		brew_use_case = BrewPotionUseCase.new(solutes)
		brew_use_case.state_changed.connect(_on_state_changed)
		add_herb_button.text = "取り出す"
	else:
		brew_use_case.get_solution_inventory()
		brew_use_case = null

func _on_solution_added(solution: Solution):
	print("新しい製品が追加されました: %s" % solution)

func _on_material_inventory_changed(materials: Dictionary[String, int]) -> void:
	if material_list == null:
		return
	material_list.clear()
	for item_name in materials.keys():
		var qty = materials[item_name]
		material_list.add_item("%s x%d" % [item_name, qty])
		material_list.set_item_metadata(-1, [item_name, qty])

func _on_state_changed(state: String):
	print("状態: %s" % state)
