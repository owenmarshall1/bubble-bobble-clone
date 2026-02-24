extends Node2D
@export var enemy_scene : PackedScene
enum GameState {MENU, PLAYING, GAMEOVER}
var state: GameState = GameState.MENU

@onready var menu_label: Label = $HUD/MenuLabel
@onready var game_over_label: Label = $HUD/GameOverLabel
@onready var player: Node = $Player
@onready var bonus_health_sound = $HealSound

var score: int = 0
@onready var score_label: Label = $HUD/ScoreLabel

var enemies_killed := 0

func _ready() -> void:
	set_state(GameState.MENU)
	pass 
	
func _process(_delta):
	match state:
		GameState.MENU:
			if Input.is_action_just_pressed("shoot"):
				start_game()
		GameState.PLAYING:
			pass
		GameState.GAMEOVER:
			if Input.is_action_just_pressed("shoot"):
				restart_game()
				
func set_state(new_state: GameState) -> void:
	state = new_state
	menu_label.visible = state == GameState.MENU
	game_over_label.visible = state == GameState.GAMEOVER
	
	
func start_game():
	#so player doesnt shoot on game start
	player.can_shoot = false
	Input.action_release("shoot")
	
	set_state(GameState.PLAYING)
	
	#spawn enemies
	for i in range(5):
			var enemy = enemy_scene.instantiate()
			enemy.position = Vector2(200 + i * 120, -100)
			add_child(enemy)
	check_spawn_condition()
	
	#initialize player
	player.health = 3
	player.update_hearts()
	player.global_position = Vector2(100,300)
	player.can_shoot = true
	
	
func game_over():
	set_state(GameState.GAMEOVER)
	
func restart_game():
	#clear enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	start_game()
	score = 0

func enemy_killed():
	enemies_killed += 1
	score += 100
	score_label.text = "Score: %d" % score
	
	#heal feature after killing 10 enemies
	if score % 1000 == 0 and player.health < 3:
		player.health += 1
		player.update_hearts()
		bonus_health_sound.play()
		
	check_spawn_condition()

func check_spawn_condition():
	var alive = get_tree().get_nodes_in_group("enemies").size()
	print("enemies alive: ", alive)
	#if only 2 are left alive spawn more (idk why its 3, it just works)
	if alive <= 3:
		for i in range(5):
			var enemy = enemy_scene.instantiate()
			enemy.position = Vector2(200 + i * 120, -100)
			add_child(enemy)
