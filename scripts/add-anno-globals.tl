;;; add-anno globals — chapter file suffixes, names, and shared constants.
;;; `basepath' is set from the --anno_path argument in add-anno.tl.

(setq basepath "")

;; Directory holding the templates (preface.htm, firstpage-*.htm); set in main.
;; Empty means cwd-relative, matching mime's bare buffer("preface.htm").
(setq templates-path "")

(setq chapters (list
  "/index.php-telem.htm"   "/index.php-nestor.htm"  "/index.php-proteus.htm"
  "/index.php-calypso.htm" "/index.php-lotus.htm"   "/index.php-hades.htm"
  "/index.php-aeolus.htm"  "/index.php-lestry.htm"  "/index.php-scylla.htm"
  "/index.php-wrocks.htm"  "/index.php-sirens.htm"  "/index.php-cyclops.htm"
  "/index.php-nausicaa.htm" "/index.php-oxen.htm"   "/index.php-circe.htm"
  "/index.php-eumaeus.htm" "/index.php-ithaca.htm"  "/index.php-penelope.htm"))

(setq chapter-names (list
  "Telemachus" "Nestor" "Proteus" "Calypso" "Lotus Eaters" "Hades"
  "Aeolus" "Lestrygonians" "Scylla and Charybdis" "Wandering Rocks"
  "Sirens" "Cyclops" "Nausicaa" "Oxen of the Sun" "Circe"
  "Eumaeus" "Ithaca" "Penelope"))

(setq pagebreak "<p class=\"pagebreak\"></p>")
