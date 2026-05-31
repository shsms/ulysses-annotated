;; Port jp-diffs.mime (ChaiScript data) -> jp-diffs.tl (tulisp list of (FROM . TO)),
;; run through mime-rs itself:  mime run --local jp-diffs-to-tl.tl --file jp-diffs.mime
(goto-char (point-min)) (replace-string "//" ";;")
;; drop the `class diff {...};` definition block
(goto-char (point-min))
(if (search-forward "class diff {" nil t)
    (progn (beginning-of-line)
           (let ((s (point))) (search-forward "};" nil t) (delete-region s (point)))))
(goto-char (point-min)) (replace-string "var items = [" "(setq items (list")
;; each  diff( "FROM", "TO" ),  -> (cons "FROM" "TO")   (strings have no inner quotes)
(goto-char (point-min))
(replace-regexp "diff\\(\\s*\"([^\"]*)\"\\s*,\\s*\"([^\"]*)\"\\s*\\),?" "(cons \"\\1\" \"\\2\")")
;; the lone `]` closing line -> close (list and (setq
(goto-char (point-min)) (replace-regexp "(?m)^\\]$" "))")
(write-file "/vagrant/ulysses-annotated/scripts/jp-diffs.tl")
(goto-char (point-min)) (report "cons-entries" (count-matches "\\(cons "))
