class_name BrewPotionUseCase
extends RefCounted

signal state_changed(state: String)
signal temperature_changed(temp: float)
signal progress_changed(progress: float)
signal potion_created(potion: Potion)

const HEATING_RATE = 10.0
const COOLING_RATE = 5.0

var alchemy_process: AlchemyProcess
var current_state: String = "待機中"

func start_with_herb(herb: Herb) -> void:
	alchemy_process = AlchemyProcess.new(herb)
	alchemy_process.progress_updated.connect(_on_progress_updated)
	alchemy_process.completed.connect(_on_potion_completed)
	change_state("薬草投入完了")

func toggle_heating() -> bool:
	if not alchemy_process:
		return false
	
	alchemy_process.is_active = not alchemy_process.is_active
	if alchemy_process.is_active:
		change_state("加熱中")
	else:
		change_state("冷却中")
	return alchemy_process.is_active

func update(delta: float) -> void:
	if alchemy_process:
		alchemy_process.update(delta, HEATING_RATE, COOLING_RATE)
		temperature_changed.emit(alchemy_process.temperature.value)

func change_state(new_state: String) -> void:
	current_state = new_state
	state_changed.emit(current_state)

func _on_progress_updated(progress: float) -> void:
	progress_changed.emit(progress)

func _on_potion_completed(potion: Potion) -> void:
	change_state("完成！%s の%sができました！" % [potion.get_quality_text(), potion.name])
	potion_created.emit(potion)
