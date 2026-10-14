extends Control

const ROOT = "res://recursos, GENIOS/"
const NFT_DIR = ROOT + "Nfts/"
const UPGRADE_DIR = ROOT + "incrementos-efectos/"
const ACH_DIR = ROOT + "logros/"
const SFX_DIR = ROOT + "sonidos/"
const INTRO_VIDEO = "res://inicio/Pollo-caminando-con-Mecha-Mecha-de-fondo.ogv"

var points: int = 0
var taps: int = 0
var multiplier: int = 1
var tung_count: int = 0
var tnt_count: int = 0
var unlocked: Array[int] = [1]
var achievements_unlocked: Array[int] = []
var current_tab: String = "Incrementadores"
var game_started := false
var achievement_popup: Control
var points_label: Label
var status_label: Label
var store_list: VBoxContainer
var main_area: HBoxContainer
var menu_layer: Control
var game_layer: Control
var video_player: VideoStreamPlayer
var sound_player: AudioStreamPlayer
var genio_player: AudioStreamPlayer
var tungs_player: AudioStreamPlayer
var tnt_player: AudioStreamPlayer
var background_audio_player: AudioStreamPlayer
var selected_genio_points: int = 0
var secret_word_buffer: String = ""
var click_button: TextureButton
var equipped_nft_label: Label
var owned_tung_button: TextureButton
var achievement_tween: Tween
var selected_nft_id: int = 1
var genio_texture: Texture2D
var tungs_texture: Texture2D
var tnt_texture: Texture2D
var explosion_texture: Texture2D

var upgrades := [
	{"id": 1, "name": "Tungtungsahur", "price": 15, "description": "+1 punto por click", "kind": "tung"},
	{"id": 2, "name": "TNT", "price": 60, "description": "Cada 3 clicks: +4 puntos", "kind": "tnt"},
	{"id": 3, "name": "Por dos", "price": 150, "description": "Duplica todos los puntos ganados", "kind": "double"}
]
var nfts := [
	{"id": 1, "name": "Genio", "price": 0, "file": "1-genio.jpg"},
	{"id": 2, "name": "Burro", "price": 100, "file": "2-burro.jpg"},
	{"id": 3, "name": "Genia", "price": 250, "file": "3-genia.jpg"},
	{"id": 4, "name": "Bzzz", "price": 500, "file": "4-bzzz.jpg"},
	{"id": 5, "name": "Geniol", "price": 900, "file": "5-geniol.jpg"},
	{"id": 6, "name": "Eo", "price": 1500, "file": "6-Eo.jpg"},
	{"id": 7, "name": "Prodigio", "price": 2500, "file": "7-prodigio.jpg"},
	{"id": 8, "name": "Mogolico", "price": 4000, "file": "8-mogolico.jpg"},
	{"id": 9, "name": "Jujeño", "price": 6500, "file": "9-jujeño.jpg"},
	{"id": 10, "name": "Webiwabo", "price": 10000, "file": "10-webiwabo.jpg"},
	{"id": 11, "name": "Magnifico", "price": 16000, "file": "11-magnifico.jpg"},
	{"id": 12, "name": "God", "price": 25000, "file": "12-god.jpg"},
	{"id": 13, "name": "Genio HD", "price": 40000, "file": "13-geniohd.jpg"},
	{"id": 14, "name": "Iñarandu", "price": 65000, "file": "14-iñarandu.jpg"},
	{"id": 15, "name": "Genius", "price": 100000, "file": "15-genius.jpg"},
	{"id": 16, "name": "Genio 16", "price": 150000, "file": "16-genio tierra prometida.jpg"}
]
var achievements := [
	{"id": 1, "points": 10, "description": "Consigue 10 GenioPuntos.", "image": "1-logro 10.jpg"},
	{"id": 2, "points": 100, "description": "Consigue 100 GenioPuntos.", "image": "2-logro 100.jpg"},
	{"id": 3, "points": 1000, "description": "Consigue 1000 GenioPuntos.", "image": "3-logro 1000.jpg"},
	{"id": 4, "points": 10000, "description": "Consigue 10000 GenioPuntos.", "image": "4-logro 10000.jpg"},
	{"id": 5, "points": 100000, "description": "Consigue 100000 GenioPuntos.", "image": "5-logro 100000.jpg"},
	{"id": 6, "points": 1000000, "description": "Consigue 1000000 GenioPuntos.", "image": "6-logro 1000000.jpg"},
	{"id": 7, "points": 10000000, "description": "Consigue 10000000 GenioPuntos.", "image": "7-logro 10000000.jpg"},
	{"id": 8, "points": 3000, "description": "Consigue 3000 puntos usando el NFT Genio 16.", "nft_id": 16, "image": "8- logro 3000.jpg"}
]

func _input(event: InputEvent) -> void:
	# Easter egg: escribir "genio" en el teclado suma 1000 GenioPuntos.
	if event is InputEventKey and event.pressed and not event.echo and event.unicode > 0:
		var character = String.chr(event.unicode).to_lower()
		if character >= "a" and character <= "z":
			secret_word_buffer += character
			if secret_word_buffer.length() > 5:
				secret_word_buffer = secret_word_buffer.substr(secret_word_buffer.length() - 5, 5)
			if secret_word_buffer == "genio":
				points += 1000
				secret_word_buffer = ""
				_check_achievements()
				_update_counter()
				if is_instance_valid(status_label):
					status_label.text = "¡EASTER EGG! +1000 GENIOPUNTOS"

func _ready() -> void:
	_load_assets()
	_make_audio_players()
	_build_menu()
	_build_game()
	_show_menu()

func _load_assets() -> void:
	genio_texture = load(NFT_DIR + "1-genio.jpg")
	tungs_texture = load(UPGRADE_DIR + "1-tungsahur.webp")
	tnt_texture = load(UPGRADE_DIR + "2-TNT.webp")
	explosion_texture = load(ROOT + "efecto/1-explosion para el tnt.webp")

func _make_audio_players() -> void:
	sound_player = AudioStreamPlayer.new()
	genio_player = AudioStreamPlayer.new()
	tungs_player = AudioStreamPlayer.new()
	tnt_player = AudioStreamPlayer.new()
	background_audio_player = AudioStreamPlayer.new()
	for player in [sound_player, genio_player, tungs_player, tnt_player, background_audio_player]:
		add_child(player)
	genio_player.stream = load(SFX_DIR + "Genio.mp3")
	tungs_player.stream = load(SFX_DIR + "audioparagolpedetungsahur.mp3")
	tnt_player.stream = load(SFX_DIR + "explosion de la tnt.mp3")
	sound_player.stream = load(SFX_DIR + "Genio.mp3")
	var background_audio = load(SFX_DIR + "extracted-audio.mp3")
	if background_audio:
		background_audio_player.stream = background_audio
		background_audio_player.volume_db = -24.0
		background_audio_player.finished.connect(func():
			if selected_nft_id == 16 and not background_audio_player.playing:
				background_audio_player.play()
		)

func _play(player: AudioStreamPlayer) -> void:
	if player.stream:
		player.stop()
		player.play()

func _build_menu() -> void:
	menu_layer = Control.new()
	menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_layer)
	video_player = VideoStreamPlayer.new()
	video_player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	video_player.expand = true
	video_player.autoplay = true
	video_player.audio_track = 0
	var video = load(INTRO_VIDEO)
	if video:
		video_player.stream = video
	menu_layer.add_child(video_player)
	var shade = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.02, 0.08, 0.58)
	menu_layer.add_child(shade)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(center)
	var panel = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(360, 250)
	panel.add_theme_constant_override("separation", 18)
	center.add_child(panel)
	var title = Label.new()
	title.text = "TAP YOUR GENIO!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("#ffe66d"))
	panel.add_child(title)
	var subtitle = Label.new()
	subtitle.text = "El clicker definitivo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	panel.add_child(subtitle)
	var start = _make_button("INICIAR", 24)
	start.pressed.connect(_start_game)
	panel.add_child(start)
	var quit = _make_button("SALIR", 20)
	quit.pressed.connect(func(): get_tree().quit())
	panel.add_child(quit)

func _build_game() -> void:
	game_layer = Control.new()
	game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_layer)

	# NFT como fondo/clicker a pantalla completa.
	click_button = TextureButton.new()
	click_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_button.texture_normal = genio_texture
	click_button.texture_hover = genio_texture
	click_button.texture_pressed = genio_texture
	click_button.stretch_mode = TextureButton.STRETCH_SCALE
	click_button.pressed.connect(_on_genio_click)
	game_layer.add_child(click_button)

	# Navigation buttons centered over the full-screen NFT.
	var nav_center = CenterContainer.new()
	nav_center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	nav_center.offset_left = 0
	nav_center.offset_top = 12
	nav_center.offset_right = 0
	nav_center.offset_bottom = 88
	nav_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nav_center.z_index = 8
	game_layer.add_child(nav_center)
	var nav_row = HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 18)
	nav_row.mouse_filter = Control.MOUSE_FILTER_STOP
	nav_center.add_child(nav_row)
	var menu_button = _make_button("MENU", 22)
	menu_button.custom_minimum_size = Vector2(160, 64)
	menu_button.pressed.connect(_show_menu)
	nav_row.add_child(menu_button)
	points_label = Label.new()
	points_label.text = "GENIOPUNTOS: 0"
	points_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	points_label.add_theme_font_size_override("font_size", 22)
	points_label.add_theme_color_override("font_color", Color("#1685ad"))
	nav_row.add_child(points_label)
	var shop_button = _make_button("TIENDA", 22)
	shop_button.custom_minimum_size = Vector2(160, 64)
	shop_button.pressed.connect(_show_shop)
	nav_row.add_child(shop_button)
	var achievements_button = _make_button("LOGROS", 22)
	achievements_button.custom_minimum_size = Vector2(160, 64)
	achievements_button.pressed.connect(_show_achievements)
	nav_row.add_child(achievements_button)

	# Herramienta local de desarrollo: solo aparece si el entorno la habilita.
	if OS.get_environment("TAPYOURGENIO_DEV_MODE") == "1":
		var dev_button = _make_button("+1000 DEV", 16)
		dev_button.custom_minimum_size = Vector2(130, 64)
		dev_button.tooltip_text = "Añadir 1000 puntos (modo desarrollo local)"
		dev_button.pressed.connect(func():
			points += 1000
			_check_achievements()
			_update_counter()
		)
		nav_row.add_child(dev_button)

	status_label = Label.new()
	status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	status_label.offset_left = 12
	status_label.offset_top = -48
	status_label.offset_right = -12
	status_label.offset_bottom = -10
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label.z_index = 6
	game_layer.add_child(status_label)

	# Tung Sahur pequeño superpuesto como botón en la esquina inferior izquierda.
	owned_tung_button = TextureButton.new()
	owned_tung_button.texture_normal = tungs_texture
	owned_tung_button.texture_hover = tungs_texture
	owned_tung_button.texture_pressed = tungs_texture
	owned_tung_button.custom_minimum_size = Vector2(42, 42)
	owned_tung_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	owned_tung_button.tooltip_text = "Tung Sahur"
	owned_tung_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	owned_tung_button.position = Vector2(18, 12)
	owned_tung_button.size = Vector2(42, 42)
	owned_tung_button.visible = false
	owned_tung_button.z_index = 7
	owned_tung_button.pressed.connect(func(): _play(tungs_player))
	game_layer.add_child(owned_tung_button)

	# Pantalla de tienda.
	var shop_overlay = ColorRect.new()
	shop_overlay.name = "ShopOverlay"
	shop_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_overlay.color = Color(0.035, 0.035, 0.09, 0.97)
	shop_overlay.visible = false
	shop_overlay.z_index = 10
	game_layer.add_child(shop_overlay)
	var shop_root = VBoxContainer.new()
	shop_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_root.offset_left = 42
	shop_root.offset_top = 32
	shop_root.offset_right = -42
	shop_root.offset_bottom = -32
	shop_root.add_theme_constant_override("separation", 16)
	shop_overlay.add_child(shop_root)
	var shop_header = HBoxContainer.new()
	shop_root.add_child(shop_header)
	var shop_title = Label.new()
	shop_title.text = "TIENDA"
	shop_title.add_theme_font_size_override("font_size", 36)
	shop_title.add_theme_color_override("font_color", Color("#ffe66d"))
	shop_header.add_child(shop_title)
	var shop_spacer = Control.new()
	shop_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_header.add_child(shop_spacer)
	var back_from_shop = _make_button("VOLVER AL JUEGO", 20)
	back_from_shop.pressed.connect(_show_gameplay)
	shop_header.add_child(back_from_shop)
	var tabs = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 12)
	shop_root.add_child(tabs)
	var upgrades_tab = _make_button("INCREMENTADORES", 18)
	upgrades_tab.pressed.connect(func(): current_tab = "Incrementadores"; _refresh_store())
	tabs.add_child(upgrades_tab)
	var nfts_tab = _make_button("GENIOS (NFT)", 18)
	nfts_tab.pressed.connect(func(): current_tab = "GENIOS"; _refresh_store())
	tabs.add_child(nfts_tab)
	var shop_scroll = ScrollContainer.new()
	shop_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_root.add_child(shop_scroll)
	store_list = VBoxContainer.new()
	store_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	store_list.add_theme_constant_override("separation", 12)
	shop_scroll.add_child(store_list)

	# Pantalla de logros.
	var achievements_overlay = ColorRect.new()
	achievements_overlay.name = "AchievementsOverlay"
	achievements_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievements_overlay.color = Color(0.035, 0.035, 0.09, 0.97)
	achievements_overlay.visible = false
	achievements_overlay.z_index = 11
	game_layer.add_child(achievements_overlay)
	var achievements_root = VBoxContainer.new()
	achievements_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievements_root.offset_left = 42
	achievements_root.offset_top = 32
	achievements_root.offset_right = -42
	achievements_root.offset_bottom = -32
	achievements_root.add_theme_constant_override("separation", 16)
	achievements_overlay.add_child(achievements_root)
	var achievements_header = HBoxContainer.new()
	achievements_root.add_child(achievements_header)
	var achievements_title = Label.new()
	achievements_title.text = "LOGROS"
	achievements_title.add_theme_font_size_override("font_size", 36)
	achievements_title.add_theme_color_override("font_color", Color("#ffe66d"))
	achievements_header.add_child(achievements_title)
	var achievements_spacer = Control.new()
	achievements_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_header.add_child(achievements_spacer)
	var back_from_achievements = _make_button("VOLVER AL JUEGO", 20)
	back_from_achievements.pressed.connect(_show_gameplay)
	achievements_header.add_child(back_from_achievements)
	var achievements_scroll = ScrollContainer.new()
	achievements_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	achievements_root.add_child(achievements_scroll)
	var achievements_list = VBoxContainer.new()
	achievements_list.name = "AchievementsList"
	achievements_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievements_list.add_theme_constant_override("separation", 12)
	achievements_scroll.add_child(achievements_list)

	achievement_popup = PanelContainer.new()
	achievement_popup.visible = false
	achievement_popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	achievement_popup.position = Vector2(-190, 100)
	achievement_popup.custom_minimum_size = Vector2(380, 125)
	achievement_popup.z_index = 30
	game_layer.add_child(achievement_popup)

	_update_equipped_nft()
	_refresh_store()
	_refresh_achievements_view()
	_update_counter()

func _make_button(text_value: String, font_size: int = 18) -> Button:
	var button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(120, 42)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#5741a5")
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	button.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color("#7963d4")
	button.add_theme_stylebox_override("hover", hover)
	return button

func _show_menu() -> void:
	menu_layer.visible = true
	game_layer.visible = false
	if video_player.stream:
		video_player.play()

func _start_game() -> void:
	game_started = true
	menu_layer.visible = false
	game_layer.visible = true
	if video_player:
		video_player.stop()
	_show_gameplay()

func _show_gameplay() -> void:
	if not is_instance_valid(game_layer):
		return
	game_layer.get_node("ShopOverlay").visible = false
	game_layer.get_node("AchievementsOverlay").visible = false
	click_button.visible = true
	if is_instance_valid(owned_tung_button):
		owned_tung_button.visible = tung_count > 0
	if is_instance_valid(points_label):
		points_label.get_parent().visible = true
	if is_instance_valid(status_label):
		status_label.visible = true

func _show_shop() -> void:
	if not game_started:
		return
	click_button.visible = false
	owned_tung_button.visible = false
	points_label.get_parent().visible = false
	status_label.visible = false
	game_layer.get_node("ShopOverlay").visible = true
	game_layer.get_node("AchievementsOverlay").visible = false
	current_tab = "Incrementadores"
	_refresh_store()

func _show_achievements() -> void:
	if not game_started:
		return
	click_button.visible = false
	owned_tung_button.visible = false
	points_label.get_parent().visible = false
	status_label.visible = false
	game_layer.get_node("ShopOverlay").visible = false
	game_layer.get_node("AchievementsOverlay").visible = true
	_refresh_achievements_view()

func _refresh_achievements_view() -> void:
	if not is_instance_valid(game_layer):
		return
	var list = game_layer.find_child("AchievementsList", true, false)
	if list == null:
		return
	for child in list.get_children():
		child.queue_free()
	for item in achievements:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		list.add_child(row)
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(92, 92)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = load(ACH_DIR + str(item.get("image", str(item.id) + "-logro " + str(item.points) + ".jpg")))
		if icon.texture == null and int(item.id) == 7:
			icon.texture = load(ACH_DIR + "6-logro 1000000.jpg")
		icon.modulate = Color.WHITE if achievements_unlocked.has(int(item.id)) else Color(0.28, 0.28, 0.32, 1.0)
		row.add_child(icon)
		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var title = Label.new()
		title.text = "Logro " + str(item.id)
		title.add_theme_font_size_override("font_size", 20)
		info.add_child(title)
		var desc = Label.new()
		desc.text = str(item.get("description", "Completa el objetivo de este logro."))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(desc)
		var state = Label.new()
		state.text = "¡DESBLOQUEADO!" if achievements_unlocked.has(int(item.id)) else "Bloqueado"
		info.add_child(state)

func _on_genio_click() -> void:
	if not game_started:
		return
	taps += 1
	var earned = 1 + tung_count
	if taps % 3 == 0 and tnt_count > 0:
		earned += 4 * tnt_count
		_show_explosion()
		_play(tnt_player)
	points += earned * multiplier
	if selected_nft_id == 16:
		selected_genio_points += earned * multiplier
	_check_achievements()
	_play(genio_player)
	_update_counter()

func _show_explosion() -> void:
	var explosion = TextureRect.new()
	explosion.texture = explosion_texture
	explosion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	explosion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	explosion.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	explosion.custom_minimum_size = Vector2(220, 220)
	explosion.z_index = 10
	game_layer.add_child(explosion)
	var tween = create_tween()
	tween.tween_property(explosion, "scale", Vector2(1.8, 1.8), 0.35)
	tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.45)
	tween.tween_callback(explosion.queue_free)

func _refresh_store() -> void:
	if not is_instance_valid(store_list):
		return
	for child in store_list.get_children():
		child.queue_free()
	if current_tab == "Incrementadores":
		for item in upgrades:
			var owned = _upgrade_owned(item.kind)
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			store_list.add_child(row)
			var icon = TextureRect.new()
			icon.custom_minimum_size = Vector2(70, 70)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			if item.kind == "tung":
				icon.texture = tungs_texture
			elif item.kind == "tnt":
				icon.texture = tnt_texture
			else:
				icon.texture = load(UPGRADE_DIR + "3-multiplicadorpodos.webp")
			row.add_child(icon)
			var info = VBoxContainer.new()
			info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(info)
			var title = Label.new()
			title.text = str(item.name) + "  x" + str(owned)
			info.add_child(title)
			var desc = Label.new()
			desc.text = str(item.description)
			desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info.add_child(desc)
			var buy = _make_button("Comprar\n" + str(item.price), 13)
			buy.custom_minimum_size = Vector2(90, 55)
			buy.disabled = points < int(item.price)
			buy.pressed.connect(func(): _buy_upgrade(item))
			row.add_child(buy)
	elif current_tab == "GENIOS":
		for item in nfts:
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			store_list.add_child(row)
			var icon = TextureButton.new()
			icon.custom_minimum_size = Vector2(80, 80)
			icon.size = Vector2(80, 80)
			icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture_normal = load(NFT_DIR + str(item.file))
			icon.pressed.connect(func(): _play(genio_player))
			row.add_child(icon)
			var info = VBoxContainer.new()
			info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(info)
			var title = Label.new()
			title.text = str(item.id) + " - " + str(item.name)
			info.add_child(title)
			var desc = Label.new()
			desc.text = "Desbloqueado" if unlocked.has(int(item.id)) else "Precio: " + str(item.price)
			info.add_child(desc)
			var buy = _make_button("VER /\nCOMPRAR", 12)
			buy.custom_minimum_size = Vector2(90, 55)
			if unlocked.has(int(item.id)):
				buy.text = "EQUIPAR" if int(item.id) != selected_nft_id else "EQUIPADO"
				buy.disabled = int(item.id) == selected_nft_id
			else:
				buy.text = "COMPRAR\n" + str(item.price)
				buy.disabled = points < int(item.price)
			buy.pressed.connect(func(): _on_nft_action(item))
			row.add_child(buy)

func _upgrade_owned(kind: String) -> int:
	if kind == "tung":
		return tung_count
	if kind == "tnt":
		return tnt_count
	return multiplier - 1

func _buy_upgrade(item: Dictionary) -> void:
	var price = int(item.price) * (1 + _upgrade_owned(item.kind))
	if points < price:
		return
	points -= price
	if item.kind == "tung":
		tung_count += 1
		if is_instance_valid(owned_tung_button):
			owned_tung_button.visible = true
	elif item.kind == "tnt":
		tnt_count += 1
	else:
		multiplier *= 2
	_refresh_store()
	_update_counter()

func _on_nft_action(item: Dictionary) -> void:
	var id = int(item.id)
	if unlocked.has(id):
		selected_nft_id = id
		_update_equipped_nft()
		_refresh_store()
		return
	_buy_nft(item)

func _buy_nft(item: Dictionary) -> void:
	var id = int(item.id)
	if unlocked.has(id) or points < int(item.price):
		return
	points -= int(item.price)
	unlocked.append(id)
	selected_nft_id = id
	_update_equipped_nft()
	_play(genio_player)
	_refresh_store()
	_update_counter()

func _update_equipped_nft() -> void:
	for item in nfts:
		if int(item.id) == selected_nft_id:
			var texture = load(NFT_DIR + str(item.file)) as Texture2D
			if texture and is_instance_valid(click_button):
				click_button.texture_normal = texture
				click_button.texture_hover = texture
				click_button.texture_pressed = texture
			if is_instance_valid(equipped_nft_label):
				equipped_nft_label.text = "NFT equipado: " + str(item.name)
			_sync_genio16_audio()
			return

func _sync_genio16_audio() -> void:
	if not is_instance_valid(background_audio_player) or background_audio_player.stream == null:
		return
	if selected_nft_id == 16:
		if not background_audio_player.playing:
			background_audio_player.play()
	else:
		background_audio_player.stop()

func _check_achievements() -> void:
	for item in achievements:
		var id = int(item.id)
		var condition_met = points >= int(item.points)
		if int(item.get("nft_id", 0)) == 16:
			condition_met = selected_genio_points >= int(item.points)
		if condition_met and not achievements_unlocked.has(id):
			achievements_unlocked.append(id)
			_show_achievement(item)

func _show_achievement(item: Dictionary) -> void:
	if achievement_tween and achievement_tween.is_running():
		achievement_tween.kill()
	for child in achievement_popup.get_children():
		child.queue_free()
	achievement_popup.visible = true
	achievement_popup.modulate.a = 0.0
	achievement_popup.scale = Vector2(0.72, 0.72)
	var row = HBoxContainer.new()
	achievement_popup.add_child(row)
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(100, 100)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(ACH_DIR + str(item.get("image", str(item.id) + "-logro " + str(item.points) + ".jpg")))
	if icon.texture == null and int(item.id) == 7:
		icon.texture = load(ACH_DIR + "6-logro 1000000.jpg")
	row.add_child(icon)
	var text_col = VBoxContainer.new()
	row.add_child(text_col)
	var title = Label.new()
	title.text = "¡LOGRO DESBLOQUEADO!"
	title.add_theme_color_override("font_color", Color("#ffe66d"))
	text_col.add_child(title)
	var desc = Label.new()
	desc.text = "Logro " + str(item.id) + "\n" + str(item.get("description", "Completa el objetivo de este logro."))
	text_col.add_child(desc)
	achievement_tween = create_tween()
	achievement_tween.set_parallel(true)
	achievement_tween.tween_property(achievement_popup, "modulate:a", 1.0, 0.22)
	achievement_tween.tween_property(achievement_popup, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	achievement_tween.set_parallel(false)
	achievement_tween.tween_interval(2.4)
	achievement_tween.set_parallel(true)
	achievement_tween.tween_property(achievement_popup, "modulate:a", 0.0, 0.3)
	achievement_tween.tween_property(achievement_popup, "scale", Vector2(0.9, 0.9), 0.3)
	achievement_tween.set_parallel(false)
	achievement_tween.tween_callback(func():
		if is_instance_valid(achievement_popup):
			achievement_popup.visible = false
			achievement_popup.scale = Vector2.ONE
	)
	_play(sound_player)

func _update_counter() -> void:
	if is_instance_valid(points_label):
		points_label.text = "GENIOPUNTOS: " + str(points)
	if is_instance_valid(status_label):
		status_label.text = "Por click: " + str((1 + tung_count) * multiplier) + "  |  TNT cada 3 clicks: +" + str(4 * tnt_count * multiplier) + "  |  Multiplicador: x" + str(multiplier)
	if is_instance_valid(store_list):
		_refresh_store()
