local GameController = {extends = Node, class_name = "GameController"}
local N = 8
local states = {}
local discs = {}
GameController.is_black = function(self, b)
  if (b == true) then
	return true
  else
	return false
  end
end
GameController.is_white = function(self, b)
  return not self:is_black(b)
end
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
GameController.clear_states = function(self)
  for x = 1, N do
	for y = 1, N do
	  self:set_state(x, y, nil)
	end
  end
  return nil
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
GameController.print_score = function(self)
  local a_sum = self:disc_count_side(true)
  local b_sum = self:disc_count_side(false)
  print("black: ", a_sum)
  return print("white: ", b_sum)
end
GameController.update_score = function(self)
  local a_sum = self:disc_count_side(true)
  local b_sum = self:disc_count_side(false)
  self.black_count_label.text = str(a_sum)
  self.white_count_label.text = str(b_sum)
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
  print("restarted")
  self:clear_states()
  self:clearDiscs()
  self:initDiscs()
  self:update_score()
  self.finished = false
  if not self:is_black(self.cur_turn_state) then
	self.disc_for_indicate:flip()
	self.cur_turn_state = true
	return nil
  else
	return nil
  end
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
  self.black_count_label = Finder:find_child_by_name(self.root, "BlackCountLabel")
  self.white_count_label = Finder:find_child_by_name(self.root, "WhiteCountLabel")
  self.score_view = Finder:find_child_by_name(self.root, "ScoreView")
  self.option_view = Finder:find_child_by_name(self.root, "OptionView")
  self.toggle_animation_indicator = Finder:find_child_by_name(self.root, "ToggleAnimationIndicator")
  self.toggle_score_indicator = Finder:find_child_by_name(self.root, "ToggleScoreIndicator")
  self.toggle_assist_indicator = Finder:find_child_by_name(self.root, "ToggleAssistIndicator")
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
	self:print_score()
  else
  end
  if Input:is_action_just_pressed("ToggleAssist") then
	self.show_assist = not self.show_assist
	print("assist", self.show_assist)
	if self.show_assist then
	  self.toggle_assist_indicator.visible = true
	else
	  self.toggle_assist_indicator.visible = false
	end
  else
  end
  if Input:is_action_just_pressed("ToggleScore") then
	print("toggle score view")
	if self.score_view.visible then
	  self.toggle_score_indicator.visible = false
	  self.score_view.visible = false
	else
	  self.toggle_score_indicator.visible = true
	  self.score_view.visible = true
	end
  else
  end
  if Input:is_action_just_pressed("ToggleOptionView") then
	print("toggle option view")
	if self.option_view.visible then
	  self.option_view.visible = false
	else
	  self.option_view.visible = true
	end
  else
  end
  if Input:is_action_just_pressed("ToggleAnimation") then
	self.b_animation = not self.b_animation
	if self.b_animation then
	  self.toggle_animation_indicator.visible = true
	else
	  self.toggle_animation_indicator.visible = false
	end
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
	local function _20_(e)
	  return not not e
	end
	n = _20_
	local f1
	local function _21_(x0, y0)
	  return {(x0 - 1), y0}
	end
	f1 = _21_
	local f2
	local function _22_(x0, y0)
	  return {x0, (y0 - 1)}
	end
	f2 = _22_
	local f3
	local function _23_(x0, y0)
	  return {(x0 + 1), y0}
	end
	f3 = _23_
	local f4
	local function _24_(x0, y0)
	  return {x0, (y0 + 1)}
	end
	f4 = _24_
	local f5
	local function _25_(x0, y0)
	  return {(x0 - 1), (y0 - 1)}
	end
	f5 = _25_
	local f6
	local function _26_(x0, y0)
	  return {(x0 + 1), (y0 - 1)}
	end
	f6 = _26_
	local f7
	local function _27_(x0, y0)
	  return {(x0 - 1), (y0 + 1)}
	end
	f7 = _27_
	local f8
	local function _28_(x0, y0)
	  return {(x0 + 1), (y0 + 1)}
	end
	f8 = _28_
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
  local function _41_(e)
	return not not e
  end
  n = _41_
  return (n(disc1) or n(disc2) or n(disc3) or n(disc4) or n(disc5) or n(disc6) or n(disc7) or n(disc8))
end
GameController.is_able_to_put = function(self, x, y, state)
  if not self:able_judge1(x, y, state) then
	return false
  else
	local s = state
	local n
	local function _42_(e)
	  return not not e
	end
	n = _42_
	local f1
	local function _43_(x0, y0)
	  return {(x0 - 1), y0}
	end
	f1 = _43_
	local f2
	local function _44_(x0, y0)
	  return {x0, (y0 - 1)}
	end
	f2 = _44_
	local f3
	local function _45_(x0, y0)
	  return {(x0 + 1), y0}
	end
	f3 = _45_
	local f4
	local function _46_(x0, y0)
	  return {x0, (y0 + 1)}
	end
	f4 = _46_
	local f5
	local function _47_(x0, y0)
	  return {(x0 - 1), (y0 - 1)}
	end
	f5 = _47_
	local f6
	local function _48_(x0, y0)
	  return {(x0 + 1), (y0 - 1)}
	end
	f6 = _48_
	local f7
	local function _49_(x0, y0)
	  return {(x0 - 1), (y0 + 1)}
	end
	f7 = _49_
	local f8
	local function _50_(x0, y0)
	  return {(x0 + 1), (y0 + 1)}
	end
	f8 = _50_
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
GameController.is_disc_sum_nn = function(self)
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
GameController.disc_count_side = function(self, side)
  local sum
  do
	local sm = 0
	for _, v in pairs(states) do
	  if (not (v == nil) and (v == side)) then
		sm = (sm + 1)
	  else
		sm = sm
	  end
	end
	sum = sm
  end
  return sum
end
GameController.is_all_the_same_color = function(self)
  local a_sum = self:disc_count_side(true)
  local b_sum = self:disc_count_side(false)
  return (not ((a_sum == 0) and (b_sum == 0)) and ((a_sum == 0) or (b_sum == 0)))
end
GameController.check_finished = function(self)
  local check1 = self:is_disc_sum_nn()
  local check2 = self:is_all_the_same_color()
  return (check1 and check2)
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
  do
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
		else
		end
	  else
	  end
	else
	end
  end
  return self:update_score()
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
  local and_66_ = (nil ~= event)
  if and_66_ then
	local e = event
	and_66_ = Variant.is(e, InputEventMouseButton)
  end
  if and_66_ then
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
