;;; mime-compat — the shsms `mime` (ChaiScript) buffer API expressed as mime-rs
;;; helpers, so the ported scripts read like the originals. Trusted tier (some
;;; helpers open files). `load` this before the ported script body.

;; ---- search / region / edit -------------------------------------------------
;; mime's find/find_fuzzy return the match START (often used as a position) and
;; leave point PAST the match; rfind returns the start with point AT it. We
;; normalise to that here (match-beginning + point), so `goto_pos(find(...))'
;; ports faithfully. All return nil on a miss.
(defun find (s)        (and (search-forward  s nil t) (match-beginning)))
(defun find_fuzzy (s)  (and (search-fuzzy    s nil t) (match-beginning)))
(defun rfind (s)       (and (search-backward s nil t) (point)))
(defun replace (from to &optional n)
  "Literal replace of FROM by TO from point; with N non-nil, only the first."
  (if n
      (when (search-forward from nil t) (replace-match to))
    (replace-string from to)))
(defun set_mark ()     (set-mark (point)))
(defun get_pos ()      (point))
(defun goto_pos (n)    (goto-char n))
(defun forward (n)     (forward-char n))
(defun start_of_buffer () (goto-char (point-min)))
(defun end_of_buffer ()   (goto-char (point-max)))
(defun paste (s)       (insert s))
(defun copy ()         (buffer-substring (region-beginning) (region-end)))
(defun erase_region () (delete-region (region-beginning) (region-end)))
(defun cut ()          (let ((s (copy))) (erase-region) s))
(defun to_string (n)   (number-to-string n))

;; ---- cursors: independent (point + narrowing) states over ONE buffer --------
;; A cursor is (MARKER . NARROW) where NARROW is nil (widened) or (LO . HI).
;; `use_cursor' saves the active cursor's point and restores the target's point
;; and restriction — emulating mime's multiple cursors.
(setq *cursor* nil)

(defun new_cursor ()
  (cons (point-marker) nil))

(defun use_cursor (c)
  (when *cursor*
    (set-marker (car *cursor*) (point))                 ; save where we were
    ;; a narrowed cursor's bounds may have grown from its own edits; refresh them
    ;; from the live restriction so they are not stale when we come back.
    (when (cdr *cursor*) (setcdr *cursor* (cons (point-min) (point-max)))))
  (setq *cursor* c)
  (widen)
  (when (cdr c) (narrow-to-region (car (cdr c)) (cdr (cdr c))))
  (goto-char (marker-position (car c))))

;; mime's narrow_to_region() narrows to mark..point AND remembers it on the
;; active cursor (so use_cursor restores it); widen clears it.
(defun narrow_to_region ()
  (let ((lo (region-beginning)) (hi (region-end)))
    (narrow-to-region lo hi)
    (when *cursor* (setcdr *cursor* (cons lo hi)))))

(defun cur-widen ()
  (widen)
  (when *cursor* (setcdr *cursor* nil)))
