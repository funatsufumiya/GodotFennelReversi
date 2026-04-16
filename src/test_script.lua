local TestScript = {extends = Node}
TestScript._ready = function(self)
  return print("Hello from fennel!")
end
return TestScript
