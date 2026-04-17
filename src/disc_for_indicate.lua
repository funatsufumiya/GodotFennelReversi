local DiscForIndicate = {extends = Node3D, class_name = "DiscForIndicate"}
DiscForIndicate.flip = function(self)
  self.flipped = not self.flipped
  return self:rotate_x(deg_to_rad(180))
end
DiscForIndicate._ready = function(self)
  self.placed = false
  self.flipped = false
  return nil
end
DiscForIndicate._process = function(self, delta)
  if not self.placed then
    self.placed = true
    return nil
  else
    return nil
  end
end
DiscForIndicate.is_black = function(self)
  return not self.flipped
end
DiscForIndicate.is_white = function(self)
  return not not self.flipped
end
DiscForIndicate.is_placed = function(self)
  return not not self.placed
end
return DiscForIndicate
