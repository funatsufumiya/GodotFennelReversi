(local Disc 
  {:extends Node3D
   :class_name "Disc"})

(fn Disc.flip [self]
  (self:rotate_x (deg_to_rad 180)))

(fn Disc._ready [self]
  ;(print "disc ready")
  )

Disc