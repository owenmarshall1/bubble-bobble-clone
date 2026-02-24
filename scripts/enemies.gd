extends CharacterBody2D
class_name Enemy

@onready var sprite: Sprite2D = $Sprite2D
@onready var rage_sound = $RageSound

@export var speed := 150
var direction := -1
var gravity := 900
enum State { ACTIVE, TRAPPED }
var state: State = State.ACTIVE
var trapped_bubble: Node = null

func _physics_process(delta):
	match state:
		State.ACTIVE:
			patrol(delta)
		State.TRAPPED:
			if trapped_bubble:
				global_position = trapped_bubble.global_position
func patrol(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if global_position.y > 480:
		global_position.y = -10

	velocity.x = direction * speed

	move_and_slide()

	#check slide collisions manually
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("player") and state == State.ACTIVE:
			collider.take_damage(global_position)
			
	#turn if hit wall
	if is_on_wall():
		var wall_only = true
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("player"):
				wall_only = false

		if wall_only:
			direction *= -1
			$Sprite2D.flip_h = direction > 0

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state == State.ACTIVE:
		body.take_damage(global_position)
		
func rage():
	speed = 300
	sprite.modulate = Color(1, 0.3, 0.3)
	rage_sound.play()
	
