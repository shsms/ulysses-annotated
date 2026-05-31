;;; add-anno structure/reorder transforms — ports of the same-named functions in
;;; add-anno.mime. They edit the CURRENT buffer (mime's buffer param is dropped;
;;; the caller sets the buffer/cursor). Uses mime-compat (find/cut/paste/…).

(defun lotus_reorder ()
  (find "saint Peter Claver and the African Mission.")
  (set_mark)
  (find "religion.")
  (let ((passage (cut)))
    (find "Rank heresy for them. ")
    (paste passage))
  (start_of_buffer))

(defun aeolus_reorder ()
  (find "Hell of a racket they make.")
  (set_mark)
  (find "Iron nerves.")
  (let ((passage (cut)))
    (rfind "He wants it in for July")
    (find "</p>")
    (paste (concat "<p>" passage "</p>")))
  (start_of_buffer))

(defun penelope_reorder ()
  (find "they hide it with a cabbageleaf")
  (set_mark)
  (find "kick or a bang of something there")
  (let ((passage (cut)))
    (find "go about like that I asked him")
    (paste passage))
  (start_of_buffer))

(defun fix_chapter_anchors ()
  ;; move each "<a ...>H2 anchor</a>" inside the following </h2>.
  (start_of_buffer)
  (while (find "H2 anchor")
    (find "</a>")
    (set_mark)
    (rfind "<a")
    (let ((anchor (cut)))
      (find "</h2>")
      (paste anchor)))
  (start_of_buffer))
