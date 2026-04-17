local Disc = {extends = Node3D, class_name = "Disc"}
Disc.flip = function(self)
  self.flipped = not self.flipped
  return self:rotate_x(deg_to_rad(180))
end
Disc._ready = function(self)
  self.placed = false
  self.flipped = false
  return nil
end
Disc._process = function(self, delta)
  if not self.placed then
	self.placed = true
	return nil
  else
	return nil
  end
end
Disc.is_black = function(self)
  return not self.flipped
end
Disc.is_white = function(self)
  return not not self.flipped
end
Disc.is_placed = function(self)
  return not not self.placed
end
Disc.set_x = function(self, x)
  self.x = x
  return nil
end
Disc.set_y = function(self, y)
  self.y = y
  return nil
end
Disc.get_x = function(self)
  return self.x
end
Disc.get_y = function(self)
  return self.y
end
return Disc
