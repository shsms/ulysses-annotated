;;; fuzzy-search — the original mime's find_fuzzy as plain Emacs primitives.
;;; Shared by add-anno.tl and upd-epub-to-jp.tl.

;; Compile NEEDLE to a regex: case-insensitive, with leading/trailing whitespace
;; trimmed and each internal whitespace run matching any run of whitespace.
;; `split-string' (no separator) trims and splits on whitespace runs.
(defun fuzzy-regex (needle)
  (concat "(?i)" (mapconcat (lambda (w) (regexp-quote w)) (split-string needle) "\\s+")))

;; Fuzzy forward search: returns the match start (point moves past it), nil on a
;; miss; an optional BOUND limits the search like re-search-forward's.
(defun find-fuzzy (s &optional bound)
  (and (re-search-forward (fuzzy-regex s) bound t) (match-beginning)))
