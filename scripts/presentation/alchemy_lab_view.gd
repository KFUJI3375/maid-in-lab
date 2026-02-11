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
var brew_use_case: BrewPotionUseCase

var brewing_time: float = 0.0
var fps_label: Label

func _ready():
	# FPS表示ラベル作成（デバッグ用）
	fps_label = Label.new()
	fps_label.position = Vector2(10, 10)
	fps_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(fps_label)

	# 体積ラベル作成（シーンになければ）
	if not volume_label:
		volume_label = Label.new()
		# ... 配置とスタイル設定

	brew_use_case = BrewPotionUseCase.new()

	# Use Caseのシグナル接続
	brew_use_case.state_changed.connect(_on_state_changed)
	brew_use_case.temperature_changed.connect(_on_temperature_changed)
	brew_use_case.progress_changed.connect(_on_progress_changed)
	brew_use_case.potion_created.connect(_on_potion_created)
	brew_use_case.solution_color_changed.connect(_on_solution_color_changed)
	brew_use_case.volume_changed.connect(_on_volume_changed) # 新規

	# UIボタンのシグナル接続
	add_herb_button.pressed.connect(_on_add_herb_pressed)
	heat_button.pressed.connect(_on_heat_pressed)

func _process(delta):
	# FPS表示更新（デバッグ用）
	fps_label.text = "FPS: %d (Max: %d)" % [
		Engine.get_frames_per_second(),
		Engine.max_fps
	]

	brew_use_case.update(delta)
	if brew_use_case.alchemy_process and brew_use_case.alchemy_process.is_active:
		brewing_time += delta
		time_label.text = "煮出し時間: %.1f秒" % brewing_time

func _on_add_herb_pressed():
	var herb = Herb.create_healing_herb()
	brew_use_case.start_with_herb(herb)
	add_herb_button.disabled = true
	# 初期色は設定しない（溶液の色変化に任せる）

func _on_heat_pressed():
	var is_heating = brew_use_case.toggle_heating()
	heat_button.text = "加熱停止" if is_heating else "加熱開始"

func _on_state_changed(state: String):
	status_label.text = "状態: " + state

func _on_temperature_changed(temp: float):
	temp_label.text = "温度: %.1f°C" % temp

func _on_progress_changed(progress: float):
	status_label.text = "成分抽出: %.1f%%" % progress

func _on_solution_color_changed(color: Color):
	beaker_rect.color = color

func _on_volume_changed(volume: float):
	if volume_label:
		volume_label.text = "体積: %.1f ml" % volume

	# 警告表示
	if volume < 30.0:
		volume_label.add_theme_color_override("font_color", Color.RED)
	else:
		volume_label.add_theme_color_override("font_color", Color.WHITE)

func _on_potion_created(potion: Potion):
	heat_button.disabled = true
	print("ポーション完成: %s (品質: %s, 効力: %.1f)" % [
		potion.name,
		potion.get_quality_text(),
		potion.potency
	])
