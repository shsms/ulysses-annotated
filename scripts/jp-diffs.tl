;; Gutenberg-base -> Joyce Project text reconciliations, applied in order by
;; upd-epub-to-jp.tl.  Use place-diff.tl to find where a new diff belongs.



(setq items (list
    ;; telem
    (cons "Kinch, the knife-blade" "Kinch, the knifeblade")

    (cons "his grey searching eyes" "his great searching eyes")

    (cons "Dottyville with Connolly Norman" "Dottyville with Conolly Norman")

    (cons "featherfans" "feather fans")

    (cons "No, mother!" "No, mother.")

    (cons "briskly to and fro about the hearth" "briskly about the hearth to and fro")

    (cons "three quarts is a shilling. That’s a shilling and one and two is two and two" "three quarts is a shilling and one and two is two and two")

    (cons "base into the sea,</i>" "base into the sea</i>,")

    (cons "I am a servant of two masters" "I am the servant of two masters")

    (cons "et apostolicam ecclesiam:</i>" "</i><i> et apostolicam ecclesiam</i>:")


    (cons "Übermensch." "Uebermensch.")

    ;; nestor
    (cons "tartan fillibegs" "tartan filibegs")

    (cons "lord Hastings’ <i>Repulse</i>, the duke of Westminster’s <i>Shotover</i>, the duke of Beaufort’s <i>Ceylon</i>" "lord Hastings’ Repulse, the duke of Westminster’s\nShotover, the duke of Beaufort’s Ceylon")

    (cons "amid the bawls of bookies on their pitches" "amid bawls of bookies on their pitches")

    (cons "money <i>Fair Rebel.</i> Ten to one the field" "money Fair Rebel: ten to one the field")

    (cons "Emperor’s horses at Mürzsteg" "Emperor’s horses at Murzsteg")

    (cons "<i>&mdash;The Evening Telegraph...</i>" "<i>The Evening Telegraph</i>...")

    ;; proteus
    (cons "Hello. Kinch here. Put me" "Hello! Kinch here. Put me")

    (cons "heresiarch! In a Greek watercloset he breathed his last: <i>euthanasia</i>.
With beaded mitre and with crozier, stalled upon his throne, widower of
a widowed see, with upstiffed <i>omophorion</i>" "heresiarch. In a Greek watercloset he breathed his last: euthanasia.
With beaded mitre and with crozier, stalled upon his throne, widower of
a widowed see, with upstiffed omophorion")

    (cons "Get down, baldpoll!" "Get down, bald poll!")

    (cons "Mother dying" "Nother dying")

    (cons "flan bréton" "flan breton")

    (cons "sétier!" "setier!")

    (cons "<i>Il est irlandais. Hollandais? Non fromage. Deux irlandais, nous,
      Irlande, vous savez ah, oui!</i>" "<i>Il est irlandais. Hollandais? Non fromage. Deux irlandais,
nous, Irlande, vous savez? Ah, oui!</i>")

    (cons "<i>The boys of Kilkenny are stout roaring blades</i>" "<i>The boys of Kilkenny are</i> stout roaring blades")

    (cons " ensablé</i> Louis" " ensablé</i>, Louis")

    (cons "safe mong the bulrushes" "safe among the bulrushes")

    (cons "he woke me last night" "he woke me up last night")

    ;; calypso
    (cons "three, four: right" "three, four : right")

    (cons "cuddling her in Eccles’ Lane" "cuddled her in Eccles lane")

    (cons "Citron still in Saint" "Citron still alive in Saint")

    (cons "Valuation is only twentyeight" "Valuation is only twenty-eight")

    (cons "metamspychosis" "metempsychosis")

    (cons "Everyone says I am quite the belle in my new tam." "Everyone says I’m quite the belle in my new tam.")

    (cons "XL Café" "XL Cafe")

    (cons "Funny I don’t" "Funny, I don’t")

    ;; lotus
    (cons "Girl in Eustace
      street hallway Monday was it settling her garter. Her friend covering the
      display of. <i>Esprit de corps</i>. Well, what are you gaping at?" "Girl in Eustace
street hallway Monday was it settling her garter. Her friend covering
the display of <i>esprit de corps</i>. Well, what are you gaping at?")

    (cons "Nathan’s voice! His son’s voice! I hear the voice of Nathan who left his
      father to die of grief and misery in my arms, who left the house of his
      father and left the God of his father." "&mdash;Nathan’s voice! His son’s voice! I hear the voice of Nathan who left his
father to die of grief and misery in my arms, who left the house of his
father and left the God of his father.")

    (cons "<i>O, Mairy lost the pin of her drawers.
     She didn’t know what to do
     To keep it up,
     To keep it up.</i>" " <i>O, Mairy lost the pin of her drawers. 
     She didn’t know what to do
     To keep it up
     To keep it up.</i>")

    (cons "John Conmee S. J. on saint Peter Claver S. J." "John Conmee S.J.
on saint Peter Claver")

    (cons "Prayers for the
      conversion of Gladstone they had too when he was almost unconscious. The
      protestants are the same. Convert Dr William J. Walsh D.D. to the true
      religion." "Prayers for the
conversion of Gladstone they had too when he was almost unconscious. The
protestants are the same. Convert Dr William J. Walsh D.D. to the true
religion.")

    (cons "They don’t seem to chew it: only swallow it
      down. Rum idea: eating bits of a corpse. Why the cannibals cotton to it." "They
don’t seem to chew it: only swallow it down. Rum idea: eating bits of a
corpse why the cannibals cotton to it.")

    (cons "Peter Carey, yes. No, Peter Claver" "Peter Carey. No, Peter Claver")

    (cons "Those old popes keen on
      music, on art and statues and pictures of all kinds. Palestrina for
      example too." "Those old popes were keen on music,
on art and statues and pictures of all kinds. Palestrina for example
too.")

    (cons "Still Captain Culler" "Still Captain Buller")

    ;; hades
    (cons "slammed it twice till it" "slammed it tight till it")

    (cons "Wallace Bros: the bottleworks: Dodder bridge." "Wallace Bros the\nbottleworks. Dodder bridge.")

    (cons "Secret eyes,
      secretsearching. Mason, I think: not sure." "Secret
eyes, secretsearching eyes. Mason, I think: not sure.")

    (cons "Wonder he had the gumption to propose to any girl." "Wonder how he had the gumption to propose to any girl.")

    (cons "<i>Church Times.</i>" "<i>Church Times</i>.")

    ;; aeolus
    (cons "<i>Weekly Freeman and National Press</i>" "<i>Weekly Freeman</i><i>\nand National Press</i>")

    (cons "<i>Co-ome thou lost one, Co-ome" "<i>Co-ome thou lost one,</i> Co-ome")

    (cons "mangiD kcirtaP." "mangiD. kcirtaP.")

    (cons "Who the deuce scrawled all over those" "Who the deuce scrawled all over these")

    (cons "A recently discovered fragment of Cicero, professor MacHugh
      answered with pomp of tone." "A recently discovered fragment of Cicero’s, professor MacHugh answered
with pomp of tone.")

    (cons "<i>Sport</i>’s tissues" "<i>Sport’s</i> tissues")

    (cons "Tay Pay who took him on to the <i>Star.</i>" "Tay Pay who took him on to the <i>Star</i>.")

    (cons "<i>........................ la tua pace .................. che parlar ti piace Mentre che il vento, come fa, si tace.</i>" "<i>. . . . . . . . . . . . . . . la tua pace
    . . . . . . . . . . . . che parlar ti piace
    . . . .mentreche il vento, come fa, si tace.</i>")

    (cons "oriafiamma</i>, gold of oriflamme, <i>di rimirar fè più ardenti.</i>" "oriafiamma</i>, in gold of oriflamme, <i>di rimirar fè più ardenti.</i>")

    (cons "only
      for .... But no matter." "only for... But no matter.")

    (cons "A&mdash;sudden&mdash;at&mdash;the&mdash;moment&mdash;though&mdash;from&mdash;lingering&mdash;illness&mdash;often&mdash;previously&mdash;expectorated&mdash;demise" "A sudden&#8211;at&#8211;the&#8211;moment&#8211;though&#8211;from&#8211;lingering&#8211;illness&#8211;often&#8211;previously&#8211;expectorated&#8211;demise")

    (cons "Face glistering tallow under her fustian shawl." "Face glistening tallow under her fustian shawl.")

    (cons "threepenny bits and sixpences" "threepenny bits and a sixpence")

    (cons "<h3>K.M.A.</h3>" "<h3>K. M. A.</h3>")

    (cons "deus nobis hæc otia fecit." "deus nobis haec otia fecit.")

    (cons "<i>The Parable of The Plums.</i>" "<i>The Parable of the Plums</i>.")

    ;; lestry
    (cons "£. s. d." "L.s.d.")

    (cons "two windows of the ballastoffice" "two windows of the ballast office")

    (cons "A procession of whitesmocked sandwichmen" "A procession of whitesmocked men")

    (cons "U. p: up" "U.P.: up")

    (cons "Express.</i>" "Express</i>.")

    (cons "Luncheon interval. A sixpenny" "Luncheon interval a sixpenny")

    (cons "Peaceful eyes. Weight off their mind." "Peaceful eyes. Weight off their minds.")

    (cons "Barmaids too. Tobaccoshopgirls." "Barmaids too. Tobacco shopgirls.")

    (cons "Homerule sun rising up" "Home Rule sun rising up")

    (cons "Drop into the D.B.C. probably for his coffee, play chess there." "Drop into the D. B. C. probably for his coffee, play chess there.")

    (cons "Now that I come to think of it that ball falls at Greenwich time. It’s the
      clock is worked by an electric wire from Dunsink. Must go out there some
      first Saturday of the month. If I could get an introduction to professor
      Joly or learn up something about his family. That would do to: man always
      feels complimented. Flattery where least expected. Nobleman proud to be
      descended from some king’s mistress. His foremother. Lay it on with a
      trowel. Cap in hand goes through the land. Not go in and blurt out what
      you know you’re not to: what’s parallax?" "Now that I come to think of it, that ball falls at Greenwich time. It’s
the clock is worked by an electric wire from Dunsink. Must go out there
some first Saturday of the month. If I could get an introduction to
professor Joly or learn up something about his family. That would do to:
man always feels complimented. Flattery where least expected. Nobleman
proud to be descended from some king’s mistress. His foremother. Lay it
on with a trowel. Cap in hand goes through the land. Not go in and blurt
out what you know you’re not to: what’s parallax?")

    (cons "Spat-on sawdust, sweetish warmish cigarettesmoke" "Spaton sawdust, sweetish warmish cigarette smoke")

    (cons "musterred and bred there" "mustered and bred there")

    (cons "women sculped Junonian" "woman sculped Junonian")

    (cons "<i>Why I left the church
      of Rome? Birds’ Nest.</i> Women run him. They say they used to give pauper
      children soup to change to protestants in the time of the potato blight.
      Society over the way papa went to for the conversion of poor jews. Same
      bait. Why we left the church of Rome." "<i>Why I left the church
of Rome.</i> Birds’ nest women run him. They say they used to give pauper
children soup to change to protestants in the time of the potato blight.
Society over the way papa went to for the conversion of poor jews. Same
bait. Why we left the church of Rome.")

    (cons "The devil on moneylenders. Gave
      Reuben J a great strawcalling. Now he’s really what they call a dirty
      jew." "The devil
on moneylenders. Gave Reuben J. a great strawcalling. Now he’s really
what they call a dirty jew.")

    (cons "Ah soap there I yes. Gate." "Ah, soap there! Yes. Gate.")

    ;; scylla
    (cons "<i>First he tickled her
     Then he patted her
     Then he passed the female catheter
     For he was a medical
     Jolly old medi...</i>" "<i>First he tickled her
     Then he patted her
     Then he passed the female catheter.
     For he was a medical
     Jolly old medi...</i>")

    (cons "<i>Homestead.</i>" "<i>Homestead</i>.")

    (cons "For years in this fleshcase a shesoul dwelt.</i>" "<i>For years in this fleshcase a shesoul dwelt.</i>")

    (cons "<i>Punkt.</i>" "<i>Punkt</i>")

    (cons "<i>Amplius. Adhuc. Iterum. Postea.</i>" "Just <i>Amplius. Adhuc. Iterum. Postea.</i>")

    (cons "a shattering daylight of no thought." "a shattering daylight of no thoughts.")

    ;; wrocks
    (cons "John Conmee S. J." "John Conmee S.J.")

    (cons "On Newcomen bridge the very reverend John Conmee S. J. of saint Francis
      Xavier’s church, upper Gardiner street, stepped on to an outward bound
      tram." "On Newcomen bridge the very reverend John Conmee S.J. of saint Francis
Xavier’s church, upper Gardiner street, stepped on to an outward bound
tram.")

    (cons "vas naturale mulieris,</i>" "vas naturale mulieris</i>")

    (cons "in eternum omnia iudicia" "in eternum omnia indicia")

    (cons "<i>&mdash;Ma!</i> Almidano Artifoni said." "&mdash;<i>Ma!</i> Almidano Artifoni said.")

    (cons "&mdash;<i>Anch’io ho avuto di queste idee</i>, Almidano Artifoni said, <i>quand’
      ero giovine come Lei. Eppoi mi sono convinto che il mondo è una bestia. È
      peccato. Perchè la sua voce... sarebbe un cespite di rendita, via. Invece,
      Lei si sacrifica.</i>" "&mdash;<i>Anch’io ho avuto di queste idee</i> Almidano Artifoni said <i>quand’ ero
giovine come Lei. Eppoi mi sono convinto che il mondo è una bestia.
È peccato. Perchè la sua voce... sarebbe un cespite di rendita, via.
Invece, Lei si sacrifica.</i>")

    (cons "<i>General Slocum</i> explosion." "General Slocum explosion.")

    (cons "We call it D.B.C. because they have damn bad cakes." "We call it D. B. C. because they have damn bad cakes.")

    (cons "I hope he’s in purgatory now because he went to confession" "I hope he is in purgatory now because he went to confession")

    (cons "Richie Goulding with the costbag of Goulding, Collis and Ward" "Richie Goulding with the costsbag of Goulding, Collis and Ward")

    (cons "<i>My girl’s a Yorkshire girl.</i>" "<i>My girl’s a Yorkshire girl</i>.")

    (cons "Northumberland and Lansdowne roads" "Northumberland and Landsdowne roads")

    ;; sirens
    (cons "All gone. All fallen." "Naminedamine. All gone. All fallen.")

    (cons "Imperthnthn thnthnthn, bootssnout sniffed rudely" "Imperthnthn thnthnthn, bootsnout sniffed rudely")

   (cons "Prosper Loré" "Prosper Lore")

    (cons "to greaseabloom." "to greaseaseabloom.")

    (cons "the door of the bar and diningroom" "the door of the diningroom")

    (cons "Does that to all.
    </p>
    <p>
      For men." "Does that to all. For men.")

    (cons "<i>to Flora’s lips" "<i>Flora’s lips")

    (cons "Independent,</i>" "Independent</i>,")

    (cons "Tenderness it welled: slow, swelling, full it throbbed." "Tenderness it welled: slow, swelling. Full it throbbed.")

    (cons "Flood of warm jamjam" "Flood of warm jimjam")

    (cons "U. P: up" "U. P.: up")

    (cons "&mdash;What key? Six sharps?" "&mdash; What key? Six sharps?")

    (cons "&mdash;F sharp major, Ben Dollard said." "&mdash; F sharp major, Ben Dollard said.")

    (cons "how solemn fell his footsteps there" "how solemn fell his footstep there")

    (cons "Domini,</i> in God’s name he" "Domini,</i> in God’s name. He")

    (cons "passed, reposed and, gently touching" "passed, repassed and, gently touching")

    (cons "Can leave that <i>Freeman</i>." "Can leave that Freeman.")

    ;; cyclops
    (cons "smooth sleek Leinster and of Cruachan" "smooth sleek Leinster and of Cruahan")

    (cons "the agate with this dun" "the agate with the dun")

    (cons "with U. p: up on it" "with u. p.: up on it")

    (cons "<i>&mdash;Bi i dho husht,</i>" "&mdash;<i>Bi i dho husht,</i>")

    (cons "the young chief of the O’Bergan’s" "the young chief of the O’Bergans")

    (cons "Goosepond Prhklstr Kratchinabritchisitch, Borus Hupinkoff," "Goosepond Přhklštř Kratchinabritchisitch, Boris Hupinkoff,")

    (cons "a straw</i>." "a straw.</i>")

    (cons "O’Molloy’s, a comely" "O’Molloys, a comely")

    (cons "&mdash;Of course an action would lie, says J. J. It implies that he is not <i>compos mentis</i>. U. p: up." "&mdash; Of course an action would lie, says J. J. It implies that he is not <i>compos mentis</i>. U. p. up.")

    (cons "your eye! says Alf" "your eye? says Alf")

    (cons "Ay, says Alf. Reuben J was bloody lucky" "Ay, says Alf. Reuben J. was bloody lucky")

    ;; nausicaa
    (cons "though she didn’t like her mother’s
      taking pinches of snuff and that was the only single thing they ever had
      words about, taking snuff" "though she didn’t like her mother taking pinches of snuff and that was the only single thing they ever had words about, taking snuff")

    (cons "Louis J Walsh, Magherafelt" "Louis J. Walsh, Magherafelt")

    (cons "Featherbed mountain." "the featherbed mountain.")

    (cons "the Gold Cup races!" "the Gold Cup race!")

    (cons "<i>Leah, Lily of Killarney.</i>" "<i>Leah,</i> Lily of Killarney.")

    (cons "Dreamt last night?
      Wait. Something confused. She had red slippers on. Turkish. Wore the
      breeches. Suppose she does?" "Dreamt last night? Wait.
Something confused. She had red slippers on. Turkish. Wore the breeches.
Suppose she does.")

    (cons "<i>Cuckoo Cuckoo Cuckoo.</i>" "<i>Cuckoo. Cuckoo. Cuckoo.</i>")

    ;; oxen
    (cons "allhardest of woman" "all hardest of woman")

    (cons "sinned against my light" "sinned against the light")

    (cons "from waters of old Nile" "from water of old Nile")

    (cons "sustained on currents of the cold interstellar wind" "sustained on currents of cold interstellar wind")

    (cons "Forward to the ribbon counter." "Forward the ribbon counter.")

    (cons "Allee samee dis bunch." "Allee samee this bunch.")

    (cons "<i>Retamplatan digidi boumboum</i>" "<i>Retamplan Digidi Boum Boum</i>")

    (cons "Tramp, tramp, tramp, the boys are (attitudes!) parching." "Tramp, tramp, tramp, the boys are (atitudes!) parching.")

    (cons "Beer, beef, business, bibles, bulldogs battleships, buggery and bishops." "Beer, beef, business, bibles, bulldogs, battleships, buggery and bishops.")

    (cons "Whether on the scaffold high. Beer, beef, trample the bibles. When for Irelandear. Trample the trampellers." "Whether on the scaffold high. Beerbeef trample the bibles. When for Irelandear. Trample the trampellers.")

    (cons "Bishops boosebox." "Bishops’ boosebox.")

    (cons "<i>Übermensch.</i>" "<i>Uebermensch</i>.")

    (cons "We are nae fou. We’re nae tha fou." "We are nae fou.
We’re nae the fou.")

    (cons "O lust our refuge and our strength." "O,\nlust, our refuge and our strength.")

    (cons "Time, gents! Who wander through the world. Health all!" "Time. Who wander through the world. Health all!")

    ;; circe
    (cons "U. p: up." "U. p.: Up.")

    (cons "Leah</i>, Mrs Bandmann Palmer" "Leah.</i> Mrs Bandmann Palmer")

    (cons ". A</i> Titbits <i>back" ".</i> A Titbits <i>back")

    (cons "Berlin, W. 13." "Berlin, W.13.")

    (cons "S. J." "S.J.")

    (cons "<i>Cui bono?</i> But our bucaneering Vanderdeckens" "<i>Cui bono</i>? But our buccaneering Vanderdeckens")

    (cons "Lorcan Sherlock,</i> locum tenens. <i>" "Lorcan Sherlock, locum tenens. ")

    (cons "Reuben J Dodd, blackbearded Iscariot, bad shepherd" "Reuben J. Dodd, blackbearded Iscariot, bad shepherd")

    (cons "chorus from Handel’s Messiah" "the Alleluia chorus")

    (cons "Reuben J Antichrist, wandering jew" "Reuben J. Antichrist, wandering jew")

    (cons "Ben Jumbo Dollard, rubicund, musclebound, hairynostrilled,
      hugebearded, cabbageeared, shaggychested, shockmaned, fatpapped, stands
      forth, his loins and genitals tightened into a pair of black bathing
      bagslops." "Ben Jumbo Dollard, rubicund, musclebound, hairynostrilled,
hugebearded, cabbageeared, shaggychested, shockmaned, fat-papped, stands
forth, his loins and genitals tightened into a pair of black bathing
bagslops.")

    (cons "teabrown artcolours, descends from her grotto and
      passing under interlacing yews stands over Bloom.)</i>" "</i> <i>teabrown artcolours</i>, <i>descends from her
grotto and passing under interlacing yews stands over Bloom.</i>)")

    (cons "lights the</i> Erin’s King <i>sails" "lights the Erin’s King sails")

    (cons "She clutches again in her robe." "She clutches in her robe.")

    (cons "(Sated, smiles.)" "(Seated, smiles.)")

    (cons "a Scottish widow’s insurance policy" "a Scottish widows’ insurance policy")

    (cons "Dreams goes by contraries." "Dreams go by contraries.")

    (cons "<i>(He cries.) Pater!</i> Free!" "<i>Pater!</i> Free!")

    (cons "Yet I’ve a sort of a" "Yet I’ve a sort a")

    (cons "with outstretched finger." "with outstretched fingers.")

   (cons "of</i> Sweets of Sin," "of Sweets of Sin,")

    (cons "Moses Herzog, Michael E Geraghty" "Moses Herzog, Michael E. Geraghty")

    (cons "Struggle for
      life is the law of existence but but human philirenists, notably the tsar
      and the king of England, have invented arbitration." "Struggle
for life is the law of existence but human philirenists, notably the
tsar and the king of England, have invented arbitration.")

    (cons "a plasterer’s bucket" "</i> <i>a plasterer’s bucket")

    ;; eumaeus
    (cons "tone of voice <i>à propos</i> of" "tone of voice <i>apropos</i> of")

    (cons "Bow to the inevitable. Grin and bear it. I remain with much love your brokenhearted husband W. B. Murphy." "Bow to the inevitable. Grin and bear it. I remain with much love your brokenhearted husband D. B. Murphy.")

    (cons "there was a steamtram" "there was a steam tram")

    (cons "simply letting spirt a jet of spew" "simply letting spurt a jet of spew")

    (cons "it is a simple substance and
      therefore incorruptible. It would be immortal, I understand, but for the
      possibility of its annihilation by its First Cause Who, from all I can
      hear, is quite capable of adding that to the number of His other practical
      jokes, <i>corruptio per se</i> and <i>corruptio per accidens</i> both
      being excluded by court etiquette." "it is a simple substance and
therefore incorruptible. It would be immortal, I understand, but for the
possibility of its annihilation by its First Cause, Who, from all I
can hear, is quite capable of adding that to the number of His other
practical jokes, <i>corruptio per se</i> and <i>corruptio per accidens</i> both
being excluded by court etiquette.")

    (cons "triangle Miss Portinari he" "triangle, Miss Portinari, he")

    (cons "queen’s evidence or king’s now like" "queen’s evidence&mdash;or king’s now&mdash;like")

    (cons "indulge in any " "indulge in any...")

    (cons "the subject and then orthodox as" "the subject, and then, orthodox as")

    (cons "you are. But in the economic, not touching religion, domain the priest" "you are... But in the economic, not touching religion, domain, the priest")

    (cons "the lives of the submerged tenth, viz. coalminers, divers, scavengers
      etc., were very much under the microscope lately" "the lives of the submerged tenth, viz.,
coalminers, divers, scavengers, etc., were very much under the microscope
lately")

    (cons "edition extra sporting of the <i>Telegraph</i> tell" "edition, extra sporting, of the <i>Telegraph</i>, tell")

    (cons "Ascot meeting, the Gold Cup.
      Victory of outsider <i>Throwaway</i> recalls Derby of ’92 when Capt.
      Marshall’s dark horse <i>Sir Hugo</i> captured the blue ribband at long
      odds." "Ascot
<i>Throwaway</i> recalls Derby of ’92 when
Captain Marshall’s dark horse, <i>Sir Hugo</i>, captured the blue ribband at long
odds.")

    (cons "New York disaster. thousand" "New York disaster, thousand")

    (cons "no 9 Newbridge Avenue" "n° 9 Newbridge Avenue")

    (cons "Cornelius T. Kelleher, Joseph M’C Hynes, L. Boom, C P
      M’Coy,&mdash;M’Intosh" "Cornelius Kelleher, Joseph M’C Hynes, L. Boom, C P
      M’Coy,&mdash;M’lntosh")

    (cons "the account of the third event at Ascot on page three, his side.
      Value 1000 sovs with 3000 sovs in specie added. For entire colts and
      fillies. Mr F. Alexander’s <i>Throwaway</i>, b. h. by <i>Rightaway-Thrale</i>, 5
      yrs, 9 st 4 lbs (W. Lane) 1. Lord Howard de Walden’s <i>Zinfandel</i> (M.
      Cannon) 2. Mr W. Bass’s <i>Sceptre</i> 3. Betting 5 to 4 on <i>Zinfandel</i>,
      20 to 1 <i>Throwaway</i> (off). <i>Sceptre</i> a shade heavier. It was anybody’s race then the rank outsider drew to
      the fore, got long lead, beating Lord Howard de Walden’s chestnut colt and
      Mr W. Bass’s bay filly Sceptre on a 2 1/2 mile course. Winner trained by
      Braime so that Lenehan’s version of the business was all pure buncombe.
      Secured the verdict cleverly by a length. 1000 sovs with 3000 in specie.
      Also ran: J de Bremond’s (French horse Bantam Lyons was anxiously
      inquiring after not in yet but expected any minute) <i>Maximum II</i>." "the account of the third event at Ascot on page three,
his sidevalue 1,000 sovs., with 3,000 sovs. in specie added for entire
colts and fillies, Mr F. Alexander’s <i>Throwaway</i>, b. h. by <i>Rightaway</i>,
5 yrs, 9 st 4 lbs, Thrale (W. Lane) 1. Lord Howard de Walden’s <i>Zinfandel</i> (M.
Cannon) 2. Mr W. Bass’s <i>Sceptre</i> 3. Betting 5 to 4 on <i>Zinfandel</i>,
20 to 1 <i>Throwaway</i> (off).<i> Throwaway</i> and <i>Zinfandel</i>
stood close order. It was anybody’s race then the rank outsider drew to
the fore got long lead, beating lord Howard de Walden’s chestnut
colt and Mr W. Bass’s bay filly Sceptre on a 2½ mile course. Winner
trained by Braine so that Lenehan’s version of the business was all pure
buncombe. Secured the verdict cleverly by a length. 1,000 sovs. with
3000 in specie. Also ran: J. de Bremond’s (French horse Bantam Lyons was
anxiously inquiring after not in yet but expected any minute) <i>Maximum
II</i>.")

    (cons "ship of the street was manœuvring" "ship of the street was manoeuvring")

    (cons "their <i>tête à tête</i> (which, of course, he was utterly out of)" "their <i>tête-à-tête</i> (which of course he was utterly out of)")

    ;; ithaca
    (cons "as far as the farther corner of Temple street: then," "as far as the farther corner of Temple street, north: then,")

    (cons "a man regulating a gasflame of 14 CP, a man lighting a
      candle of 1 CP, a man removing in turn each of his two boots, a man
      leaving the kitchen holding a candle." "a man regulating a gasflame of 14 CP, a man lighting a
candle, a man removing in turn each of his two boots, a man
leaving the kitchen holding a candle of 1 CP.")

    (cons "Freeman’s Journal</i> and <i>National Press" "</i> <i>Freeman’s Journal and
National Press</i> <i>")

    (cons "picked at and gently lacerated the protruding part of the
      great toenail, raised the part lacerated to his nostrils and inhaled the
      odour of the quick, then, with satisfaction, threw away the lacerated
      ungual fragment" "picked at and gently lacerated the protruding
part of the great toenail, raised the part lacerated to his nostrils and
inhaled the odour of the quick, then, with satisfaction, threw away the
lacerated unguical fragment")

    (cons "sir James W. Mackey (Limited)" "sir James W. Mackey Limited,")

    (cons "postage stamps (7 schilling, mauve" "postage stamps (7 shilling, mauve")

    (cons "from Mr + Mrs M. Comerford" "from Mr and Mrs M. Comerford")

    (cons "c/o. P. O. Dolphin" "c/o P. O.\nDolphin")

    (cons "the transliterated name and address of the addresser of the 3 letters in
      reversed alphabetic boustrophedonic punctated quadrilinear cryptogram
      (vowels suppressed) N. IGS./WI. UU. OX/W. OKS. MH/Y. IM" "the transliterated name and address of the addresser
of the 3 letters in reversed alphabetic boustrophedonic punctated
quadrilinear cryptogram (vowels suppressed) N. IGS. /WI. UU. OX/W. OKS.
MH/Y. IM")

    (cons "Coventry House, South Place, London E C" "Coventry House, South Place, London E. C.")

    (cons "an endowment assurance policy of £ 500" "an endowment assurance policy of £500")

    (cons "An ancient haggadah book" "An ancient hagadah book")

    (cons "<i>City Arms</i> hotel" "City Arms hotel")

    ;; penelope
    (cons "for £ 10000 for a postcard U p up" "for £10000 for a postcard up up")

    (cons "coming man Griffiths is" "coming man Griffith is")

    (cons "that blue suit he had on and stylish tie and
      socks with the skyblue silk things on them hes certainly welloff I know
      by the cut his clothes have" "that blue suit he had on and stylish tie and socks
with the skyblue silk things on them hes certainly well off I know by
the cut his clothes have")

    (cons "deaead days beyondre call" "deaead days beyond recall")

    (cons "the hour wait two oclock well" "the hour wait 2 oclock well")

    (cons "he was a potent professor" "he was a patent professor")

    (cons "strand bathingplace" "strand bathing place")

    (cons "mi fa pieta Masetto" "mi fa pietà Masetto")

    (cons "presto non son piu forte" "presto non son più forte")
))
