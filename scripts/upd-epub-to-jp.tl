;; Apply the Joyce-Project text reconciliations to the EPUB source.
;; Run from this directory: mime run upd-epub-to-jp.tl --infile INFILE --outfile OUTFILE
(load "fuzzy-search.tl")  ; find-fuzzy
(load "jp-diffs.tl")      ; defines `items`

(defun update (from to)
  ;; find-fuzzy searches forward from point (diffs are in document order) and
  ;; sets the match data, so replace-match rewrites exactly the matched span.
  (if (find-fuzzy from)
      (progn (replace-match to) t)
    (message (concat "failed: " from))
    nil))

;; Visit the input as the current buffer; the reconciliations below run on it.
(find-file (arg "infile"))

(let ((misses 0))
  (dolist (i items)
    (if (update (car i) (cdr i)) nil (setq misses (1+ misses))))
  (report "applied" (- (length items) misses))
  (report "misses" misses)
  (if (= misses 0) (write-file (arg "outfile"))
    (error "some diffs did not match the base; output not written")))
