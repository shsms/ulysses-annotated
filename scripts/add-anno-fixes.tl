;;; add-anno text-cleanup transforms — ports of join_repeated_links/italics,
;;; fix_basics, fix_cyclops, fix_ithaca, fix_mismatches from add-anno.mime.
;;; They edit the CURRENT buffer (the mime `b' param is dropped). Uses mime-compat.

;; Collapse two adjacent same-target links (matched fuzzily by PATTERN) into one,
;; replacing the join with TO-PASTE, when both <a> point at the same href.
;; The href equality test is exact here. The original add-anno.mime relied on a
;; ChaiScript string `==` that mis-compared ~14 distinct-href pairs per run as
;; equal, spuriously merging unrelated notes; this port compares correctly, so
;; its output differs from the legacy mime only at those (mime-erroneous) spots.
(defun join_repeated_links (pattern to-paste)
  (start_of_buffer)
  (let ((rep-pos (find_fuzzy pattern)))
    (while rep-pos
      (goto_pos (rfind "href=\""))
      (set_mark)
      (goto_pos (find "\""))
      (let ((url-left (copy)))
        (goto_pos rep-pos)
        (find "href=\"")
        (set_mark)
        (goto_pos (find "\""))
        (let ((url-right (copy)))
          (when (string= url-left url-right)
            (goto_pos rep-pos)
            (set_mark)
            (find "<a")
            (find ">")
            (erase_region)
            (paste to-paste))))
      (setq rep-pos (find_fuzzy pattern)))))

;; Merge "</i> <i>" runs (point lands past the match, so mark=end, rep-pos=start).
(defun join_repeated_italics ()
  (start_of_buffer)
  (let ((rep-pos (find_fuzzy "</i> <i>")))
    (while rep-pos
      (set_mark)
      (goto_pos rep-pos)
      (erase_region)
      (paste " ")
      (setq rep-pos (find_fuzzy "</i> <i>")))))

;; First-stage cleanup: normalise the characters the Joyce-Project API encodes
;; differently from the Gutenberg base, drop <br/> noise, and strip page spans.
;; All replacements run from main-pos (just past the chapter's opening tag).
(defun fix_basics ()
  (find "<p class=\"newchapter\">")
  (let ((main-pos (get_pos)))
    (goto_pos main-pos) (replace "em>"     "i>")
    (goto_pos main-pos) (replace "&#x27;"  "’")
    (goto_pos main-pos) (replace "&#39;"   "’")
    (goto_pos main-pos) (replace "&quot;"  "\"")
    (goto_pos main-pos) (replace "&#34;"   "\"")
    (goto_pos main-pos) (replace "— "      "&mdash;")
    (goto_pos main-pos) (replace "—"       "&mdash;")
    (goto_pos main-pos) (replace "–"       "&#8211;")
    (goto_pos main-pos) (replace "'"       "’")
    (goto_pos main-pos) (replace " <br />" "")
    (goto_pos main-pos) (replace "<br/>"   "")
    (goto_pos main-pos) (replace "<br />"  " ")
    (goto_pos main-pos) (replace " </i>"   "</i>")
    (goto_pos main-pos) (replace "</i>!"   "!</i>")
    (goto_pos main-pos) (replace "em>"     "i>")
    (goto_pos main-pos) (replace "<a/>"    "</a>")
    (goto_pos main-pos) (replace "</a<"    "</a>")
    (goto_pos main-pos) (replace "</i>\n<i>"  "\n")
    (goto_pos main-pos) (replace "</i> \n<i>" "\n")
    (goto_pos main-pos) (replace "&nbsp;"  "")
    (goto_pos main-pos) (replace "&#8212;" "&mdash;")
    (goto_pos main-pos) (replace "&ntilde;" "ñ")
    (goto_pos main-pos) (replace "&dagger;" "†")
    (goto_pos main-pos) (replace "&agrave;" "à")
    (goto_pos main-pos) (replace "&aacute;" "á")
    (goto_pos main-pos) (replace "ā"        "&#257;")
    (goto_pos main-pos) (replace "&ecirc;"  "ê")
    (goto_pos main-pos) (replace "&eacute;" "é")
    (goto_pos main-pos) (replace "&Eacute;" "É")
    (goto_pos main-pos) (replace "&egrave;" "è")
    (goto_pos main-pos) (replace "&oelig;"  "œ")
    (goto_pos main-pos) (replace "&ugrave;" "ù")
    (goto_pos main-pos) (replace "&uuml;"   "ü")
    (goto_pos main-pos)
    (while (find "<span class=\"page\" ")
      (rfind "<span class=\"page\" ")
      (set_mark)
      (find "</span>")
      (erase_region))))

;; Cyclops: the API splits a word across two adjacent same-note links; rejoin
;; each into one correctly-spelled link so it matches the base.
(defun fix_cyclops ()
  (replace "Give you g</a><a href=\"notes/LH_wVp4BqcWimr1oKTys.htm\" data-color=\"F59627\">ood den" "Give you good den")
  (replace "a lusty t</a><a href=\"notes/LH_wVp4BqcWimr1oKTys.htm\" data-color=\"F59627\">rencherman" "a lusty trencherman"))

;; Ithaca: the prayer is two same-note links split by a <br/>; merge into one
;; link matching the base, so the whole prayer takes a single note marker.
(defun fix_ithaca ()
  (replace "<a href=\"notes/bE-bJZUBeQi-aLQfd7Cb.htm\" data-color=\"AB59C2\"><i>Liliata rutilantium. Turma circumdet.</i> </a><i><a href=\"notes/bE-bJZUBeQi-aLQfd7Cb.htm\" data-color=\"AB59C2\">Iubilantium te virginum. Chorus excipiat.</a></i>"
           "<a href=\"notes/bE-bJZUBeQi-aLQfd7Cb.htm\" data-color=\"AB59C2\"><i>Liliata rutilantium. Turma circumdet. Iubilantium te virginum. Chorus excipiat.</i></a>"))

;; Per-chapter fixups: basics, the "[ N ]" chapter badge, chapter-specific joins,
;; then the generic link/italic joins.
(defun fix_mismatches (chapter)
  (fix_basics)
  (start_of_buffer)
  (let ((ch-num (to_string (1+ chapter))))
    (replace (concat "<font size=\"+2\">[" ch-num "]</font>") (concat "[ " ch-num " ]") 1)
    (cond ((= chapter 11) (fix_cyclops))
          ((= chapter 16) (fix_ithaca)))
    (join_repeated_links "</a> <a" " ")
    (join_repeated_links "</a><a" " ")
    (join_repeated_italics)
    (start_of_buffer)))
