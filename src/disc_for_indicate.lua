local DiscForIndicate = {extends = Node3D, class_name = "DiscForIndicate"}
local init_offset_y = 0.1
local flip_offset_y = 0.2
local init_anim_duration = 0.3
local flip_anim_duration = 0.3
local pi = 3.141592
local two_pi = (2.0 * 3.141592)
DiscForIndicate.flip = function(self)
  self.flipped = not self.flipped
  if self:need_animation() then
	self.flip_anim_elapsed = 0
	self.flip_anim_started = true
	return nil
  else
	return nil
  end
end
DiscForIndicate.on_init = function(self)
  self.offset_node = Finder:find_child_by_name(self, "Offset")
  self.rot_node = Finder:find_child_by_name(self, "Rot")
  if self:need_animation() then
	return Utils:update_y(self, init_offset_y)
  else
	return nil
  end
end
DiscForIndicate._ready = function(self)
  self.placed = false
  if (self.flipped == nil) then
	self.flipped = false
  else
  end
  self.elapsed = 0
  self.flip_anim_delay = 0
  self.flip_anim_elapsed = nil
  self.flip_anim_started = false
  return nil
end
DiscForIndicate.update_flip_anim = function(self, delta)
  if not (self.flip_anim_elapsed == nil) then
	local r = (self.flip_anim_elapsed / flip_anim_duration)
	local angle_offset
	if self.flipped then
	  angle_offset = 0
	else
	  angle_offset = pi
	end
	local angle = ((r * pi) + angle_offset)
	local h = (flip_offset_y * sin((2 * angle)))
	Utils:update_y(self, h)
	Utils:set_rotated_x(self.rot_node, angle)
  else
  end
  if not (self.flip_anim_elapsed == nil) then
	self.flip_anim_elapsed = (self.flip_anim_elapsed + delta)
	if (self.flip_anim_elapsed >= flip_anim_duration) then
	  self.flip_anim_elapsed = nil
	  self.flip_anim_started = false
	  Utils:update_y(self, 0)
	  if self.flipped then
		return Utils:set_rotated_x(self.rot_node, pi)
	  else
		return Utils:set_rotated_x(self.rot_node, 0)
	  end
	else
	  return nil
	end
  else
	return nil
  end
end
DiscForIndicate._process = function(self, delta)
  if self.placed then
	if not (self:need_animation() and self.flip_anim_started) then
	  if self.flipped then
		Utils:set_rotated_x(self.rot_node, deg_to_rad(180))
	  else
		Utils:set_rotated_x(self.rot_node, 0)
	  end
	else
	end
	if not self:need_animation() then
	  self.flip_anim_started = false
	  self.flip_anim_elapsed = nil
	  Utils:update_y(self, 0)
	else
	end
	if (self:need_animation() and self.flip_anim_started) then
	  self:update_flip_anim(delta)
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
DiscForIndicate.is_black = function(self)
  return not self.flipped
end
DiscForIndicate.is_white = function(self)
  return not not self.flipped
end
DiscForIndicate.is_placed = function(self)
  return not not self.placed
end
DiscForIndicate.set_game_controller = function(self, gc)
  self.game_controller = gc
  return nil
end
DiscForIndicate.need_animation = function(self)
  return false
end
return DiscForIndicate
