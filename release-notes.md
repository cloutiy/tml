# October 4, 2014
V. 1.02
## Fixed
- `{typeset}` is set as default, unless `{typewrite}` or `{typewrite:singlespace}` is specified => required by MOM
- `[tableofcontents]` after `[start]` => inserts `.AUTO_RELOCATE_TOC` before `.START` as required by MOM to have TOC at beginning.

## Added
- Pair kerning => `F<-5>or the re<+5>cord.`
- `<size n<...>` command
- `<mono<...> / <monospaced<...> / <m<...>` command => changes the text between <...> to mono spaced font
- `[chapter]` => `.CHAPTER_TITLE` / `[section]` => `.HEADING 1` / `[subsection]` => `.HEADING 2`
- Special chars are now denoted by `|char|` instead of `[char]`.  Ex: `350|degrees|F`   /  `1|3/4| cups`
- `{typeset}, {typewrite}, {typewrite:singlespace}`
