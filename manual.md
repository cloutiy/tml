---
...

v0.1.7

**The Typesetting Markup Language**

\

Conventions used in this manual {.western}
===============================

Following is an example of the conventions used throughout this
document:

### Style {.western}

**{epigraphs}**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

lead: \<value\>

\

### Usage {.western}

**[epigraph]**

**...**

**[end]**

\

In this example, *Style* refers to an element's *style definition*. A
*style* *definition* describes how a particular element will look like
throughout the document. *Style definitions* should be defined at the
top of an *TML* document, prior to the introducing any *document
structure elements*.

\

*Usage* refers to how the element would be used in a document. They
describe a document's *structure*. Although it is best practice to set
an element's style once for the entire document, it is possible to set
the style for an individual occurance of an element by specifying these
options immediately after the element's `[tag]`{.western}. For example,
to set the color for this instance of `[epigraph]`{.western}:

\

**[epigraph]**

***color:*** blue

...text...

**[end]**

\

In this example, the scope of the `color: blue`{.western} begins at
`[epigraph] `{.western}and ends at `[end]`{.western}. This differs from
the *style definition* for `{epigraph}`{.western}, which applies
globally to all occurances of `[epigraph]`{.western}, unless overwridden
by *local* options as in the example above.

\

In most cases the options which can be set locally are the same that can
be set in its *style* *definition.* Exceptions to this rule will be
pointed out where it applies.

\

In the *style definition* in the example above, we see
`{epigraph`{.western}`s`{.western}`}`{.western} followed by a list of
`option: value`{.western} pairs. This particular The table below
describes the conventions used when listing
`option: value pairs`{.western}.

\

  ------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Identifier    Description
  \<string\>    A string of text. For example, a chapter or heading title, or perhaps a font name. Strings do not need to be enclosed in quotation marks. A quotation character within a string will need to be preceeded enclosed by square brackets [”]
  \<value\>     A numerical value.
  \<unit\>      A unit of measure. *TML*recognizes centimeters (cm), inches (in), points (p), picas (P).
  \<no-args\>   This means this means this option does not take any arguments, in which case the option is invoked without any colon. (i.e.: caps vs caps:)
  ------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

\

\

\

\

Document Layout {.western}
===============

General Style and Metadata {.western}
--------------------------

**{document}**

title: \<string\>

subtitle: \<string\>

author: \<string\>

draft: \<string\>

revision: \<string\>

pdf-title: \<string\>

**\#style**

family:

font:

size:

lead:

autolead:

\

The `{document}`{.western} directive is used to set the document's
metadata, such as author, draft version, revision and title. Typically
these are the information that are displayed only when looking at a PDF
document's properties. For example:

\

~~~~ {.western}
{document}
author:         Jim Jones
pdf-title:  The New Earth
#style
    family:     Arial
    size:       10
~~~~

\

Page Size {.western}
---------

**{page}**

**\#dimensions**

papersize: letter|legal|trade ...

width: \<value\>\<units\>

length: \<value\>\<units\>

**\#margins**

left: \<value\>\<units\>

right: \<value\>\<units\>

top: \<value\>\<units\>

bottom: \<value\>\<units\>

recto-verso \<no-args\> or

recto-verso: force

\

\

The `{page}`{.western} directive is used to set the page's dimensions.
`size`{.western} is used to use a standard predefined size. Alternately
`width`{.western} and `length`{.western} can be used to set a custom
page size. For example:

\

~~~~ {.western}
{page}
#dimensions
    width:  6in
    length: 9in
#margins
    left:   2cm
    right:  1.5cm
    recto-verso: force
~~~~

\

The `recto-verso`{.western} directive can be used with or without the
`force`{.western} option. Used by itself, `recto-verso`{.western}
switches the left and right margins and header/footer placement for odd
and even pages when printing on both sides of the page. Adding the
`force`{.western} option will add blank pages as required to ensure that
new chapters always begin on odd pages.

Headers {.western}
-------

**{headers}**

**\#general**

family: \<string\>

size: \<value\>

color: \<string\>

margin: \<value\>\<units\>

gap: \<value\>\<units\>

**\#left**

family: \<string\>

font: \<string\>

size: \<string\>

string: \<string\>

color: \<string\>

caps \<no-args\>

smallcaps \<no-args\>

**\#right**

family: \<string\>

font: \<string\>

size: \<string\>

string:\<string\>

color: \<string\>

caps \<no-args\>

smallcaps \<no-args\>

**\#center**

family: \<string\>

font: \<string\>

size: \<string\>

string:\<string\>

color: \<string\>

caps \<no-args\>

smallcaps \<no-args\>

**\#rule**

weight: \<value\>

gap: \<value\>\<units\>

color: \<string\>

none \<no-args\>

\

Example:

~~~~ {.western}
{headers}
~~~~

\

\

  -------------------------- ------------------------------------------------------------------------------------------------------------------------
  Header Variables           \
                             

  \\E\*[\$TITLE]             the current argument passed to .TITLE

  \\E\*[\$DOCTITLE]          the current argument passed to .DOCTITLE

  \\E\*[\$DOC\_TYPE]         the NAMED argument passed to .DOCTYPE

  \\E\*[\$AUTHOR]            the current first argument passed to .AUTHOR

  \\E\*[\$CHAPTER\_STRING]   he current argument passed to .CHAPTER\_STRING. If not specified, will use “Chapter” as the chapter string by default.

  \\E\*[\$CHAPTER]           The current chapter number.

  \\E\*[\$CHAPTER\_TITLE]    The current argument passed to .CHAPTER\_TITLE

  \#                         To replace a header string with page number.

  \\\*[PAGE\#]               To include page number as part of a string.
  -------------------------- ------------------------------------------------------------------------------------------------------------------------

\

Footers {.western}
-------

{footers}

/\* not available yet \*/

\

Margins {.western}
-------

**{margins}**

left: \<value\>\<units\>

right: \<value\>\<units\>

top: \<value\>\<units\>

bottom: \<value\>\<units\>

\

Pagination {.western}
----------

### Style {.western}

**{pagination}**

style: roman|ROMAN|alpha|ALPHA|digit

position:top-left|top-center|top-right|bottom-left|bottom-center|bottom-right

family: \<string\>

font: \<value\>

size: \<string\>

color: \<string\>

on-first-page //Paginate the first page.

hyphenate-page-numbers //For example: -3-

### Toggles {.western}

{pagination: on}

{pagination: off}

{page \#\<value\>} //Sets the page number to \<value\>.

\

Document Style and Structure {.western}
============================

[cover]

\

[cover] is used to create a cover page.

\

[title]

\

[title] is used to create a title page.

\

[copyright]

\

[copyright] is used to create a copyright page.

\

[introduction]

[preface]

[foreword]

[acknowledgements]

[section]

[comment]

\

Chapters {.western}
--------

### Style {.western}

**{chapter-****headings****}**

**\#number**

string: \<string\>

family: \<string\>

font: \<string\>

quad: left|right|center|justify

**\#title**

family: \<string\>

font: \<string\>

quad: \<string\>

start-on-odd-pages //To force new chapters to start on odd pages.

\

### Usage {.western}

**[chapter \<string\>] \<string\>**

\

The `[chapter]`{.western} element is used to create a chapter. The
chapter number must be specified within the tag. In its most simple form
is used in the following way:

\

~~~~ {.western}
[chapter 1] The Winner
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 

[chapter Two] The Loser
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
~~~~

\

The additional options are also availble for `[chapter]`{.western}:

\

**[chapter \<string\>] \<string\>**

title: \<string\>

subtitle: \<string\>

attribution:\<string\>

author: \<string\>

editor: \<string\>

toc-entry: \<string\>

header-title:\<string\>

title-family:\<string\>

\

For example, if we would like to specify a different chapter title in
the Table of Contents and in the header:

\

~~~~ {.western}
[chapter 3] The Wandering Ascetic and the Magical Seed
toc-entry:       The Wandering Ascetic
header-title:    The Wandering Ascetic
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
~~~~

\

Headings {.western}
--------

### Style {.western}

**{h1|h2|h3...|ph}**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

underscore: \<weight\>\<gap\>

underscore2: \<weight\>\<gap\>

adjust: \<value\>\<units\>

color: \<string\>

quad: left|right|center|justify

numbered //To number the headings

caps //For ALL CAPS

smallcaps //For Smallcaps

\

### Usage {.western}

**[h1] \<String\>**

\

'Headings' refer to `[h1]`{.western}, `[h2]`{.western}, `[h3]`{.western}
and `[parahead]`{.western}. Headings provide various levels of
hierearchical delineation of a document. For example:

\

~~~~ {.western}
[h1] Level 1
Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. Donec et auctor nisi. 

[h2] Level 1.1
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 

[h3] Level 1.1.1
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
~~~~

\

`[p`{.western}`h`{.western}`]`{.western} is used to create a
paragraph-level heading:

\

~~~~ {.western}
[ph Things to remember] Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
~~~~

\

will produce:

\

~~~~ {.western}
Things to remember Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
~~~~

Epigraphs {.western}
---------

### Style {.western}

**{epigraphs}**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

lead: \<value\>

\

### Usage {.western}

**[epigraph]**

**...**

**[end]**

\

The `epigraph`{.western} element is used to create an epigraph. An
epigraph is typically found after a chapter title and the start of
running text, and often used for quotes or explanatory text. In its most
simple form is used in the following way:

\

~~~~ {.western}
[chapter 1] Daylight
[epigraph]
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
[end]

The running text begins here. Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus. 
~~~~

\

Although it is best practice to set document-wide style options with the
`{epigraph}`{.western} directive, the following options are also
available for `[`{.western}`epigraph`{.western}`]`{.western}:

\

**[****epigraph****]**

family: \<string\>

font: \<string\>

size: \<string\>

lead: \<string\>

color: \<string\>

*...text...*

**[end]**

\

For example, if we would like to have an epigraph with font differing
from what was set for document-wide occurances of `[epigraph]`{.western}
by the style `{epigraphs}`{.western}:

\

~~~~ {.western}
[epigraph]
font: italic
Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh, lobortis gravida massa libero vitae metus.
[end] 
~~~~

\

Epigraph Blocks {.western}
---------------

### Style {.western}

**{epigraph-blocks}**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

lead: \<value\>

indent: \<value\>\<units\>

\

### Usage {.western}

See **[epigraph-****block****]**

Paragraphs {.western}
----------

### Style {.western}

**{paragraphs}**

indent: \<value\>\<units\>

space: \<value\>\<units\>

indent-first-paragraphs //To indent the first paragraphs as well.

\

### Usage {.western}

Paragraphs are identified by starting the line of text with any of the
following:

-   -   -   -   -   

A space after the paragraph tag / character is optional.

For example, all of the examples below identify the start of a
paragraph:

~~~~ {.western}
> Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. Donec et auctor nisi. Curabitur eu sapien nisi. Donec in ipsum id ipsum dignissim tristique eget non justo.

.p Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. Donec et auctor nisi. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh.
 
p> Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. Donec et auctor nisi. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh.

[p] Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. Donec et auctor nisi. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh.

,,Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. Donec et auctor nisi. Suspendisse pellentesque, magna in consectetur fringilla, augue nisi venenatis nibh.
~~~~

\

Blockquotes {.western}
-----------

### Style {.western}

**{blockquotes}**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

lead: \<value\>

indent: \<value\>\<units\>

quad: left|right|center|justify

\

### Usage {.western}

**[blockquote]**

...

**[end]**

Quotes {.western}
------

### Style {.western}

**{quotes}**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

lead: \<value\>

indent: \<value\>\<units\>

quad: left|right|center|justify

\

\

### Usage {.western}

**[quote]**

...

**[end]**

Footnotes {.western}
---------

### Style {.western}

**{footnotes}**

family: \<string\>

font: \<string\>

size: \<string\>

color: \<string\>

lead: \<value\>

quad: left|right|center|justify

padding: \<value\>\<units\>

marker: star|number

spacing: \<value\>\<units\>

rule-weight:\<value\>

rule-length:\<value\>\<units\>

rule-adjust:\<value\>\<units\>

no-rule //If you don't want a horizontal rule.

reset-on-new-page //To restart note numbering on each page.

\

### Usage {.western}

\<text\>**[\*]**.

...

**[footnote]**

...

**[end]**

\

Example:

~~~~ {.western}
He was a manager[*] while she was a leader[*].

[footnote]
A manager is someone who manages other people.
[end]

[footnote]
A leader is someone who leads other people.
[end]
~~~~

Endnotes (coming...) {.western}
--------------------

{endnotes}

to do...

### Usage {.western}

\<text\>**[****+****]**.

...

**[endnote]**

...

**[end]**

\

Example:

~~~~ {.western}
He was a manager[+] while she was a leader[+].

[endnote]
A manager is someone who manages other people.
[end]

[endnote]
A leader is someone who leads other people.
[end]
~~~~

Lists {.western}
-----

### Style {.western}

**{lists}**

type: alpha|ALPHA|numbered|roman|ROMAN|bullet|dash

start-at: \<value\>

prefix: \<char\>

enumerator: \<char\>

space-before: \<value\>\<units\>

space-after: \<value\>\<units\>

item-spacing: \<value\>\<units\>

padding: \<value\>\<units\>

family: \<string\>

font: \<string\>

size: \<value\>

autolead:

quad: left|right|center|justify

indent: \<value\>\<units\>

auto-indent:

color: \<string\>

padding: left|right

\

### Usage {.western}

**[list]**

@ item 1

@ item 2

**[end]**

\

### Options {.western}

\
 \

### List styles {.western}

[list] \<by itself will use the default which was set in {lists}\>
(coming...)

[list 1] \<numbered\>

[list a] \<alpha\>

[list A] \<ALPHA\>

[list i] \<roman\>

[list I] \<ROMAN\>

[list -] \<dash\>

[list \*] \<bullet\>

\

### Prefix and Enumerators {.western}

A prefix and enumerator characters can be specified for lists of type
numbered, alpha, ALPHA, roman and ROMAN. Examples of commonly used
prefix characters: \# ( \> and enumerator characters: ) . \>

Examples:

\

  ------------------------------------------------------------- -------------
  Input                                                         Output

  *//Numbered with . As enumerator.*                            ​1. apple
                                                                
  [list 1.]                                                     ​2. orange
                                                                
  @ apple                                                       
                                                                
  @ orange                                                      
                                                                
  [end]                                                         

  *//Numbered starting at 3, with ( prefix and ) enumerator.*   ​(3) apple
                                                                
  [list (3)]                                                    ​(4) orange
                                                                
  @ apple                                                       
                                                                
  @ orange                                                      
                                                                
  [end]                                                         

  *//Bulleted list*                                             ● apple
                                                                
  [list \*]                                                     ● orange
                                                                
  @ apple                                                       
                                                                
  @ orange                                                      
                                                                
  [end]                                                         

  *//Dashed list*                                               - apple
                                                                
  [list -]                                                      - orange
                                                                
  @ apple                                                       
                                                                
  @ orange                                                      
                                                                
  [end]                                                         
                                                                
  \                                                             
                                                                

  *//Alpha list with ) as enumerator*                           ​a) apple
                                                                
  [list a)]                                                     ​b) orange
                                                                
  @ apple                                                       
                                                                
  @ orange                                                      
                                                                
  [end]                                                         
                                                                
  \                                                             
                                                                

  *//Roman list starting at 3 with ) as enumerator*             ​iii) apple
                                                                
  [list iii)]                                                   ​iv) orange
                                                                
  @ apple                                                       
                                                                
  @ orange                                                      
                                                                
  *[end]*                                                       
  ------------------------------------------------------------- -------------

\

\

Now some examples of additional list options:

\

  -------------------------------------------- --------
  Input                                        Output

  *//**Nested lists, the second is indented*   \
                                               
  **[list 1.]**                                
                                               
  @ apple                                      
                                               
  @ orange                                     
                                               
  **[list a)]**                                
                                               
  **indent: 18p**                              
                                               
  @ trees                                      
                                               
  @ rocks                                      
                                               
  **[end]**                                    
                                               
  **[end]**                                    

  *//Increase the space between items*         \
                                               
  **[list a)]**                                
                                               
  **item-spacing: 20p**                        
                                               
  @ apple                                      
                                               
  @ orange                                     
                                               
  @ pear                                       
                                               
  **[end]**                                    

  *//Set space before and after the list*      \
                                               
  **[list a)]**                                
                                               
  **space-before: 20p**                        
                                               
  **space-after: 20p**                         
                                               
  @ apple                                      
                                               
  @ orange                                     
                                               
  @ pear                                       
                                               
  **[end]**                                    
  -------------------------------------------- --------

\

\

Table of Contents {.western}
-----------------

### Style {.western}

**{contents}**

**\#general**

family: \<string\>

font: \<string\>

size: \<value\>

lead: \<value\>

pagination-style: digit|alpha|ALPHA|roman|ROMAN|none

spaced-entries //To space entries automatically, best as possible

recto-verso //For recto-verso

no-pagination //Same as pagination-style: none

**\#header**

vertical-position: \<value\>\<units\>

string: \<string\>

family: \<string\>

font: \<string\>

size: \<value\>

quad: left|right|center|justify

color: \<string\>

caps //For ALL CAPS

underline //For underlining the TOC Heading string

**\#titles**

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

indent: \<value\>\<units\>

caps //For ALL CAPS

**\#h****x** *(where x is heading level number 1, 2, 3 etc...)*

family: \<string\>

font: \<string\>

size: \<value\>

color: \<string\>

indent: \<value\>\<indent\>

prefix-number-style: full|truncate|none

caps //For ALL CAPS

**\#entry-page-numbers**

family: \<string\>

font: \<string\>

size: \<value\>

padding:\<value\>

\

### Usage {.western}

**[contents]**

The `contents`{.western} tag is used to insert a table of contents into
the working document.

Example:

~~~~ {.western}
{contents}
#general
  family: berling
  font:   bold
  size:   10
  lead:   12  
  pagination-style: roman
  spaced-entries
  recto-verso
#header
  vertical-position:  1cm
  string: Contents
  family: berling
  font:   italic
  size:   14
  quad:   left
  color:  blue
  caps
  underline
#titles
  family: berling
  font:   roman
  size:   13
  color:  red 
  indent: 1cm
  caps
#h1
  family: times
  font:   italic
  size:   10
  color:  green
  indent: 1.5cm
  prefix-number-style: full
#page-numbers
  family: times
  font:   bold
  size:   -2

[cover]
...
[end]

[copyright]
...
[end]

[contents]

[chapter 1] The Light
Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. 
~~~~

\

\

\

\

Dropcaps {.western}
--------

### Style {.western}

**{dropcaps}**

family: \<string\>

font: \<string\>

adjust: +/-\<value\>

color: \<string\>

gutter: \<value\>\<units\>

condense%: \<value\>

expand%: \<value\>

linespan: \<value\>

### Usage {.western}

**[char]**\<string\>

Example:

~~~~ {.western}
{dropcaps}
font:   bold
color:  red
linespan:   3

[chapter 1] The Light
[I]n the begining there was light. Ut eu arcu porttitor, molestie libero ac, condimentum sem. Sed in orci sed erat egestas euismod. Donec euismod sagittis dictum. 
~~~~

Inline Formatting {.western}
=================

### Usage {.western}

Text **\<option\<***text***\>** text.\
 Text **\<option value\<***text***\>** text.\
 Text **\<option1, option2, option3\<***text***\>** text.\
 Text **\<option1, option2****value****\<***text***\>** text.

\

Alignment and Quadding {.western}
======================

Alignment {.western}
---------

Alignment shifts the text to the left, right or center without adjusting
or filling.

### Usage {.western}

{left|right|center}

Quadding {.western}
--------

Quadding differs from alignment in that the text is adjusted to fill
from one margin to the other in the best way possible.

### Usage {.western}

{quad: left|right|center|justify}

{justify}

\

Typographic Refinements {.western}
=======================

Kerning {.western}
-------

### Toggle {.western}

{kerning: on}\
 {kerning: off}

\

Pair Kerning {.western}
------------

### Usage {.western}

X**\<-1\>**y

X**\<+2\>**y

\

### **Example** {.western}

~~~~ {.western}
T<-1>here was a spectacular arrangement of f<+2>lowers.
~~~~

Ligatures {.western}
---------

### Toggle {.western}

{ligatures: on}

{ligatures: off}

Hyphenation {.western}
-----------

### Parameters {.western}

{hyphenation}

max-consecutive-lines: \<value\>

margin: \<value\>\<units\>

space: \<value\>\<units\>

### Toggle {.western}

{hyphenation: on}

{hyphenation: off}

\
 \

If hyphenation parameters are defined with `{hyphenation}`{.western},
hyphenation is automatically turned on.

Special Characters {.western}
==================

Aliases {.western}
-------

**{aliases}**

\<word\> = \<sring\>

\

The `{alias`{.western}`es`{.western}`}`{.western} directive instructs
the *TML*parser**to scan the document and replace all instances of
`<word>`{.western} with `<string>`{.western}, wherever it is encountered
within `[...]`{.western} and `<...<`{.western} tags. This provides the
user the ability to create “shorthand” to replace other commands or
multiple commands. The `{alias}`{.western} directive also makes it
possible to easily add internationalization and language customization.

Example:

~~~~ {.western}
{aliases}
chapitre    = chapter
berling1 = family berling, italic, size +2
berline2 = family berling, italic, size -2
 
[chapitre 2] L'ours et la tortue
Il existait un gros <berling1<ours> et une petite <berling1<tortue>.
~~~~

\

In this example, the instances of `chapitre`{.western},
`berling1`{.western} and `berling`{.western}`2`{.western} are expanded
when they are encountered within `[...]`{.western} or `<...<`{.western}
anywhere in the document after `{aliases}`{.western} has been defined.
The example becomes:

\

~~~~ {.western}
[chapter 2] L'ours et la tortue
Il existait un gros <family berling, italic, size +2<ours> et une petite <family berling, italic, size -2<tortue>.
~~~~

\

User-defined Strings {.western}
--------------------

### Usage {.western}

**{strings}**

\#br = [br]

\#chapter-string = \\E\*[\$CHAPTER\_STRING]

\#chapter-number = \\E\*[\$CHAPTER]

\#chapter-title = \\E\*[\$CHAPTER\_TITLE]

\#page-number = \\\*[PAGE\#]

\

If the parser encounters any instances of \#string anywhere in the TML
document, it will be expanded with its synonym.

Hyphenation Dictionnary {.western}
-----------------------

### Usage {.western}

**{dictionnary}**

my-so-gy-ny

do-mi-na-trix

\

/\* not implemented yet \*/

Including External Files {.western}
------------------------

**{include}**

\<filename\>.tml

\

The `{include}`{.western} directive instructs the *TML*parser to insert
the files specified. The insertion happens there where the directive is
encountered.

\

Having the ability to `{include}`{.western} external files makes it
simple to quickly change the style of a document by saving them as
stylesheets and including them in our working document:

\

~~~~ {.western}
{include}
modern-syle.tml
~~~~

\

where `modern-style.tml`{.western} is a file that contains style
configuration for various document elements:

\

~~~~ {.western}
{page}
size: trade

{margins}
left:   1cm
right: 1cm

{blockquotes}
family: aragon
font:   italic
indent:18p
~~~~

\

We could also create a set of `{aliases}`{.western} and simply include
it in our working document. For example:

\

~~~~ {.western}
{include}
modern-style.tml
em/languages/french.tml
~~~~

\

where `french.tml`{.western} is a file in which was defined a list of
french commands and their mapping to default *TML*directives:

\

~~~~ {.western}
{aliases}
chapitre    = chapter
table des matieres  = contents 
liste       = list
gras        = bold
~~~~

\
