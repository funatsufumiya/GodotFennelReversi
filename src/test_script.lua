local TestScript = {
	extends = Node,
}

-- Called when the node enters the scene tree for the first time.
function TestScript:_ready()
	print("hello from lua!")
end

return TestScript
