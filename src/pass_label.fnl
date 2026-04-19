(local PassLabel 
  {:extends Node3D
   :class_name "PassLabel"})

(var show_time_left 0)

(fn PassLabel._ready [self]
  ;(print "PassLabel ready")
  (set self.placed false))

(fn PassLabel._process [self delta]
  (if self.placed
    (do
      (if (> show_time_left 0) (do
        (set show_time_left (- show_time_left delta))
        (if (< show_time_left 0) (do
          (set show_time_left 0)
          (set self.visible false)))))
    ))

  (if (not self.placed)
    (do
      (set self.placed true)
    ;   (self:on_init) ;WORKAROUND
    ))
    )

(fn PassLabel.is_placed [self]
  ; WORKAROUND
  (not (not self.placed)))

(fn PassLabel.show [self]
  (set self.visible true)
  (set show_time_left 1))

PassLabel