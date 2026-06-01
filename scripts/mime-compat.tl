;;; mime-compat — the shsms `mime` (ChaiScript) buffer API expressed as mime-rs
;;; helpers, so the ported scripts read like the originals. Trusted tier (some
;;; helpers open files). `load` this before the ported script body.

;; ---- search / region / edit -------------------------------------------------
;; mime's find/find_fuzzy return the match START (often used as a position) and
;; leave point PAST the match; rfind returns the start with point AT it. We
;; normalise to that here (match-beginning + point), so `goto_pos(find(...))'
;; ports faithfully. All return nil on a miss.
(defun find (s)        (and (search-forward  s nil t) (match-beginning)))
(defun find_re (r)     (and (re-search-forward r nil t) (match-beginning)))  ; mime's find(regex(R))
;; mime's rfind RETURNS the match END but leaves POINT at the match start: the
;; join uses the return value (goto_pos(rfind ...) -> URL start), while
;; cut/find-after-rfind use point (the match start). search-backward lands at
;; the start, so return start+(length s) without moving point.
(defun rfind (s)       (and (search-backward s nil t) (+ (point) (length s))))

;; mime's find_fuzzy compiles the needle to a regex: case-insensitive, leading/
;; trailing whitespace trimmed, and each internal run of whitespace matching any
;; run of whitespace. `split-string' (no separator) trims and splits on
;; whitespace runs; quote each word and rejoin with \s+.
(defun fuzzy-regex (needle)
  (concat "(?i)" (mapconcat (lambda (w) (regexp-quote w)) (split-string needle) "\\s+")))
(defun find_fuzzy (s &optional bound)
  (and (re-search-forward (fuzzy-regex s) bound t) (match-beginning)))
(defun replace (from to &optional n)
  "Literal replace of FROM by TO from point; with N, at most N occurrences."
  (if n
      (let ((i 0))
        (while (and (< i n) (search-forward from nil t))
          (replace-match to)
          (setq i (1+ i))))
    (replace-string from to)))
(defun get_contents () (buffer-substring (point-min) (point-max)))  ; mime's get_contents()
(defun set_mark ()     (set-mark (point)))
(defun get_pos ()      (point))
(defun goto_pos (n)    (goto-char n))
(defun forward (&optional n)  (forward-char (or n 1)))
(defun backward (&optional n) (forward-char (- (or n 1))))
(defun next_line ()    (forward-line 1))
(defun start_of_buffer () (goto-char (point-min)))
(defun end_of_buffer ()   (goto-char (point-max)))
(defun paste (s)       (insert s))
(defun copy ()         (buffer-substring (region-beginning) (region-end)))
(defun erase_region () (delete-region (region-beginning) (region-end)))
(defun cut ()          (let ((s (copy))) (erase_region) s))
(defun to_string (n)   (number-to-string n))

;; ---- cursors: independent (point + narrowing) states, possibly in different
;; buffers -------------------------------------------------------------------
;; A cursor is (MARKER NARROW BUFNAME): a saved point, a restriction (nil =
;; widened, or (LO . HI)), and the buffer it lives in. `use_cursor' saves the
;; active cursor and restores the target's buffer, point, and restriction —
;; emulating mime's multiple cursors.
(setq *cursor* nil)

(defun new_cursor () (list (point-marker) nil (current-buffer)))

(defun use_cursor (c)
  (when *cursor*
    ;; Save from the active cursor's OWN buffer: the caller may have set-buffer'd
    ;; to an unrelated buffer (e.g. a chapter source) while this cursor stayed
    ;; active, and (point)/(point-min) there would corrupt the saved state.
    (set-buffer (car (cdr (cdr *cursor*))))
    (set-marker (car *cursor*) (point))
    ;; a narrowed cursor's bounds may have grown from its own edits; refresh them
    ;; from the live restriction so they are not stale when we come back.
    (when (car (cdr *cursor*))
      (setcar (cdr *cursor*) (cons (point-min) (point-max)))))
  (setq *cursor* c)
  (set-buffer (car (cdr (cdr c))))                      ; the cursor's buffer
  (widen)
  (let ((nw (car (cdr c))))
    (when nw (narrow-to-region (car nw) (cdr nw))))
  (goto-char (marker-position (car c))))

;; mime's narrow_to_region() narrows to mark..point AND remembers it on the
;; active cursor (so use_cursor restores it).
(defun narrow_to_region ()
  (let ((lo (region-beginning)) (hi (region-end)))
    (narrow-to-region lo hi)
    (when *cursor* (setcar (cdr *cursor*) (cons lo hi)))))

;; plain narrow for non-cursor buffers (chapter/note buffers), leaving the
;; active epub cursor's remembered restriction untouched.
(defun narrow_here () (narrow-to-region (region-beginning) (region-end)))
