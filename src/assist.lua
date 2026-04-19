local Assist = {extends = Node3D, class_name = "Assist"}
Assist._ready = function(self)
  self.placed = false
  return nil
end
Assist._process = function(self, delta)
  if not self.placed then
	self.placed = true
	return nil
  else
	return nil
  end
end
Assist.is_placed = function(self)
  return not not self.placed
end
return Assist
