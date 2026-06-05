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

;; Remember the empty primary buffer: the run ends back on it so the CLI's
;; closing diff is empty instead of dumping the whole reconciled document.
(setq *home-buffer* (current-buffer))

;; Visit the input as the current buffer; the reconciliations below run on it.
(find-file (arg "infile"))

;; On a failed run the CLI emits only the error string (reports and the message
;; log are dropped), so the error itself must carry the diagnostics.
(let ((misses 0) (first-miss nil))
  (dolist (i items)
    (if (update (car i) (cdr i)) nil
      (setq misses (1+ misses))
      (when (not first-miss) (setq first-miss (car i)))))
  (report "applied" (- (length items) misses))
  (report "misses" misses)
  (if (= misses 0) (write-file (arg "outfile"))
    (error (concat (number-to-string misses) " of " (number-to-string (length items))
                   " reconciliations did not match the base (first: \"" first-miss
                   "\"); output not written"))))

(set-buffer *home-buffer*)
