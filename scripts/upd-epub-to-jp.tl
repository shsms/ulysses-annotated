;; Port of upd-epub-to-jp.mime — apply the Joyce-Project text reconciliations.
;; Run: mime run --local upd-epub-to-jp.tl --file INFILE --outfile OUTFILE
(load "/vagrant/ulysses-annotated/scripts/jp-diffs.tl")   ; defines `items`

(defun update (from to)
  ;; mime's find_fuzzy searches forward from point (diffs are in document order).
  (if (search-fuzzy from nil t)
      (progn (replace-match to) t)
    (message (concat "failed: " from))
    nil))

(let ((misses 0))
  (dolist (i items)
    (if (update (car i) (cdr i)) nil (setq misses (1+ misses))))
  (report "applied" (- (length items) misses))
  (report "misses" misses)
  (if (= misses 0) (write-file (arg "outfile"))
    (message "some diffs failed; not writing output")))
