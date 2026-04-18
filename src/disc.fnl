(local Disc 
  {:extends Node3D
   :class_name "Disc"})

(local init_offset_y 0.1)
(local init_anim_duration 0.3)
(local need_rotate false)

(fn Disc.flip [self]
  (set self.flipped (not self.flipped))
  (set self.need_rotate true))

(fn Disc.set_game_controller [self gc]
  (set self.game_controller gc))

(fn Disc.on_init [self]
  ; (set self.root (Finder:get_root))
  ; (set self.root (self:get_tree))
  ; (set self.game_controller (Finder:find_child_by_name self.root "GameController"))
  ; (print self.game_controller)
  (set self.offset_node (Finder:find_child_by_name self "Offset"))
  (set self.rot_node (Finder:find_child_by_name self "Rot"))
  ; (print self.rot_node)

  (if (self:need_animation)
    (Utils:update_y self init_offset_y)))

(fn Disc._ready [self]
  ;(print "disc ready")
  (set self.placed false)
  (set self.flipped false)
  (set self.elapsed 0))

(fn Disc._process [self delta]
  (if self.placed
    (do 
      (if self.need_rotate (do
        (if (not (= self.rot_node nil)) (do
          (self.rot_node:rotate_x (deg_to_rad 180))
          (set self.need_rotate false)))))
      
      (if (< self.elapsed init_anim_duration)
        (if (self:need_animation)
          (do
            (let [r (/ self.elapsed init_anim_duration)
                  p (* (- 1 r) init_offset_y)]
              (Utils:update_y self p)))
          ;else
          (do
            (Utils:update_y self 0))))))

  ; (if (and (= self.x 4) (= self.y 4))
  ;   ; (print self.game_controller)
  ;   ; (print self.game_controller.b_animation)
  ;   (print (self:need_animation))
  ;   )

  (if (not self.placed)
    (do
      (set self.placed true)
      (self:on_init) ;WORKAROUND
    ))

  (set self.elapsed (+ self.elapsed delta)))

(fn Disc.need_animation [self]
  (not (not self.game_controller.b_animation)))

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