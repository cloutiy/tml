# TML Specification v.1.0.4
Nov 9, 2014

## PAGE LAYOUT
### Page sizes by name
```
{paper-size: letter}
{paper-size: legal}
{paper-size: statement}
{paper-size: tabloid}
{paper-size: ledger}
{paper-size: folio}
{paper-size: quarto}
{paper-size: trade}
		
{paper-size: executive}
{paper-size: 10x14}
{paper-size: a3}
{paper-size: a4}
{paper-size: a5}
{paper-size: b4}
{paper-size: b5}
{paper-size: 6x9}
		
{page-size: letter}
{page-size: legal}
{page-size: statement}
{page-size: tabloid}
{page-size: ledger}
{page-size: folio}
{page-size: quarto}
{page-size: trade}
		
{page-size: executive}
{page-size: 10x14}
{page-size: a3}
{page-size: a4}
{page-size: a5}
{page-size: b4}
{page-size: b5}
{page-size: 6x9}
```
### Page width and height
```
{page-width: nx}
{paper-width: nx}
{page-height: nx}
{paper-height: nx}
```
### Margins
```
{margin-left: nx}
{margin-right: nx}
{margin-top: nx}
{margin-bottom: nx}
{margins: nx nx nx nx}
```
## RECTO VERSO / DOUBLE SIDED
```
{double-sided}
{recto-verso}
```

## FONTS
### Font Family
```
{font-family: avant-garde}
{font-family: avantgarde}
{font-family: avant-garde}
{font-family: bookman}
{font-family: helvetica}
{font-family: helvetica-narrow}
{font-family: helveticanarrow}
{font-family: new-century-schoolbook}
{font-family: newcenturyschoolbook}
{font-family: palatino}
{font-family: times-roman}
{font-family: times}
{font-family: zapf-chancery}
{font-family: zapf}
{font-family: my-groff-font}
```		

### Font Style
```
{font-style: roman}
{font-style: r}
{font-style: italic}
{font-style: i}
{font-style: bold}
{font-style: b}
{font-style: bold-italic}
{font-style: bolditalic}
{font-style: bi}
{font-style: smallcaps}
{font-style: sc}
```

### Font Size
`{font-size: x}`
### Leading
```
{leading: 10/13} => sets {font-size: xx} to 10 and {line-spacing: xx} to 13 at same time
{autoleading: [factor of] 2}  => not implemented yet. 
```

## JUSTIFICATION 
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
## HEADERS AND FOOTERS
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
## PARAGRAPHS
### Spacing and Indent
```
{paragraph-indent: nx}
{paragraph-spacing: nx}
```
### Line Length and Spacing
```
{line-length: 3i}
{line-spacing: 13}
```
## KERNING/LIGATURES
### Kerning
```
{kerning-on} *kerning is on by default
{kerning-off}
<-x> / <+n>  (ex.: T<-2>he trees turned to dust.)
### Ligatures
{ligatures-on} *ligatures are on by default
{ligatures-off}
```

## HYPHENATION
```
{hyphenation-on} *hyphenation is on by default
{hyphenation-off}
{hyphenation-language: spanish} 
{hyphenation-max-lines: x}
{hyphenation-margin: x}
{hyphenation-space: x}
{hyphenation-defaults}
```

## SMARTQUOTES
```
{smartquotes-on} *smartquotes are on by default
{smartquotes-off}
{smartquotes: danish}
{smartquotes: german}
{smartquotes: spanish}
{smartquotes: french}
{smartquotes: italian}
{smartquotes: dutch}
{smartquotes: norwegian}
{smartquotes: portugese}
{smartquotes: swedish}

{smartquotes: da}
{smartquotes: ge}
{smartquotes: es}
{smartquotes: fr}
{smartquotes: it}
{smartquotes: nl}
{smartquotes: no}
{smartquotes: pt}
{smartquotes: sv}
```

## LANGUAGE
`{language: spanish}` => Sets both hypenation-language and smartquotes to spanish

## PRINT STYLE
```
{typeset} *typeset is the default
{typewrite}
{typewrite: singlespace}
```

## CHAPTERS
```
{chapters-on-odd-pages} => starts new chapters on even numbered pages
```

## METADATA TAGS
```
[author]
[title]
[doctitle]
[subtitle]
[chaptertitle]
[draft]
[revision]
[covertitle]
[doccovertitle]
[pdftitle]
```

## DOCUMENT ELEMENT TAGS
```
[include] path-to-external-file.xxx
[start]
[tableofcontents]
[epigraph]
[epigraphblock]
[chapter] "Title"
[chapter] Title => The chapter title doesn't need to be enclosed in quotes
[chapter]\nTitle => The chapter title can be entered on the next line
[chapter 1] => Sets the chapter number to 1
[chapter One] "Title" => Sets the chapter number to One and the title to the string Title
[h1]/[heading1]/[section]/[sec]
[h2]/[heading2]/[subsection]/[subsec]
[h3]/[heading3]/[subsubsection]/[subsubsec]
[blockquote]
[quote]
[list]
[list:digit]
[list:dash]
[list:bullet]
[list:alpha]
[list:ALPHA]
[list:romanX]
[list:ROMANx]
[list:square]
[list:hand]
[list:arrow]
[list:dblarrow]
[list:checkmark]
[list:user x]
[*footnote]
[endnote*]
[newpage]
[blankpage]
[break] / [br] / [linebreak]
[finis]
```

## INLINE FORMATTING COMMANDS
```
<bold<...> / <bd<...> / <b<...>
<italic<...> / <it<...> / <i<...>
<smallcaps<...> / <sc<...>
<uppercase<...> / <caps<...> / <uc<...>
<lowercase<...> / <lc<...>

<bolder x<...>
<slant x<...>
<condense x<...>
<extend x<...>
<up x<...>
<down x<...>
<forward x<...>
<back x<...>
<caps -1<...>
```
### Size
```
<+n<...>
<-n<...>
<n<...>
<size n<...>
```

## Kerning
`<-x> / <+n>` => `T<-2>he trees turned to dust.`

## Alignment
```
<left<...>
<right<...>
<center<...>
```

## COMMENTS:
`#`   

## SPECIAL CHARS
### En/EM Dashes
`|en|` / `.. - ..` 
`|em|` / `..--..` 

### Plus/minus (arithmetic)
`|+/-|`

### Subtract (arithmetic)
`|-|`

### Multiply (arithmetic)
`|x|`

### Divide (arithmetic)
`|/|` 

### Left double-quote 
`|lq|`

### Right double-quote
`|rq|`

### Open (left) single-quote
`|oq|`

### Close (right) single-quote
`|oq|`

### Bullet \[bu] 
`|bu| / [bullet]`

### Ballot box
```
|sq|
|square|
```

### One-quarter
`|1/4|`

### One-half 
`|1/2|`

### Three-quarters 
`|3/4|`

### Degree sign 
`|de| / [deg] / [degree]`

### Dagger 
`|dg| / [dagger]`

### Foot mark 
`|fm| / [footmark]`

### Cent sign 
`|ct| /[cent]`

### Registered trademark 
`|rg| / |tm| / [trademark]`

### Copyright 
`|co| / [copyright]`

### Section symbol
`|se]` 

### Foot and Inch
`|'|`
`|"|`

### Braces and brackets
```
|{| / |lc|
|}| / |rc| 
|<| / |lt| 
|>| / |gt| 
|[| / |ls| 
|]| / |rs| 
```
