extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var rigid_body : RigidBody3D


func _physics_process(delta):
	pass
	#self.set_global_position(rigid_body.global_position)
