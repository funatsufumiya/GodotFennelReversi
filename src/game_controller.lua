local GameController = {extends = Node, class_name = "GameController"}
local N = 8
local states = {}
local discs = {}
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
	s = (s .. " " .. self:get_state_str(i, x))
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
  local x = disc:get_x()
  local y = disc:get_y()
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
  self.camera = Finder:find_child_by_name(self.root, "Camera3D")
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
  self:print_states()
  self.cur_turn_state = false
  return nil
end
GameController._process = function(self, delta)
  if self.is_dirty then
	self.is_dirty = false
  else
  end
  if Input:is_action_just_pressed("DoDebug") then
	print(self:get_timestamp())
	self:print_states()
  else
  end
  if Input:is_action_just_pressed("Exit") then
	local tree = self:get_tree()
	return tree:quit()
  else
	return nil
  end
end
local function to_array(arr)
  return Array(arr)
end
GameController.get_timestamp = function(self)
  local now = Time:get_datetime_dict_from_system()
  return Utils:format("%04d-%02d-%02d %02d:%02d:%02d", to_array({now.year, now.month, now.day, now.hour, now.minute, now.second}))
end
GameController.get_raycast_result = function(self)
  local root = self.root
  local w3d = root:get_world_3d()
  local space_state = w3d.direct_space_state
  local viewport = self:get_viewport()
  local mousepos = viewport:get_mouse_position()
  local cam = self.camera
  local origin = cam:project_ray_origin(mousepos)
  local ray_end = (origin + (cam:project_ray_normal(mousepos) * 1000))
  local query = PhysicsRayQueryParameters3D:create(origin, ray_end)
  local _
  query.collide_with_areas = true
  _ = nil
  local result = space_state:intersect_ray(query)
  return result
end
GameController.flip_discs = function(self, x, y, state)
  return print("flip discs not implemented yet: ", x, y, state)
end
GameController.judge_next_touch = function(self, position)
  local x = position.x
  local y = position.z
  local px = ((x - self.x0) / self.width)
  local py = ((y - self.y0) / self.height)
  local nx = (floor((px * N)) + 1)
  local ny = (floor((py * N)) + 1)
  local already_exist = not (self:get_state(nx, ny) == nil)
  if not already_exist then
	if self.cur_turn_state then
	  self:newDiscFlippedAt(nx, ny)
	else
	  self:newDiscAt(nx, ny)
	end
	self:flip_discs(nx, ny, self.cur_turn_state)
	self.cur_turn_state = not self.cur_turn_state
	return nil
  else
	return nil
  end
end
GameController.try_raycast = function(self)
  local result = self:get_raycast_result()
  if not not result then
	if (result.collider.name == "BoardArea") then
	  return self:judge_next_touch(result.position)
	else
	  return nil
	end
  else
	return nil
  end
end
GameController._input = function(self, event)
  local and_10_ = (nil ~= event)
  if and_10_ then
	local e = event
	and_10_ = Variant.is(e, InputEventMouseButton)
  end
  if and_10_ then
	local e = event
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
