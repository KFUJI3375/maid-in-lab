extends Control

# ノードの参照
@onready var beaker_rect = $BeakerRect
@onready var status_label = $UIContainer/StatusLabel
@onready var add_herb_button = $UIContainer/AddHerbButton
@onready var heat_button = $UIContainer/HeatButton

# Use Case
var brew_use_case: BrewPotionUseCase = null
var fps_label: Label

func _ready():
	# FPS表示ラベル作成（デバッグ用）
	fps_label = Label.new()
	fps_label.position = Vector2(10, 10)
	fps_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(fps_label)

	# UIボタンのシグナル接続
	if add_herb_button:
		add_herb_button.pressed.connect(_on_add_herb_pressed)


func _process(delta):
	# FPS表示更新（デバッグ用）
	fps_label.text = "FPS: %d (Max: %d)" % [
		Engine.get_frames_per_second(),
		Engine.max_fps
	]
	if brew_use_case:
		brew_use_case.update(delta)
func _on_add_herb_pressed():
	if brew_use_case == null:
		brew_use_case = BrewPotionUseCase.new()
		brew_use_case.state_changed.connect(_on_state_changed)
		add_herb_button.text = "取り出す"
	else:
		var solution = brew_use_case.get_solution()
		brew_use_case = null
		if solution:
			print("完成した薬: %s" % solution)
		else:
			print("薬は完成しませんでした。")

func _on_state_changed(state: String):
	print("状態: %s" % state)
