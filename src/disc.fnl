(local Disc 
  {:extends Node3D
   :class_name "Disc"})

(fn Disc.flip [self]
  (set self.flipped (not self.flipped))
  (self:rotate_x (deg_to_rad 180)))

(fn Disc._ready [self]
  ;(print "disc ready")
  (set self.placed false)
  (set self.flipped false)
  )

(fn Disc._process [self delta]
  (if (not self.placed)
    (do
      (set self.placed true)
    )))

(fn Disc.is_black [self]
  (not self.flipped))

(fn Disc.is_white [self]
  ; WORKAROUND
  (not (not self.flipped)))

(fn Disc.is_placed [self]
  ; WORKAROUND
  (not (not self.placed)))

(fn Disc.set_x [self x]
  (set self.x x))

(fn Disc.set_y [self y]
  (set self.y y))

(fn Disc.get_x [self]
  self.x)

(fn Disc.get_y [self]
  self.y)

Disc