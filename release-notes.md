# November 6, 2014
V. 1.0.4
## Added 
### Hyphenation
```
{hyphenation-language: spanish}
{hyphenation-language: es}
{language: spanish} => sets both hyphenation-language and smartquotes to spanish
```
### Left
```
{justification: left}
{justify-left}
{quad-left}
{left-justified}
```
### Right	
```
{justification: right}
{justify-right}
{quad-right}
{right-justified}
```
### Center	
```
{justification: center}
{justify-center}
{quad-center}
{center-justified}
```
### Full	
```
{justification: full}
{justify-full}
{justify}
{justified}
{quad-justified}
{full-justified}
```
## Headers
```
{headers-plain}
{plain-headers}
{header-font-family: font-family}
{header-font-family-left: font-family}
{header-font-family-right: font-family}
{header-font-family-center: font-family}
{header-font-style-left: font-style}
{header-font-style-right: font-style}
{header-font-style-center: font-style}
{header-string-left: Header String}
{header-string-right: Header String}
{header-string-center: Header String}
```
# November 6, 2014
V. 1.0.4
## Added 
Chapter titles do not need to be enlcosed in "Quotations":

`[chapter One] The Happening`

will get converted to:

`[chapter One] "The Happening"`

Also chapter titles can be specified on the next line:
```
[chapter]
The Happening
```
and 

`[chapter] The Happening`

Are both the same for the interpreter.

# November 5, 2014
V. 1.0.3
## Added 
- `[chapter]`
- `[chapter 1]`
- `[chapter]` "Title"
- `[chapter 1]` "Title"
- `[chapter Two]` "Title"
- `[chapter IV]` "Title"

# October 4, 2014
V. 1.0.2
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
