# TML Specification v.1.0.4
Nov 5, 2014

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
{page-height: nx}
		
{paper-width: nx}
{paper-height: nx}
```

### MARGINS
```
{margin-left: nx}
{margin-right: nx}
{margin-top: nx}
{margin-bottom: nx}
{margins: nx nx nx nx}
```

### FONTS
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

### FONT STYLE
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

### FONT SIZE
`{font-size: x}`

### LINE SPACING/LEADING
```
{leading: 10/13} => sets PT_SIZE to 10 and .LS to 13 at same time
{autoleading: [factor of] 2}  => not implemented yet. 
{line-spacing: 13}
```

### JUSTIFICATION 
```
{justfication:left}
{justfication:right}
{justification:center}
{justification:full}
```

### PARAGRAPHS
```
{paragraph-indent: nx}
{paragraph-space: nx}
{line-length: 3i}
```

### KERNING/LIGATURES
```
{kerning-on}
{kerning-off}
{ligatures-on}
{ligatures-off}
```

### HYPHENATION
```
{hyphenation-on}
{hyphenation-off}
{hyphenationlanguage:spanish} => not implemeted yet
{hyphenation-max-lines: x}
{hyphenation-margin: x}
{hyphenation-space: x}
{hyphenation-defaults}
```

### SMARTQUOTES
```
{smartquotes-on}
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
`{language: spanish}`
(not implemented yet) maybe make it so that language also determines hyphenation language automatically.

## PRINT STYLE
```
{typeset}
{typewrite}
{typewrite: singlespace}
```

## CHAPTERS
```
{chapters-on-odd-pages}
```

### METADATA TAGS
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

### DOCUMENT ELEMENT TAGS
```
[include] path-to-external-file.xxx
[start]
[tableofcontents]
[epigraph]
[epigraphblock]
[chapter] "Title"
[chapter 1]
[chapter One] "Title"
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
