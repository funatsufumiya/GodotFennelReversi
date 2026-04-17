extends Node
class_name Preloaded
var disc_prefab = preload("res://prefabs/disc.tscn")

static var _singleton: Preloaded = null # メンバ変数はこのクラスに集約する

static func singleton() -> Preloaded:
	if _singleton == null:
		_singleton = Preloaded.new()
	return _singleton
