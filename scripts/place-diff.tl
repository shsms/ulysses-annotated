;;; place-diff.tl — add a (FROM . TO) reconciliation to jp-diffs.tl in document
;;; order, or (without --to) just report the index where it would go.
;;;
;;; upd-epub-to-jp.tl applies the diffs in a single forward find-fuzzy pass with
;;; an advancing point, so we replicate that pass over the base: walk the existing
;;; diffs in order, advancing point as the apply loop does, and find the first
;;; existing diff at or after the new diff's place — the new diff goes just before
;;; it.  (A plain backward search can't stand in for find-fuzzy's matching, hence
;;; the forward simulation.)
;;;
;;;   mime run place-diff.tl --from "<base text>" \
;;;       [--to "<replacement>"] [--base ../4300-h/4300-h.htm] \
;;;       [--diffs jp-diffs.tl] </dev/null
;;;
;;; Run from this directory (loads fuzzy-search.tl and jp-diffs.tl by relative path).
(load "fuzzy-search.tl")  ; find-fuzzy
(load "jp-diffs.tl")      ; defines `items`

;; backslash-escape \ and " so a string can go in a tulisp double-quoted literal.
(defun escape-str (s)
  (string-replace "\"" "\\\"" (string-replace "\\" "\\\\" s)))

(let* ((home (current-buffer)) ; the empty primary buffer; end here for clean output
       (from (arg "from"))
       (to (arg "to"))
       (basefile (if (arg "base") (arg "base") "../4300-h/4300-h.htm"))
       (difffile (if (arg "diffs") (arg "diffs") "jp-diffs.tl")))
  (find-file basefile)
  (goto-char (point-min))
  (if (not (find-fuzzy from))
      (message "place not found (the --from text is not in the base)")
    ;; Forward simulation: find the first existing diff at or after `from`.
    (goto-char (point-min))
    (let ((idx (length items)) (k 0) (done nil))
      (dolist (item items)
        (when (not done)
          (let* ((at (point))
                 (new-pos (and (find-fuzzy from) (match-beginning 0))))
            (goto-char at)
            (let ((item-pos (and (find-fuzzy (car item)) (match-beginning 0))))
              (if (and new-pos item-pos (<= new-pos item-pos))
                  (progn (setq idx k) (setq done t))
                (progn
                  (when (not item-pos) (goto-char at))
                  (setq k (1+ k))))))))
      (if (not to)
          (report "insert-before" idx)
        ;; Insert the new diff before item idx (or append) in the diffs file.
        (let ((entry (concat "(cons \"" (escape-str from) "\" \"" (escape-str to) "\")")))
          (find-file difffile)
          (goto-char (point-min))
          (search-forward "(setq items (list")
          (if (>= idx (length items))
              (progn ; append after the last entry, before the closing ))
                (goto-char (point-max))
                (search-backward "))")
                (search-backward ")")
                (forward-char 1)
                (insert (concat "\n\n    " entry)))
            (progn ; insert before item idx's (cons
              (dotimes (_ (1+ idx)) (search-forward "(cons "))
              (search-backward "(cons ")
              (insert (concat entry "\n\n    "))))
          (write-file difffile)
          (report "inserted-before" idx)))))
  (set-buffer home))
