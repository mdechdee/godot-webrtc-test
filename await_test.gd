extends Node

signal a(b,c)

func _ready():
	run_timer()
	var val = await a
	print(val)

func run_timer():
	await get_tree().create_timer(1.0).timeout
	a.emit(1,2)
