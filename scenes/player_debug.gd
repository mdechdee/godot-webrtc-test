extends Control

@export var player: Player

func _process(delta):
	queue_redraw()

func _draw():
	draw_circle(Vector2(0,0), 50.0, Color.GRAY)
	draw_line(
		Vector2.ZERO, 
		Vector2(player.direction.x, player.direction.z).normalized() * 50, 
		Color.RED
	)
	draw_line(
		Vector2.ZERO, 
		Vector2(player.facing_dir.x, player.facing_dir.z).normalized() * 50, 
		Color.BLUE
	)
