(local GameController
  {:extends Node
   :class_name "GameController"})
  
(local N 8)
(local states {})
(local discs {})

(fn GameController.get_state [self x y]
  (. states (+ x (* y N))))

(fn GameController.set_state [self x y b]
  (tset states (+ x (* y N)) b))

(fn GameController.get_disc [self x y]
  (. discs (+ x (* y N))))

(fn GameController.set_disc [self x y disc]
  (tset discs (+ x (* y N)) disc))

(fn GameController.get_state_str [self x y]
  (let [st (self:get_state x y)]
    (case st nil "." true "x" false "o")))

(fn GameController.init_states [self]
  (for [i 1 (* N N)]
    (table.insert states nil)))

(fn GameController.init_discs [self]
  (for [i 1 (* N N)]
    (table.insert states nil)))

(fn GameController.get_state_raw [self x]
  (var s "")
  (for [i 1 N]
    (set s (.. s " " (self:get_state_str x i))))
  s)

(fn GameController.print_states [self]
  (for [i 1 N]
    (print (self:get_state_raw i))))

(fn GameController.get_width [self]
  (- self.right_bottom_pos.x self.left_top_pos.x))

(fn GameController.get_height [self]
  (- self.right_bottom_pos.z self.left_top_pos.z))

(fn GameController.get_pos_x [self x]
  (+ self.x0 (* (- x 0.5) self.dw)))

(fn GameController.get_pos_y [self y]
  (+ self.y0 (* (- y 0.5) self.dh)))

(fn GameController.get_global_position [self disc]
  (if (not (disc:is_placed)) (Vector3 0 0 0) disc.global_position))

(fn GameController.move [self disc x y]
  (let [nx (self:get_pos_x x)
        ny (self:get_pos_y y)
        gp (self:get_global_position disc)]

    ; (print "nx" nx "ny" ny)
    (set gp.x nx)
    (set gp.z ny)
    (set disc.global_position gp)
    ; (Utils:set_global_position_deferred disc gp)
    ))

(fn GameController.move_deferred [self disc x y]
  (let [nx (self:get_pos_x x)
        ny (self:get_pos_y y)
        gp (self:get_global_position disc)]

    ; (print "nx" nx "ny" ny)
    (set gp.x nx)
    (set gp.z ny)
    ; (set disc.global_position gp)
    (Utils:set_global_position_deferred disc gp)
    ))

(fn GameController.newDiscAt [self x y]
  (let [disc (self:newDisc)]
    (self:move_deferred disc x y)
    (disc:set_x x)
    (disc:set_y y)
    (self:set_state x y true)
    (self:set_disc x y disc)
    disc))

(fn GameController.newDiscFlippedAt [self x y]
  (let [disc (self:newDisc)]
    (self:move_deferred disc x y)
    (disc:set_x x)
    (disc:set_y y)
    (disc:flip)
    (self:set_state x y false)
    (self:set_disc x y disc)
    ; (Utils:flip_disc_deferred disc)
    disc))

(fn GameController.flipDisc [self disc]
  (disc:flip)
  (self:set_state x y (not (self:get_state x y))))

(fn GameController.flipDiscAt [self x y]
  (let [disc (self:get_disc x y)]
    (disc:flip)
    (self:set_state x y (not (self:get_state x y)))))

(fn GameController.newDisc [self]
  (let [disc (self.disc_prefab:instantiate)]
    ; (print self.root)
    (Utils:add_child_deferred self.root disc)
    (disc:set_x nil)
    (disc:set_y nil)
    disc))

(fn GameController.clearDiscs [self]
  (let [discs (Finder:find_children_by_type self.root "Disc")]
    ; (print discs)
    ; (print (typeof discs))
    (each [_ disc (pairs discs)]
      (disc:queue_free)
      ; (print disc)
      )))

(fn GameController.initDiscs [self]
  (self:newDiscFlippedAt 4 4)
  (self:newDiscFlippedAt 5 5)
  (self:newDiscAt 4 5)
  (self:newDiscAt 5 4)
  (self:newDiscFlippedAt 1 1)
  ; (self:flipDiscAt 1 1)
  )

(fn GameController._ready [self]
  (set self.is_dirty true)

  (self:init_states)
  (self:init_discs)

  (set self.preloaded (Preloaded:singleton))
  (set self.root (Finder:get_root))
  (set self.disc_prefab self.preloaded.disc_prefab)

  (set self.left_top_marker (Finder:find_child_by_name self.root "LeftTopMarker"))
  (set self.right_bottom_marker (Finder:find_child_by_name self.root "RightBottomMarker"))
  (set self.left_top_pos self.left_top_marker.global_position)
  (set self.right_bottom_pos self.right_bottom_marker.global_position)

  (set self.x0 self.left_top_pos.x)
  (set self.y0 self.left_top_pos.z)
  (set self.width (self:get_width))
  (set self.height (self:get_height))
  (set self.dw (/ self.width N))
  (set self.dh (/ self.height N))

  ; (print self.left_top_marker)
  ; (print self.right_bottom_marker)
  (self:clearDiscs)
  (self:initDiscs)

  (self:print_states))

(fn GameController._process [self delta]
  (if self.is_dirty
    (do
      (set self.is_dirty false)
    )))

GameController