(local DiscForIndicate
  {:extends Node3D
   :class_name "DiscForIndicate"})

(fn DiscForIndicate.flip [self]
  (set self.flipped (not self.flipped))
  (self:rotate_x (deg_to_rad 180)))

(fn DiscForIndicate._ready [self]
  ;(print "disc ready")
  (set self.placed false)
  (set self.flipped false)
  )

(fn DiscForIndicate._process [self delta]
  (if (not self.placed)
    (do
      (set self.placed true)
    )))

(fn DiscForIndicate.is_black [self]
  (not self.flipped))

(fn DiscForIndicate.is_white [self]
  ; WORKAROUND
  (not (not self.flipped)))

(fn DiscForIndicate.is_placed [self]
  ; WORKAROUND
  (not (not self.placed)))

DiscForIndicate