extends Node2D

enum STATE {
	MENU,
	CREDITS
}

var current_state = MENU
var current_option = 0
var credits
var options

func _ready():
	options = $UI/Options
	credits = $UI/Credits

	set_current_option_color(current_option)

	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_up") and current_state == MENU:
		if current_option - 1 >= 0:
			current_option -= 1
		set_current_option_color(current_option)

	elif event.is_action_pressed("ui_down") and current_state == MENU:
		if current_option + 1 <= 2:
			current_option += 1
		set_current_option_color(current_option)

	elif event.is_action_pressed("ui_accept"):
		if current_option == 1:
			toggle_credits()
		elif current_option == 2 and current_state == MENU:
			get_tree().quit()

# Highlights currently selected menu option
func set_current_option_color(option):
	for ops in options.get_children():
		if ops == options.get_children()[option]:
			ops.set("custom_colors/font_color", Color("ffff00"))
		else:
			ops.set("custom_colors/font_color", Color("ffffff"))

# Toggles visibility of credits section
func toggle_credits():
	options.visible = !options.visible
	credits.visible = !credits.visible

	if credits.visible:
		current_state = CREDITS
	else:
		current_state = MENU