local Disc = {extends = Node3D, class_name = "Disc"}
Disc.flip = function(self)
  return self:rotate_x(deg_to_rad(180))
end
Disc._ready = function(self)
end
return Disc
