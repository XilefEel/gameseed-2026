class_name Camera
extends Camera2D


func _ready() -> void:
	pass # Replace with function body.


func setup_camera(grid_size: int) -> void:
	var grid_pixel_size = grid_size * 16
	position = Vector2(grid_pixel_size / 2.0, grid_pixel_size / 2.0)

	var viewport_size = get_viewport().get_visible_rect().size
	
	var zoom_x = viewport_size.x / grid_pixel_size
	var zoom_y = viewport_size.y / grid_pixel_size
	var zoom_level = min(zoom_x, zoom_y) * 0.9 
    
	zoom = Vector2(zoom_level, zoom_level)