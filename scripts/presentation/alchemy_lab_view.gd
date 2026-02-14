extends Control

# ノードの参照
@onready var beaker_rect = $BeakerRect
@onready var temp_label = $UIContainer/TempLabel
@onready var time_label = $UIContainer/TimeLabel
@onready var status_label = $UIContainer/StatusLabel
@onready var volume_label = $UIContainer/VolumeLabel # 新規：体積表示
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
	if heat_button:
		heat_button.pressed.connect(_on_heat_pressed)

func _process(delta):
	# FPS表示更新（デバッグ用）
	fps_label.text = "FPS: %d (Max: %d)" % [
		Engine.get_frames_per_second(),
		Engine.max_fps
	]
	if brew_use_case:
		brew_use_case.update(delta)
func _on_add_herb_pressed():
	brew_use_case = BrewPotionUseCase.new()
	brew_use_case.state_changed.connect(_on_state_changed)

func _on_heat_pressed():
	pass
func _on_state_changed(state: String):
	print("状態: %s" % state)

func _on_temperature_changed(temp: float):
	temp_label.text = "温度: % .1f°C" % temp

func _on_progress_changed(progress: float):
	status_label.text = "成分抽出: % .1f % %" % progress

func _on_solution_color_changed(color: Color):
	beaker_rect.color = color

func _on_volume_changed(volume: float):
	if volume_label:
		volume_label.text = "体積: % .1fml" % volume

	# 警告表示
	if volume < 30.0:
		volume_label.add_theme_color_override("font_color", Color.RED)
	else:
		volume_label.add_theme_color_override("font_color", Color.WHITE)
