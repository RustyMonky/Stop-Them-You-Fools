extends Node2D

enum GAME_STATE {
	PROMPTING,
	CHOOSING,
	PROCESSING,
	EXECUTING
}

var choices
var choices_array = [
	[
		{label = "arrow barrage", command = "Unleash an arrow barrage and blot out the sun!", type = "trap"},
		{label = "zombie horde", command = "Send forth the zombie horde to eat their brains!", type = "monster"},
		{label = "magic barrier", command = "Cast an inpenetrable magic barrier around the walls!", type = "magic"}
	],
	[
		{label = "crushing walls", command = "Crush him with the moving walls, you fools!", type = "trap"},
		{label = "minotaur", command = "Send the damn minotaur to crush him!", type = "monster"},
		{label = "flood the halls", command = "Summon so much water that they'll drown in their stupidity!", type = "magic"}
	],
	[
		{label = "remote detonation", command = "Detonate the hallway mines, you imbecile!", type = "trap"},
		{label = "dragon", command = "Wait are you waiting for!? Wake the dragon!", type = "monster"},
		{label = "black hole", command = "Summon a black hole and pull him into oblivion!", type = "magic"}
	]
]
var choices_index = 0
var current_choice = 0
var current_choice_label
var current_game_state
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
	choices = $GUI/Choices
	current_choice_label = $"GUI/Current Choice"
	label = $GUI/Label

	current_game_state = PROMPTING

	choose_rand_hero()

	set_process(true)

	set_process_input(true)

func _process(delta):
	if current_game_state == PROMPTING and text_array.size() == 0:
		choose_rand_hero()
		prepare_text([
			"Master, a " + hero.type + " is " + hero_locations[hero.locationIndex] + ".",
			"How shall we deal with them?"
		])
		set_text(0)

	elif current_game_state == CHOOSING:
		if not choices.visible or not current_choice_label.visible:
			choices.visible = true
			current_choice_label.visible = true

func _input(event):
	if event.is_action_pressed("ui_accept") and current_game_state == PROMPTING:
		if (text_index + 1) >= (text_array.size()):
			prepare_choices()
			current_game_state = CHOOSING
		else:
			text_index += 1
			set_text(text_index)

# Chooses random hero type from preconstructed array
func choose_rand_hero():
	var index = randi() % hero_types.size()
	hero.type = hero_types[index]
	hero.locationIndex = 0

# Prepares choices labels
func prepare_choices():
	for choice in choices.get_children():
		var index = choices.get_children().find(choice)
		choice.text = choices_array[choices_index][index].label
	current_choice_label.text = String(current_choice)

# Prepares sequential texts to display
func prepare_text(texts):
	for t in texts:
		text_array.append(t)

	text_index = 0

# Updates label text
func set_text(index):
	label.text = text_array[index]
