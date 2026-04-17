(local GameController
  {:extends Node
   :class_name "GameController"})
  
(local N 8)

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
    disc))

(fn GameController.newDiscFlippedAt [self x y]
  (let [disc (self:newDisc)]
    (self:move_deferred disc x y)
    (disc:flip)
    ; (Utils:flip_disc_deferred disc)
    disc))

(fn GameController.newDisc [self]
  (let [disc (self.disc_prefab:instantiate)]
    ; (print self.root)
    (Utils:add_child_deferred self.root disc)
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
  ; (self:newDiscFlippedAt 1 1)
  )

(fn GameController._ready [self]
  (set self.is_dirty true)
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
  (self:initDiscs))

(fn GameController._process [self delta]
  (if self.is_dirty
    (do
      (set self.is_dirty false)
    )))

GameController