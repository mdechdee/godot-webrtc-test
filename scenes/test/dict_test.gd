extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("hi")
	var d1 = []
	var d2 = [{"1": "2"}, {"3":"4"}]
	print(d1.has({"1": "2"}))
	print(d1.has({"3": "4"}))
	print(
		d2.filter(
		func(a): 
			print(a)
			return !d1.has(a)
	))
