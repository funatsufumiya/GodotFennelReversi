(local Disc 
  {:extends Node3D
   :class_name "Disc"})

(fn Disc.flip [self]
  (set self.flipped (not self.flipped))
  (self:rotate_x (deg_to_rad 180)))

(fn Disc._ready [self]
  ;(print "disc ready")
  (set self.root (Finder:get_root))
  (set self.game_controller (Finder:find_child_by_name self.root "GameController"))
  (set self.placed false)
  (set self.flipped false)
  )

(fn Disc._process [self delta]
  ; (if (and (= self.x 4) (= self.y 4))
  ;   ; (print self.game_controller)
  ;   ; (print self.game_controller.b_animation)
  ;   )

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