# Typesetting Markup Language

Lightweight Markup languages like Markdown help to increase productivity and insulate users of the technical complexity of their target platforms.

Although Markdown offers a simple way of handling structural elements of a document (headings, blockquotes, lists etc..), it does not provide a way to address stylistic elements of a document, such as:

- font manipulation (font family, size, color) 
- typographical features (word spacing, pair kerning, vertical and horizontal positioning on a page, margins, indentation, text justification and text flow).

TML addresses the needs of typographers, authors, writers that need a little more control over the visual elements of text offered by more complex systems asich as TeX and Groff, in a way that insulates the user from having to know TeX or Groff, yet still benefit from their powerful features and beautiful output. 

# Generated Output
Currently the TML interpretter generates only .mom and .pdf.  However once the core spec has been implemented, it will be possible to generate:

- plain text
- html
- xml
- mom
- groff
- latex
- context
- pdf
- epub
- and many more...

Heavily inspired by Peter Schaffter's tremendous work and relies on his [MOM macros](http://www.schaffter.ca/mom/mom-05.html) for groff.

## How do I use it?

Well, first you will need to have Peter Schaffter's MOM macros installed [MOM macros](http://www.schaffter.ca/mom/mom-05.html).

Then you can run:

`perl tml.pl showcase.tml`

This will spit stuff out on the screen. If you want the output to be saved to a file, do:

`perl tml.pl showcase.tml > showcase.mom`

Finally, if you want to turn the resulting .mom file into a pdf:

`pdfmom showcase.mom > showcase.pdf`

## Some final notes

1. I am not really a programmer, this is all one big experiment. If you can improve on my code...please do!
2. This is still just a prototype...use at your own risk!

