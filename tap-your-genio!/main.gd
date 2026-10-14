extends Control

const ROOT = "res://recursos, GENIOS/"
const NFT_DIR = ROOT + "Nfts/"
const UPGRADE_DIR = ROOT + "incrementos-efectos/"
const ACH_DIR = ROOT + "logros/"
const SFX_DIR = ROOT + "sonidos/"
const INTRO_VIDEO = "res://inicio/Pollo caminando con Mecha Mecha de fondo.mp4"

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
var click_button: TextureButton
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
	{"id": 15, "name": "Genius", "price": 100000, "file": "15-genius.jpg"}
]
var achievements := [
	{"id": 1, "points": 10, "name": "Primeros 10"},
	{"id": 2, "points": 100, "name": "Centenario"},
	{"id": 3, "points": 1000, "name": "Mil puntos"},
	{"id": 4, "points": 10000, "name": "Diez mil"}
]

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
	for player in [sound_player, genio_player, tungs_player, tnt_player]:
		add_child(player)
	genio_player.stream = load(SFX_DIR + "Genio.mp3")
	tungs_player.stream = load(SFX_DIR + "audioparagolpedetungsahur.mp3")
	tnt_player.stream = load(SFX_DIR + "explosion de la tnt.mp3")
	sound_player.stream = load(SFX_DIR + "Genio.mp3")

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
	quit.pressed.connect(func(): _play(sound_player); get_tree().quit())
	panel.add_child(quit)

func _build_game() -> void:
	game_layer = Control.new()
	game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_layer)
	var background = ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#111323")
	game_layer.add_child(background)
	var root = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	root.add_theme_constant_override("margin_left", 18)
	root.add_theme_constant_override("margin_right", 18)
	root.add_theme_constant_override("margin_top", 14)
	root.add_theme_constant_override("margin_bottom", 14)
	game_layer.add_child(root)
	var top = HBoxContainer.new()
	root.add_child(top)
	var heading = Label.new()
	heading.text = "TAP YOUR GENIO!"
	heading.add_theme_font_size_override("font_size", 28)
	heading.add_theme_color_override("font_color", Color("#ffe66d"))
	top.add_child(heading)
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	var back = _make_button("MENÚ", 16)
	back.pressed.connect(_show_menu)
	top.add_child(back)
	points_label = Label.new()
	points_label.text = "GENIOPUNTOS: 0"
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points_label.add_theme_font_size_override("font_size", 30)
	points_label.add_theme_color_override("font_color", Color("#ffffff"))
	root.add_child(points_label)
	status_label = Label.new()
	status_label.text = "Por click: 1  |  Multiplicador: x1"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status_label)
	main_area = HBoxContainer.new()
	main_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_area.add_theme_constant_override("separation", 16)
	root.add_child(main_area)
	# Character on the left
	var character_panel = PanelContainer.new()
	character_panel.custom_minimum_size = Vector2(210, 0)
	main_area.add_child(character_panel)
	var character_col = VBoxContainer.new()
	character_col.alignment = BoxContainer.ALIGNMENT_CENTER
	character_col.add_theme_constant_override("separation", 12)
	character_panel.add_child(character_col)
	var char_title = Label.new()
	char_title.text = "¡TOCÁ AL GENIO!"
	char_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_col.add_child(char_title)
	click_button = TextureButton.new()
	click_button.texture_normal = tungs_texture
	click_button.texture_hover = tungs_texture
	click_button.texture_pressed = tungs_texture
	click_button.custom_minimum_size = Vector2(170, 170)
	click_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	click_button.pressed.connect(_on_genio_click)
	character_col.add_child(click_button)
	var char_help = Label.new()
	char_help.text = "Tungtungsahur
está a tu izquierda"
	char_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_col.add_child(char_help)
	# Store in the middle
	var shop_panel = PanelContainer.new()
	shop_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_panel.custom_minimum_size = Vector2(360, 0)
	main_area.add_child(shop_panel)
	var shop_col = VBoxContainer.new()
	shop_col.add_theme_constant_override("separation", 8)
	shop_panel.add_child(shop_col)
	var shop_title = Label.new()
	shop_title.text = "TIENDA"
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_title.add_theme_font_size_override("font_size", 24)
	shop_col.add_child(shop_title)
	var tabs = HBoxContainer.new()
	shop_col.add_child(tabs)
	var upgrades_tab = _make_button("INCREMENTADORES", 14)
	upgrades_tab.pressed.connect(func(): current_tab = "Incrementadores"; _refresh_store())
	tabs.add_child(upgrades_tab)
	var nfts_tab = _make_button("GENIOS (NFT)", 14)
	nfts_tab.pressed.connect(func(): current_tab = "GENIOS"; _refresh_store())
	tabs.add_child(nfts_tab)
	var achievements_tab = _make_button("LOGROS", 14)
	achievements_tab.pressed.connect(func(): current_tab = "LOGROS"; _refresh_store())
	tabs.add_child(achievements_tab)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_col.add_child(scroll)
	store_list = VBoxContainer.new()
	store_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	store_list.add_theme_constant_override("separation", 8)
	scroll.add_child(store_list)
	achievement_popup = PanelContainer.new()
	achievement_popup.visible = false
	achievement_popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	achievement_popup.position = Vector2(-190, 65)
	achievement_popup.custom_minimum_size = Vector2(380, 125)
	achievement_popup.z_index = 20
	game_layer.add_child(achievement_popup)
	_refresh_store()
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
	_play(sound_player)
	game_started = true
	menu_layer.visible = false
	game_layer.visible = true
	video_player.stop()
	_refresh_store()

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
	_play(genio_player)
	_check_achievements()
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
			var icon = TextureRect.new()
			icon.custom_minimum_size = Vector2(64, 64)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture = load(NFT_DIR + str(item.file))
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
			buy.disabled = unlocked.has(int(item.id)) or points < int(item.price)
			buy.pressed.connect(func(): _buy_nft(item))
			row.add_child(buy)
	elif current_tab == "LOGROS":
		for item in achievements:
			var row = HBoxContainer.new()
			store_list.add_child(row)
			var icon = TextureRect.new()
			icon.custom_minimum_size = Vector2(78, 78)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.texture = load(ACH_DIR + str(item.id) + "-logro " + str(item.points) + ".jpg")
			row.add_child(icon)
			var info = VBoxContainer.new()
			info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(info)
			var title = Label.new()
			title.text = str(item.name) + " (" + str(item.points) + ")"
			info.add_child(title)
			var state = Label.new()
			state.text = "¡DESBLOQUEADO!" if achievements_unlocked.has(int(item.id)) else "Bloqueado"
			info.add_child(state)
			if achievements_unlocked.has(int(item.id)):
				icon.modulate = Color.WHITE
			else:
				icon.modulate = Color(0.28, 0.28, 0.32, 1.0)

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
	elif item.kind == "tnt":
		tnt_count += 1
	else:
		multiplier *= 2
	_refresh_store()
	_update_counter()

func _buy_nft(item: Dictionary) -> void:
	var id = int(item.id)
	if unlocked.has(id) or points < int(item.price):
		return
	points -= int(item.price)
	unlocked.append(id)
	_play(genio_player)
	_refresh_store()
	_update_counter()

func _check_achievements() -> void:
	for item in achievements:
		var id = int(item.id)
		if points >= int(item.points) and not achievements_unlocked.has(id):
			achievements_unlocked.append(id)
			_show_achievement(item)

func _show_achievement(item: Dictionary) -> void:
	for child in achievement_popup.get_children():
		child.queue_free()
	achievement_popup.visible = true
	var row = HBoxContainer.new()
	achievement_popup.add_child(row)
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(100, 100)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(ACH_DIR + str(item.id) + "-logro " + str(item.points) + ".jpg")
	row.add_child(icon)
	var text_col = VBoxContainer.new()
	row.add_child(text_col)
	var title = Label.new()
	title.text = "¡LOGRO DESBLOQUEADO!"
	title.add_theme_color_override("font_color", Color("#ffe66d"))
	text_col.add_child(title)
	var desc = Label.new()
	desc.text = str(item.name) + "\n" + str(item.points) + " puntos"
	text_col.add_child(desc)
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		if is_instance_valid(achievement_popup):
			achievement_popup.visible = false
	)
	_play(sound_player)

func _update_counter() -> void:
	if is_instance_valid(points_label):
		points_label.text = "GENIOPUNTOS: " + str(points)
	if is_instance_valid(status_label):
		status_label.text = "Por click: " + str((1 + tung_count) * multiplier) + "  |  TNT cada 3 clicks: +" + str(4 * tnt_count * multiplier) + "  |  Multiplicador: x" + str(multiplier)
	if is_instance_valid(store_list):
		_refresh_store()
