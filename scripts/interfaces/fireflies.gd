
extends GPUParticles2D

@export var background: TextureRect

const PARTICLE_AMOUNT: int = 75
const PARTICLE_LIFETIME: float = 6.0
const COVER_ZOOM: float = 1.15

var particle_material: ParticleProcessMaterial


func _ready() -> void:
	amount = PARTICLE_AMOUNT
	lifetime = PARTICLE_LIFETIME
	emitting = true
	local_coords = false
	preprocess = 3.0

	_create_white_texture()
	_configure_movement()
	_configure_glow()

	sync_with_background()


func _create_white_texture() -> void:
	var image := Image.create(
		32,
		32,
		false,
		Image.FORMAT_RGBA8
	)
	image.fill(Color.WHITE)
	texture = ImageTexture.create_from_image(image)


func _configure_movement() -> void:
	particle_material = ParticleProcessMaterial.new()

	particle_material.emission_shape = (
		ParticleProcessMaterial.EMISSION_SHAPE_BOX
	)

	# La caja completa se ajusta al tamaño real de la imagen.
	particle_material.emission_box_extents = Vector3(400, 250, 0)

	particle_material.direction = Vector3(0, -1, 0)
	particle_material.spread = 180.0

	# Mayor velocidad para que se desplacen de forma más perceptible.
	particle_material.initial_velocity_min = 12.0
	particle_material.initial_velocity_max = 28.0

	particle_material.gravity = Vector3.ZERO

	particle_material.linear_accel_min = -3.0
	particle_material.linear_accel_max = 3.0

	particle_material.scale_min = 0.35
	particle_material.scale_max = 0.8

	particle_material.turbulence_enabled = true
	particle_material.turbulence_noise_strength = 3.0
	particle_material.turbulence_noise_scale = 1.5
	particle_material.turbulence_influence_min = 0.5
	particle_material.turbulence_influence_max = 1.0

	process_material = particle_material


func _configure_glow() -> void:
	var shader := Shader.new()

	shader.code = """
shader_type canvas_item;
render_mode unshaded, blend_add;

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv);

    float core = 1.0 - smoothstep(0.0, 0.10, dist);
    float halo = 1.0 - smoothstep(0.05, 0.48, dist);

    // Variación suave de brillo.
    float flicker = 0.8 + 0.2 * sin(TIME * 2.5);

    vec3 orange = vec3(1.0, 0.38, 0.08);
    float brightness = (core + halo * 0.35) * flicker;
    float alpha = clamp(brightness, 0.0, 1.0);

    COLOR = vec4(orange * alpha, alpha);
}
"""

	var glow_material := ShaderMaterial.new()
	glow_material.shader = shader
	material = glow_material


func sync_with_background() -> void:
	if background == null or background.texture == null:
		return

	var image_size: Vector2 = background.texture.get_size()

	if image_size.x <= 0.0 or image_size.y <= 0.0:
		return

	var scale_factor: float = maxf(
		background.size.x / image_size.x,
		background.size.y / image_size.y
	) * COVER_ZOOM

	var draw_size: Vector2 = image_size * scale_factor
	var background_offset: float = float(
		background.get("offset_x")
	)

	# Centra el emisor sobre la imagen dibujada.
	position = background.position + Vector2(
		background_offset + draw_size.x * 0.5,
		draw_size.y * 0.5
	)

	# La emisión cubre toda la imagen, no solo una esquina.
	particle_material.emission_box_extents = Vector3(
		draw_size.x * 0.5,
		draw_size.y * 0.5,
		0.0
	)
