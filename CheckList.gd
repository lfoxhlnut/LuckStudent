extends WindowDialog

class_name CheckList

# 信号名理应用过去时态, 但是我累了
#signal select_all
#signal invert
signal add
signal delete(id_array)
signal more_setting(id_array)


enum BUTTON {SELECT_ALL, INVERT, ADD, DELETE, MORE_SETTING, CANCEL}
const BUTTON_TEXT_ZH: Array = ["全选", "反选", "添加", "删除", "更多设置", "关闭"]
const BUTTON_SIGNAL: Array = ["", "", "add", "delete", "more_setting", ""]	# cancel button 对应的信号名设置为空字符串, 因为 emit_signal("") 不会产生效果.
const BUTTON_NUM: int = 6

var check: Array
var button: Array
var scroll_container := ScrollContainer.new()
var check_list := VBoxContainer.new()



func _init(name_list: Array = [], rect_size_v: Vector2 = OS.window_size * 0.7) -> void:
	add_child(scroll_container)
	scroll_container.add_child(check_list)
	popup_exclusive = true
	if name_list.size():
		for i in name_list.size():
			check.append(CheckBox.new())
			check[i].text = name_list[i]
#			check[i].rect_position = Vector2(0, 40 * i)
			check_list.add_child(check[i])
	
	rect_size = rect_size_v
	scroll_container.rect_size = Vector2(rect_size.x * 0.6, rect_size.y)
	for i in BUTTON_NUM:
		button.append(Button.new())
		add_child(button[i])
		button[i].text = BUTTON_TEXT_ZH[int(i)]
		button[i].rect_position = Vector2(520, 20 + (rect_size.y - 40) / BUTTON_NUM * i)
		button[i].connect("pressed", self, "_on_Button_pressed", [i])


func _exit_tree() -> void:
	remove_and_free_all_check()
	for i in button:
		i.queue_free()
	scroll_container.queue_free()
	check_list.queue_free()


func remove_and_free_check(id: int) -> void:
	check_list.remove_child(check[id])		# 经测试, 可行
	check[id].queue_free()
	check.remove(id)


func remove_and_free_all_check() -> void:
	for i in check:
		i.queue_free()
		check_list.remove_child(i)
	check.clear()


func set_check_name(id: int, s: String) -> void:
	check[id].text = s


func is_selected(id: int) -> bool:
	return check[id].pressed


func add_check(check_name: String) -> void:
	check.append(CheckBox.new())
	check[-1].text = check_name
	check_list.add_child(check[-1])


func hide_button(id: int) -> void:
	button[id].hide()


func show_button(id: int) -> void:
	button[id].show()


func _on_Button_pressed(id: int) -> void:		# 这个函数代码(或者这个类的设计模式)有点臭, 待重构
	var a: Array
	for i in check.size():
		if check[i].pressed:
			a.append(i)
	
	match id:
		BUTTON.DELETE:
			emit_signal("delete", a)
		BUTTON.MORE_SETTING:
			emit_signal("more_setting", a)
		BUTTON.SELECT_ALL:
			for i in check:
				i.pressed = true
		BUTTON.INVERT:
			for i in check:
				i.pressed = not i.pressed
		BUTTON.CANCEL:
			hide()
		_:
			emit_signal(BUTTON_SIGNAL[id])

















