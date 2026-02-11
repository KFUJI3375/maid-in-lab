class_name BrewPotionUseCase
extends RefCounted

signal state_changed(state: String)
signal temperature_changed(temp: float)
signal progress_changed(progress: float)
signal potion_created(potion: Potion)
signal solution_color_changed(color: Color)
signal volume_changed(volume: float) # 新規

const HEATING_RATE = 10.0
const COOLING_RATE = 5.0

var alchemy_process: AlchemyProcess
var current_state: String = "待機中"

func start_with_herb(herb: Herb, solvent: Solvent = null) -> void:
	# 溶媒を指定可能（デフォルトは水）
	alchemy_process = AlchemyProcess.new(herb, solvent)
	alchemy_process.progress_updated.connect(_on_progress_updated)
	alchemy_process.completed.connect(_on_potion_completed)
	alchemy_process.solution_updated.connect(_on_solution_updated)
	alchemy_process.evaporation_warning.connect(_on_evaporation_warning) # 新規
	change_state("薬草投入完了（溶媒: %s）" % alchemy_process.solution.solvent.name)

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
		volume_changed.emit(alchemy_process.solution.volume) # 新規

func change_state(new_state: String) -> void:
	current_state = new_state
	state_changed.emit(current_state)

func _on_progress_updated(progress: float) -> void:
	progress_changed.emit(progress)

func _on_potion_completed(potion: Potion) -> void:
	change_state("完成！%s の%sができました！" % [potion.get_quality_text(), potion.name])
	potion_created.emit(potion)

func _on_solution_updated(solution: Solution) -> void:
	solution_color_changed.emit(solution.color)

func _on_evaporation_warning(remaining_volume: float) -> void:
	change_state("警告: 体積が %.1f ml まで減少しました" % remaining_volume)
