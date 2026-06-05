;;; add-anno.tl — build the annotated Ulysses EPUB source
;;; from the Gutenberg base + the Joyce-Project annotation dump. Trusted tier:
;;;
;;;   mime run add-anno.tl --infile IN --outfile OUT \
;;;       --colour_outfile COUT --anno_path DIR --date DATE \
;;;       [--templates_path DIR] [--max_unmatched_pct N] [--max_broken_pct N] [--with_badges 1]
;;;
;;; Run from this directory: modules and templates load by relative path.

(load "fuzzy-search.tl")
(load "add-anno-globals.tl")
(load "add-anno-fixes.tl")
(load "add-anno-structure.tl")
(load "add-anno-notes.tl")

;; A buffer to return to when killing each run's epub buffer (mime-rs forbids
;; killing the current buffer).
(setq *home-buffer* (current-buffer))

(defun make_epub (use-colours outfile)
  (setq basepath (arg "anno_path"))
  ;; Quire-backed (find-file) so the thousands of mid-document noteref inserts
  ;; into the growing ~38MB result stay O(log n); killed at the end so the next
  ;; run re-reads the infile fresh rather than reusing this modified buffer.
  (let ((epub (find-file (arg "infile"))))
    (goto-char (point-min))
    ;; three independent edit positions in the one epub buffer: the base text
    ;; (where noterefs go), the Annotations section, and the Index section.
    (let ((main-mark (point-marker))
          (notes-mark (point-marker))
          (index-mark (point-marker))
          (stats (list nil))
          (notes-box (list nil)))
      (add-epub-namespace)
      (update-css)
      (if use-colours
          (replace-first-page (concat templates-path "firstpage-colour.htm") (arg "date"))
        (replace-first-page (concat templates-path "firstpage-monochrome.htm") (arg "date")))
      (update-author-formatting)
      (update-toc)
      (insert-preface)
      ;; bound the reorders + anchor fixer to the book body: the front matter and
      ;; the freshly-built Annotations section must stay untouched.
      (let ((body-start (point))
            (end-pos (prepare-notes-section notes-mark)))
        (narrow-to-region body-start end-pos)
        (goto-char (point-min))
        (lotus-reorder)
        (aeolus-reorder)
        (penelope-reorder)
        (fix-chapter-anchors)
        (widen))
      (add-notes epub main-mark notes-mark use-colours notes-box stats)
      ;; the Index section begins where the Annotations section now ends
      (set-marker index-mark (marker-position notes-mark))
      (add-notes-index epub notes-box index-mark notes-mark stats)
      (widen)
      (write-file outfile)
      (set-buffer *home-buffer*)
      (kill-buffer epub)
      stats)))

(defun badge_json (key value colour)
  (concat "{\n  \"schemaVersion\": 1,\n  \"label\": \"" key
          "\",\n  \"message\": \"" (number-to-string value)
          "\",\n  \"color\": \"" colour "\"\n}\n"))

(defun make_badges (stats)
  (let ((buf (generate-new-buffer "badge")) (colour "green"))
    (with-current-buffer buf
      (when (<= (stat-get stats "total") 0) (setq colour "red"))
      (insert (badge_json "total references" (stat-get stats "total") colour))
      (write-file "badge-total.json")

      (setq colour "green")
      (let ((found (stat-get stats "found")) (total (stat-get stats "total")))
        (cond ((<= found 0) (setq colour "red"))
              ((< found total) (setq colour "orange"))))
      (erase-buffer)
      (insert (badge_json "matched references" (stat-get stats "found") colour))
      (write-file "badge-found.json")

      (erase-buffer)
      (setq colour "green")
      (when (> (stat-get stats "not_found") 0) (setq colour "red"))
      (insert (badge_json "unmatched references" (stat-get stats "not_found") colour))
      (write-file "badge-not-found.json")

      (erase-buffer)
      (setq colour "green")
      (when (> (stat-get stats "broken_links") 0) (setq colour "red"))
      (insert (badge_json "broken links" (stat-get stats "broken_links") colour))
      (write-file "badge-broken-links.json")

      (erase-buffer)
      (setq colour "green")
      (when (<= (stat-get stats "distinct_notes") 0) (setq colour "red"))
      (insert (badge_json "distinct notes" (stat-get stats "distinct_notes") colour))
      (write-file "badge-distinct.json"))))

;; Error out if STATS' STAT-KEY count exceeds the --PCT-ARG percentage of the
;; total references (defaulting to DEFAULT-PCT when the arg is absent).
(defun check-pct (stats stat-key label pct-arg default-pct)
  (let* ((total (stat-get stats "total"))
         (count (stat-get stats stat-key))
         (max-pct (if (arg pct-arg) (string-to-number (arg pct-arg)) default-pct)))
    (when (and (> total 0) (> (* 100 count) (* max-pct total)))
      (error (concat "too many " label ": " (number-to-string count) "/"
                     (number-to-string total) " exceeds " (number-to-string max-pct) "%")))))

;; Fail the build when no references were processed at all, or when too many
;; went unmatched or had a broken note. Each ceiling defaults to 10% of the
;; total; override with --max_unmatched_pct / --max_broken_pct.
(defun check-thresholds (stats)
  (let ((total (stat-get stats "total")))
    (when (or (not total) (= total 0))
      (error "no annotation references were processed; output is unannotated")))
  (check-pct stats "not_found" "unmatched references" "max_unmatched_pct" 10)
  (check-pct stats "broken_links" "broken links" "max_broken_pct" 10))

(defun main ()
  (when (arg "templates_path") (setq templates-path (arg "templates_path")))
  (make_epub nil (arg "outfile"))
  (let ((stats (make_epub t (arg "colour_outfile"))))
    (when (arg "with_badges") (make_badges stats))
    (check-thresholds stats)))

(main)
