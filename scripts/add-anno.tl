;;; add-anno.tl — port of add-anno.mime: build the annotated Ulysses EPUB source
;;; from the Gutenberg base + the Joyce-Project annotation dump. Trusted tier:
;;;
;;;   mime run --local add-anno.tl --infile IN --outfile OUT \
;;;       --colour_outfile COUT --anno_path DIR --date DATE \
;;;       --templates_path DIR [--with_badges 1]
;;;
;;; Modules are loaded by absolute path so the cwd does not matter.

(load "/vagrant/ulysses-annotated/scripts/mime-compat.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-globals.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-fixes.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-structure.tl")
(load "/vagrant/ulysses-annotated/scripts/add-anno-notes.tl")

;; A buffer to return to when killing each run's epub buffer (mime-rs forbids
;; killing the current buffer).
(setq *home-buffer* (current-buffer))

(defun make_epub (use-colours outfile)
  (setq *cursor* nil)
  (setq basepath (arg "anno_path"))
  ;; Quire-backed (find-file) so the thousands of mid-document noteref inserts
  ;; into the growing ~38MB result stay O(log n); killed at the end so the next
  ;; run re-reads the infile fresh rather than reusing this modified buffer.
  (let ((epub (find-file (arg "infile"))))
    (goto-char (point-min))
    (let ((main-cur (new_cursor))
          (notes-cur (new_cursor))
          (index-cur (new_cursor))
          (stats (list nil))
          (notes-box (list nil)))
      (use_cursor main-cur)
      (add_epub_namespace)
      (update_css)
      (if use-colours
          (replace_first_page (concat templates-path "firstpage-colour.htm") (arg "date"))
        (replace_first_page (concat templates-path "firstpage-monochrome.htm") (arg "date")))
      (update_author_formatting)
      (update_toc)
      (insert_preface)
      (let ((end-pos (prepare_notes_cursor notes-cur)))
        (prepare_main_cursor main-cur end-pos))
      (lotus-reorder)
      (aeolus-reorder)
      (penelope-reorder)
      (fix-chapter-anchors)
      (add_notes epub main-cur notes-cur use-colours notes-box stats)
      (use_cursor notes-cur)
      (let ((notes-cur-pos (get_pos)))
        (use_cursor index-cur)
        (goto_pos notes-cur-pos))
      (add_notes_index epub notes-box index-cur notes-cur stats)
      (set-buffer epub)
      (widen)
      (write-file outfile)
      (set-buffer *home-buffer*)
      (kill-buffer epub)
      stats)))

(defun badge_json (key value colour)
  (concat "{\n  \"schemaVersion\": 1,\n  \"label\": \"" key
          "\",\n  \"message\": \"" (to_string value)
          "\",\n  \"color\": \"" colour "\"\n}\n"))

(defun make_badges (stats)
  (let ((buf (generate-new-buffer "badge")) (colour "green"))
    (set-buffer buf)
    (when (<= (stat-get stats "total") 0) (setq colour "red"))
    (paste (badge_json "total references" (stat-get stats "total") colour))
    (write-file "badge-total.json")

    (setq colour "green")
    (let ((found (stat-get stats "found")) (total (stat-get stats "total")))
      (cond ((<= found 0) (setq colour "red"))
            ((< found total) (setq colour "orange"))))
    (erase-buffer)
    (paste (badge_json "matched references" (stat-get stats "found") colour))
    (write-file "badge-found.json")

    (erase-buffer)
    (setq colour "green")
    (when (> (stat-get stats "not_found") 0) (setq colour "red"))
    (paste (badge_json "unmatched references" (stat-get stats "not_found") colour))
    (write-file "badge-not-found.json")

    (erase-buffer)
    (setq colour "green")
    (when (> (stat-get stats "broken_links") 0) (setq colour "red"))
    (paste (badge_json "broken links" (stat-get stats "broken_links") colour))
    (write-file "badge-broken-links.json")

    (erase-buffer)
    (setq colour "green")
    (when (<= (stat-get stats "distinct_notes") 0) (setq colour "red"))
    (paste (badge_json "distinct notes" (stat-get stats "distinct_notes") colour))
    (write-file "badge-distinct.json")))

(defun main ()
  (when (arg "templates_path") (setq templates-path (arg "templates_path")))
  (make_epub nil (arg "outfile"))
  (let ((stats (make_epub t (arg "colour_outfile"))))
    (when (arg "with_badges") (make_badges stats))))

(main)
