(local Assist 
  {:extends Node3D
   :class_name "Assist"})

(fn Assist._ready [self]
  ;(print "Assist ready")
  (set self.placed false))

(fn Assist._process [self delta]
  (if (not self.placed)
    (do
      (set self.placed true)
    ;   (self:on_init) ;WORKAROUND
    ))
    )

(fn Assist.is_placed [self]
  ; WORKAROUND
  (not (not self.placed)))

Assist