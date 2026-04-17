(local GameController
  {:extends Node
   :class_name "GameController"})
  
(local N 8)
(local states {})
(local discs {})
; (local cur_turn_state false)

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
    (set s (.. s " " (self:get_state_str i x))))
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
  (let [x (disc:get_x)
        y (disc:get_y)]
    (self:set_state x y (not (self:get_state x y)))))

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
  ; (self:newDiscFlippedAt 1 1)
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
  (set self.camera (Finder:find_child_by_name self.root "Camera3D"))
  (set self.right_bottom_marker (Finder:find_child_by_name self.root "RightBottomMarker"))
  (set self.left_top_pos self.left_top_marker.global_position)
  (set self.right_bottom_pos self.right_bottom_marker.global_position)

  (set self.x0 self.left_top_pos.x)
  (set self.y0 self.left_top_pos.z)
  (set self.width (self:get_width))
  (set self.height (self:get_height))
  (set self.dw (/ self.width N))
  (set self.dh (/ self.height N))
  (set self.finished false)

  ; (print self.left_top_marker)
  ; (print self.right_bottom_marker)
  (self:clearDiscs)
  (self:initDiscs)

  (self:print_states)

  (set self.cur_turn_state false))

(fn GameController._process [self delta]
  (if self.is_dirty
    (do
      (set self.is_dirty false)
    ))
  
  (if (Input:is_action_just_pressed "DoDebug")
    (do
      (print (self:get_timestamp))
      (self:print_states)
    ))

  (if (Input:is_action_just_pressed "Exit")
    (do
      (let [tree (self:get_tree)]
        (tree:quit)))))

(fn to_array [arr]
  ; (var a (Array))
  ; (each [_ e (ipairs arr)]
  ;   (a:push_back e))
  ; a)
  (Array arr))

(fn GameController.get_timestamp [self]
  (let [now (Time:get_datetime_dict_from_system)]
    (Utils:format "%04d-%02d-%02d %02d:%02d:%02d"
      (to_array [
        now.year
        now.month
        now.day
        now.hour
        now.minute
        now.second])
      )))

(fn GameController.get_raycast_result [self]
  (let [
    root self.root
    w3d (root:get_world_3d)
    space_state w3d.direct_space_state
    viewport (self:get_viewport)
    mousepos (viewport:get_mouse_position)
    cam self.camera
    origin (cam:project_ray_origin mousepos)
    ray_end (+ origin (* (cam:project_ray_normal mousepos) 1000))
    query (PhysicsRayQueryParameters3D:create origin ray_end)
    _  (set query.collide_with_areas true)
    result (space_state:intersect_ray query)
    ]
    result))


(fn GameController.flip_discs [self x y state]
  (print "flip discs not implemented yet: " x y state))
  ; (let [disc (self:get_disc (- x 1) y)]
  ;   (if disc (do
  ;     (self:flipDisc disc)
  ;   ))))

(fn GameController.is_able_to_put [self x y state]
  (print "WARN: is_able_to_put not implmented yet!")
  ; WORKAROUND
  (let [
    disc1 (self:get_disc (- x 1) y)
    disc2 (self:get_disc x (- y 1))
    disc3 (self:get_disc (+ x 1) y)
    disc4 (self:get_disc x (+ y 1))
    disc5 (self:get_disc (- x 1) (- y 1))
    disc6 (self:get_disc (+ x 1) (- y 1))
    disc7 (self:get_disc (- x 1) (+ y 1))
    disc8 (self:get_disc (+ x 1) (+ y 1))
    n (fn [e] (not (not e)))
    ]
    (or
      (n disc1)
      (n disc2)
      (n disc3)
      (n disc4)
      (n disc5)
      (n disc6)
      (n disc7)
      (n disc8)
      )))
  ; true)

(fn GameController.check_finished [self]
  (let [sum (accumulate [sm 0 _ v (pairs states)]
              (if (not (= v nil)) (+ sm 1) sm))]
    ; (print "sum" sum)
    (= sum (* N N))))

(fn GameController.judge_finished [self]
  (if (self:check_finished)
    (do
      (set self.finished true)
      (print "finished!!!!!!!"))))

(fn GameController.judge_next_touch [self position]
  ; (print position)
  (let [
    x position.x
    y position.z
    px (/ (- x self.x0) self.width)
    py (/ (- y self.y0) self.height)
    nx (+ (floor (* px N)) 1)
    ny (+ (floor (* py N)) 1)
    already_exist (not (= (self:get_state nx ny) nil))
    ok_to_put (self:is_able_to_put nx ny self.cur_turn_state)
    ]
    ; (print nx ny)
    (if (and (not already_exist) ok_to_put)
      (do
        ; (print "current state" self.cur_turn_state)
        (if self.cur_turn_state
          (self:newDiscFlippedAt nx ny)
          (self:newDiscAt nx ny))
        (self:flip_discs nx ny self.cur_turn_state)
        (self:judge_finished)
        (set self.cur_turn_state (not self.cur_turn_state))
          ))))

(fn GameController.try_raycast [self]
  (let [result (self:get_raycast_result)]
    ; (print result)
    (if (not (not result))
      (do 
        (if (= result.collider.name "BoardArea")
          (do
            ; (print "hit!" result)
            (self:judge_next_touch result.position)
          ))))))

(fn GameController._input [self event]
  (match event
    (where e (Variant.is e InputEventMouseButton))
    (do 
      ; (print "MouseButton Event" event)
      (if event.pressed
        (do
          (self:try_raycast)
          ; (print "mouse pressed event!" event)
        )))))

GameController