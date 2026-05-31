;;; add-anno text-cleanup transforms — join-repeated-links/italics, fix-basics,
;;; fix-cyclops, fix-ithaca, fix-mismatches. They edit the CURRENT buffer with
;;; plain Emacs primitives; `find_fuzzy' is a shared fuzzy-search helper.

;; Collapse two adjacent same-target links (matched fuzzily by PATTERN) into one,
;; replacing the join with TO-PASTE, when both <a> point at the same href.
;; The href equality test is exact here. The original add-anno.mime relied on a
;; ChaiScript string `==` that mis-compared ~14 distinct-href pairs per run as
;; equal, spuriously merging unrelated notes; this port compares correctly, so
;; its output differs from the legacy mime only at those (mime-erroneous) spots.
(defun join-repeated-links (pattern to-paste)
  (goto-char (point-min))
  (let ((rep-pos (find_fuzzy pattern)))
    (while rep-pos
      ;; href values of the links on either side of the fuzzy-matched boundary
      (search-backward "href=\"")
      (let* ((url-start (match-end 0))
             (url-left (progn (goto-char url-start) (search-forward "\"")
                              (buffer-substring url-start (match-beginning 0))))
             (right-start (progn (goto-char rep-pos) (search-forward "href=\"") (point)))
             (url-right (progn (search-forward "\"")
                               (buffer-substring right-start (match-beginning 0)))))
        (when (string= url-left url-right)
          (goto-char rep-pos)
          (let ((start (point)))
            (search-forward "<a")
            (search-forward ">")
            (delete-region start (point))
            (insert to-paste))))
      (setq rep-pos (find_fuzzy pattern)))))

;; Merge "</i> <i>" runs (point lands past the match, so mark=end, rep-pos=start).
(defun join-repeated-italics ()
  (goto-char (point-min))
  (let ((rep-pos (find_fuzzy "</i> <i>")))
    (while rep-pos
      (delete-region rep-pos (point))
      (insert " ")
      (setq rep-pos (find_fuzzy "</i> <i>")))))

;; First-stage cleanup: normalise the characters the Joyce-Project API encodes
;; differently from the Gutenberg base, drop <br/> noise, and strip page spans.
;; All replacements run from main-pos (just past the chapter's opening tag).
(defun fix-basics ()
  (search-forward "<p class=\"newchapter\">")
  (let ((main-pos (point)))
    (goto-char main-pos) (replace-string "em>"     "i>")
    (goto-char main-pos) (replace-string "&#x27;"  "’")
    (goto-char main-pos) (replace-string "&#39;"   "’")
    (goto-char main-pos) (replace-string "&quot;"  "\"")
    (goto-char main-pos) (replace-string "&#34;"   "\"")
    (goto-char main-pos) (replace-string "— "      "&mdash;")
    (goto-char main-pos) (replace-string "—"       "&mdash;")
    (goto-char main-pos) (replace-string "–"       "&#8211;")
    (goto-char main-pos) (replace-string "'"       "’")
    (goto-char main-pos) (replace-string " <br />" "")
    (goto-char main-pos) (replace-string "<br/>"   "")
    (goto-char main-pos) (replace-string "<br />"  " ")
    (goto-char main-pos) (replace-string " </i>"   "</i>")
    (goto-char main-pos) (replace-string "</i>!"   "!</i>")
    (goto-char main-pos) (replace-string "em>"     "i>")
    (goto-char main-pos) (replace-string "<a/>"    "</a>")
    (goto-char main-pos) (replace-string "</a<"    "</a>")
    (goto-char main-pos) (replace-string "</i>\n<i>"  "\n")
    (goto-char main-pos) (replace-string "</i> \n<i>" "\n")
    (goto-char main-pos) (replace-string "&nbsp;"  "")
    (goto-char main-pos) (replace-string "&#8212;" "&mdash;")
    (goto-char main-pos) (replace-string "&ntilde;" "ñ")
    (goto-char main-pos) (replace-string "&dagger;" "†")
    (goto-char main-pos) (replace-string "&agrave;" "à")
    (goto-char main-pos) (replace-string "&aacute;" "á")
    (goto-char main-pos) (replace-string "ā"        "&#257;")
    (goto-char main-pos) (replace-string "&ecirc;"  "ê")
    (goto-char main-pos) (replace-string "&eacute;" "é")
    (goto-char main-pos) (replace-string "&Eacute;" "É")
    (goto-char main-pos) (replace-string "&egrave;" "è")
    (goto-char main-pos) (replace-string "&oelig;"  "œ")
    (goto-char main-pos) (replace-string "&ugrave;" "ù")
    (goto-char main-pos) (replace-string "&uuml;"   "ü")
    (goto-char main-pos)
    (while (search-forward "<span class=\"page\" " nil t)
      (search-backward "<span class=\"page\" ")
      (let ((start (point)))
        (search-forward "</span>")
        (delete-region start (point))))))

;; Cyclops: the API splits a word across two adjacent same-note links; rejoin
;; each into one correctly-spelled link so it matches the base.
(defun fix-cyclops ()
  (replace-string "Give you g</a><a href=\"notes/LH_wVp4BqcWimr1oKTys.htm\" data-color=\"F59627\">ood den" "Give you good den")
  (replace-string "a lusty t</a><a href=\"notes/LH_wVp4BqcWimr1oKTys.htm\" data-color=\"F59627\">rencherman" "a lusty trencherman"))

;; Ithaca: the prayer is two same-note links split by a <br/>; merge into one
;; link matching the base, so the whole prayer takes a single note marker.
(defun fix-ithaca ()
  (replace-string "<a href=\"notes/bE-bJZUBeQi-aLQfd7Cb.htm\" data-color=\"AB59C2\"><i>Liliata rutilantium. Turma circumdet.</i> </a><i><a href=\"notes/bE-bJZUBeQi-aLQfd7Cb.htm\" data-color=\"AB59C2\">Iubilantium te virginum. Chorus excipiat.</a></i>"
           "<a href=\"notes/bE-bJZUBeQi-aLQfd7Cb.htm\" data-color=\"AB59C2\"><i>Liliata rutilantium. Turma circumdet. Iubilantium te virginum. Chorus excipiat.</i></a>"))

;; Per-chapter fixups: basics, the "[ N ]" chapter badge, chapter-specific joins,
;; then the generic link/italic joins.
(defun fix-mismatches (chapter)
  (fix-basics)
  (goto-char (point-min))
  (let ((ch-num (number-to-string (1+ chapter))))
    (when (search-forward (concat "<font size=\"+2\">[" ch-num "]</font>") nil t)
      (replace-match (concat "[ " ch-num " ]")))
    (cond ((= chapter 11) (fix-cyclops))
          ((= chapter 16) (fix-ithaca)))
    (join-repeated-links "</a> <a" " ")
    (join-repeated-links "</a><a" " ")
    (join-repeated-italics)
    (goto-char (point-min))))
