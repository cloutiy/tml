The Typesetting Markup Language
===============================
*TML v0.1.7*

**Please see WIKI for comprehensive documentation**

TML is an attempt to create a typesetting language that is simple, elegant and easy to understand and use.

The current implementation targets **groff** as the target output, which can then be used to generate professional quality postscipt and PDF documents.

Groffers will rejoice in knowing that since **groff** is under the hood, you may also include groff code in TML documents. The parser will simply pass over and include them in the generated output.  Note however the current implementation depends heavilty on Peter Schaffter's **MOM macros**.

Although usable, it is still a proof of concept, an experiment and an attempt to attract more users to the world of `groff.`  After more than a year of secrecy, Peter and I thought it was time to share with other what we had been up to, and how an elegant markup could help make things easier for new users.

## Samples
As a starting point, I recommend you have a look at the `tests` folder to see examples of what TML markup looks like.
Examples of complete works typeset using `TML`, or a combination of `TML` and `groff` will be added shortly.

**Please see WIKI for comprehensive documentation**

## How do I use it?

Well, first you will need to have Peter Schaffter's MOM macros installed [MOM macros](http://www.schaffter.ca/mom/mom-05.html).

Then you can run:

`perl tml.pl filename.tml`

This will spit stuff out on the screen. If you want the output to be saved to a file, do:

`perl tml.pl filename.tml > filename.mom`

Finally, if you want to turn the resulting .mom file into a pdf:

`pdfmom filename.mom > filename.pdf`

## Some final notes

1. I am a hobby programmer and this is all one big experiment. If you want to contribute...please do!
2. Although it produces useable output, this is still just a prototype.
3. If there is enough interest in this project, I would ideally see TML being backend agnostic, and using an architecture that would read tokens into a parse tree, and code generators to output various targets, such as laTex, HTML, markdown or even directly to PDF.

