(local GameController
  {:extends Node
   :class_name "GameController"})
  
(local N 8)
(local states {})
(local discs {})

(fn GameController.is_black [self b]
  (if (= b true) true false))

(fn GameController.is_white [self b]
  (not (self:is_black b)))

(macro set_black [v]
  `(set ,v true))

(macro set_white [v]
  `(set ,v false))

(fn GameController.get_turn_name [self]
  (if (= self.cur_turn_state true) "black" "white"))

(fn GameController.get_state [self x y]
  (if (self:is_in_range x y)
    (. states (+ x (* y N)))
    nil))

(fn GameController.set_state [self x y b]
  (tset states (+ x (* y N)) b))

(fn GameController.get_disc [self x y]
  (if (self:is_in_range x y)
    (. discs (+ x (* y N)))
    nil))

(fn GameController.set_disc [self x y disc]
  (tset discs (+ x (* y N)) disc))

(fn GameController.get_state_str [self x y]
  (let [st (self:get_state x y)]
    (case st nil "." true "o" false "x")))

(fn GameController.clear_states [self]
  (for [x 1 N]
    (for [y 1 N]
      (self:set_state x y nil))))

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

(fn GameController.print_score [self]
  (let [a_sum (self:disc_count_side true)
        b_sum (self:disc_count_side false)]
      (print "black: " a_sum)
      (print "white: " b_sum)))

(fn GameController.update_score [self]
  (let [a_sum (self:disc_count_side true)
        b_sum (self:disc_count_side false)]
      (set self.black_count_label.text (str a_sum))
      (set self.white_count_label.text (str b_sum))))

(fn GameController.get_width [self]
  (- self.right_bottom_pos.x self.left_top_pos.x))

(fn GameController.get_height [self]
  (- self.right_bottom_pos.z self.left_top_pos.z))

(fn GameController.get_pos_x [self x]
  (+ self.x0 (* (- x 0.5) self.dw)))

(fn GameController.get_pos_y [self y]
  (+ self.y0 (* (- y 0.5) self.dh)))

(fn GameController.get_global_position [self e]
  (if (not (e:is_placed)) (Vector3 0 0 0) e.global_position))

(fn GameController.move [self e x y]
  (let [nx (self:get_pos_x x)
        ny (self:get_pos_y y)
        gp (self:get_global_position e)]

    ; (print "nx" nx "ny" ny)
    (set gp.x nx)
    (set gp.z ny)
    (set e.global_position gp)
    ; (Utils:set_global_position_deferred disc gp)
    ))

(fn GameController.move_deferred [self e x y]
  (let [nx (self:get_pos_x x)
        ny (self:get_pos_y y)
        gp (self:get_global_position e)]

    ; (print "nx" nx "ny" ny)
    (set gp.x nx)
    (set gp.z ny)
    ; (set disc.global_position gp)
    (Utils:set_global_position_deferred e gp)
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

(fn GameController.flipDisc [self disc opt]
  (disc:flip opt)
  (let [x (disc:get_x)
        y (disc:get_y)]
    (self:set_state x y (not (self:get_state x y)))))

(fn GameController.flipDiscAt [self x y opt]
  (let [disc (self:get_disc x y)]
    (disc:flip opt)
    (self:set_state x y (not (self:get_state x y)))))

(fn GameController.newDisc [self]
  (let [disc (self.disc_prefab:instantiate)]
    ; (print self.root)
    (Utils:add_child_deferred self.root disc)
    (disc:set_game_controller self)
    (disc:set_x nil)
    (disc:set_y nil)
    disc))

(fn GameController.newAssist [self black_or_white]
  (let [e (if (self:is_black black_or_white)
              (self.assist_black_prefab:instantiate)
              (self.assist_white_prefab:instantiate))]
    ; (print self.root)
    (Utils:add_child_deferred self.root e)
    e))

(fn GameController.newAssitAt [self black_or_white x y]
  (let [e (self:newAssist black_or_white)]
    (self:move_deferred e x y)
    e))

(fn GameController.clearDiscs [self]
  (let [discs (Finder:find_children_by_type self.root "Disc")]
    ; (print discs)
    ; (print (typeof discs))
    (each [_ disc (pairs discs)]
      (disc:queue_free)
      ; (print disc)
      )))

(fn GameController.clearAssists [self]
  (let [es (Finder:find_children_by_type self.root "Assist")]
    (each [_ e (pairs es)]
      (e:queue_free)
      )))

(fn GameController.putAssists [self]
  (if self.show_assist (do
    (let [lst (self:list_able_to_put)]
      (each [k v (pairs lst)]
        (let [x (. v 0)
              y (. v 1)]
          (self:newAssitAt self.cur_turn_state x y))))
  )))

(fn GameController.initDiscs [self]
  (self:newDiscFlippedAt 4 4)
  (self:newDiscFlippedAt 5 5)
  (self:newDiscAt 4 5)
  (self:newDiscAt 5 4))

(fn GameController.restart [self]
  (print "restarted")
  (self:clear_states)
  (self:clearDiscs)
  (self:clearAssists)
  (self:putAssists)
  (self:initDiscs)
  (self:update_score)

  (set self.finished false)
  
  (if (not (self:is_black self.cur_turn_state)) (do
    (self.disc_for_indicate:flip)
    (set_black self.cur_turn_state)
    )))

; =======================================
; =======================================

(fn GameController._ready [self]
  (set self.is_dirty true)

  (self:init_states)
  (self:init_discs)

  (set self.preloaded (Preloaded:singleton))
  (set self.root (Finder:get_root))
  (set self.disc_prefab self.preloaded.disc_prefab)
  (set self.assist_black_prefab self.preloaded.assist_black_prefab)
  (set self.assist_white_prefab self.preloaded.assist_white_prefab)

  (set self.disc_for_indicate (Finder:find_child_by_name self.root "DiscForIndicate"))
  (self.disc_for_indicate:set_game_controller self)
  (set self.left_top_marker (Finder:find_child_by_name self.root "LeftTopMarker"))
  (set self.camera (Finder:find_child_by_name self.root "Camera3D"))
  (set self.right_bottom_marker (Finder:find_child_by_name self.root "RightBottomMarker"))
  (set self.left_top_pos self.left_top_marker.global_position)
  (set self.right_bottom_pos self.right_bottom_marker.global_position)

  (set self.black_count_label (Finder:find_child_by_name self.root "BlackCountLabel"))
  (set self.white_count_label (Finder:find_child_by_name self.root "WhiteCountLabel"))
  (set self.score_view (Finder:find_child_by_name self.root "ScoreView"))
  (set self.option_view (Finder:find_child_by_name self.root "OptionView"))
  (set self.toggle_animation_indicator (Finder:find_child_by_name self.root "ToggleAnimationIndicator"))
  (set self.toggle_score_indicator (Finder:find_child_by_name self.root "ToggleScoreIndicator"))
  (set self.toggle_assist_indicator (Finder:find_child_by_name self.root "ToggleAssistIndicator"))
  (set self.toggle_option_area (Finder:find_child_by_name self.root "ToggleOptionArea"))
  (set self.toggle_assist_area (Finder:find_child_by_name self.root "ToggleAssistArea"))
  (set self.toggle_animation_area (Finder:find_child_by_name self.root "ToggleAnimationArea"))
  (set self.toggle_score_view_area (Finder:find_child_by_name self.root "ToggleScoreViewArea"))

  (set self.x0 self.left_top_pos.x)
  (set self.y0 self.left_top_pos.z)
  (set self.width (self:get_width))
  (set self.height (self:get_height))
  (set self.dw (/ self.width N))
  (set self.dh (/ self.height N))
  (set self.finished false)
  (set self.show_assist false)
  (set self.b_animation true)

  (if self.option_view.visible
    (self:option_area_enabled true)
    (self:option_area_enabled false))

  ; (print self.left_top_marker)
  ; (print self.right_bottom_marker)
  (self:clearDiscs)
  (self:clearAssists)
  (self:putAssists)
  (self:initDiscs)

  ; (self:print_states)

  (set self.cur_turn_state true))

; =======================================  
; =======================================

(fn GameController._process [self delta]
  (if self.is_dirty
    (do
      (set self.is_dirty false)
    ))
  
  (if (Input:is_action_just_pressed "DoDebug")
    (do
      (print (self:get_timestamp))
      (self:print_states)
      (self:print_score)
    ))

  (if (Input:is_action_just_pressed "ToggleAssist")
    (do
      (set self.show_assist (not self.show_assist))
      (print "assist" self.show_assist)
      (if self.show_assist
        (set self.toggle_assist_indicator.visible true)
        (set self.toggle_assist_indicator.visible false))
      (self:clearAssists)
      (self:putAssists)
    ))

  (if (Input:is_action_just_pressed "ToggleScore")
    (do
      (print "toggle score view")
      ; (print self.score_view)
      (if self.score_view.visible
        (do
          (set self.toggle_score_indicator.visible false)
          (set self.score_view.visible false))
        (do
          (set self.toggle_score_indicator.visible true)
          (set self.score_view.visible true)))))

  (if (Input:is_action_just_pressed "ToggleOptionView")
    (do
      (print "toggle option view")
      ; (print self.option_view)
      (if self.option_view.visible
        (do
          (self:option_area_enabled false)
          (set self.option_view.visible false))
        (do 
          (self:option_area_enabled true)
          (set self.option_view.visible true)))))

  (if (Input:is_action_just_pressed "ToggleAnimation")
    (do
      (set self.b_animation (not self.b_animation))
      (if self.b_animation
        (set self.toggle_animation_indicator.visible true)
        (set self.toggle_animation_indicator.visible false))
      (print "animation" self.b_animation)
    ))

  (if (Input:is_action_just_pressed "Restart")
    (do
      (self:restart)
    ))

  (if (Input:is_action_just_pressed "Exit")
    (do
      (let [tree (self:get_tree)]
        (tree:quit)))))

(fn GameController.set_area_enabled [self area enabled]
  (let [collider (area:get_child 0)]
    (set collider.disabled (not enabled))))

(fn GameController.option_area_enabled [self enabled]
  (if enabled
    (do
      (self:set_area_enabled self.toggle_option_area true)
      (self:set_area_enabled self.toggle_animation_area true)
      (self:set_area_enabled self.toggle_score_view_area true)
      (self:set_area_enabled self.toggle_assist_area true)
      )
    ; else
    (do
      (self:set_area_enabled self.toggle_option_area false)
      (self:set_area_enabled self.toggle_animation_area false)
      (self:set_area_enabled self.toggle_score_view_area false)
      (self:set_area_enabled self.toggle_assist_area false)
      ))
  )

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
  (if (not (self:able_judge1 x y state))
    false
    (let [
      s state
      n (fn [e] (not (not e)))
      f1 (fn [x y] [(- x 1) y])
      f2 (fn [x y] [x (- y 1)])
      f3 (fn [x y] [(+ x 1) y])
      f4 (fn [x y] [x (+ y 1)])
      f5 (fn [x y] [(- x 1) (- y 1)])
      f6 (fn [x y] [(+ x 1) (- y 1)])
      f7 (fn [x y] [(- x 1) (+ y 1)])
      f8 (fn [x y] [(+ x 1) (+ y 1)])
      c1 (self:check_and_flip_accum_states x y s f1)
      c2 (self:check_and_flip_accum_states x y s f2)
      c3 (self:check_and_flip_accum_states x y s f3)
      c4 (self:check_and_flip_accum_states x y s f4)
      c5 (self:check_and_flip_accum_states x y s f5)
      c6 (self:check_and_flip_accum_states x y s f6)
      c7 (self:check_and_flip_accum_states x y s f7)
      c8 (self:check_and_flip_accum_states x y s f8)
      ]
      
      true)))

(fn GameController.is_in_range [self x y]
  (and (> x 0) (> y 0) (<= x N) (<= y N)))

(fn GameController.accum_states [self start_x start_y start_state incl_f]
  (var result [start_state])
  (var done? false)
  (var x start_x)
  (var y start_y)

  ; (print "x" x "y" y)

  (while (not done?) (do
    (let [v (incl_f x y)]
      (set x (. v 1))
      (set y (. v 2)))
    ; (print "x" x "y" y)
    (let [disc (if (self:is_in_range x y) (self:get_state x y) nil)]
      (if (or (not (self:is_in_range x y)) (= disc nil))
        (set done? true))
      (if (not done?)
        (if (= disc start_state)
          (do
            (if (= disc start_state) (table.insert result disc))
            (set done? true))
          (do
            (table.insert result disc)))))))

  ; (print "end")
  (Array result))

(fn GameController.is_accum_center_all_ok [self accum start_state]
  (let [
    n (accum:size)
    begin_index 1
    end_index (- n 2)]

    (var i begin_index)
    (var result nil)

    (while (and (= result nil) (<= i end_index))
      ; (print "i" i ", v" (. accum i))
      (if (not (= (. accum i) (not start_state)))
        (set result false))
      (set i (+ i 1)))

    (if (= result nil) true false)))

(fn GameController.check_accum_states [self start_x start_y start_state incl_f]
  (let [
    accum (self:accum_states start_x start_y start_state incl_f)
    n (accum:size)]
    ; (print accum n)
    (if (< n 3) false
      (let [
        a (. accum 0)
        b (. accum (- n 1))
        bridge_ok (= a b)
        center_ok (self:is_accum_center_all_ok accum start_state)
        ]
        ; (print "bridge_ok" bridge_ok "center_ok" center_ok)
        ; (print accum)
        (and bridge_ok center_ok)
      ))))

(fn GameController.apply_flip_on_accum_states [self accum start_x start_y start_state incl_f]
  (let [
    n (accum:size)
    begin_index 1
    end_index (- n 2)]

    (var dist 0)
    (var i begin_index)
    (var x start_x)
    (var y start_y)
    (var need_stop false)

    (while (and (= need_stop false) (<= i end_index))
      (local v (incl_f x y))
      (set x (. v 1))
      (set y (. v 2))
      (self:flipDiscAt x y (Dictionary {:dist dist}))
      (if (not (= (. accum i) (not start_state)))
        (set need_stop true))
      (set i (+ i 1))
      (set dist (+ dist 1)))))

(fn GameController.check_and_flip_accum_states [self start_x start_y start_state incl_f]
  (let [
    accum (self:accum_states start_x start_y start_state incl_f)
    n (accum:size)]
    ; (print accum n)
    (if (< n 3) false
      (let [
        a (. accum 0)
        b (. accum (- n 1))
        bridge_ok (= a b)
        center_ok (self:is_accum_center_all_ok accum start_state)
        ]
        (if (and bridge_ok center_ok)
          (do
            (self:apply_flip_on_accum_states accum start_x start_y start_state incl_f)
          true)
          false)
      ))))

(fn GameController.able_judge1 [self x y state]
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

(fn GameController.is_able_to_put [self x y state]
  (let [already_exist (not (= (self:get_state x y) nil))]
    (if (or already_exist (not (self:able_judge1 x y state)))
      false
      (let [
        s state
        n (fn [e] (not (not e)))
        f1 (fn [x y] [(- x 1) y])
        f2 (fn [x y] [x (- y 1)])
        f3 (fn [x y] [(+ x 1) y])
        f4 (fn [x y] [x (+ y 1)])
        f5 (fn [x y] [(- x 1) (- y 1)])
        f6 (fn [x y] [(+ x 1) (- y 1)])
        f7 (fn [x y] [(- x 1) (+ y 1)])
        f8 (fn [x y] [(+ x 1) (+ y 1)])
        c1 (self:check_accum_states x y s f1)
        c2 (self:check_accum_states x y s f2)
        c3 (self:check_accum_states x y s f3)
        c4 (self:check_accum_states x y s f4)
        c5 (self:check_accum_states x y s f5)
        c6 (self:check_accum_states x y s f6)
        c7 (self:check_accum_states x y s f7)
        c8 (self:check_accum_states x y s f8)
        ]
        (or
          (n c1)
          (n c2)
          (n c3)
          (n c4)
          (n c5)
          (n c6)
          (n c7)
          (n c8)
          )))))

(fn GameController.flip_indicate_disc [self]
  (let [d self.disc_for_indicate]
    (d:flip)))

(fn GameController.list_able_to_put [self]
  (var lst (Array))
  (for [x 1 N]
    (for [y 1 N]
      (if (self:is_able_to_put x y self.cur_turn_state)
        (do 
          (lst:push_back (Array [x y]))))))
  lst)

(fn GameController.check_need_pass [self]
  (var flag? false)
  (var done? false)
  (var first? true)
  (var x 1)
  (var y 1)

  ; (print "check pass for" (self:get_turn_name))

  (while (not done?)
    (if (not first?)
      (if (< x N)
        (set x (+ x 1))
        (do
          (set x 1)
          (set y (+ y 1)))))

    ; (print "x" x "y" y " / in_range" (self:is_in_range x y))
    ; (print "is state null?" (= (self:get_state x y) nil))
    ; (print "state" (self:get_state_str x y))
    
    (if (not (self:is_in_range x y))
      (do
        (set flag? true)
        (set done? true))
      (do
        (if (= (self:get_state x y) nil)
          (do
            (if (self:is_able_to_put x y self.cur_turn_state)
              (do
                (set flag? false)
                (set done? true)))))))

    (set first? false))
  
  ; (print "need_pass" flag?)
  flag?)

(fn GameController.is_disc_sum_nn [self]
  (let [sum (accumulate [sm 0 _ v (pairs states)]
              (if (not (= v nil)) (+ sm 1) sm))]
    ; (print "sum" sum)
    (= sum (* N N))))

(fn GameController.disc_count_side [self side]
  (let [sum (accumulate [sm 0 _ v (pairs states)]
              (if (and (not (= v nil)) (= v side)) (+ sm 1) sm))]
    sum))

(fn GameController.is_all_the_same_color [self]
  (let [a_sum (self:disc_count_side true)
        b_sum (self:disc_count_side false)]
    ; (print "black sum" a_sum)
    ; (print "white sum" b_sum)
    (and 
      (not (and (= a_sum 0) (= b_sum 0)))
      (or (= a_sum 0) (= b_sum 0)))))

(fn GameController.check_finished [self]
  (let [check1 (self:is_disc_sum_nn)
        check2 (self:is_all_the_same_color)]
    (and check1 check2)))

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
          (self:newDiscAt nx ny)
          (self:newDiscFlippedAt nx ny))
        (self:flip_discs nx ny self.cur_turn_state)
        (self:flip_indicate_disc)
        (self:judge_finished)
        (set self.cur_turn_state (not self.cur_turn_state))

        (if (not self.finished)
          (if (self:check_need_pass)
            (do
              ; TODO: show pass message
              (print (self:get_turn_name) "pass!!")
              (self:flip_indicate_disc)
              (self:judge_finished)
              (set self.cur_turn_state (not self.cur_turn_state)))))

          )))

        (self:clearAssists)
        (self:putAssists)
        (self:update_score))

(fn GameController.try_raycast [self]
  (let [result (self:get_raycast_result)]
    ; (print result)
    (if (and (not (= result nil)) (not (= result.collider nil)))
      (do 
        (case result.collider.name
          "BoardArea"
          (do
            ; (print "hit!" result)
            (self:judge_next_touch result.position))
          "OptionArea"
          (do
            (print "option area hit")
            (if (not self.option_view.visible) (do
              (self:option_area_enabled true)
              (set self.option_view.visible true))))
          "ToggleOptionArea"
          (do
            (print "toggle option area hit")
            (if self.option_view.visible (do
              (self:option_area_enabled false)
              (set self.option_view.visible false))))
          "ToggleAssistArea"
          (if self.option_view.visible
            (do
              (set self.show_assist (not self.show_assist))
              (print "assist" self.show_assist)
              (if self.show_assist
                (set self.toggle_assist_indicator.visible true)
                (set self.toggle_assist_indicator.visible false)))
              (self:clearAssists)
              (self:putAssists))
          "ToggleAnimationArea"
          (if self.option_view.visible
            (do
              (set self.b_animation (not self.b_animation))
              (if self.b_animation
                (set self.toggle_animation_indicator.visible true)
                (set self.toggle_animation_indicator.visible false))
              (print "animation" self.b_animation)))
          "ToggleScoreViewArea"
          (if self.option_view.visible
            (do
              (print "toggle score view")
              ; (print self.score_view)
              (if self.score_view.visible
                (do
                  (set self.toggle_score_indicator.visible false)
                  (set self.score_view.visible false))
                (do
                  (set self.toggle_score_indicator.visible true)
                  (set self.score_view.visible true)))))
          )))))

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