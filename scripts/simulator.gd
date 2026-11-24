extends Node3D

const RANGE_LENGTH := 260.0
const GRAVITY := 9.81
const PROFILE_PATH := "user://balvox_settings.json"

var camera: Camera3D
var yaw := 0.0
var pitch := -0.12
var move_speed := 16.0
var quality := 1
var paused := false
var help_visible := true
var launch_power := 0.72
var launch_angle := 0.42
var launches := 0
var impacts := 0
var elapsed := 0.0
var projectiles: Array[Dictionary] = []
var target_nodes: Array[Node3D] = []
var hud: CanvasLayer
var status_label: Label
var telemetry_label: Label
var settings_panel: PanelContainer
var quality_select: OptionButton
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    _build_environment()
    _build_range()
    _build_launcher()
    _build_camera()
    _build_hud()
    _load_settings()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.12, 0.27, 0.43)
    sky_mat.sky_horizon_color = Color(0.72, 0.79, 0.82)
    sky_mat.ground_bottom_color = Color(0.12, 0.13, 0.12)
    sky_mat.ground_horizon_color = Color(0.48, 0.52, 0.48)
    sky_mat.sun_angle_max = 18.0
    sky.sky_material = sky_mat
    env.sky = sky
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.tonemap_exposure = 1.15
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_sky_contribution = 0.72
    env.ambient_light_energy = 0.8
    env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
    env.ssr_enabled = true
    env.ssao_enabled = true
    env.ssao_radius = 2.0
    env.ssao_intensity = 2.0
    env.glow_enabled = true
    env.glow_intensity = 0.28
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.012
    world.environment = env
    add_child(world)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-43, -28, 0)
    sun.light_energy = 1.45
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 180.0
    add_child(sun)
    var fill := DirectionalLight3D.new()
    fill.rotation_degrees = Vector3(-18, 145, 0)
    fill.light_energy = 0.28
    fill.light_color = Color(0.58, 0.7, 1.0)
    add_child(fill)

func _mat(color: Color, roughness := 0.82, metallic := 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    m.metallic = metallic
    return m

func _box(parent: Node3D, pos: Vector3, size: Vector3, material: Material, collision := false) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.material_override = material
    node.position = pos
    parent.add_child(node)
    if collision:
        var body := StaticBody3D.new()
        body.position = pos
        var shape := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = size
        shape.shape = box_shape
        body.add_child(shape)
        add_child(body)
    return node

func _build_range() -> void:
    var terrain := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(520, 520)
    plane.subdivide_width = 120
    plane.subdivide_depth = 120
    terrain.mesh = plane
    terrain.position = Vector3(0, -0.65, -80)
    var terrain_shader := load("res://shaders/terrain.gdshader") as Shader
    var ground_mat := ShaderMaterial.new()
    ground_mat.shader = terrain_shader
    terrain.material_override = ground_mat
    add_child(terrain)
    var concrete := _mat(Color(0.34, 0.37, 0.37), 0.88)
    var dark_concrete := _mat(Color(0.20, 0.23, 0.24), 0.92)
    var sand := _mat(Color(0.40, 0.39, 0.31), 1.0)
    _box(self, Vector3(0, -0.18, -42), Vector3(48, 0.3, 185), concrete)
    for i in range(0, 14):
        var z := -i * 15.0
        _box(self, Vector3(-26, -0.15, z), Vector3(1.1, 0.25, 2.0), dark_concrete)
        _box(self, Vector3(26, -0.15, z), Vector3(1.1, 0.25, 2.0), dark_concrete)
    for side in [-1.0, 1.0]:
        for i in range(12):
            var z := -18.0 - i * 19.0
            var h := rng.randf_range(2.5, 8.0)
            var rock := _box(self, Vector3(side * rng.randf_range(42, 78), h * 0.35, z), Vector3(rng.randf_range(8, 18), h, rng.randf_range(8, 20)), sand)
            rock.rotation.y = rng.randf_range(-0.5, 0.5)
    for i in range(8):
        var x := -21.0 + i * 6.0
        _box(self, Vector3(x, 0.15, -92), Vector3(0.18, 0.3, 1.8), _mat(Color(0.86, 0.72, 0.34), 0.7))
    for i in range(7):
        var target := Node3D.new()
        target.position = Vector3(-18 + i * 6.0, 1.4, -55 - (i % 2) * 22)
        add_child(target)
        var body := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.7
        cylinder.bottom_radius = 0.9
        cylinder.height = 2.8
        body.mesh = cylinder
        body.material_override = _mat(Color(0.35, 0.39, 0.36), 0.72, 0.32)
        target.add_child(body)
        var plate := MeshInstance3D.new()
        var plate_mesh := BoxMesh.new()
        plate_mesh.size = Vector3(2.4, 1.7, 0.22)
        plate.mesh = plate_mesh
        plate.position.y = 0.1
        plate.material_override = _mat(Color(0.52, 0.22, 0.16), 0.58, 0.18)
        target.add_child(plate)
        target_nodes.append(target)
    _box(self, Vector3(-34, 2, -32), Vector3(7, 4, 9), dark_concrete)
    _box(self, Vector3(34, 2, -32), Vector3(7, 4, 9), dark_concrete)

func _build_launcher() -> void:
    var base := Node3D.new()
    base.name = "TestPlatform"
    base.position = Vector3(0, 0, 8)
    add_child(base)
    var steel := _mat(Color(0.22, 0.27, 0.29), 0.36, 0.72)
    var rubber := _mat(Color(0.055, 0.065, 0.07), 0.92)
    var plinth := MeshInstance3D.new()
    var plinth_mesh := BoxMesh.new()
    plinth_mesh.size = Vector3(8, 0.5, 7)
    plinth.mesh = plinth_mesh
    plinth.position.y = 0.25
    plinth.material_override = _mat(Color(0.18, 0.21, 0.22))
    base.add_child(plinth)
    for x in [-2.8, 2.8]:
        for z in [-2.2, 2.2]:
            var foot := MeshInstance3D.new()
            var foot_mesh := CylinderMesh.new()
            foot_mesh.top_radius = 0.42
            foot_mesh.bottom_radius = 0.52
            foot_mesh.height = 0.65
            foot.mesh = foot_mesh
            foot.position = Vector3(x, 0.1, z)
            foot.material_override = rubber
            base.add_child(foot)
    var pivot := Node3D.new()
    pivot.name = "ElevationPivot"
    pivot.position.y = 1.2
    base.add_child(pivot)
    var tube := MeshInstance3D.new()
    var tube_mesh := CylinderMesh.new()
    tube_mesh.top_radius = 0.52
    tube_mesh.bottom_radius = 0.58
    tube_mesh.height = 5.0
    tube.mesh = tube_mesh
    tube.rotation.x = PI / 2
    tube.position.z = -2.0
    tube.material_override = steel
    pivot.add_child(tube)
    var support := MeshInstance3D.new()
    var support_mesh := BoxMesh.new()
    support_mesh.size = Vector3(3.4, 0.4, 2.2)
    support.mesh = support_mesh
    support.position.y = 0.55
    support.material_override = steel
    base.add_child(support)
    base.set_meta("pivot", pivot)

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.position = Vector3(0, 5.5, 23)
    camera.rotation.x = -0.16
    camera.fov = 76
    camera.current = true
    add_child(camera)

func _build_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.add_child(root)
    var header := Label.new()
    header.text = "BALVOX  /  REALISTIC TEST RANGE"
    header.position = Vector2(28, 22)
    header.add_theme_font_size_override("font_size", 22)
    header.add_theme_color_override("font_color", Color(0.88, 0.93, 0.94))
    root.add_child(header)
    status_label = Label.new()
    status_label.position = Vector2(30, 58)
    status_label.add_theme_color_override("font_color", Color(0.48, 0.78, 0.73))
    root.add_child(status_label)
    telemetry_label = Label.new()
    telemetry_label.position = Vector2(30, 78)
    telemetry_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.87))
    root.add_child(telemetry_label)
    var help := Label.new()
    help.name = "Help"
    help.text = "WASD MOVE   MOUSE LOOK   SPACE TEST   Q/E ANGLE   +/- POWER   F2 GRAPHICS   TAB PAUSE   ESC CURSOR"
    help.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    help.position.y = -42
    help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    help.add_theme_color_override("font_color", Color(0.88, 0.89, 0.85))
    root.add_child(help)
    settings_panel = PanelContainer.new()
    settings_panel.position = Vector2(30, 125)
    settings_panel.custom_minimum_size = Vector2(300, 180)
    settings_panel.visible = false
    root.add_child(settings_panel)
    var settings := VBoxContainer.new()
    settings_panel.add_child(settings)
    var title := Label.new()
    title.text = "SIMULATION SETTINGS"
    title.add_theme_font_size_override("font_size", 17)
    settings.add_child(title)
    var quality_title := Label.new()
    quality_title.text = "Graphics quality"
    settings.add_child(quality_title)
    quality_select = OptionButton.new()
    quality_select.add_item("Low")
    quality_select.add_item("Medium")
    quality_select.add_item("High")
    quality_select.add_item("Ultra")
    quality_select.selected = quality
    quality_select.item_selected.connect(func(index: int):
        quality = index
        _apply_quality()
    )
    settings.add_child(quality_select)
    var speed_title := Label.new()
    speed_title.text = "Camera movement speed"
    settings.add_child(speed_title)
    var speed_slider := HSlider.new()
    speed_slider.min_value = 5
    speed_slider.max_value = 34
    speed_slider.value = move_speed
    speed_slider.value_changed.connect(func(value: float):
        move_speed = value
        _save_settings()
    )
    settings.add_child(speed_slider)
    var power_title := Label.new()
    power_title.text = "Test power"
    settings.add_child(power_title)
    var power_slider := HSlider.new()
    power_slider.min_value = 0.2
    power_slider.max_value = 1.0
    power_slider.step = 0.01
    power_slider.value = launch_power
    power_slider.value_changed.connect(func(value: float):
        launch_power = value
        _save_settings()
    )
    settings.add_child(power_slider)
    var fullscreen := CheckButton.new()
    fullscreen.text = "Fullscreen"
    fullscreen.button_pressed = false
    fullscreen.toggled.connect(func(enabled: bool):
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
    )
    settings.add_child(fullscreen)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not paused:
        yaw -= event.relative.x * 0.0025
        pitch = clampf(pitch - event.relative.y * 0.0022, -1.0, 0.65)
        camera.rotation = Vector3(pitch, yaw, 0)
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            move_speed = minf(move_speed + 2.0, 34.0)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            move_speed = maxf(move_speed - 2.0, 5.0)
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_ESCAPE:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
            KEY_TAB:
                paused = not paused
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
            KEY_F1:
                help_visible = not help_visible
                hud.get_node("Control/Help").visible = help_visible
            KEY_F2:
                quality = (quality + 1) % 4
                if quality_select:
                    quality_select.select(quality)
                _apply_quality()
            KEY_F3:
                settings_panel.visible = not settings_panel.visible
            KEY_SPACE:
                if not paused:
                    _launch_test_projectile()
            KEY_R:
                _reset_range()
            KEY_Q:
                launch_angle = clampf(launch_angle + 0.025, 0.12, 1.15)
            KEY_E:
                launch_angle = clampf(launch_angle - 0.025, 0.12, 1.15)
            KEY_EQUAL, KEY_KP_ADD:
                launch_power = minf(launch_power + 0.04, 1.0)
            KEY_MINUS, KEY_KP_SUBTRACT:
                launch_power = maxf(launch_power - 0.04, 0.2)

func _physics_process(delta: float) -> void:
    if paused:
        return
    elapsed += delta
    var forward := Vector3(sin(yaw), 0, cos(yaw))
    var right := Vector3(cos(yaw), 0, -sin(yaw))
    var movement := Vector3.ZERO
    if Input.is_key_pressed(KEY_W): movement -= forward
    if Input.is_key_pressed(KEY_S): movement += forward
    if Input.is_key_pressed(KEY_A): movement -= right
    if Input.is_key_pressed(KEY_D): movement += right
    if movement.length_squared() > 0:
        camera.position += movement.normalized() * move_speed * delta
    camera.position.y = clampf(camera.position.y, 1.7, 35.0)
    for i in range(projectiles.size() - 1, -1, -1):
        var p: Dictionary = projectiles[i]
        var velocity: Vector3 = p.velocity
        velocity.y -= GRAVITY * delta
        var next_position: Vector3 = p.position + velocity * delta
        p.velocity = velocity
        p.position = next_position
        p.age += delta
        var visual: Node3D = p.visual
        visual.position = next_position
        visual.look_at(next_position + velocity.normalized(), Vector3.UP)
        if next_position.y < 0.15 or p.age > 12.0 or _check_target_hit(next_position):
            _spawn_impact(next_position)
            visual.queue_free()
            projectiles.remove_at(i)
    telemetry_label.text = "TIME %.1f s     TESTS %03d     IMPACTS %03d     QUALITY %s" % [elapsed, launches, impacts, ["LOW", "MEDIUM", "HIGH", "ULTRA"][quality]]
    status_label.text = "SIMULATION ACTIVE  |  RANGE 01  |  FPS %d" % Engine.get_frames_per_second()

func _launch_test_projectile() -> void:
    var visual := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.16
    mesh.height = 0.32
    visual.mesh = mesh
    visual.material_override = _mat(Color(1.0, 0.55, 0.19), 0.28, 0.25)
    add_child(visual)
    var origin := Vector3(0, 2.1, 8)
    visual.position = origin
    var direction := Vector3(0, sin(launch_angle), -cos(launch_angle))
    var speed := 38.0 + launch_power * 45.0
    projectiles.append({"visual": visual, "position": origin, "velocity": direction * speed, "age": 0.0})
    launches += 1

func _check_target_hit(point: Vector3) -> bool:
    for target in target_nodes:
        if target.visible and target.position.distance_to(point) < 1.7:
            target.visible = false
            impacts += 1
            return true
    return false

func _spawn_impact(point: Vector3) -> void:
    var burst := GPUParticles3D.new()
    var process := ParticleProcessMaterial.new()
    process.direction = Vector3(0, 1, 0)
    process.spread = 180
    process.initial_velocity_min = 2.0
    process.initial_velocity_max = 8.0
    process.gravity = Vector3(0, -9.81, 0)
    process.scale_min = 0.06
    process.scale_max = 0.22
    burst.process_material = process
    burst.amount = 48
    burst.lifetime = 1.4
    burst.one_shot = true
    burst.emitting = true
    var sphere := SphereMesh.new()
    sphere.radius = 0.12
    burst.draw_pass_1 = sphere
    burst.position = point
    add_child(burst)
    var timer := get_tree().create_timer(2.0)
    timer.timeout.connect(burst.queue_free)

func _reset_range() -> void:
    for p in projectiles:
        (p.visual as Node3D).queue_free()
    projectiles.clear()
    for target in target_nodes:
        target.visible = true
    launches = 0
    impacts = 0
    elapsed = 0.0

func _apply_quality() -> void:
    var world := get_node_or_null("WorldEnvironment") as WorldEnvironment
    if world == null: return
    var env := world.environment
    env.ssao_enabled = quality >= 1
    env.ssr_enabled = quality >= 2
    env.volumetric_fog_enabled = quality >= 2
    env.glow_enabled = quality >= 1
    env.glow_intensity = [0.12, 0.22, 0.32, 0.45][quality]
    if quality == 0:
        env.ambient_light_energy = 0.65
    else:
        env.ambient_light_energy = 0.8 + quality * 0.08
    _save_settings()

func _save_settings() -> void:
    var file := FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({"quality": quality, "speed": move_speed, "power": launch_power}))

func _load_settings() -> void:
    if not FileAccess.file_exists(PROFILE_PATH): return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(PROFILE_PATH))
    if parsed is Dictionary:
        quality = clampi(int(parsed.get("quality", 1)), 0, 3)
        move_speed = clampf(float(parsed.get("speed", 16)), 5, 34)
        launch_power = clampf(float(parsed.get("power", 0.72)), 0.2, 1.0)
        _apply_quality()
        if quality_select:
            quality_select.select(quality)
