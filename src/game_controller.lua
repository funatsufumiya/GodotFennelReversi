local GameController = {extends = Node, class_name = "GameController"}
local N = 8
local states = {}
local discs = {}
local cur_turn_state = false
GameController.get_state = function(self, x, y)
  return states[(x + (y * N))]
end
GameController.set_state = function(self, x, y, b)
  states[(x + (y * N))] = b
  return nil
end
GameController.get_disc = function(self, x, y)
  return discs[(x + (y * N))]
end
GameController.set_disc = function(self, x, y, disc)
  discs[(x + (y * N))] = disc
  return nil
end
GameController.get_state_str = function(self, x, y)
  local st = self:get_state(x, y)
  if (st == nil) then
	return "."
  elseif (st == true) then
	return "x"
  elseif (st == false) then
	return "o"
  else
	return nil
  end
end
GameController.init_states = function(self)
  for i = 1, (N * N) do
	table.insert(states, nil)
  end
  return nil
end
GameController.init_discs = function(self)
  for i = 1, (N * N) do
	table.insert(states, nil)
  end
  return nil
end
GameController.get_state_raw = function(self, x)
  local s = ""
  for i = 1, N do
	s = (s .. " " .. self:get_state_str(x, i))
  end
  return s
end
GameController.print_states = function(self)
  for i = 1, N do
	print(self:get_state_raw(i))
  end
  return nil
end
GameController.get_width = function(self)
  return (self.right_bottom_pos.x - self.left_top_pos.x)
end
GameController.get_height = function(self)
  return (self.right_bottom_pos.z - self.left_top_pos.z)
end
GameController.get_pos_x = function(self, x)
  return (self.x0 + ((x - 0.5) * self.dw))
end
GameController.get_pos_y = function(self, y)
  return (self.y0 + ((y - 0.5) * self.dh))
end
GameController.get_global_position = function(self, disc)
  if not disc:is_placed() then
	return Vector3(0, 0, 0)
  else
	return disc.global_position
  end
end
GameController.move = function(self, disc, x, y)
  local nx = self:get_pos_x(x)
  local ny = self:get_pos_y(y)
  local gp = self:get_global_position(disc)
  gp.x = nx
  gp.z = ny
  disc.global_position = gp
  return nil
end
GameController.move_deferred = function(self, disc, x, y)
  local nx = self:get_pos_x(x)
  local ny = self:get_pos_y(y)
  local gp = self:get_global_position(disc)
  gp.x = nx
  gp.z = ny
  return Utils:set_global_position_deferred(disc, gp)
end
GameController.newDiscAt = function(self, x, y)
  local disc = self:newDisc()
  self:move_deferred(disc, x, y)
  disc:set_x(x)
  disc:set_y(y)
  self:set_state(x, y, true)
  self:set_disc(x, y, disc)
  return disc
end
GameController.newDiscFlippedAt = function(self, x, y)
  local disc = self:newDisc()
  self:move_deferred(disc, x, y)
  disc:set_x(x)
  disc:set_y(y)
  disc:flip()
  self:set_state(x, y, false)
  self:set_disc(x, y, disc)
  return disc
end
GameController.flipDisc = function(self, disc)
  disc:flip()
  return self:set_state(x, y, not self:get_state(x, y))
end
GameController.flipDiscAt = function(self, x, y)
  local disc = self:get_disc(x, y)
  disc:flip()
  return self:set_state(x, y, not self:get_state(x, y))
end
GameController.newDisc = function(self)
  local disc = self.disc_prefab:instantiate()
  Utils:add_child_deferred(self.root, disc)
  disc:set_x(nil)
  disc:set_y(nil)
  return disc
end
GameController.clearDiscs = function(self)
  local discs0 = Finder:find_children_by_type(self.root, "Disc")
  for _, disc in pairs(discs0) do
	disc:queue_free()
  end
  return nil
end
GameController.initDiscs = function(self)
  self:newDiscFlippedAt(4, 4)
  self:newDiscFlippedAt(5, 5)
  self:newDiscAt(4, 5)
  return self:newDiscAt(5, 4)
end
GameController._ready = function(self)
  self.is_dirty = true
  self:init_states()
  self:init_discs()
  self.preloaded = Preloaded:singleton()
  self.root = Finder:get_root()
  self.disc_prefab = self.preloaded.disc_prefab
  self.left_top_marker = Finder:find_child_by_name(self.root, "LeftTopMarker")
  self.right_bottom_marker = Finder:find_child_by_name(self.root, "RightBottomMarker")
  self.left_top_pos = self.left_top_marker.global_position
  self.right_bottom_pos = self.right_bottom_marker.global_position
  self.x0 = self.left_top_pos.x
  self.y0 = self.left_top_pos.z
  self.width = self:get_width()
  self.height = self:get_height()
  self.dw = (self.width / N)
  self.dh = (self.height / N)
  self:clearDiscs()
  self:initDiscs()
  return self:print_states()
end
GameController._process = function(self, delta)
  if self.is_dirty then
	self.is_dirty = false
	return nil
  else
	return nil
  end
end
GameController.try_raycast = function(self)
  return print("raycast not implemented yet")
end
GameController._input = function(self, event)
  if Variant.is(event, InputEventMouseButton) then
	if event.pressed then
	  return self:try_raycast()
	else
	  return nil
	end
  else
	return nil
  end
end
return GameController
