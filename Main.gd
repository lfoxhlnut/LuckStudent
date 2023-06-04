extends TabContainer

enum SEASON { SPRING, SUMMER, AUTUMN, WINTER }

class Timing:
	extends Reference
	var hour: int
	var minute: int
	
	func _init(h: int, m: int):
		hour = h
		minute = m
	
	
	func less_than(t: Timing) -> bool:
		if hour < t.hour or (hour == t.hour and minute < t.minute):
			return true
		return false
	
	
	func equal_to(t: Timing) -> bool:
		return hour == t.hour and minute == t.minute
	
	
	func less_or_equal(t: Timing) -> bool:
		return less_than(t) or equal_to(t)
	
	
	func greater_than(t: Timing) -> bool:
		return not(less_or_equal(t))
	
	
	func greater_or_equal(t: Timing) -> bool:
		return greater_than(t) or equal_to(t)
	
	
	func is_in(s: Spell) -> bool:
		return greater_or_equal(s.front) and less_or_equal(s.back)
	
	
	func to_str() -> String:
		return String("%02d:%02d" % [hour, minute])


func Timing(h: int, m: int) -> Timing:	# 但是这样的做法会导致警告
	return Timing.new(h, m)				# 把 new() 藏在这里了. new() 但是不用担心这些东西的内存泄漏

class Spell:
	extends Reference
	var front: Timing
	var back: Timing
	
	func _init(f: Timing, b: Timing):
		front = f
		back = b
	
	
	func  include(t: Timing) -> bool:
		return front.less_or_equal(t) and back.greater_or_equal(t)
	
	
	func to_str() -> String:
		return String("%s ~ %s" % [front.to_str(), back.to_str()])
 

func Spell(f: Timing, b: Timing) -> Spell:
	return Spell.new(f, b)


#const t: Timing = Timing(4, 4)		# 可惜不彳亍
# 下边这俩是 var, 但是当作 const 来用
var season_time_list: Dictionary = {
	0: [
		Spell(Timing(0, 4), Timing(3, 4)),
	],
	1: [
		Spell(Timing(0, 4), Timing(3, 4)),
	],
	2: [
		Spell(Timing(8, 0), Timing(8, 45)),
		Spell(Timing(8, 55), Timing(9, 40)),
		Spell(Timing(10, 10), Timing(10, 55)),
		Spell(Timing(11, 05), Timing(11, 50)),
		Spell(Timing(14, 30), Timing(15, 15)),
		Spell(Timing(15, 25), Timing(16, 10)),
		Spell(Timing(16, 20), Timing(17, 04)),
		Spell(Timing(17, 05), Timing(18, 05)),
	],
	3: [
		Spell(Timing(7, 30), Timing(7, 50)),
		Spell(Timing(8, 0), Timing(8, 45)),
		Spell(Timing(8, 55), Timing(9, 40)),
		Spell(Timing(10, 10), Timing(10, 55)),
		Spell(Timing(11, 05), Timing(11, 50)),
		Spell(Timing(14, 0), Timing(14, 45)),
		Spell(Timing(14, 55), Timing(15, 40)),
		Spell(Timing(15, 50), Timing(16, 35)),
		Spell(Timing(16, 45), Timing(17, 35)),
	],
}

var season_start_time: Dictionary = {
	SEASON.SPRING: Timing(3, 1),
	SEASON.SUMMER: Timing(5, 1),
	SEASON.AUTUMN: Timing(9, 1),
	SEASON.WINTER: Timing(10, 8),
}

const WIN_HEIGHT: int = 600
const WIN_WIDTH: int = 1024
const WIN_SIZE: Vector2 = Vector2(WIN_WIDTH, WIN_HEIGHT)
const ROLL_INITIAL_CD: int = 10
const ROLL_AUTO_NUM: int = 13
const DATA_PATH: String = "user://data.dat"
const DATA_KEY: String = "Want the electric power of the world cut"
const SEASON_ZH: Array = ["春季", "夏季", "秋季", "冬季"]
const WEEKDAY_ZH: Array = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期天"]
const KEY_PRESSED_CD: int = 10
const ABOUT_1: String = (
"""(使用鼠标滚轮以阅读全文)
● 关于程序本身

	● 程序名为「LuckyStudent」, ver 1.0, 64bit.

	●  程序存在内存泄漏问题. 实际上我不知道究竟哪里漏了, 我觉着该释放的都释放了.
		这个问题也不是不能解决, 就是有点麻烦, 赶时间 + 比较懒, 这个版本就没修.
		虽然, 但是只泄露一点点, 也不能泄露多了.
		正常使用没有问题. 泄漏的内存应该会被操作系统回收.

	● 程序存档位置为「"""
)
const ABOUT_2 = (
"""」.
		存档已加密.

	● 按下「F1」开启或关闭安全模式. 安全模式的状态会被记录,
		程序启动时会同步为上一次关闭时的安全模式状态.
		● 安全模式下, 只有「Roll」界面可用, 可以防止学生修改参数整活.


● 功能简介与使用细节

	●「设置班级」中可以添加, 删除, 重命名班级,
		还可具体调整班级中每个学生的姓名和被选取的概率.
		● 「导入」只接受文本文档格式(*.txt), 其内容要求为:
			每一行有且仅有一个名字. 最多读取六十个名字, 多余的部分会被忽略.
			文件中的空行会被忽略.
		● 学生被选取的概率, 默认值为 100%,, 只能导入后再修改.
		●「设置班级」中的「更多设置」是针对于具体的班级而言的, 需要先选择班级.
			如果选择了多个班级, 只有第一个会进入「更多设置」.

	●「定时」中可以预设时间.
		● 如果程序打开的时间处于预设的时间之中,
			那么「Roll」会自动初始化为对应的班级, 否则自动初始化为列表中的第一个班级.
			如果同一个时间段有多个班级, 会初始化为列表中的第一个.
		● 会根据程序打开的时间初始化为相应的季节所对应的时间表.
			当然, 也可以手动选取季节. 目前, 春季和夏季的时间表暂缺.
		● 预设中季节所对应的起始时间为:
			春季为三月一号, 夏季为五月一号, 秋季为九月一号, 冬季为十月八号.

	● 在「Roll」界面, 可以随机挑选幸运观众. 
		● 按下「Start」开始, 按下「Stop」结束.
		●「Auto」模式可以自动停止, 不过也可以选择按下「Stop」提前停止.
		● 学生被 Roll 到的概率只影响最后结果, 不影响过场动画.
			也就是说, 就算一个学生的概率是 0, 动画中依然可能被选中, 但是停止时不会是他.

	●「说明」中包含有一些信息.
(我也不知道为啥需要这行字才能显示完整上边的内容)
● 以后的版本可能更新的内容
	●「设置班级」中, 删除班级前会提示确认.
	● 可以调节班级在列表中的顺序.
	● 可以 Roll 一个炫酷的班级名字.
	● 可以添加或删除学生.
	● 可以调整学生的位置.
	● 确认季节开始的时间, 补全季节所对应的时间表.
	● 可以设置随机选取时, 在每个学生之间停留的时间.
	● 可以设置「Auto」模式在选出最终的幸运观众之前停留的次数.

	● 使用版本控制系统
	● 重构代码
	● 修复内存泄漏问题
	● 更换默认的主题(使用新皮肤)"""
)
var safe_mode: bool = false
var safe_mode_cd: int = 0

# 设置班级 相关变量
var classes: Array

# 定时 相关变量
var season_to_link: int = 0
var weekday_to_link: int = 0
var timing_to_link: int = 0
var class_to_link: int = 0
var reservation: Array		# 每一个元素是一个数组, 该数组含义为: [season, weekday, timing, class_name]

# Roll 相关变量
var program_start_season: int
var roll_class: int = 0
var last_student: int = 0
var auto_num = ROLL_AUTO_NUM
var roll_actived: bool = false
var roll_auto: bool = false
var roll_cd: int = 0

# 设置班级 相关
onready var set_class: Control = $"设置班级"
onready var admin_class_page := $"设置班级/AdminClassPage"
onready var file_dialog := $"设置班级/FileDialog"
onready var get_class_name_page := $"设置班级/GetClassName"
onready var get_class_name_vbox := $"设置班级/GetClassName/ScrollContainer/VBoxContainer"	# 哦我的老天啊, 给变量命名真的比隔壁家格林奶奶的靴子还臭.
onready var get_class_name_input := $"设置班级/GetClassName/LineEdit"
onready var get_class_name_hint := $"设置班级/GetClassName/HintLabel"
onready var get_class_name_roll := $"设置班级/GetClassName/RollClassName"
onready var more_setting_page := $"设置班级/AdminClassPage/MoreClassSetting"
onready var more_setting_grid := $"设置班级/AdminClassPage/MoreClassSetting/GridContainer"
onready var more_setting_rename := $"设置班级/AdminClassPage/MoreClassSetting/LineEdit"
onready var more_setting_rename_hint := $"设置班级/AdminClassPage/MoreClassSetting/RenameHint"
onready var admin_student_page := $"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage"
onready var admin_student_name := $"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage/Name"
onready var admin_student_weight := $"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage/Weight"
onready var warning_page := $WarningPage

# 定时 相关
onready var set_time := $"定时"
onready var set_time_weekday := $"定时/WeekdayList"
onready var set_time_timing := $"定时/TimingList"
onready var set_time_class := $"定时/ScrollContainer/ClassList"
onready var set_time_season := $"定时/SeasonSelect"
onready var reservation_page := $"定时/ReservationPage"
onready var reservation_list := $"定时/ReservationPage/ScrollContainer/ReservationList"
onready var program_start_time: Dictionary = OS.get_datetime()

# Roll 相关
onready var roll: Control = $Roll
onready var roll_set_class = $Roll/SetRollClass
onready var roll_grid := $Roll/GridContainer



func _ready() -> void:
	ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
	ProjectSettings.set_setting("application/config/custom_user_dir_name", "LuckyStudent")
	randomize()
	OS.center_window()
	rect_size = WIN_SIZE
	set_tab_hidden(get_child_count() - 1, false)
	current_tab = 2
	load_data()
#	if safe_mode:
	for i in get_child_count() - 1:
		if i != 2:
			set_tab_disabled(i, safe_mode)
	initialize_set_class()
	initialize_set_time()
	initialize_roll()
#	$"说明/RichTextLabel".rect_size = WIN_SIZE + Vector2(0, 500)
	$"说明/RichTextLabel".text = ABOUT_1 + ProjectSettings.globalize_path(DATA_PATH) + ABOUT_2
	pass

func _process(_delta) -> void:
	if roll_actived:
		if not roll_cd:		# 重置 cd
			if roll_auto and auto_num <= 5:
				roll_cd = ROLL_INITIAL_CD * (27.0 - auto_num * 2) / 10
			else:
				roll_cd = ROLL_INITIAL_CD
		
		roll_cd -= 1;
		if not roll_cd:		# 等待结束, 随机抽取下一个学生
			roll_grid.get_child(last_student).disabled = true
			last_student = get_rand_student()
			roll_grid.get_child(last_student).disabled = false
		
			if roll_auto:
				auto_num -= 1;
				print_debug("auto num = ", auto_num)
				if not auto_num:
					roll_grid.get_child(last_student).disabled = true
					last_student = get_rand_student_by_probability()
					roll_grid.get_child(last_student).disabled = false
					roll_actived = false	# gds 不能连等有点不舒服
					roll_auto = false
	
	if safe_mode_cd:						# 这个判断不能放在「if Input.is_key_pressed(KEY_F1):」这个判断里,
		safe_mode_cd -= 1					# 因为每个人击键的习惯不同, 不能在键被按下时才去计算 cd, 因为这样做就很难达到流畅的效果.
	
	if Input.is_key_pressed(KEY_F1):
		if not safe_mode_cd:
			safe_mode_cd = KEY_PRESSED_CD
			safe_mode = not safe_mode
			for i in get_child_count() - 1:
				if i != 2:
					set_tab_disabled(i, safe_mode)
		


func _exit_tree() -> void:		# 虽然这样写了, 但是 Godot 的控制台仍让提示有内存泄漏, 我不明白.
	remove_and_free(get_class_name_vbox)
	remove_and_free(set_time_timing)
	remove_and_free(reservation_list)
	remove_and_free(roll_grid)
	remove_and_free(more_setting_grid)
	save_data()
	print_debug("exit")
#	for i in season_start_time:
#		season_start_time[i].unreference()
#	for i in season_time_list:
#		for k in season_time_list[i]:
			

func initialize_roll() -> void:
	if not classes.size():
		return
	
	# 根据 reservation 设置当前的 roll_class
	var t := Timing(program_start_time.hour, program_start_time.minute)
#	print_debug(t.to_str())
#	program_start_time.weekday = 2
#	t = Timing(9, 22)
	for i in reservation:
		if i[0] == program_start_season:
			if i[1] + 1 == program_start_time.weekday:
				if season_time_list[i[0]][i[2]].include(t):
					for k in classes.size():
						if classes[k]["name"] == i[3]:
							roll_class = k
							break
					break
	
	# 设置 roll_set_class
	var d: Dictionary = classes[roll_class]
#	printerr("roll_class is ", d)
	roll_set_class.clear()
	for i in classes:
		roll_set_class.add_item(i.name)
	roll_set_class.select(roll_class)
	
	# 在 roll 之前提前设置一个 last_student, 就不会每次初始 roll 都从第一个学生开始了
	last_student = get_rand_student()
	
	# 设置 roll_grid
	remove_and_free(roll_grid)
	roll_grid.columns = 8
#	var loop: int = 0
#	print_debug('d["count"] is ', d["count"])
	for i in d["count"]:
#		printerr("i is ", i)
#		loop += 1
		var b := Button.new()
		b.text = d[str(i)]["name"]		# 奇怪的. 本来是数字做键名, 储存后再读取就成字符串做键名了	# 不奇怪, 来自群佬的指导.
		b.disabled = true
		b.rect_min_size = Vector2(roll_grid.rect_size.x / (roll_grid.columns + 1),
				roll_grid.rect_size.y / (2 + int(d.count) / roll_grid.columns))
		roll_grid.add_child(b)
#	print_debug(loop)

func get_rand_student_by_probability() -> int:
	var lucky_student: int = randi() % int(classes[roll_class]["count"])
	while randi() % 100 > int(classes[roll_class][str(lucky_student)]["weight"]):
		lucky_student = randi() % int(classes[roll_class]["count"])
#	var t = randi() % 100
#	while t > int(classes[roll_class][str(lucky_student)]["weight"]):
#		print_debug("t is %d, probability is %s" % [t, classes[roll_class][str(lucky_student)]["weight"]])
#		t = randi() % 100
#		lucky_student = randi() % int(classes[roll_class]["count"])
	return lucky_student


func get_rand_student() -> int:
	return randi() % int(classes[roll_class]["count"])


func initialize_set_class() -> void:
	var xx: float = get_class_name_page.rect_size.x
	var yy: float = get_class_name_page.rect_size.y
	get_class_name_page.window_title = "新的班级叫什么名字呢"
	admin_class_page.remove_and_free_all_check()
	remove_and_free(get_class_name_vbox)
	for i in classes:
		if i.has(name):
			admin_class_page.add_check(i.name)
		else:
			admin_class_page.add_check(i["name"])
		var t := Label.new()
		t.rect_min_size = Vector2(xx, yy * 0.1)
		t.align = Label.ALIGN_CENTER
		if i.has(name):
			t.text = i.name
		else:
			t.text = i["name"]
		get_class_name_vbox.add_child(t)
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.rect_size = 0.6 * WIN_SIZE
	
	# 离谱, 我不知道为啥我就得用代码设置它.
	get_class_name_vbox.rect_position = Vector2(0, 0)
	get_class_name_vbox.rect_size = Vector2(xx * 0.8, yy * 0.65)
	get_class_name_input.rect_position = Vector2(0, yy * 0.75)
	get_class_name_input.rect_size = Vector2(xx, yy * 0.1)
	get_class_name_hint.rect_position = Vector2(0, yy * 0.65)
	get_class_name_hint.rect_size = Vector2(xx * 0.4, yy * 0.1)
	get_class_name_roll.rect_position = Vector2(xx * 0.4, yy * 0.65)
	get_class_name_roll.rect_size = Vector2(xx * 0.6, yy * 0.1)
	get_class_name_roll.hide()
	
	more_setting_page.rect_size = WIN_SIZE * 0.8
	var mspx:float = more_setting_page.rect_size.x
	var mspy:float = more_setting_page.rect_size.y
	more_setting_rename_hint.rect_position = Vector2(0, 4)
	more_setting_rename_hint.rect_size = Vector2(mspx * 0.4, mspy * 0.05)
	more_setting_rename_hint.text = "重命名"
	more_setting_rename.rect_position = Vector2(mspx * 0.4, 0)
	more_setting_rename.rect_size = Vector2(mspx * 0.6, mspy * 0.03)
	more_setting_grid.rect_position = Vector2(0, mspy * 0.1)
	
#	printerr(mspy * 0.69)
#	more_setting_grid.rect_size = Vector2(820, 358.8)			# 真是见鬼了, 有点离谱
	more_setting_grid.rect_size = Vector2(mspx, mspy * 0.69)
#	printerr(more_setting_grid.rect_size)						# 如今, 我相信神的存在. (　ˇωˇ)人
	
	var aspx:float = admin_student_page.rect_size.x
	var aspy:float = admin_student_page.rect_size.y
	admin_student_name.rect_position = Vector2(0, 0)
	admin_student_name.rect_size = Vector2(aspx, aspy * 0.2)
	admin_student_weight.rect_position = Vector2(aspx * 0.5, aspy * 0.4)
	admin_student_weight.rect_size = Vector2(aspx * 0.4, aspy * 0.2)
	$"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage/WeightPrefix".rect_position = Vector2(0, aspy * 0.4 + 3)
	$"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage/WeightPrefix".rect_size = Vector2(aspx * 0.5, aspy * 0.2)
	$"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage/WeightSuffix".rect_position = Vector2(aspx * 0.9, aspy * 0.4 + 3)
	$"设置班级/AdminClassPage/MoreClassSetting/AdminStudentPage/WeightSuffix".rect_size = Vector2(aspx * 0.1, aspy * 0.2)
	
#	admin_student_page.connect("confirmed", self, "_on_AdminStudentPage_confirmed")


func initialize_set_time() -> void:
	# 根据启动时的时间预设当前季节
	var date: Timing = Timing(program_start_time.month, program_start_time.day)
	for i in 4:
		if i and date.greater_or_equal(season_start_time[i - 1]) and date.less_than(season_start_time[i]):
			program_start_season = i - 1
			_on_SeasonSelect_item_selected(i - 1)
			set_time_season.select(season_to_link)
	
	# 设置 set_time_class
	remove_and_free(set_time_class)
	for i in classes.size():
		var t := CheckBox.new()
		set_time_class.add_child(t)
		t.text = classes[i].name
		t.connect("pressed", self, "_on_Link_choice_pressed", ["class", 1 << i])
	
	# 上边和下边的信号连接都是因为实现...
	for i in set_time_timing.get_child_count():
		set_time_timing.get_child(i).connect("pressed", self, "_on_Link_choice_pressed", ["timing", 1 << i])
	
	for i in set_time_weekday.get_child_count():
		set_time_weekday.get_child(i).connect("pressed", self, "_on_Link_choice_pressed", ["weekday", 1 << i])


#func update_set_time() -> void:
#	# 设置 set_time_class
#	remove_and_free(set_time_class)
#	for i in classes.size():
#		var t := CheckBox.new()
#		set_time_class.add_child(t)
#		t.text = classes[i].name

func initialize_reservation_page() -> void:
	# Todo: 标注无效的 reservation(但是并不删除). set_time_class 添加一个 button_group.
	remove_and_free(reservation_list)
	for i in reservation:
		var t := CheckBox.new()
		if i.size() == 4:
#			t.text = "%s %s %s %s" % i
			t.text = "%s %s %s %s" % [SEASON_ZH[i[0]], WEEKDAY_ZH[i[1]], season_time_list[i[0]][i[2]].to_str(), i[3]]
		elif i.size() == 3:
			t.text = "%s %s %s" % i
		else:
			t.text = "Unknown error"
		reservation_list.add_child(t)


func remove_and_free(n: Node) -> void:
	if n.get_child_count():
		for i in n.get_children():
			i.queue_free()
			n.remove_child(i)


func warn(info: String) -> void:
	warning_page.dialog_text = info
	warning_page.popup_centered()

func save_data() -> void:
	reservation.sort_custom(self, "sort_reservation")
	var d: Dictionary = {
		"class": classes,
		"reservation": reservation,
		"safe_mode": safe_mode,
	}
#	printerr(d["reservation"])
	var data: File = File.new()
	var err := data.open_encrypted_with_pass(DATA_PATH, File.WRITE, DATA_KEY)
	if err:
		warn("存档失败, 错误代码 %s" % err)
	if data.is_open():
		print_debug("Saving...")
#		print_debug(JSON.print(d))
		data.store_pascal_string(JSON.print(d))
	else:
		print_debug("存档失败", err)
		warn("Can't save datas. Please make sure the data file 「%s」 is not being used." % DATA_PATH)
	data.close()
	data.unreference()


func sort_reservation(a: Array, b: Array) -> bool:
	for i in a.size():
		if not a[i] == b[i]:
			return a[i] < b[i]
	return true


func update_data() -> void:
#	save_data()
	initialize_set_class()
	initialize_set_time()
	initialize_roll()


func load_data() -> void:
	var res: JSONParseResult
	var data: File = File.new()
	var err := data.open_encrypted_with_pass(DATA_PATH, File.READ, DATA_KEY)
#	if err:										# 有可能是首次运行, 并没有存档
#		warn("读取存档失败, 错误代码 %s" % err)
	
	if data.is_open():
		res = JSON.parse(data.get_pascal_string())
	else:
		data.close()
		data.unreference()
		return
#		warn("Can't load datas. Please make sure the data file 「%s」 is not being used." % DATA_PATH)
	data.close()
	data.unreference()
	if res.error:
		warn("Can't analyse datas. ERR code is 「%s」." % str(res.error))
	elif res.result is Dictionary:
		reservation = res.result["reservation"]
		classes = res.result["class"]
		safe_mode = res.result["safe_mode"]
	
	for i in classes.size():
		classes[i]["count"] = int(classes[i].count)
	for i in reservation:
		for k in i.size() - 1:				# 最后一个是 class_name, 是字符串
			i[k] = int(i[k])


func _on_Start_pressed() -> void:
	print_debug("start")
	roll_actived = true


func _on_Stop_pressed() -> void:
	print_debug("stop")
	roll_actived = false
	roll_auto = false
	roll_grid.get_child(last_student).disabled = true
	last_student = get_rand_student_by_probability()
	roll_grid.get_child(last_student).disabled = false


func _on_Auto_pressed() -> void:
	print_debug("auto")
	roll_actived = true
	roll_auto = true
	auto_num = ROLL_AUTO_NUM


func _on_Import_pressed() -> void:
	get_class_name_input.text = ""
	get_class_name_page.popup_centered()
	


func _on_SetRollClass_item_selected(x: int) -> void:
	if roll_class == x:
		return
	roll_class = x
	OS.set_window_title(classes[roll_class].name)
	initialize_roll()


func _on_Link_pressed() -> void:		# 实际上用 basebutton 的 pressed 属性就彳亍. 来自群里的大哥的指导. 或者用 bool 数组也彳亍, 也不缺那点空间, 也是来自群佬的指导.
#	var d: Array = [3]		# 这样写, 是可行的
#	print_debug(weekday_to_link, timing_to_link, class_to_link)
	for i in set_time_weekday.get_child_count():
		for k in set_time_timing.get_child_count():
			for x in set_time_class.get_child_count():
				if weekday_to_link & (1 << i) and timing_to_link & (1 << k) and class_to_link & (1 << x):
#					print_debug("new reservation: ", [season_to_link, i, k, x])
#					for t in reservation:
#						printerr(t)
					if not reservation.has([season_to_link, i, k, classes[x]["name"]]):
#						print_debug("new reservation linked")
						printerr("new reservation's class name is : ", classes[x]["name"])
						reservation.append([season_to_link, i, k, classes[x]["name"]])
#	save_data()


func _on_SeasonSelect_item_selected(index: int) -> void:		# 这个函数的代码有点臭, 待重构	# 重构已完成
	if season_to_link == index:
		return
	season_to_link = index
	
	var a: Array = season_time_list[season_to_link]
	for i in a.size():								# 修改为对应季节的时间列表
		var t := set_time_timing.get_child(i)
		t.pressed = false							# 只需把可见的 checkbox 设置为未选中. 因为判断是否选中看的是 timing_to_link 的记录, 只需等下重置这个变量.
		t.show()
		t.text = a[i].to_str()
#	weekday_to_link = 0								# 我真是 nt 了才把这两行写上. 查了半天 bug 不知道咋回事, 还好突然想到这个了
#	class_to_link = 0
	timing_to_link = 0								# 把子 checkbox 的 pressed 状态取消掉之后, 也要取消相应的记录. 哎呀如果直接检测子 chexkbox 的 pressed 属性就不会有这么多事. 不过写都写了也懒得改了.
	for i in set_time_timing.get_child_count():		# 把多余的 checkbox 隐藏, 而他们的 pressed 不用管.
		if i >= a.size():
			set_time_timing.get_child(i).hide()


func _on_Link_choice_pressed(s: String, x: int) -> void:
#	print_debug(x)
	match s:
		"class":
			class_to_link ^= x
#			print_debug("class selected")
		"timing":
			timing_to_link ^= x
#			print_debug("timing selected")
		"weekday":
			weekday_to_link ^= x
#			print_debug("weekday selected")
		_:
			printerr("Unexpected string ", s)


func _on_StartReservationPage_pressed() -> void:
	initialize_reservation_page()
	reservation_page.popup()


func _on_SelectAllReservation_pressed() -> void:
	for i in reservation_list.get_children():
		i.pressed = true


func _on_InvertSelectedReservation_pressed() -> void:
	for i in reservation_list.get_children():
		i.pressed = not i.pressed


func _on_DeleteSelectedReservation_pressed() -> void:
	var a: Array
	for i in reservation_list.get_child_count():
		var t = reservation_list.get_child(i)
		if not t.pressed:
			a.append(reservation[i])
	reservation = a
#	save_data()
	initialize_reservation_page()


func _on_CancelReservationPage_pressed() -> void:
	reservation_page.hide()


func _on_StartClassPage_pressed() -> void:
	admin_class_page.popup_centered()


func _on_FileDialog_file_selected(path: String) -> void:
	file_dialog.hide()
	var f := File.new()
	f.open(path, File.READ)
	if not f.is_open():
		file_dialog.popup_centered()
		warn("File [%s] opening failed." % path)
		return
	
	var new_class: Dictionary
	var line: String
	var count: int = 0
	while count < 60:								# 一个班最多 60 个学生
		if f.eof_reached():
			break
		line = f.get_line()
		if not line == "":
			new_class[str(count)] = {"name": line, "weight": "100"}
			count += 1
#	print_debug("count is ", count)
	f.close()
	f.unreference()
	new_class["name"] = get_class_name_input.text	# _on_Import_pressed() 会保证名字不冲突
#	new_class["count"] = str(count)					# 简直吃屎了, 我为啥要转成 str, 导致刚导入的班级总是只有两个学生(遍历 ["count"], i 分别是 "6", "0")
	new_class["count"] = count
#	print_debug("new_class[\"count\"]  is ", new_class["count"])
#	printerr(new_class)
	classes.append(new_class)
	
	update_data()
#	save_data()
#
#	# 应该写一个 update_data() 这样的函数. 这也说明了初始化和刷新并不同
#	initialize_set_class()
#	initialize_set_time()
#	initialize_roll()
	


func _on_GetClassName_confirmed() -> void:
	for i in classes:
		if i["name"] == get_class_name_input.text:
			_on_Import_pressed()
			warn("「%s」 与现存的班级名字重复, 请换一个." % i["name"])
			return
	get_class_name_page.hide()
	file_dialog.deselect_items()
	file_dialog.invalidate()
	# 上边两句话不知道有啥用, 写了也没变化
	file_dialog.popup_centered()


func _on_AdminClassPage_delete(id_array: Array) -> void:
	if not id_array.size():
		return
	# 还是先不要这个功能好了
#	warning_page.dialog_text = "确定要删除这些班级吗"
#	var t: Button = warning_page.add_cancel("取消")
#	warning_page.popup_centered()
#	yield(warning_page, "confirmed")
#	warning_page.remove_button(t)
	var k: int = 0
	var a: Array
	for i in classes.size():				# 应保证 id_array 严格递增
		if not i == id_array[k]:			# classes[i] 不应被删除
			a.append(classes[i])
		else:
			k += 1 if not k == id_array.size() - 1 else 0
	classes = a
	update_data()
	

func _on_AdminClassPage_more_setting(id_array: Array) -> void:
	if not id_array.size():
		warn("「更多设置」是针对于具体的班级而言的, 请先选择班级.\n如果选择了多个班级, 只有第一个会进入「更多设置」.")
		return
	var current_class: Dictionary = classes[id_array[0]]
	more_setting_page.window_title = "班级「%s」更多设置" % current_class["name"]
	
	remove_and_free(more_setting_grid)
	
	print_debug("more_setting_grid.rect_size.y is ", more_setting_grid.rect_size.y)
	
	for i in int(current_class["count"]):
		var t = Button.new()
#		t.rect_min_size = Vector2(0, more_setting_grid.rect_size.y / (4 + more_setting_grid.columns))
		t.rect_min_size = Vector2(0, 30)
#		print_debug(t.rect_min_size)
		t.text = "%s[%s%%]" % [current_class[str(i)]["name"], current_class[str(i)]["weight"]]
		t.connect("pressed", self, "_on_MoreStudentSetting_pressed", [id_array[0], i])
		more_setting_grid.add_child(t)
	
	more_setting_rename.text = current_class["name"]
	if more_setting_page.is_connected("confirmed", self, "_on_MoreClassSetting_confirmed"):
		more_setting_page.disconnect("confirmed", self, "_on_MoreClassSetting_confirmed")
	more_setting_page.connect("confirmed", self, "_on_MoreClassSetting_confirmed", [id_array[0]])
	
	more_setting_page.popup_centered()
#	yield(more_setting_page, "confirmed")				# 还没搞懂咋用的
#	_on_MoreClassSetting_confirmed(id_array[0])			# 本来是做信号连接用的, 后来不连了, 不过懒得改名了.


func _on_MoreClassSetting_confirmed(class_id: int) -> void:
	print_debug("class name changed from [%s] to [%s]" % [classes[class_id]["name"], more_setting_rename.text])
	classes[class_id]["name"] = more_setting_rename.text
	update_data()
	_on_AdminClassPage_more_setting([class_id])
	more_setting_page.hide()


func _on_MoreStudentSetting_pressed(class_id: int, student_id: int) -> void:
	var d: Dictionary = classes[class_id][str(student_id)]
	admin_class_page.window_title = "正在修改学生「%s」的信息" % d["name"]
	admin_student_page.popup_centered()
	admin_student_name.text = d["name"]
	admin_student_weight.get_line_edit().text = d["weight"]
	if admin_student_page.is_connected("confirmed", self, "_on_AdminStudentPage_confirmed"):
		admin_student_page.disconnect("confirmed", self, "_on_AdminStudentPage_confirmed")
	admin_student_page.connect("confirmed", self, "_on_AdminStudentPage_confirmed", [class_id, student_id], CONNECT_ONESHOT)	# 其实如果照上边这么写了, oneshot 也可以不用加.
	
#	yield(admin_student_page, "confirmed")
#	_on_AdminStudentPage_confirmed(class_id, student_id)


func _on_AdminStudentPage_confirmed(class_id: int, student_id: int) -> void:
#	print_debug("student information changed ")
	print_debug("student information changed from [%s, %s] to [%s, %s]" % [classes[class_id][str(student_id)]["name"], classes[class_id][str(student_id)]["weight"], admin_student_name.text, admin_student_weight.get_line_edit().text])
	classes[class_id][str(student_id)]["name"] = admin_student_name.text
#	print_debug(admin_student_weight.get_line_edit().text)
	classes[class_id][str(student_id)]["weight"] = admin_student_weight.get_line_edit().text
	print_debug("should hide")
	admin_student_page.hide()
	update_data()
	_on_AdminClassPage_more_setting([class_id])

