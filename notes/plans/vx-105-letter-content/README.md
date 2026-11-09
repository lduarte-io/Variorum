# VX-105 content — her finished text, verbatim (2026-10-29)

**What is here: ONE text, not two.** The ticket's old language ("the readme" + "the letter")
converged during her edit passes: the final text is a single letter-shaped readme, confirmed
by her in session on 2026-10-29. `read-me.txt` is that text, captured through the Variorum
MCP door (`read_note`, the document format) from note `DC4D224B-2578-45C2-AEC7-1B2A240D0081`
("readmev5", book "readme / letter", wing v^2) after she declared the pass done. Every block
holds exactly one take, so the plain document format carries the whole content — there are
no alternates to ride along. The file's header line carries the WORKING title and tag
(`readmev5`, `#readme`); the seeded note uses neither (see her instructions below).

**R-13s-28 binds:** her text is never edited, reworded, re-punctuated or "cleaned up" — not
even capitalization. The build copies from this file byte-exact, or re-reads the note itself.

**The repo's face: `LETTER.md`** (VX-939, R-940-3; `notes/plans/fixes/vx-940-pre-oss-followups.md`
W1). The same seventeen paragraphs with this file's header line stripped, at the repo root, for a
stranger's first click. Kept in step BY HAND: `LaunchFurnitureTests` pins `ReadmeSeeder.paragraphs`
against THIS file, and nothing reads `LETTER.md`. A change to her text changes this file, the
seeder's literals and `LETTER.md` in one commit.
**Verification:** the manifest below is each block's chosen take's SHA-256 (of the stored
text, UTF-8 bytes, lowercase hex), read from the store. If this file and the manifest ever
disagree, the manifest and the note in her library win — re-fetch rather than trust the file.

## Her instructions (verbatim, in-session 2026-10-29)

- Title and shape: *"I want the title of this to just be 'read me' I think in the app -
  lowercase. it can be a standalone note with no tags or book inclusions or whatever."*
- Date and time: *"maybe 4:44am on Oct 29th?"* — then, on its confirmation: *"i agree on the
  date / time."* (= **October 29, 2026, 4:44 am**)
- Starred: *"yeah make it born starred."*
- Sign-off: it is **in the text itself** — the final two short blocks ("Thank you for trying
  Variorum," / "Lillian") are deliberate blocks of the note, seeded like any others.
- The Sherlock door: *"ok well can you add a note to this ticket that when it adds this
  readme, which i will give more details on (title exactly and add date) that it should also
  add a door just for sherlock holmes?"* — i.e. a dedicated **Help ▸ Restore door for "the
  adventures of sherlock holmes"** lands with this seed (today the book returns only through
  Help ▸ Restore the Sample Library). The readme's own text quotes the book in Title Case —
  the quoted name must match the final door label exactly (seed casing is lowercase per
  R-13s-38), and she knows this casing question is open.

The same dispositions are recorded on the VX-105 Linear thread (comments of 2026-10-29).

## Seed spec, as one list

title **read me** (lowercase) · **standalone** — no tags, no book memberships · stamp
**2026-10-29 4:44 am** · **born starred** · text `read-me.txt` byte-exact, one block per
blank-line-separated paragraph, the final two short sign-off blocks included.

## Open questions for the Pro session (ask her; never guess)

1. Does "read me" replace the 13s placeholder ("Lillian's Start Here") outright — fresh
   stores and the installed base — and does R-13s-29's ordering rule (readme tops the list)
   still apply now that readme and letter are one note? (The ticket's two-artifact
   description predates the convergence.)
2. The exact label of the new Sherlock Help ▸ Restore door — and therefore the casing of the
   quoted title inside the readme text, which is a text change only she may make.

## Manifest — note `DC4D224B-2578-45C2-AEC7-1B2A240D0081`, 17 blocks, captured 2026-10-29

| # | block_id | chosen take_id | sha256 |
|---|----------|----------------|--------|
| 1 | 3A97D5AE-9547-4B45-A5F9-625ACDF7D2AD | 4C81EAA1-CD22-49CC-8660-C82161704AF6 | 16abee4da8b6a06f26cbd9ea8f8a0a8b1cc5666c9d453e482c625bf515761029 |
| 2 | 738E6A47-3133-4B3E-89FC-76705D674A3E | 63FBBBD0-FFA0-4309-88D8-63E8C37D2B56 | ccc3c95f6e13fc2d38de5be8625922adffa68f5fbe7db0e6503b49ac0fa213f0 |
| 3 | B093CB0C-F465-476E-92D9-4579F5C0AD96 | F84B7AED-5C5E-4394-8C2C-C21FA20B229E | b684f8384171bc9ca84de39494b22578fa21fae1f1b15ee4d18dc3c5ae6925d4 |
| 4 | 2927020D-E6EE-4593-A15E-C675F688FCE7 | 499A200D-F2DE-4B02-B54E-4B715C0B34A2 | 1a4ea53a08d9a69cb1ce7013dfe07028e69f51df46fa638bbd8663e6271cb1fb |
| 5 | 2369E25E-4F1C-4D4A-85B2-7F0B44F0FC88 | 37060A39-93EC-4C02-9BB3-1EB70A56059D | 3bfd662c51e944e7f11180ac43ec9a39cbe8bf604fab36fcc2edd6f31e561e9c |
| 6 | 4DBE371C-1D0E-45BE-BE59-91E35E8A2BE2 | 3AC84586-C652-4CD5-A0C1-1DBB4C89B0E6 | 1a1a15367fd80dda20c95f30a9599352f82c12ad2d4aacadaec9bdd43d4ba4df |
| 7 | 47772E00-0988-42E6-AAD7-2651C3C7A6C3 | 5714C5C2-552E-4815-BA11-31370D19F98B | 9b1070bdd6642cd65c1598a51da3d62d96ef2d6e9ddedd72474341a7e558ca3a |
| 8 | 6CA2D816-50F3-4935-A7D8-65C2DFFC0EF5 | 3EDBDAB0-CADA-41F6-950C-2035DA77F95E | 26212229de860063770888effdbf1bda8ed67d5b90828218e69a409f1495db66 |
| 9 | E2575BDA-15B4-49C2-9581-D0D4C5EDF40D | DE88E0F2-9194-4662-82C6-5C5C0EF45BFC | 5f3b8ae589fa4dbe8006d51e73f6af96d9946b246c13b941872df87621f3cd12 |
| 10 | 43CBAB0D-CC42-4597-9C52-E7F86A4CAB19 | E560A6D8-2856-45B2-B6CC-542531D6EDB1 | c8c5d42ff67d2d23bd81a9df84f2a06d850b5357a8c71babf4c963b2be8b536b |
| 11 | C0780130-0529-4B57-93A3-B3329048FD42 | 915E094D-2C26-4CC8-8441-414F8E145D29 | aa946c04fca9b97aab94694b0a1bba3fb62cc2e802c16328000dda03bb8fc66f |
| 12 | 69700C57-15D2-4AB2-9827-B25F18D10575 | C25E2D08-3D59-4B4B-B5FA-A935F3795DE1 | 4f0f248de944d3bd9a24a0067f8547cdbade1da3f565e34ed6564a49e4005cdb |
| 13 | AE47539F-2664-4C2F-B8F7-312EE1F68259 | DD9BA74D-CD2C-4FE2-827D-7E468FDF9ED4 | 6f643c73a5b89846e6c46db0c56a05b6483e28b7d075c32b5f78daba1e6728b0 |
| 14 | 3D7244C2-6F5F-457F-9757-3E0647CFD831 | 0D0A15D2-85DE-4182-B49D-961D5DFBC0CF | d957a9205336a3314f324f0d73805c7545ee1f121713626ee060daacea690482 |
| 15 | C64D4C07-734D-4551-BC5F-9D2CB9282F2E | 6317976D-E92B-48C7-87FC-2F2FFB22D754 | c4b9b25f51055411afd0f1bfc62cae145c27dd09384c494a0bccf4c56531696a |
| 16 | 5E2D169E-DAE0-4C95-A1AD-A3A4ED1732B5 | 98658913-FC2E-4E93-A01E-3C20C956CE73 | 16f428caf18e8e6fa5eeb16fbca497fdef6669045b63b15c98cc9fa075d83d5a |
| 17 | 4C7E14EB-781F-4636-9BF1-79F51D965E5F | 7E4925F6-B92B-43F7-8993-5D5ADC6DCE1E | eabcdcdaaff8c65b717b1223c99c02c84d890935b8309357ac391d2c46217aa6 |

Blocks 16 and 17 are the sign-off ("Thank you for trying Variorum," / "Lillian").
Most takes end with a single trailing space (the app's own storage); blocks 2, 12, 16 and 17
do not. The sha256s settle any doubt.
