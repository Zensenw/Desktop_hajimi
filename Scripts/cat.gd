extends Node

var dragging = false
var drag_offset = Vector2()
var movement_tween: Tween

func _ready():
	# 强制设置窗口大小
	get_window().size = Vector2i(60, 60)
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	
	var timer = Timer.new()
	timer.wait_time = 10.0
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = Vector2(DisplayServer.mouse_get_position()) - Vector2(get_window().position)
				# 停止随机移动
				if movement_tween:
					movement_tween.kill()
					movement_tween = null
					_set_to_idle()
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		get_window().position = Vector2i(Vector2(DisplayServer.mouse_get_position()) - drag_offset)

func _on_timer_timeout():
	movement_tween = create_tween()
	var current_pos = get_window().position
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if abs(random_direction.y / random_direction.x) > 1:
		random_direction.x = 0
	var target_pos = current_pos + Vector2i(random_direction * 200)
	# 获取屏幕尺寸
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size

	# 检查并修正目标位置，确保不超出屏幕范围
	if target_pos.x < 40:
		target_pos.x = abs(target_pos.x)
		random_direction.x = -random_direction.x
	elif target_pos.x + window_size.x > (screen_size.x-40):
		target_pos.x = screen_size.x - window_size.x - (target_pos.x + window_size.x - screen_size.x)
		random_direction.x = -random_direction.x

	if target_pos.y < 40:
		target_pos.y = abs(target_pos.y)
		random_direction.y = -random_direction.y
	elif target_pos.y + window_size.y > (screen_size.y-40):
		target_pos.y = screen_size.y - window_size.y - (target_pos.y + window_size.y - screen_size.y)
		random_direction.y = -random_direction.y
	
	movement_tween.tween_property(get_window(), "position", target_pos, 3.0)
	movement_tween.tween_callback(_set_to_idle)
	print("Moving to New position : ", target_pos)
	if random_direction.x == 0:
		_set_to_drop()
	else:
		_set_to_move(random_direction)


func _set_to_idle():
	get_node("idle").visible = true
	get_node("move1").visible = false
	get_node("move2").visible = false
	get_node("move3").visible = false
	get_node("move4").visible = false
	get_node("drop").visible = false

func _set_to_move(direction):
	var random_num = randi() % 4 + 1
	get_node("idle").visible = false
	get_node("move1").visible = false
	get_node("move2").visible = false
	get_node("move3").visible = false
	get_node("move4").visible = false
	get_node("move" + str(random_num)).visible = true
	if direction.x > 0:
		get_node("move" + str(random_num)).scale.x = -1
	else:
		get_node("move" + str(random_num)).scale.x = 1

func _set_to_drop():
	get_node("idle").visible = false
	get_node("move1").visible = false
	get_node("move2").visible = false
	get_node("move3").visible = false
	get_node("move4").visible = false
	get_node("drop").visible = true
