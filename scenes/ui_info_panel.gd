## ui_info_panel.gd
## Compatibility wrapper for refactored InformationPanelController
## This maintains backward compatibility for existing scene files

class_name StructureInfoPanel
extends Control

# Use the refactored InformationPanelController
const InformationPanelController = preload("res://scripts/ui/InformationPanelController.gd")

# Delegate to the refactored controller
var controller: InformationPanelController

# Signals for compatibility
signal panel_closed

func _ready():
	"""Initialize the compatibility wrapper"""
	print("[UI_INFO_PANEL] Initializing compatibility wrapper...")
	
	# Create the actual controller
	controller = InformationPanelController.new()
	if controller:
		add_child(controller)
		
		# Connect signals if they exist
		if controller.has_signal("panel_closed"):
			controller.panel_closed.connect(_on_panel_closed)
		
		print("[UI_INFO_PANEL] Controller initialized successfully")
	else:
		push_error("[UI_INFO_PANEL] Failed to create InformationPanelController")

func display_structure_data(structure_data: Dictionary):
	"""Display structure data using the controller"""
	if controller and controller.has_method("display_structure_data"):
		controller.display_structure_data(structure_data)
	else:
		print("[UI_INFO_PANEL] Controller not available for display_structure_data")

func hide_panel():
	"""Hide the panel"""
	if controller and controller.has_method("hide_panel"):
		controller.hide_panel()
	else:
		visible = false

func show_panel():
	"""Show the panel"""
	if controller and controller.has_method("show_panel"):
		controller.show_panel()
	else:
		visible = true

func dispose():
	"""Clean up resources"""
	if controller and controller.has_method("dispose"):
		controller.dispose()

func _on_panel_closed():
	"""Handle panel closed signal"""
	emit_signal("panel_closed")

# Note: Removed has_method() and call() overrides to avoid conflicts with Object base class
# The controller handles method routing internally