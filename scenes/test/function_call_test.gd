extends Node

func _ready():
	var room_id = await FunctionTest.host_room()
	FunctionTest.store_message(room_id, "HI MOM")
