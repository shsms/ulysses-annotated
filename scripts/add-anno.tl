;;; add-anno.tl — port of add-anno.mime: build the annotated Ulysses EPUB source
;;; from the Gutenberg base + the Joyce-Project annotation dump. Trusted tier:
;;;
;;;   mime run --local add-anno.tl --infile IN --outfile OUT \
;;;       --colour_outfile COUT --anno_path DIR --date DATE \
;;;       --templates_path DIR [--with_badges 1]
;;;
;;; Modules are loaded by absolute path so the cwd does not matter.

(load "/vagrant/ulysses-annotated/scripts/fuzzy-search.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-globals.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-fixes.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-structure.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-notes.tl")

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

(defun main ()
  (when (arg "templates_path") (setq templates-path (arg "templates_path")))
  (make_epub nil (arg "outfile"))
  (let ((stats (make_epub t (arg "colour_outfile"))))
    (when (arg "with_badges") (make_badges stats))))

(main)
