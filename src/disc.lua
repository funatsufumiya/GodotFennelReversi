local Disc = {extends = Node3D, class_name = "Disc"}
local init_offset_y = 0.1
local init_anim_duration = 0.3
local need_rotate = false
Disc.flip = function(self)
  self.flipped = not self.flipped
  self.need_rotate = true
  return nil
end
Disc.set_game_controller = function(self, gc)
  self.game_controller = gc
  return nil
end
Disc.on_init = function(self)
  self.offset_node = Finder:find_child_by_name(self, "Offset")
  self.rot_node = Finder:find_child_by_name(self, "Rot")
  if self:need_animation() then
	return Utils:update_y(self, init_offset_y)
  else
	return nil
  end
end
Disc._ready = function(self)
  self.placed = false
  self.flipped = false
  self.elapsed = 0
  return nil
end
Disc._process = function(self, delta)
  if self.placed then
	if self.need_rotate then
	  if not (self.rot_node == nil) then
		self.rot_node:rotate_x(deg_to_rad(180))
		self.need_rotate = false
	  else
	  end
	else
	end
	if (self.elapsed < init_anim_duration) then
	  if self:need_animation() then
		local r = (self.elapsed / init_anim_duration)
		local p = ((1 - r) * init_offset_y)
		Utils:update_y(self, p)
	  else
		Utils:update_y(self, 0)
	  end
	else
	end
  else
  end
  if not self.placed then
	self.placed = true
	self:on_init()
  else
  end
  self.elapsed = (self.elapsed + delta)
  return nil
end
Disc.need_animation = function(self)
  return not not self.game_controller.b_animation
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
