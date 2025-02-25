extends Node3D

var mugic_data = {}
var extra_rotation_degrees = 0

@onready var cube = $Cube
@onready var info_label = $INFO
@onready var osc_server = $OSCServer
@onready var osc_receiver = $OSCReceiver

func _ready():
	# Set up OSC server and receiver
	osc_server.port = 4000  # Use the same port as in the Python script
	osc_receiver.target_server = osc_server
	osc_receiver.osc_address = "/mugicdata"

	# Connect the message_received signal
	osc_server.connect("message_received", Callable(self, "_on_osc_message"))

	# Set up cube materials
	#setup_cube_materials()

func setup_cube_materials():
	var materials = [
		create_material(Color(0, 1, 0)),
		create_material(Color(1, 0.5, 0)),
		create_material(Color(1, 0, 0)),
		create_material(Color(1, 1, 0)),
		create_material(Color(0, 0, 1)),
		create_material(Color(1, 0, 1))
	]

	for i in range(6):
		cube.set_surface_override_material(i, materials[i])

func create_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material

func _on_osc_message(address, value, time):
	if address == "/mugicdata":
		parse_mugic_data(value)
		print("mugic data adress")

func parse_mugic_data(data):
	mugic_data = {
		"AX": data[0], "AY": data[1], "AZ": data[2],
		"EX": data[3], "EY": data[4], "EZ": data[5],
		"GX": data[6], "GY": data[7], "GZ": data[8],
		"MX": data[9], "MY": data[10], "MZ": data[11],
		"QW": data[12], "QX": data[13], "QY": data[14], "QZ": data[15],
		"Battery": data[16], "mV": data[17],
		"calib_sys": data[18], "calib_gyro": data[19],
		"calib_accel": data[20], "calib_mag": data[21],
		"seconds": data[22], "seqnum": data[23]
	}

func _process(delta):
	if not mugic_data.is_empty():
		update_cube_transform()
		update_info_label()

func update_cube_transform():
	for key in mugic_data:
		var value = mugic_data[key]
		print("Stat: %s, Value: %s" % [key, value])
	var quat = Quaternion(mugic_data.QX, mugic_data.QY, mugic_data.QZ, mugic_data.QW)
	cube.transform.basis = Basis(quat)
	cube.rotate_y(deg_to_rad(extra_rotation_degrees))
	cube.transform.origin = Vector3(-mugic_data.AX / 50.0, mugic_data.AZ / 50.0, mugic_data.AY / 50.0)

func update_info_label():
	var euler = cube.transform.basis.get_euler()
	info_label.text = (
		"PyMugic (%d%%, %dmV)\n" % [mugic_data.Battery, mugic_data.mV] +
		"Calibration: %d, %d, %d, %d\n" % [
			mugic_data.calib_sys,
			mugic_data.calib_gyro,
			mugic_data.calib_accel,
			mugic_data.calib_mag
		] +
		"Yaw: %.2f, Pitch: %.2f, Roll: %.2f" % [
			rad_to_deg(euler.y),
			rad_to_deg(euler.x),
			rad_to_deg(euler.z)
		]
	)

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.pressed and event.keycode == KEY_A:
			extra_rotation_degrees = (extra_rotation_degrees - 1) % 360
		elif event.pressed and event.keycode == KEY_S:
			extra_rotation_degrees = (extra_rotation_degrees + 1) % 360
