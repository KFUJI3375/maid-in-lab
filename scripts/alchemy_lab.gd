extends Control

# ノードの参照
@onready var beaker_rect = $BeakerRect
@onready var temp_label = $UIContainer/TempLabel
@onready var time_label = $UIContainer/TimeLabel
@onready var status_label = $UIContainer/StatusLabel
@onready var add_herb_button = $UIContainer/AddHerbButton
@onready var heat_button = $UIContainer/HeatButton

# 錬金術の状態
var has_herb: bool = false
var is_heating: bool = false
var temperature: float = 20.0 # 室温から開始
var brewing_time: float = 0.0
var cell_wall_broken: float = 0.0 # 細胞壁の破壊度 (0-100%)

# 定数
const HEATING_RATE = 10.0 # 1秒あたりの温度上昇
const COOLING_RATE = 5.0 # 1秒あたりの温度下降
const OPTIMAL_TEMP = 80.0 # 最適温度
const CELL_BREAK_TEMP = 60.0 # 細胞壁が壊れ始める温度

func _ready():
	# ボタンのシグナル接続
	add_herb_button.pressed.connect(_on_add_herb_pressed)
	heat_button.pressed.connect(_on_heat_pressed)
	
	update_ui()

func _process(delta):
	if is_heating:
		# 加熱中は温度上昇
		temperature += HEATING_RATE * delta
		temperature = min(temperature, 100.0) # 100度以上にならない
	else:
		# 冷却
		if temperature > 20.0:
			temperature -= COOLING_RATE * delta
			temperature = max(temperature, 20.0)
	
	# 薬草が入っていて温度が十分なら細胞壁破壊
	if has_herb and temperature >= CELL_BREAK_TEMP:
		brewing_time += delta
		var break_speed = (temperature - CELL_BREAK_TEMP) / 20.0 # 温度で速度変化
		cell_wall_broken += break_speed * delta * 10.0
		cell_wall_broken = min(cell_wall_broken, 100.0)
	
	update_ui()
	
	# 完成判定
	if cell_wall_broken >= 100.0:
		complete_potion()

func _on_add_herb_pressed():
	if not has_herb:
		has_herb = true
		add_herb_button.disabled = true
		status_label.text = "状態: 薬草投入完了"
		beaker_rect.color = Color(0.6, 0.8, 0.6) # 緑っぽく

func _on_heat_pressed():
	is_heating = not is_heating
	if is_heating:
		heat_button.text = "加熱停止"
		status_label.text = "状態: 加熱中"
	else:
		heat_button.text = "加熱開始"
		status_label.text = "状態: 冷却中"

func update_ui():
	temp_label.text = "温度: %.1f°C" % temperature
	time_label.text = "煮出し時間: %.1f秒" % brewing_time
	
	if has_herb:
		status_label.text = "細胞壁破壊: %.1f%%" % cell_wall_broken

func complete_potion():
	is_heating = false
	heat_button.disabled = true
	status_label.text = "完成！回復薬ができました！"
	beaker_rect.color = Color(1.0, 0.5, 0.5) # 赤っぽく
	print("回復薬完成！")