extends Control

@onready var from_text = $Panel/HBoxContainer/Info/Label
@onready var profile_icon = $Panel/HBoxContainer/Info/Profile
@onready var content_text = $Panel/HBoxContainer/Text/Content
@onready var cover_panel = $Panel/HBoxContainer/Buttons/ConverPanel
@onready var reply_btn = $Panel/HBoxContainer/Buttons/ReplyBtn
@onready var reply_w_file_btn = $Panel/HBoxContainer/Buttons/ReplyWFBtn
@onready var panel = $Panel
@onready var warning_bar = get_node("/root/Computer/Manager/WindowGroup/EMailWindow/WarningBar")
@onready var click_sound = get_node("/root/Computer/ClickSound")
@onready var email_manager = get_node("/root/Computer/Manager/WindowGroup/EMailWindow")

var is_paper_work
var is_set
var is_active
var is_done
var is_failed
var file_name
var is_reply
var with_file
var profile_path
var is_sent = false

func _ready():
	self.hide()
#	cover_panel.hide()

func set_datas(paper: bool, active: bool, sender: String, file: String, done: bool, fail: bool, path: String, sent: bool):
	is_paper_work = paper
	is_active = active
	is_done = done
	is_failed = fail
	file_name = file
	is_sent = sent
	
	from_text.text = sender
	if is_paper_work:
		content_text.text = "Hello, I’ve just delivered the papers to your desk." + \
		"Please stamp them all correctly. Once you're finished, let me know so I can come and collect them."
	else:
		content_text.text = "I hope this message finds you well. I need the file titled [color=black]\"" + file + "\"[/color]" + \
		" as soon as possible. Please send it with your reply. Thank you!"
	profile_path = path
	profile_icon.texture = load(profile_path)
	#paper: bool, set: bool, active: bool, sender: String, file: String, done: bool, fail: bool, path: String




func set_reply_datas(sender: String, success: bool, active: bool, path: String, with_file: bool, paper: bool):
	#print("set reply datas")
	panel.self_modulate = Color.AQUAMARINE
	
	var item = GameManager.get_item("reply", sender)
	item.isActive = active
	is_done = item.isDone
	is_reply = true
	is_active = active
	is_paper_work = paper
	is_failed = !success
	profile_path = path
	
	#print(is_done, "  ", is_failed, "  ", with_file)
	#print("----------------------------------------------------------------------")
	
	profile_icon.texture = load(path)	
	from_text.text = sender
	
	
	if with_file:
		#print("with file")
		# 도장 작업인데 파일을 보냈을 때
		if is_paper_work:
			content_text.text = "Excuse me, this is not what I asked? Forget it, I'll just stamp on papers. Such a terrible worker."
#			if !item.setScore and item.isSent:
#				GameManager.hearts -= 1
#				item.setScore = true
		
		# 이메일 작업, 정답 확인 
		else:
			if success:
				content_text.text = "Thank you for your reply. I checked, and it's all correct. Thank you."

			else: 
				content_text.text = "I don't thank you for your reply. Because unfortunately it's wrong." + \
				"I'll just do it by myself, forget about this task. Unkind regards, " + sender  + "."			

	else:
		#print("without file")
		# 이메일 작업인데 파일 없이 보냈을 때
		if not is_paper_work:
			content_text.text = "Hello??? With no attached file??? Forget about this task, I'll find myself. Jesus."

		# 도장 작업, 정답 확인
		else:
			#print("paper work")
			if is_done:
				#print("work done")
				if is_failed:
					content_text.text = "I checked your work, it's not stamped properly. Thanks to you" \
				+ " my workload has doubled. Great!"

				else:
					content_text.text = "Thank you, your work is perfeclty performed. Good job!"

			else: 
				#print("work not done")
				content_text.text = "I checked your work, nothings are stamped? Great work. Bravo."			
	
	
					
	reply_btn.mouse_filter = MOUSE_FILTER_IGNORE
	reply_w_file_btn.mouse_filter = MOUSE_FILTER_IGNORE
		

func _process(delta):
	if is_active:
		self.show()
	
#	if is_set:
#		cover_panel.show()
	
	if not is_reply and is_sent:
		cover_panel.show()
		reply_btn.mouse_filter = MOUSE_FILTER_IGNORE
		reply_w_file_btn.mouse_filter = MOUSE_FILTER_IGNORE





func _on_reply_btn_pressed():	
	click_sound.play()
	is_sent = true
	with_file = false
	var reply = GameManager.get_item("reply", from_text.text)	
	reply.isDone = true
	
	if not is_paper_work:
		var item = GameManager.get_item("email", from_text.text)
		item.isDone = true
		item.isSent = true
		item.isFailed = true
		item.withFile = false
		is_done = item.isDone
		is_failed = item.isFailed
		#email_manager.get_reply(self)
		GameManager.get_reply(from_text.text, is_failed, is_done)
	else:
		# Paper work일 때 작업 완료 여부를 따져서
		var item = GameManager.get_item("paper", from_text.text)		
		is_done = item.isDone
		is_failed = item.isFailed
		item.isSent = true
		item.withFile = false
		#print("//", item.from, " ", item.isSent)
		#print("button pressed:    ", is_done, " ", is_failed)
		#email_manager.get_reply(self)
		GameManager.get_reply(from_text.text, is_failed, is_done)
		pass
	reply.isDone = is_done
	reply.isFailed = is_failed
	reply.withFile = false
	reply.isSent = true	

func _on_reply_wf_btn_pressed():
	click_sound.play()
	var reply = GameManager.get_item("reply", from_text.text)	
	reply.isDone = true
	
	if GameManager.copied_file != null:
		is_sent = true
		with_file = true
		print("file name: ", file_name, "/ copied name: ", GameManager.copied_file.its_name)
		if not is_paper_work:
			var item = GameManager.get_item("email", from_text.text)
			if file_name == GameManager.copied_file.its_name:
				item.isDone = true
				item.isFailed = false
				item.isSent = true
				item.withFile = true
				is_done = item.isDone
				is_failed = item.isFailed
			else:
				item.isDone = true
				item.isFailed = true
				item.isSent = true
				item.withFile = true
				is_done = item.isDone
				is_failed = item.isFailed
			#email_manager.get_reply(self)
			GameManager.get_reply(from_text.text, is_failed, is_done)
		else:
			var item = GameManager.get_item("paper", from_text.text)
			item.isDone = true
			item.isFailed = true
			is_done = item.isDone
			is_failed = item.isFailed
			#email_manager.get_reply(self)
			GameManager.get_reply(from_text.text, is_failed, is_done)
	else: 
		print("no copied path")
		warning_bar.show()
		warning_bar.get_node("AnimationPlayer").play("warningbar_show")
	
	
	print("the task that you just sent is failed: ", is_failed)
	reply.isDone = is_done
	reply.isFailed = is_failed
	reply.withFile = true
	reply.isSent = true	
