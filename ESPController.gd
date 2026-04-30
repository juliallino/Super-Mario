extends Node
class_name SerialPort

var serial
var data

const DEADZONE_MIN = 1500
const DEADZONE_MAX = 2500

@export var port_name := "COM5"
@export var baud_rate := 115200

func _ready():
	serial = SerialPort.new()
	var err = serial.open(port_name, baud_rate)
	
	if err != OK:
		print ("Erro ao abrir porta:", err)
	else:
		print("Serial conectada")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if serial and serial.get_available_bytes() > 0:
		var data = serial.get_line()
		parse_input(data)
		
func parse_input(date: String):
	var parts = data.strip_edges().split(",")
	if parts.size() < 4:
		return
	var x = int(parts[0])
	var y = int(parts[1])
	var jump = int(parts[2])
	var shoot = int(parts[3])
	
	# Direcao
	if x < DEADZONE_MIN:
		Input.action_press("left")
	else:
		Input.action_release("left")
	if x > DEADZONE_MAX:
		Input.action_press("right")
	else:
		Input.action_release("right")
	
	# Pulo
	if jump == 0:
		Input.action_press("jump")
	else:
		Input.action_release("jump")
		
	#Tiro
	if shoot == 0:
		Input.action_press("shoot")
	else:
		Input.action_release("shoot")
	
