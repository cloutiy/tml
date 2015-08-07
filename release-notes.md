# August 6, 2015
v. 0.0.1.7
## Modified
### {document}
`{document}` now has the following options:
```
{document}
title:
subtitle:
author:
copyright:
pdf-title:
draft:
revision:
#style
  family:
  font:
  size:
  lead:
  autolead:
```
### {page}
`{page}` now has the following options:
```
{page}
#dimensions
  papersize:
  width:
  length:
#margins
  left:
  right:
  top:
  bottom:
  recto-verso
  recto-verso: force
```


# November 23, 2014
v. 1.0.8
## Added
### Aliases
Added a new configuration block for assigning aliases to refer to TML commands, tags and options:
```
{aliases}
oblique = italic
citation = blockquote
lyric = quote
```
The interpreter will search for aliases within <...<, [...] and {...} and replace it with the specified synonym. In the above example:
```
<oblique<text>
```
becomes:
```
<italic<text>
```
and
```
[citation]
```
becomes:
```
[blockquote]
```

# November 22, 2014
v. 1.0.7
## Modified
### Endnotes
Endnotes now have following syntax: 
```
[+ endnote text.]
```
### Inline Comments
Commentlines start with !, inline comments with \!:
```
! This is a comment line
Some text \! and a comment which follows
```
### Special Characters
Special characters now have the following syntax:

Before:
```
|copyright|
```
Now:
```
\copyright
```
But the old groff/mom syntax also works:
```
\[co]
```

## Added
### Comment blocks
```
[comment]
This is a multiline
comment block.
[end]
```
### Escaped brackets: 
`[, ], <, >, {, }` are used in TML syntax.  To print those characters literally, use a backslash:
```
\{ \} \[ \] \< \>
```
If you want to include TML syntax literally instead of having the interpreter interpret it, simply start the command with a backslash:
```
\{font-size: 10}
```
will literally output:
```
{font-size: 10}
```
### Metadata
```
{catalogue}/{catalogue-data}/{catalogue-info}/{metadata}/meta-data}
title:     
subtitle:
author: 
editor:
draft: 
revision:
pdf-title:
```


# November 17, 2014
V. 1.0.6
## Modified
### Blocks
- Configuration blocks no longer require `{end}`. 
- A blank line signifies the end of the current block. 
- `setup-...` is no longer required
- the string within `{...}` is prepended to each of the commands inside the block

Example:
```
{paragraph}
indent: 2cm
spacing: 0.5cm
```
will be converted into:
```
{paragraph-indent: 2cm}
{paragraph-spacing: 0.5cm}
```
### Comments
Comment lines now begin with `(!)`. Example:
```
(!) This is a comment line
```
# November 14, 2014
V. 1.0.5
## Added
### Blocks
Blocks allow a clean way of visually - and logically - grouping items together: 
```
{setup-page-layout}
option: value
Option: value
option: value
{end}

{setup-headers}
option: value
option: value
option: value
{end}
```
Within the blocks, its not necessary to add opening and curly braces for each command. The interpreter will add them for you. 

The string that begins the block can be arbitrary and means nothing to the interpreter, however it should begin with `{setup-xxx}`, this is how it knows that is needs to do a bit of processing until it reaches `{end}`
### Cover Page, Title Page and Copyright page tags
```
[coverpage]
My Book
by
Author
[end]

[titlepage]
...
[end]

[copyright]
....
[end]
```
### Alignment
```
{align-left} => non-filling left. no BR required
{align-right}
{align-center}
```

### List Numbering and List Item Spacing
`{start-at: 5} => start a list at a number other than 1`

Example:
```
[list]
{start-at: 5}
* item
* item
[end]
````
To set the spacing between list items:

`{item-spacing: 0.2cm} => sets the space between list items to 0.2cm.`

# November 9, 2014
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
