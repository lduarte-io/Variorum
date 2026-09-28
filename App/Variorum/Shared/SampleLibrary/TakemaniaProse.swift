//
//  TakemaniaProse.swift
//  Shared (Variorum + VariorumMobile)
//
//  18l-c U6 — takemania's words. Robert Louis Stevenson's *The Strange Case
//  of Dr Jekyll and Mr Hyde* (1886, public domain — Project Gutenberg eBook
//  #42, the author's own copy committed at
//  `notes/plans/18l-inputs/drjekyllandmrhyde-gutenberg-raw.txt`): the middle
//  chapters — the will, the search for Mr. Hyde, the Carew murder, the
//  letter, the last night — lifted and condensed, and beside them the other
//  takes a person reworking it would try (tighter, plainer, in the maid's
//  own voice, an open ending). `Takemania` replays the edits that turn the
//  first drafts into the note; these are only the texts.
//
//  A paragraph that the history DIVIDES or EXTRACTS from is composed here
//  from its halves, so the pins can hold each cut to the exact seam it was
//  written for (the halves are what the operations must leave behind).
//

import Foundation

nonisolated enum TakemaniaProse {

    // MARK: The will

    static let headingWill = "## The will"

    static let openingV1 = """
        Utterson came home that Sunday in a black mood and could not eat. After dinner he took \
        a candle into his business-room, opened the safe, and took out the envelope marked \
        Dr. Jekyll’s Will.
        """
    static let openingV2 = """
        That evening Mr. Utterson came home to his bachelor house in sombre spirits and sat down \
        to dinner without relish. As soon as the cloth was taken away he took up a candle, went \
        into his business-room, opened his safe, and took out the envelope endorsed \
        Dr. Jekyll’s Will.
        """
    static let openingV3 = """
        That evening Mr. Utterson came home to his bachelor house in sombre spirits and sat down \
        to dinner without relish. As soon as the cloth was taken away, he took up a candle and \
        went into his business-room. There he opened his safe, took from the most private part \
        of it a document endorsed on the envelope as Dr. Jekyll’s Will, and sat down with a \
        clouded brow to study its contents.
        """

    static let willTerms = """
        The will was holograph, for Mr. Utterson, though he took charge of it now that it was \
        made, had refused to lend the least assistance in the making of it. It provided not only \
        that, in case of the decease of Henry Jekyll, M.D., D.C.L., L.L.D., F.R.S., etc., all his \
        possessions were to pass into the hands of his “friend and benefactor Edward Hyde,” but \
        that in case of Dr. Jekyll’s “disappearance or unexplained absence for any period \
        exceeding three calendar months,” the said Edward Hyde should step into the said Henry \
        Jekyll’s shoes without further delay.
        """

    static let eyesoreFirstTry = """
        Utterson hated the will. He had always hated it; but tonight, after Enfield’s story, he \
        hated it in a new way, because now the name in it belonged to somebody.
        """
    static let eyesoreStevenson = """
        This document had long been the lawyer’s eyesore. It offended him both as a lawyer and \
        as a lover of the sane and customary sides of life, to whom the fanciful was the \
        immodest. And hitherto it was his ignorance of Mr. Hyde that had swelled his \
        indignation; now, by a sudden turn, it was his knowledge. It was already bad enough when \
        the name was but a name of which he could learn no more. It was worse when it began to \
        be clothed upon with detestable attributes; and out of the shifting, insubstantial mists \
        that had so long baffled his eye, there leaped up the sudden, definite presentment of a \
        fiend.
        """
    static let eyesoreTighter = """
        The will had long been the lawyer’s eyesore. For years it was his ignorance of Mr. Hyde \
        that had angered him; tonight it was his knowledge. A name he could learn nothing about \
        had been bad enough. A name with a cane and a trampled child behind it was a fiend.
        """

    static let madness = """
        “I thought it was madness,” he said, as he replaced the obnoxious paper in the safe, \
        “and now I begin to fear it is disgrace.”
        """

    static let candle = """
        With that he blew out his candle, put on a great-coat, and set forth in the direction of \
        Cavendish Square, that citadel of medicine, where his friend, the great Dr. Lanyon, had \
        his house and received his crowding patients.
        """
    static let ifAnyOneKnows = "“If any one knows, it will be Lanyon,” he had thought."

    static let oldestFriends = """
        “I suppose, Lanyon,” said he, “you and I must be the two oldest friends that Henry \
        Jekyll has?”
        """
    static let friendsYounger = """
        “I wish the friends were younger,” chuckled Dr. Lanyon. “But I suppose we are. And what \
        of that? I see little of him now.”
        """
    static let fanciful = """
        “Indeed?” said Utterson. “I thought you had a bond of common interest.” “We had,” was \
        the reply. “But it is more than ten years since Henry Jekyll became too fanciful for me. \
        He began to go wrong, wrong in mind. Such unscientific balderdash,” added the doctor, \
        flushing suddenly purple, “would have estranged Damon and Pythias.”
        """
    static let neverHeardOfHim = """
        Utterson gave his friend a few seconds to recover his composure, and then approached the \
        question he had come to put. “Did you ever come across a protege of his—one Hyde?” he \
        asked. “Hyde?” repeated Lanyon. “No. Never heard of him. Since my time.”
        """

    // MARK: Mr. Seek

    static let headingSeek = "## Mr. Seek"

    static let dreamScroll = """
        Six o’clock struck on the bells of the church that was so conveniently near to \
        Mr. Utterson’s dwelling, and still he was digging at the problem. As he lay and tossed \
        in the gross darkness of the night and the curtained room, Mr. Enfield’s tale went by \
        before his mind in a scroll of lighted pictures. He would be aware of the great field of \
        lamps of a nocturnal city; then of the figure of a man walking swiftly; then of a child \
        running from the doctor’s; and then these met, and that human Juggernaut trod the child \
        down and passed on regardless of her screams. Or else he would see a room in a rich \
        house, where his friend lay asleep, dreaming and smiling at his dreams; and then the door \
        of that room would be opened, the curtains of the bed plucked apart, the sleeper \
        recalled, and lo! there would stand by his side a figure to whom power was given, and \
        even at that dead hour, he must rise and do its bidding. And still the figure had no face \
        by which he might know it; and thus there sprang up and grew apace in the lawyer’s mind \
        a singularly strong, almost an inordinate, curiosity to behold the features of the real \
        Mr. Hyde.
        """
    static let dreamShort = """
        All that night Enfield’s tale went by before the lawyer’s mind in a scroll of lighted \
        pictures: a man walking swiftly through a city of lamps, a child running, the two \
        meeting, and that human Juggernaut treading the child down and passing on regardless of \
        her screams. And still the figure had no face; and there grew up in Utterson an almost \
        inordinate curiosity to behold the features of the real Mr. Hyde.
        """
    static let dreamNoFace = """
        He did not dream of the child at all, in the end. He dreamed of Harry Jekyll asleep and \
        smiling, and of the curtains of the bed plucked apart, and of a figure standing there to \
        whom power was given: a figure with no face, or with one that melted before his eyes \
        whenever he tried to know it.
        """

    static let hauntTheDoor = """
        From that time forward, Mr. Utterson began to haunt the door in the by-street of shops. \
        In the morning before office hours, at noon when business was plenty and time scarce, at \
        night under the face of the fogged city moon, by all lights and at all hours of solitude \
        or concourse, the lawyer was to be found on his chosen post.
        """
    static let mrSeek = "“If he be Mr. Hyde,” he had thought, “I shall be Mr. Seek.”"

    static let fineNightFirst = """
        And at last his patience was rewarded. It was a fine dry night; frost in the air; the \
        streets as clean as a ballroom floor; the lamps, unshaken by any wind, drawing a regular \
        pattern of light and shadow. By ten o’clock, when the shops were closed, the by-street \
        was very solitary and, in spite of the low growl of London from all round, very silent. \
        Mr. Utterson had been some minutes at his post, when he was aware of an odd, light \
        footstep drawing near; and it was with a strong, superstitious prevision of success that \
        he withdrew into the entry of the court.
        """
    /// Where sitting 7's divide falls — the first words of `fineNightSecond`.
    static let fineNightCutMarker = "The steps drew swiftly nearer"
    static let fineNightSecond = """
        The steps drew swiftly nearer, and swelled out suddenly louder as they turned the end of \
        the street. The lawyer, looking forth from the entry, could soon see what manner of man \
        he had to deal with. He was small and very plainly dressed, and the look of him, even at \
        that distance, went somehow strongly against the watcher’s inclination. But he made \
        straight for the door, crossing the roadway to save time; and as he came, he drew a key \
        from his pocket like one approaching home.
        """
    static let fineNightWhole = fineNightFirst + " " + fineNightSecond

    static let theExchange = """
        Mr. Utterson stepped out and touched him on the shoulder as he passed. “Mr. Hyde, I \
        think?” Mr. Hyde shrank back with a hissing intake of the breath; but his fear was only \
        momentary, and though he did not look the lawyer in the face, he answered coolly enough: \
        “That is my name. What do you want?” The lawyer named himself an old friend of \
        Dr. Jekyll’s and asked to see his face. Mr. Hyde appeared to hesitate, and then, as if \
        upon some sudden reflection, fronted about with an air of defiance; and the pair stared \
        at each other pretty fixedly for a few seconds. “Now I shall know you again,” said \
        Mr. Utterson. “It may be useful.”
        """

    static let hydeLeavesWithDialogue = """
        “And now,” said the other, “how did you know me?” “By description,” was the reply. \
        “Whose description?” “We have common friends,” said Mr. Utterson. “Jekyll, for \
        instance.” “He never told you,” cried Mr. Hyde, with a flush of anger. “I did not think \
        you would have lied.” The other snarled aloud into a savage laugh; and the next moment, \
        with extraordinary quickness, he had unlocked the door and disappeared into the house.
        """
    static let hydeLeavesCut = """
        When the lawyer named Jekyll as the friend they had in common, Hyde flushed with anger. \
        “He never told you,” he cried. “I did not think you would have lied.” He snarled aloud \
        into a savage laugh, and the next moment he had unlocked the door and disappeared into \
        the house.
        """

    static let hydeFaceTop = """
        The lawyer stood awhile when Mr. Hyde had left him, the picture of disquietude. Then he \
        began slowly to mount the street, pausing every step or two and putting his hand to his \
        brow like a man in mental perplexity. Mr. Hyde was pale and dwarfish, he gave an \
        impression of deformity without any nameable malformation, he had a displeasing smile, \
        he had borne himself to the lawyer with a sort of murderous mixture of timidity and \
        boldness, and he spoke with a husky, whispering and somewhat broken voice; all these \
        were points against him, but not all of these together could explain the hitherto \
        unknown disgust, loathing, and fear with which Mr. Utterson regarded him.
        """
    /// Where sitting 14's divide falls in the displayed take — the first
    /// words of `hydeFaceBottom`.
    static let hydeFaceCutMarker = "“There must be something else,”"
    static let hydeFaceBottom = """
        “There must be something else,” said the perplexed gentleman. “There is something more, \
        if I could find a name for it. God bless me, the man seems hardly human! Something \
        troglodytic, shall we say? or is it the mere radiance of a foul soul that thus transpires \
        through, and transfigures, its clay continent? The last, I think; for, O my poor old \
        Harry Jekyll, if ever I read Satan’s signature upon a face, it is on that of your new \
        friend.”
        """
    static let hydeFaceStevenson = hydeFaceTop + " " + hydeFaceBottom
    static let hydeFacePlainer = """
        Utterson stood a long while in the empty street when Hyde had gone. The man was pale \
        and small, he smiled unpleasantly, his voice was a husky whisper; and none of it \
        explained the disgust he felt. “The man seems hardly human,” he said aloud. “If ever I \
        read Satan’s signature upon a face, Harry, it is on your new friend’s.”
        """

    static let pooleAtTheDoor = """
        Round the corner, at the one house in the square still occupied entire, the lawyer \
        knocked, and Poole told him the doctor was gone out. “I saw Mr. Hyde go in by the old \
        dissecting-room door, Poole,” he said. “Is that right, when Dr. Jekyll is from home?” \
        “Quite right, Mr. Utterson, sir,” replied the servant. “Mr. Hyde has a key. We have all \
        orders to obey him.”
        """

    // MARK: The Carew murder

    static let headingCarew = "## The Carew murder"

    static let maidFirst = """
        Nearly a year later, in the month of October, London was startled by a crime of singular \
        ferocity and rendered all the more notable by the high position of the victim. A maid \
        servant living alone in a house not far from the river had gone up-stairs to bed about \
        eleven. The lane, which her window overlooked, was brilliantly lit by the full moon; and \
        she sat down upon her box, which stood immediately under the window, and fell into a \
        dream of musing. And as she so sat she became aware of an aged and beautiful gentleman \
        with white hair, drawing near along the lane; and advancing to meet him, another and \
        very small gentleman, in whom she was surprised to recognise a certain Mr. Hyde, who had \
        once visited her master and for whom she had conceived a dislike.
        """
    /// Where sitting 6's divide falls — the first words of `maidSecond`.
    static let maidCutMarker = "He had in his hand a heavy cane"
    static let maidSecond = """
        He had in his hand a heavy cane, with which he was trifling; but he answered never a \
        word, and seemed to listen with an ill-contained impatience. And then all of a sudden he \
        broke out in a great flame of anger, stamping with his foot, brandishing the cane, and \
        carrying on (as the maid described it) like a madman. The old gentleman took a step \
        back, with the air of one very much surprised and a trifle hurt; and at that Mr. Hyde \
        broke out of all bounds and clubbed him to the earth. At the horror of these sights and \
        sounds, the maid fainted.
        """
    static let maidWhole = maidFirst + " " + maidSecond
    static let maidTellsIt = """
        “I was sat on my box by the window, sir, for the moon was that bright there was no \
        thinking of sleep. There was an old gentleman coming up the lane, white-haired, and ever \
        so kind in his face, and another coming to meet him, a little one. And I knew the little \
        one. It was Mr. Hyde, as came once to see my master, and I never could abide him.”
        """

    static let twoOClock = """
        It was two o’clock when she came to herself and called for the police. The murderer was \
        gone long ago; but there lay his victim in the middle of the lane, incredibly mangled. \
        The stick with which the deed had been done had broken in the middle under the stress \
        of this insensate cruelty, and one splintered half had rolled in the neighbouring \
        gutter. Upon the body they found a purse and a gold watch, and a sealed and stamped \
        envelope bearing the name and address of Mr. Utterson.
        """

    static let recognitionStevenson = """
        “Yes,” said he, when they showed him the body, “I recognise him. I am sorry to say that \
        this is Sir Danvers Carew.” Mr. Utterson had already quailed at the name of Hyde; but \
        when the stick was laid before him, he could doubt no longer; broken and battered as it \
        was, he recognised it for one that he had himself presented many years before to Henry \
        Jekyll.
        """
    static let recognitionStick = """
        It was the stick he knew first. Broken and battered as it was, it was one he had himself \
        given to Henry Jekyll many years before; and only then, with a dry mouth, did he look at \
        the face on the table and say, “Yes. That is Sir Danvers Carew.”
        """

    static let fogToSoho = """
        It was by this time about nine in the morning, and the first fog of the season. A great \
        chocolate-coloured pall lowered over heaven, and as the cab crawled from street to \
        street, Mr. Utterson beheld a marvellous number of degrees and hues of twilight. The \
        dismal quarter of Soho, seen under these changing glimpses, seemed in the lawyer’s eyes \
        like a district of some city in a nightmare. This was the home of Henry Jekyll’s \
        favourite; of a man who was heir to a quarter of a million sterling.
        """
    static let theRooms = """
        Mr. Hyde had only used a couple of rooms, furnished with luxury and good taste; but they \
        bore every mark of having been recently and hurriedly ransacked. On the hearth there lay \
        a pile of grey ashes, as though many papers had been burned, and from these embers the \
        inspector disinterred the butt-end of a green cheque-book. The other half of the stick \
        was found behind the door.
        """

    // MARK: The letter

    static let headingLetter = "## The letter"

    static let theCabinet = """
        It was late in the afternoon when Mr. Utterson found his way to Dr. Jekyll’s door, and \
        was carried down across the yard to the laboratory, through the silent theatre, and up a \
        flight of stairs to a door covered with red baize. There, close up to the fire, sat \
        Dr. Jekyll, looking deadly sick. He did not rise to meet his visitor, but held out a \
        cold hand and bade him welcome in a changed voice.
        """

    static let oathStevenson = """
        “Utterson, I swear to God,” cried the doctor, “I swear to God I will never set eyes on \
        him again. I bind my honour to you that I am done with him in this world. It is all at \
        an end. And indeed he does not want my help; you do not know him as I do; he is safe, he \
        is quite safe; mark my words, he will never more be heard of.”
        """
    static let oathShorter = """
        “I swear to God I will never set eyes on him again,” cried the doctor. “He is safe, \
        Utterson. Mark my words, he will never more be heard of.”
        """

    static let theHydeLetter = """
        The letter was written in an odd, upright hand and signed “Edward Hyde”: and it \
        signified, briefly enough, that the writer’s benefactor, Dr. Jekyll, need labour under \
        no alarm for his safety, as he had means of escape on which he placed a sure dependence. \
        The lawyer liked this letter well enough; it put a better colour on the intimacy than he \
        had looked for.
        """

    static let guestWine = """
        Presently after, he sat on one side of his own hearth, with Mr. Guest, his head clerk, \
        upon the other, and midway between, at a nicely calculated distance from the fire, a \
        bottle of a particular old wine that had long dwelt unsunned in the foundations of his \
        house. The fog still slept on the wing above the drowned city, where the lamps glimmered \
        like carbuncles; but the room was gay with firelight, and insensibly the lawyer melted. \
        There was no man from whom he kept fewer secrets than Mr. Guest.
        """
    static let guestWineShorter = """
        He took the letter home, brought up a bottle of the old wine, and asked Guest to sit with \
        him by the fire.
        """

    static let guestComparesV1 = """
        Guest, being a great student and critic of handwriting, studied the letter with passion. \
        “No, sir,” he said: “not mad; but it is an odd hand.” Just then the servant entered with \
        a note from Dr. Jekyll, only an invitation to dinner, and the clerk laid the two sheets \
        of paper alongside and sedulously compared their contents. “There’s a rather singular \
        resemblance,” he said at last; “the two hands are in many points identical: only \
        differently sloped.”
        """
    static let guestComparesV2 = """
        That night he showed the letter to Mr. Guest, his head clerk, who was a great student and \
        critic of handwriting. “No, sir,” said Guest, when he had studied it with passion: “not \
        mad; but it is an odd hand.” Just then the servant entered with a note from Dr. Jekyll, \
        only an invitation to dinner, and the clerk laid the two sheets of paper alongside and \
        sedulously compared their contents. “There’s a rather singular resemblance,” he said at \
        last; “the two hands are in many points identical: only differently sloped.”
        """

    static let safeRemainder = """
        No sooner was Mr. Utterson alone that night than he locked the note into his safe, where \
        it reposed from that time forward. “What!” he thought. “Henry Jekyll forge for a \
        murderer!”
        """
    /// The sentence sitting 12 extracts to stand alone — the last words of
    /// `lockedInTheSafe`.
    static let bloodRanCold = "And his blood ran cold in his veins."
    static let lockedInTheSafe = safeRemainder + " " + bloodRanCold
    static let bloodSatUp = """
        He sat a long while with the two sheets before him, and did not go up to bed.
        """
    static let bloodOneHand = "Two hands, one man. He would not let himself finish the thought."

    // MARK: The last night

    static let headingLastNight = "## The last night"

    static let pooleVisits = """
        Mr. Utterson was sitting by his fireside one evening after dinner, when he was surprised \
        to receive a visit from Poole. “Mr. Utterson,” said the man, “there is something wrong. \
        I’ve been afraid for about a week, and I can bear it no more. I think there’s been foul \
        play.”
        """

    static let nightStevenson = """
        It was a wild, cold, seasonable night of March, with a pale moon, lying on her back as \
        though the wind had tilted her, and a flying wrack of the most diaphanous and lawny \
        texture. The wind made talking difficult, and flecked the blood into the face. It seemed \
        to have swept the streets unusually bare of passengers; and struggle as he might, there \
        was borne in upon the lawyer’s mind a crushing anticipation of calamity.
        """
    static let nightTighter = """
        A wild, cold night of March, the moon lying on her back as though the wind had tilted \
        her. The streets were swept bare, and all the way to the square Utterson could not shake \
        the sense of a calamity already happened.
        """

    static let theVoice = """
        Poole led him through the surgical theatre to the foot of the stair, and knocked on the \
        red baize of the cabinet door. “Mr. Utterson, sir, asking to see you.” A voice answered \
        from within: “Tell him I cannot see any one,” it said complainingly. “Sir,” said Poole \
        afterwards, looking Mr. Utterson in the eyes, “was that my master’s voice?”
        """
    static let changed = """
        “Have I been twenty years in this man’s house, to be deceived about his voice? No, sir; \
        master’s made away with; he was made away with eight days ago, when we heard him cry out \
        upon the name of God; and who’s in there instead of him, and why it stays there, is a \
        thing that cries to Heaven, Mr. Utterson!”
        """
    static let mawsNote = """
        Poole handed out a crumpled note in the doctor’s hand, addressed to Messrs. Maw: their \
        last sample was impure and quite useless, and should any of the old quality be left, it \
        was to be forwarded at once. So far the letter had run composedly enough, but here, with \
        a sudden splutter of the pen, the writer’s emotion had broken loose. “For God’s sake,” \
        he had added, “find me some of the old.”
        """
    static let seenHim = """
        “But what matters hand-of-write?” said Poole. “I’ve seen him! He had slipped out to look \
        for this drug, and there he was at the far end of the theatre, digging among the crates. \
        He looked up when I came in, gave a kind of cry, and whipped up-stairs into the cabinet. \
        Sir, if that was my master, why had he a mask upon his face? Why did he cry out like a \
        rat, and run from me?”
        """
    static let maladyTheory = """
        “These are all very strange circumstances,” said Mr. Utterson, “but I think I begin to \
        see daylight. Your master, Poole, is plainly seized with one of those maladies that both \
        torture and deform the sufferer; hence the alteration of his voice; hence the mask and \
        the avoidance of his friends; hence his eagerness to find this drug, by means of which \
        the poor soul retains some hope of ultimate recovery.”
        """
    static let notMyMaster = """
        “Sir,” said the butler, turning to a sort of mottled pallor, “that thing was not my \
        master, and there’s the truth. My master is a tall, fine build of a man, and this was \
        more of a dwarf. No, sir, that thing in the mask was never Dr. Jekyll; and it is the \
        belief of my heart that there was murder done.”
        """

    static let doorStevenson = """
        “Jekyll,” cried Utterson, with a loud voice, “I demand to see you.” There came no reply. \
        “Utterson,” said the voice at last, “for God’s sake, have mercy!” “Ah, that’s not \
        Jekyll’s voice—it’s Hyde’s!” cried Utterson. “Down with the door, Poole!” Poole swung the \
        axe over his shoulder; the blow shook the building, and the red baize door leaped \
        against the lock and hinges. A dismal screech, as of mere animal terror, rang from the \
        cabinet. Four times the blow fell; but the wood was tough and the fittings were of \
        excellent workmanship; and it was not until the fifth that the lock burst in sunder and \
        the wreck of the door fell inwards on the carpet.
        """
    static let doorFiveBlows = """
        “Utterson,” said the voice, “for God’s sake, have mercy!” “That’s not Jekyll’s voice,” \
        cried the lawyer. “It’s Hyde’s! Down with the door, Poole!” The axe fell four times on \
        the red baize, and the screech from within was the screech of an animal; at the fifth \
        the lock burst, and the wreck of the door fell inwards on the carpet.
        """

    static let quietRoom = """
        There lay the cabinet before their eyes in the quiet lamplight, a good fire glowing and \
        chattering on the hearth, the kettle singing its thin strain, a drawer or two open, \
        papers neatly set forth on the business-table, and nearer the fire, the things laid out \
        for tea: the quietest room, you would have said, and, but for the glazed presses full of \
        chemicals, the most commonplace that night in London.
        """
    static let theBody = """
        Right in the midst there lay the body of a man sorely contorted and still twitching. \
        They drew near on tiptoe, turned it on its back and beheld the face of Edward Hyde. He \
        was dressed in clothes far too large for him, clothes of the doctor’s bigness; and by \
        the crushed phial in the hand and the strong smell of kernels that hung upon the air, \
        Utterson knew that he was looking on the body of a self-destroyer.
        """
    static let tooLate = """
        “We have come too late,” he said sternly, “whether to save or punish. Hyde is gone to \
        his account; and it only remains for us to find the body of your master.”
        """
    static let kettleAndBook = """
        At one table there were traces of chemical work, measured heaps of some white salt laid \
        on glass saucers. “That is the same drug that I was always bringing him,” said Poole; \
        and even as he spoke, the kettle with a startling noise boiled over. Beside the \
        tea-things lay a copy of a pious work, for which Jekyll had several times expressed a \
        great esteem, annotated, in his own hand, with startling blasphemies.
        """
    static let chevalGlass = """
        Next they came to the cheval glass, into whose depths they looked with an involuntary \
        horror. “This glass have seen some strange things, sir,” whispered Poole. “And surely \
        none stranger than itself,” echoed the lawyer in the same tones.
        """
    static let theEnvelope = """
        On the business-table, uppermost among the neat array of papers, lay a large envelope \
        bearing, in the doctor’s hand, the name of Mr. Utterson. The first enclosure was a will, \
        drawn in the same eccentric terms as the one he had returned six months before; but in \
        place of the name of Edward Hyde, the lawyer, with indescribable amazement, read the \
        name of Gabriel John Utterson.
        """

    static let endingStevenson = """
        “There was a third enclosure?” asked Utterson. “Here, sir,” said Poole, and gave into his \
        hands a considerable packet sealed in several places. The lawyer put it in his pocket, \
        and, once more leaving the servants gathered about the fire in the hall, trudged back to \
        his office to read the two narratives in which this mystery was now to be explained.
        """
    static let endingOpen = """
        He put the packet in his pocket without opening it. It was ten o’clock; he would read the \
        papers at home, in quiet, and be back before midnight, when they would send for the \
        police. And he went out into the wind with the whole of Henry Jekyll in his coat.
        """
    static let endingLanyonNext = """
        Utterson read Lanyon’s narrative first, standing by the lamp in his business-room, still \
        in his great-coat, and did not sit down until he had finished it.
        """
}
