local GameController = {extends = Node, class_name = "GameController"}
local N = 8
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
  if self.is_dirty then
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
GameController.newDiscAt = function(self, x, y)
  local disc = self:newDisc()
  self:move(disc, x, y)
  return disc
end
GameController.newDiscFlippedAt = function(self, x, y)
  local disc = self:newDisc()
  self:move(disc, x, y)
  disc:flip()
  return disc
end
GameController.newDisc = function(self)
  local disc = self.disc_prefab:instantiate()
  Utils:add_child_deferred(self.root, disc)
  return disc
end
GameController.clearDiscs = function(self)
  local discs = Finder:find_children_by_type(self.root, "Disc")
  for _, disc in pairs(discs) do
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
  return self:initDiscs()
end
GameController._process = function(self, delta)
  if self.is_dirty then
	self.is_dirty = false
	return nil
  else
	return nil
  end
end
return GameController
