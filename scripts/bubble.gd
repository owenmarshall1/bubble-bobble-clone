extends Area2D

@onready var collision = $CollisionShape2D
@export var speed_x : float = 250
@export var float_speed : float = 50
@export var lifetime : float = 4.0
var direction : int = 1
var floating : bool = false
var timer : float = 0.0
var trapped_enemy : Node = null

func _ready():
	add_to_group("bubbles")
	$CollisionShape2D.disabled = false
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _physics_process(delta):
	timer += delta

	if not floating:
		#move horizontally
		position.x += direction * speed_x * delta
		if timer >= 0.25:
			floating = true
	else:
		#float
		position.y -= float_speed * delta

	#despawn bubble if not popped and make enemy rage
	if timer >= lifetime:
		if trapped_enemy:
			trapped_enemy.state = Enemy.State.ACTIVE
			trapped_enemy.trapped_bubble = null
			trapped_enemy.rage()
		queue_free()

#detect collision with enemy
func _on_body_entered(body: Node) -> void:
	if trapped_enemy == null and body is Enemy and body.state == Enemy.State.ACTIVE:
		#trap the enemy
		trapped_enemy = body
		body.state = Enemy.State.TRAPPED
		body.trapped_bubble = self
		body.velocity = Vector2.ZERO
		
		if body.has_node("CollisionShape2D"):
			body.get_node("CollisionShape2D").disabled = true
