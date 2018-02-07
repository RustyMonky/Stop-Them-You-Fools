extends Node2D

enum GAME_STATE {
	PROMPTING,
	CHOOSING,
	PROCESSING,
	EXECUTING,
	RESET,
	DEFEAT
}

var animated_minion
var choices
var choices_array = [
	[
		{label = "arrow barrage", command = "Unleash an arrow barrage and blot out the sun!", type = "trap", weak = "knight"},
		{label = "zombie horde", command = "Send forth the zombie horde to eat their brains!", type = "monster", weak = "cleric"},
		{label = "cast fireball", command = "Cast a fireball to engulf them!", type = "magic", weak = "mage"}
	],
	[
		{label = "crushing spike walls", command = "Crush him with the moving spiked walls, you fools!", type = "trap", weak = "cleric"},
		{label = "minotaur", command = "Send the damn minotaur to crush him!", type = "monster", weak = "knight"},
		{label = "flood the halls", command = "Summon so much water that they'll drown in their stupidity!", type = "magic", weak = "mage"}
	],
	[
		{label = "remote detonation", command = "Detonate the hallway mines, you imbecile!", type = "trap", weak = "cleric"},
		{label = "dragon", command = "Wait are you waiting for!? Wake the dragon!", type = "monster", weak = "knight"},
		{label = "black hole", command = "Summon a black hole and pull them into oblivion!", type = "magic", weak = "mage"}
	]
]
var choices_index = 0
var current_choice = 0
var current_game_state
var has_made_choice = false
var hero = {
	locationIndex = 0,
	type = ""
}
var hero_locations = ["at the castle gates", "in the main hall", "just outside the throne room"]
var hero_types = ["cleric", "mage", "knight"]
var label
var text_array = []
var text_index = 0

func _ready():
	animated_minion = $AnimatedSprite
	choices = $GUI/TextBox/Choices
	label = $GUI/TextBox/Label

	current_game_state = PROMPTING

	choose_rand_hero()

	set_process(true)

	set_process_input(true)

func _process(delta):
	if current_game_state == PROMPTING:
		animated_minion.play()
		move_minion(false)

		if text_array.size() == 0:
			reset_game()

	elif current_game_state == CHOOSING:
		if not choices.visible and not has_made_choice:
			toggle_choice_visibility()
		elif not choices.visible and has_made_choice:
			move_minion(true)

	elif current_game_state == PROCESSING:
		move_minion(false)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if current_game_state == PROMPTING:
			if (text_index + 1) >= (text_array.size()):
				prepare_choices()
				current_game_state = CHOOSING
			else:
				text_index += 1
				set_text(text_index)

		elif current_game_state == CHOOSING:
			if not has_made_choice:
				has_made_choice = true
				toggle_choice_visibility()
				prepare_text([
					choices_array[choices_index][current_choice].command,
					"As you wish, master."
				])
				set_text(text_index)
			else:
				if (text_index + 1) >= (text_array.size()):
					current_game_state = PROCESSING
					has_made_choice = false
				else:
					text_index += 1
					set_text(text_index)

		elif current_game_state == PROCESSING:
			var successful = is_successful()
			if successful:
				prepare_text(["Master, the " + hero.type + " has been destroyed."])
				set_text(text_index)
				current_game_state = RESET
			elif hero.locationIndex < hero_locations.size() - 1:
				hero.locationIndex += 1
				choices_index += 1
				current_game_state = PROMPTING
				prepare_text([
					"Master, our plan failed! The " + hero.type + " is now " + hero_locations[hero.locationIndex] + ".",
					"How shall we deal with them?"
				])
				set_text(text_index)
			else:
				current_game_state = DEFEAT
				prepare_text(["You have been vanquished."])
				set_text(text_index)

		elif current_game_state == RESET:
			current_game_state = PROMPTING
			reset_game()

	if event.is_action_pressed("ui_left") and current_game_state == CHOOSING:
		if current_choice - 1 <= 0:
			current_choice = 0
		else:
			current_choice -= 1
		update_current_choice_text(current_choice)

	elif event.is_action_pressed("ui_right") and current_game_state == CHOOSING:
		if current_choice + 1 >= 2:
			current_choice = 2
		else:
			current_choice += 1
		update_current_choice_text(current_choice)

# Determines if choice succeeds
func is_successful():
	var result = false
	var chance = 0.75
	var choice_weak = choices_array[choices_index][current_choice].weak

	if choice_weak == hero.type:
		chance = 0.25

	var rand_result = randi() % 100

	if rand_result <= 100 * chance:
		 result = true

	return result

# Chooses random hero type from preconstructed array
func choose_rand_hero():
	var index = (randi() % hero_types.size() + 1) - 1
	hero.type = hero_types[index]
	hero.locationIndex = 0

# Moves minion animated sprite into view
func move_minion(flipped):
	animated_minion.flip_h = flipped

	if not animated_minion.is_playing():
		animated_minion.play()

	if not flipped:
		if animated_minion.position.x >= 800:
			animated_minion.position.x -= 2
		elif animated_minion.is_playing():
			animated_minion.stop()
	else:
		if animated_minion.position.x <= 1120:
			animated_minion.position.x += 2
		elif animated_minion.is_playing():
			animated_minion.stop()

# Prepares choices labels
func prepare_choices():
	for choice in choices.get_children():
		var index = choices.get_children().find(choice)
		choice.text = choices_array[choices_index][index].label
	update_current_choice_text(current_choice)

# Prepares sequential texts to display
func prepare_text(texts):
	text_array = []
	for t in texts:
		text_array.append(t)

	text_index = 0

# Resets game mode and creates new hero
func reset_game():
	has_made_choice = false
	choose_rand_hero()
	prepare_text([
		"Master, a " + hero.type + " is " + hero_locations[hero.locationIndex] + ".",
		"How shall we deal with them?"
	])
	set_text(text_index)

# Updates label text
func set_text(index):
	label.text = text_array[index]

# Toggles visibility of choice options
func toggle_choice_visibility():
	choices.visible = !choices.visible

# Updates current choice text color
func update_current_choice_text(choice):
	for label in choices.get_children():
		if label == choices.get_children()[choice]:
			label.set("custom_colors/font_color", Color("ffff00"))
		else:
			label.set("custom_colors/font_color", Color("#ffffff"))
