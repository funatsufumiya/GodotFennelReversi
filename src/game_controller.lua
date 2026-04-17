local GameController = {extends = Node}
GameController._ready = function(self)
  return print("Hello from fennel!")
end
return GameController
