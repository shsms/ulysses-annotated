;;; fuzzy-search — fuzzy forward search as plain Emacs primitives.
;;; Shared by add-anno.tl and upd-epub-to-jp.tl.

;; Compile NEEDLE to a regex: case-insensitive, with leading/trailing whitespace
;; trimmed and each internal whitespace run matching any run of whitespace.
;; `split-string' (no separator) trims and splits on whitespace runs; a NEEDLE
;; with no words compiles to a never-matching regex, so an empty annotation lemma
;; is skipped rather than matched zero-width by an empty pattern.
(defun fuzzy-regex (needle)
  (let ((words (split-string needle)))
    (if words
        (concat "(?i)" (mapconcat (lambda (w) (regexp-quote w)) words "\\s+"))
      "[^\\s\\S]")))

;; Fuzzy forward search: returns the match start (point moves past it), nil on a
;; miss; an optional BOUND limits the search like re-search-forward's.
(defun find-fuzzy (s &optional bound)
  (and (re-search-forward (fuzzy-regex s) bound t) (match-beginning)))
