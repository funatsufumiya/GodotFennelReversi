extends Node
class_name Utils

static func add_child_deferred(parent, child):
	parent.add_child.call_deferred(child)

# static func flip_disc_deferred(disc):
# 	disc.flip.call_deferred()

static func set_global_position_deferred(parent, gp):
	parent.set_deferred("global_position", gp)

static func update_gx(parent, x):
	var g = parent.global_position
	g.x = x
	parent.global_position = g

static func update_gy(parent, y):
	var g = parent.global_position
	g.y = y
	parent.global_position = g

static func update_gz(parent, z):
	var g = parent.global_position
	g.z = z
	parent.global_position = g
