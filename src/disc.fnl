(local Disc 
  {:extends Node3D
   :class_name "Disc"})

(fn Disc.flip [self]
  (set self.flipped (not self.flipped))
  (self:rotate_x (deg_to_rad 180)))

(fn Disc._ready [self]
  ;(print "disc ready")
  (set self.flipped false)
  )

(fn Disc.is_black [self]
  (not self.flipped))

(fn Disc.is_white [self]
  ; WORKAROUND
  (not (not self.flipped)))

Disc