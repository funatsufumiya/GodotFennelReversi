local GameController = {extends = Node, class_name = "GameController"}
local N = 8
local states = {}
local discs = {}
GameController.get_turn_name = function(self)
  if (self.cur_turn_state == true) then
	return "black"
  else
	return "white"
  end
end
GameController.get_state = function(self, x, y)
  if self:is_in_range(x, y) then
	return states[(x + (y * N))]
  else
	return nil
  end
end
GameController.set_state = function(self, x, y, b)
  states[(x + (y * N))] = b
  return nil
end
GameController.get_disc = function(self, x, y)
  if self:is_in_range(x, y) then
	return discs[(x + (y * N))]
  else
	return nil
  end
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
	return "o"
  elseif (st == false) then
	return "x"
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
GameController.flipDisc = function(self, disc, opt)
  disc:flip(opt)
  local x = disc:get_x()
  local y = disc:get_y()
  return self:set_state(x, y, not self:get_state(x, y))
end
GameController.flipDiscAt = function(self, x, y, opt)
  local disc = self:get_disc(x, y)
  disc:flip(opt)
  return self:set_state(x, y, not self:get_state(x, y))
end
GameController.newDisc = function(self)
  local disc = self.disc_prefab:instantiate()
  Utils:add_child_deferred(self.root, disc)
  disc:set_game_controller(self)
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
GameController.restart = function(self)
  return print("restart not implemented yet")
end
GameController._ready = function(self)
  self.is_dirty = true
  self:init_states()
  self:init_discs()
  self.preloaded = Preloaded:singleton()
  self.root = Finder:get_root()
  self.disc_prefab = self.preloaded.disc_prefab
  self.disc_for_indicate = Finder:find_child_by_name(self.root, "DiscForIndicate")
  self.disc_for_indicate:set_game_controller(self)
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
  self.finished = false
  self.show_assist = false
  self.b_animation = true
  self:clearDiscs()
  self:initDiscs()
  self.cur_turn_state = true
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
  if Input:is_action_just_pressed("ToggleAssist") then
	self.show_assist = not self.show_assist
	print("assist", self.show_assist)
  else
  end
  if Input:is_action_just_pressed("ToggleAnimation") then
	self.b_animation = not self.b_animation
	print("animation", self.b_animation)
  else
  end
  if Input:is_action_just_pressed("Restart") then
	self:restart()
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
  if not self:able_judge1(x, y, state) then
	return false
  else
	local s = state
	local n
	local function _12_(e)
	  return not not e
	end
	n = _12_
	local f1
	local function _13_(x0, y0)
	  return {(x0 - 1), y0}
	end
	f1 = _13_
	local f2
	local function _14_(x0, y0)
	  return {x0, (y0 - 1)}
	end
	f2 = _14_
	local f3
	local function _15_(x0, y0)
	  return {(x0 + 1), y0}
	end
	f3 = _15_
	local f4
	local function _16_(x0, y0)
	  return {x0, (y0 + 1)}
	end
	f4 = _16_
	local f5
	local function _17_(x0, y0)
	  return {(x0 - 1), (y0 - 1)}
	end
	f5 = _17_
	local f6
	local function _18_(x0, y0)
	  return {(x0 + 1), (y0 - 1)}
	end
	f6 = _18_
	local f7
	local function _19_(x0, y0)
	  return {(x0 - 1), (y0 + 1)}
	end
	f7 = _19_
	local f8
	local function _20_(x0, y0)
	  return {(x0 + 1), (y0 + 1)}
	end
	f8 = _20_
	local c1 = self:check_and_flip_accum_states(x, y, s, f1)
	local c2 = self:check_and_flip_accum_states(x, y, s, f2)
	local c3 = self:check_and_flip_accum_states(x, y, s, f3)
	local c4 = self:check_and_flip_accum_states(x, y, s, f4)
	local c5 = self:check_and_flip_accum_states(x, y, s, f5)
	local c6 = self:check_and_flip_accum_states(x, y, s, f6)
	local c7 = self:check_and_flip_accum_states(x, y, s, f7)
	local c8 = self:check_and_flip_accum_states(x, y, s, f8)
	return true
  end
end
GameController.is_in_range = function(self, x, y)
  return ((x > 0) and (y > 0) and (x <= N) and (y <= N))
end
GameController.accum_states = function(self, start_x, start_y, start_state, incl_f)
  local result = {start_state}
  local done_3f = false
  local x = start_x
  local y = start_y
  while not done_3f do
	do
	  local v = incl_f(x, y)
	  x = v[1]
	  y = v[2]
	end
	local disc
	if self:is_in_range(x, y) then
	  disc = self:get_state(x, y)
	else
	  disc = nil
	end
	if (not self:is_in_range(x, y) or (disc == nil)) then
	  done_3f = true
	else
	end
	if not done_3f then
	  if (disc == start_state) then
		if (disc == start_state) then
		  table.insert(result, disc)
		else
		end
		done_3f = true
	  else
		table.insert(result, disc)
	  end
	else
	end
  end
  return Array(result)
end
GameController.is_accum_center_all_ok = function(self, accum, start_state)
  local n = accum:size()
  local begin_index = 1
  local end_index = (n - 2)
  local i = begin_index
  local result = nil
  while ((result == nil) and (i <= end_index)) do
	if not (accum[i] == not start_state) then
	  result = false
	else
	end
	i = (i + 1)
  end
  if (result == nil) then
	return true
  else
	return false
  end
end
GameController.check_accum_states = function(self, start_x, start_y, start_state, incl_f)
  local accum = self:accum_states(start_x, start_y, start_state, incl_f)
  local n = accum:size()
  if (n < 3) then
	return false
  else
	local a = accum[0]
	local b = accum[(n - 1)]
	local bridge_ok = (a == b)
	local center_ok = self:is_accum_center_all_ok(accum, start_state)
	return (bridge_ok and center_ok)
  end
end
GameController.apply_flip_on_accum_states = function(self, accum, start_x, start_y, start_state, incl_f)
  local n = accum:size()
  local begin_index = 1
  local end_index = (n - 2)
  local dist = 0
  local i = begin_index
  local x = start_x
  local y = start_y
  local need_stop = false
  while ((need_stop == false) and (i <= end_index)) do
	local v = incl_f(x, y)
	x = v[1]
	y = v[2]
	self:flipDiscAt(x, y, Dictionary({dist = dist}))
	if not (accum[i] == not start_state) then
	  need_stop = true
	else
	end
	i = (i + 1)
	dist = (dist + 1)
  end
  return nil
end
GameController.check_and_flip_accum_states = function(self, start_x, start_y, start_state, incl_f)
  local accum = self:accum_states(start_x, start_y, start_state, incl_f)
  local n = accum:size()
  if (n < 3) then
	return false
  else
	local a = accum[0]
	local b = accum[(n - 1)]
	local bridge_ok = (a == b)
	local center_ok = self:is_accum_center_all_ok(accum, start_state)
	if (bridge_ok and center_ok) then
	  self:apply_flip_on_accum_states(accum, start_x, start_y, start_state, incl_f)
	  return true
	else
	  return false
	end
  end
end
GameController.able_judge1 = function(self, x, y, state)
  local disc1 = self:get_disc((x - 1), y)
  local disc2 = self:get_disc(x, (y - 1))
  local disc3 = self:get_disc((x + 1), y)
  local disc4 = self:get_disc(x, (y + 1))
  local disc5 = self:get_disc((x - 1), (y - 1))
  local disc6 = self:get_disc((x + 1), (y - 1))
  local disc7 = self:get_disc((x - 1), (y + 1))
  local disc8 = self:get_disc((x + 1), (y + 1))
  local n
  local function _33_(e)
	return not not e
  end
  n = _33_
  return (n(disc1) or n(disc2) or n(disc3) or n(disc4) or n(disc5) or n(disc6) or n(disc7) or n(disc8))
end
GameController.is_able_to_put = function(self, x, y, state)
  if not self:able_judge1(x, y, state) then
	return false
  else
	local s = state
	local n
	local function _34_(e)
	  return not not e
	end
	n = _34_
	local f1
	local function _35_(x0, y0)
	  return {(x0 - 1), y0}
	end
	f1 = _35_
	local f2
	local function _36_(x0, y0)
	  return {x0, (y0 - 1)}
	end
	f2 = _36_
	local f3
	local function _37_(x0, y0)
	  return {(x0 + 1), y0}
	end
	f3 = _37_
	local f4
	local function _38_(x0, y0)
	  return {x0, (y0 + 1)}
	end
	f4 = _38_
	local f5
	local function _39_(x0, y0)
	  return {(x0 - 1), (y0 - 1)}
	end
	f5 = _39_
	local f6
	local function _40_(x0, y0)
	  return {(x0 + 1), (y0 - 1)}
	end
	f6 = _40_
	local f7
	local function _41_(x0, y0)
	  return {(x0 - 1), (y0 + 1)}
	end
	f7 = _41_
	local f8
	local function _42_(x0, y0)
	  return {(x0 + 1), (y0 + 1)}
	end
	f8 = _42_
	local c1 = self:check_accum_states(x, y, s, f1)
	local c2 = self:check_accum_states(x, y, s, f2)
	local c3 = self:check_accum_states(x, y, s, f3)
	local c4 = self:check_accum_states(x, y, s, f4)
	local c5 = self:check_accum_states(x, y, s, f5)
	local c6 = self:check_accum_states(x, y, s, f6)
	local c7 = self:check_accum_states(x, y, s, f7)
	local c8 = self:check_accum_states(x, y, s, f8)
	return (n(c1) or n(c2) or n(c3) or n(c4) or n(c5) or n(c6) or n(c7) or n(c8))
  end
end
GameController.flip_indicate_disc = function(self)
  local d = self.disc_for_indicate
  return d:flip()
end
GameController.check_need_pass = function(self)
  local flag_3f = false
  local done_3f = false
  local first_3f = true
  local x = 1
  local y = 1
  while not done_3f do
	if not first_3f then
	  if (x < N) then
		x = (x + 1)
	  else
		x = 1
		y = (y + 1)
	  end
	else
	end
	if not self:is_in_range(x, y) then
	  flag_3f = true
	  done_3f = true
	else
	  if (self:get_state(x, y) == nil) then
		if self:is_able_to_put(x, y, self.cur_turn_state) then
		  flag_3f = false
		  done_3f = true
		else
		end
	  else
	  end
	end
	first_3f = false
  end
  return flag_3f
end
GameController.check_finished = function(self)
  local sum
  do
	local sm = 0
	for _, v in pairs(states) do
	  if not (v == nil) then
		sm = (sm + 1)
	  else
		sm = sm
	  end
	end
	sum = sm
  end
  return (sum == (N * N))
end
GameController.judge_finished = function(self)
  if self:check_finished() then
	self.finished = true
	return print("finished!!!!!!!")
  else
	return nil
  end
end
GameController.judge_next_touch = function(self, position)
  local x = position.x
  local y = position.z
  local px = ((x - self.x0) / self.width)
  local py = ((y - self.y0) / self.height)
  local nx = (floor((px * N)) + 1)
  local ny = (floor((py * N)) + 1)
  local already_exist = not (self:get_state(nx, ny) == nil)
  local ok_to_put = self:is_able_to_put(nx, ny, self.cur_turn_state)
  if (not already_exist and ok_to_put) then
	if self.cur_turn_state then
	  self:newDiscAt(nx, ny)
	else
	  self:newDiscFlippedAt(nx, ny)
	end
	self:flip_discs(nx, ny, self.cur_turn_state)
	self:flip_indicate_disc()
	self:judge_finished()
	self.cur_turn_state = not self.cur_turn_state
	if not self.finished then
	  if self:check_need_pass() then
		print(self:get_turn_name(), "pass!!")
		self:flip_indicate_disc()
		self:judge_finished()
		self.cur_turn_state = not self.cur_turn_state
		return nil
	  else
		return nil
	  end
	else
	  return nil
	end
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
  local and_57_ = (nil ~= event)
  if and_57_ then
	local e = event
	and_57_ = Variant.is(e, InputEventMouseButton)
  end
  if and_57_ then
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
