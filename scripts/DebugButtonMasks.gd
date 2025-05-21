class_name DebugButtonMasks
extends Node

# This script helps debug mouse and trackpad button issues

static func print_button_mask(mask: int) -> void:
	print("===== BUTTON MASK DEBUG =====")
	print("Mask value: ", mask)
	print("LEFT (1): ", bool(mask & MouseButton.LEFT))
	print("RIGHT (2): ", bool(mask & MouseButton.RIGHT))
	print("MIDDLE (3): ", bool(mask & MouseButton.MIDDLE))
	print("===== END MASK DEBUG =====")