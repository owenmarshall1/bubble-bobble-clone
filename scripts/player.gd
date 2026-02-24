extends CharacterBody2D

@export var bubble_scene : PackedScene
var direction : int = 1
var fire_cooldown : float = 0.7
var fire_timer : float = 0.0
var gravity = 981

@export var knockback_force := 200
@export var knockback_up_force := 300
@export var invincible_time := 1.0

var is_invincible := false
var knockback_timer := 0.2
var knockback_remaining := 0.0
var can_shoot := false

@onready var sprite: Sprite2D = $Sprite2D

@onready var hit_sound = $Sounds/HitSound
@onready var death_sound = $Sounds/DeathSound

@onready var hearts := $"/root/Main/HUD/Hearts".get_children()
var health := 3

func _physics_process(delta):
	var gm = get_node("/root/Main")
	if gm.state != gm.GameState.PLAYING:
		return
		
	if health <= 0:
		print("Game Over")
		get_node("/root/Main").game_over()
		
	if global_position.y > 640:
		global_position.y = 0
		
	fire_timer -= delta

	var input_dir = 0
	if knockback_remaining <= 0:
		input_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
		if input_dir != 0:
			direction = sign(input_dir)
			sprite.flip_h = direction < 0 
		velocity.x = input_dir * 200
		
	velocity.y += gravity * delta
	
	if knockback_remaining > 0:
		knockback_remaining -= delta
		
	#move
	move_and_slide()

	#jump
	if knockback_remaining <= 0 and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -450
		move_and_slide()

	#shoot bubble
	if knockback_remaining <= 0 and Input.is_action_just_pressed("shoot") and fire_timer <= 0 and can_shoot:
		shoot_bubble()
		fire_timer = fire_cooldown
		
	check_pop_bubble()
		
func take_damage(from_position: Vector2):
	if is_invincible:
		return
		
	health -= 1
	if health > 0:
		hit_sound.play()
	elif health == 0:
		death_sound.play()
		
	update_hearts()
	print("Health:", health)
	
	var kb_dir = sign(global_position.x - from_position.x)
	velocity.x = kb_dir * knockback_force
	velocity.y = -knockback_up_force
	knockback_remaining = knockback_timer
	
	#i frames
	is_invincible = true
	await get_tree().create_timer(invincible_time).timeout
	is_invincible = false

func shoot_bubble():
	if bubble_scene and can_shoot:
		var bubble = bubble_scene.instantiate()
		bubble.position = position + Vector2(direction * 20, -10)
		bubble.direction = direction
		get_parent().add_child(bubble)
		bubble.add_to_group("bubbles")
		
func update_hearts():
	for i in range(hearts.size()):
		if i < health:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func check_pop_bubble():
	for bubble in get_tree().get_nodes_in_group("bubbles"):
		if bubble.trapped_enemy:
			if bubble.overlaps_body(self):
				pop_bubble(bubble)

func pop_bubble(bubble: Area2D) -> void:
	if bubble.trapped_enemy:
		var gm = get_node("/root/Main")
			
		bubble.trapped_enemy.queue_free()
		bubble.trapped_enemy = null
		gm.enemy_killed()
		
		
		
	bubble.queue_free()
