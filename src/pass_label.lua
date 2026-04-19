local PassLabel = {extends = Node3D, class_name = "PassLabel"}
local show_time_left = 0
PassLabel._ready = function(self)
  self.placed = false
  return nil
end
PassLabel._process = function(self, delta)
  if self.placed then
    if (show_time_left > 0) then
      show_time_left = (show_time_left - delta)
      if (show_time_left < 0) then
        show_time_left = 0
        self.visible = false
      else
      end
    else
    end
  else
  end
  if not self.placed then
    self.placed = true
    return nil
  else
    return nil
  end
end
PassLabel.is_placed = function(self)
  return not not self.placed
end
PassLabel.show = function(self)
  self.visible = true
  show_time_left = 1
  return nil
end
return PassLabel
