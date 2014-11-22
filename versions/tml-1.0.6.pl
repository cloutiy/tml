#!/usr/bin/env perl 
# V. 1.0.6
# Release notes:
# Fixed
#~~~~~~~
# blocks now in the following format:
# {paragraph}
# option:   value
# option:   value
#
# Added
#~~~~~~~


# Todo
#~~~~~

#
#:::::::::::::::::: VARIABLES ::::::::::::::::::
@elementStack=();	#Keeps track of what the current element tag is
$hasEndnotes="";	#If we use [endnote], .ENDNOTES must be added at the end of the document
$hasToc="";			#If we use [tableofcontents], we must insert .TOC at the end of the document
$firstChapter = "true"; #IF it's the first chapter, we don't want to include the .COLLATE command
%aliases ={};
@blocktypes = ("page", "paper", "margin", "font", "justification", "line", "kerning", "hyphenation", "smartquotes", "header", "chapter", "paragraph");

#:::::::::::::::::: FILE I/O ::::::::::::::::::::
# Load the input TML document into an array of strings
open(FILE, $ARGV[0]) || die("Could not open $ARGV[0]\n");
@tmlfile = <FILE>;
close(FILE);
unshift(@tmlfile, "{typeset}\n");	# Add {typeset} at the start of the document => {typeset} should be the default


#%definitions = loadDefinitions();
#loadDefinitions();

# Between [replace]...[end], store user defined commands in a dictionary
sub loadDefinitions {
    @temp = ();
	# Find the index of [replace]
    for ($i = 0; $i < @tmlfile; $i++) {
        if ($tmlfile[$i] =~ /\[replace\]/) {
            $start_idx = $i;    # save the index
            last;
        }
    }
    #Find the index of [end]
    for ($i = $start_idx; $i < @tmlfile; $i++) {
        if ($tmlfile[$i] =~ /\[end\]/) {
            $end_idx = $i;    # save the index
            last;
        }
    }
    $i = $start_idx + 1;
    for ($i; $i < $end_idx; $i++) {
        if ($tmlfile[$i] =~ /(.+)\s+with\s+(.+)/)
        {
            #print "Replace $1 => $2\n";
            $aliases{$1} = $2;
        }
    }
    #print "Found [replace] at : $start_idx\n";
    #print "Found [end] at : $end_idx\n";
    #Remove [replace]...[end] from the array...we just needed it for the purpose of loading up the aliases.
    splice(@tmlfile, $start_idx, $end_idx); 
}

# Print out the MOM file.
#foreach $_ (@tmlfile){print $_;}

sub replaceAliases {
    foreach my $command ( keys %aliases )
    {
        #print "Command: $command\n";
        #print "Replacing: $command with: $aliases{$command}\n";
        #if (/$command/) {$_ =~ s/$command/$aliases{$command}/;}
        if (/(<.*?)$command(.*?)</) {$_ =~ s/(<.*?)$command(.*?)</$1$aliases{$command}$2</;}
        if (/(\[.*?)$command(.*?)\]/) {$_ =~ s/(\[.*?)$command(.*?)\]/$1$aliases{$command}$2\]/;}
        if (/(\{.*?)$command(.*?)}/) {$_ =~ s/(\{.*?)$command(.*?)}/$1$aliases{$command}$2}/;}
    }
}





#:::::::::::::::::: MAIN PROGRAM ::::::::::::::::
# Go through each line of the input file and translate the TML Markup into Groff
$currentElement = 0; # Just a counter
foreach $_ (@tmlfile){
#	includeFiles(); # Not working....will have to work on this later.
#    replaceAliases();
    replaceConfigBlocks();
	replaceMetadata();
	replacePrintStyle();
	replacePageLayout();
	replaceFonts();
	replaceMargins();
	replaceLeading();
	replaceJustification();
	replaceParagraphLayout();
	replaceKerning();
	replaceLigatures();
	replaceLanguage();
	replaceHyphenation();
	replaceSmartquotes();
	replaceCoverPage();
	replaceTitlePage();
	replaceCopyrightPage();
	replaceAlign();
	replaceHeaders();
	replaceToc();
	replaceChapter();
	replaceChaptersOnOddPages();
	replaceEpigraph();
	replaceEpigraphBlock();
	replaceSection();
	replaceSubsection();
	replaceSubsubsection();
	replaceBlockquote();
	replaceQuote();
	replaceList();
    replaceListOptions();
	replaceListItem();
	replaceEnd(); 
	replaceParagraph();
	replaceFootnote();
	replaceEndnote();
	replaceStartFinis();
#	replaceBoldItalic();
#	replaceItalic();
#	replaceBold();
	replaceEnDash();
	replaceEmDash();
	replaceEllipses();
	replaceNewline();
	replaceBlankline();
	replaceNewPage();
	replaceBlankPage();
#	replaceCollate();
	replaceSpecialChars();
	replaceComments();
	replaceBreak();

	parseCommands();
	$currentElement += 1;
}

# If [endnote] or [tableofcontents], we need to add .ENDNOTES and or .TOC at the end of the document.
insertEndnotes();
insertToc();

# Print out the MOM file.
foreach $_ (@tmlfile){print $_;}
#::::::::::::::::::::::::: END MAIN PROGRAM:::::::::::::::::::::::

#::::::::::::::::::::::::: FUNCTIONS :::::::::::::::::::::::::::::
sub includeFiles(){
    #Note: I think files will need to be loaded into an array and inserted into  @tmlfile array for things to work properly
	#$/ = undef;
	# If [include] filename is encountered...open the file, load its contents into the main TML file
	if (/\[include\]\s*(.*?)\n/){
		open(FILE, $1) || die("Could not open $1 on line $_\n");
    #    $_ = <FILE>;
    #    print "Opening $1";
		@includefile = <FILE>;
		close(FILE);
	}
	#foreach $_ (@includefile){print $_;}
	#print $includefile[1];
	$_ = "";
	$from = $currentElement;
	$to = @includefile;
	print "Insert at $from for a length of length $to\n";
	splice(@tmlfile, $from, $to, @includefile);
	#print $#includefile;
}
sub replaceAlign{
    if (/{align:\s*left}/){
        $_ =~ s/{align:\s*left}/\.LEFT/;
    }
    if (/{align-right}/){
        $_ =~ s/{align:\s*right}/\.RIGHT/;
    }
    if (/{align-center}/){
        $_ =~ s/{align:\s*center}/\.CENTER/;
    }
}
sub replaceMetadata {
		$_ =~ s/\[author\](.*?)/\.AUTHOR $1/;
		$_ =~ s/\[title\](.*?)/\.TITLE $1/;
		$_ =~ s/\[doctitle\](.*?)/\.DOCTITLE $1/;
		$_ =~ s/\[subtitle\](.*?)/\.SUBTITLE $1/;
		$_ =~ s/\[chaptertitle\](.*?)/\.CHAPTER_TITLE $1/;
		$_ =~ s/\[draft\](.*?)/\.DRAFT $1/;
		$_ =~ s/\[revision\](.*?)/\.REVISION $1/;
		$_ =~ s/\[covertitle\](.*?)/\.COVERTITLE $1/;
		$_ =~ s/\[doccovertitle\](.*?)/\.DOC_COVERTITLE $1/;
		$_ =~ s/\[pdftitle\](.*?)/\.PDF_TITLE $1/;
		$_ =~ s/\[printstyle\](.*?)/\.PRINTSTYLE $1/;
}

sub replacePrintStyle{
	if ($_ =~ m/{typewrite}/){
		$tmlfile[0] = ".PRINTSTYLE TYPEWRITE\n";
		$_ = "#\n";
	}elsif ($_ =~ m/{typewrite:\s*single-space/){
		$tmlfile[0] = ".PRINTSTYLE TYPEWRITE SINGLESPACE\n";
		$_ = "#\n";
	}else{
		$_ =~ s/{typeset}/\.PRINTSTYLE TYPESET/;
	}
	
}

sub replacePageLayout{
		#TODO: Implement user defined sizes
		#:: Page sizes by name
		$_ =~ s/{paper-size:\s*letter}/\.PAPER LETTER/;
		$_ =~ s/{paper-size:\s*legal}/\.PAPER LEGAL/;
		$_ =~ s/{paper-size:\s*statement}/\.PAPER STATEMENT/;
		$_ =~ s/{paper-size:\s*tabloid}/\.PAPER TABLOID/;
		$_ =~ s/{paper-size:\s*ledger}/\.PAPER LEDGER/;
		$_ =~ s/{paper-size:\s*folio}/\.PAPER FOLIO/;
		$_ =~ s/{paper-size:\s*quarto}/\.PAPER QUARTO/;
		$_ =~ s/{paper-size:\s*trade}/.PAGEWIDTH 6i\n.PAGELENGTH 9i/;
		
		$_ =~ s/{paper-size:\s*executive}/\.PAPER EXECUTIVE/;
		$_ =~ s/{paper-size:\s*10x14}/\.PAPER 10x14/;
		$_ =~ s/{paper-size:\s*a3}/\.PAPER A3/;
		$_ =~ s/{paper-size:\s*a4}/\.PAPER A4/;
		$_ =~ s/{paper-size:\s*a5}/\.PAPER A5/;
		$_ =~ s/{paper-size:\s*b4}/\.PAPER B4/;
		$_ =~ s/{paper-size:\s*b5}/\.PAPER B5/;
		$_ =~ s/{paper-size:\s*6x9}/.PAGEWIDTH 6i\n.PAGELENGTH 9i/;
		
		$_ =~ s/{page-size:\s*letter}/\.PAPER LETTER/;
		$_ =~ s/{page-size:\s*legal}/\.PAPER LEGAL/;
		$_ =~ s/{page-size:\s*statement}/\.PAPER STATEMENT/;
		$_ =~ s/{page-size:\s*tabloid}/\.PAPER TABLOID/;
		$_ =~ s/{page-size:\s*ledger}/\.PAPER LEDGER/;
		$_ =~ s/{page-size:\s*folio}/\.PAPER FOLIO/;
		$_ =~ s/{page-size:\s*quarto}/\.PAPER QUARTO/;
		$_ =~ s/{page-size:\s*trade}/.PAGEWIDTH 6i\n.PAGELENGTH 9i/;
		
		$_ =~ s/{page-size:\s*executive}/\.PAPER EXECUTIVE/;
		$_ =~ s/{page-size:\s*10x14}/\.PAPER 10x14/;
		$_ =~ s/{page-size:\s*a3}/\.PAPER A3/;
		$_ =~ s/{page-size:\s*a4}/\.PAPER A4/;
		$_ =~ s/{page-size:\s*a5}/\.PAPER A5/;
		$_ =~ s/{page-size:\s*b4}/\.PAPER B4/;
		$_ =~ s/{page-size:\s*b5}/\.PAPER B5/;
		$_ =~ s/{page-size:\s*6x9}/.PAGEWIDTH 6i\n.PAGELENGTH 9i/;

		#:: Page width and height
		$_ =~ s/{page-width:\s*(.+)}/\.PAGEWIDTH $1/;
		$_ =~ s/{page-height:\s*(.+)}/\.PAGELENGTH $1/;
		
		$_ =~ s/{paper-width:\s*(.+)}/\.PAGEWIDTH $1/;
		$_ =~ s/{paper-height:\s*(.+)}/\.PAGELENGTH $1/;
		
		#TODO: Implement user defined sizes
}

sub replaceMargins{
		#{marginleft:nx}
		#{marginright:nx}
		#{margintop:nx}
		#{marginbottom:nx}
		#{margins:nx nx nx nx}
		$_ =~ s/{margin-left:\s*(.+)}/\.L_MARGIN $1/;
		$_ =~ s/{margin-right:\s*(.+)}/\.R_MARGIN $1/;
		$_ =~ s/{margin-top:\s*(.+)}/\.T_MARGIN $1/;
		$_ =~ s/{margin-bottom:\s*(.+)}/\.B_MARGIN $1/;
		$_ =~ s/{margins:\s*(.+)\s*(.+)\s*(.+)\s*(.+)}/\.L_MARGIN $1\n\.R_MARGIN $2\n\.T_MARGIN $3\n\.B_MARGIN $4/;
}


sub replaceFonts{
		#{fontfamily:}
		$_ =~ s/{font-family:\s*avant-garde}/\.FAMILY A/;
		$_ =~ s/{font-family:\s*avantgarde}/\.FAMILY A/;
		$_ =~ s/{font-family:\s*avant-garde}/\.FAMILY A/;
		$_ =~ s/{font-family:\s*bookman}/\.FAMILY BM/;
		$_ =~ s/{font-family:\s*helvetica}/\.FAMILY H/;
		$_ =~ s/{font-family:\s*helvetica-narrow}/\.FAMILY HN/;
		$_ =~ s/{font-family:\s*helveticanarrow}/\.FAMILY HN/;
		$_ =~ s/{font-family:\s*new-century-schoolbook}/\.FAMILY N/;
		$_ =~ s/{font-family:\s*newcenturyschoolbook}/\.FAMILY N/;
		$_ =~ s/{font-family:\s*palatino}/\.FAMILY P/;
		$_ =~ s/{font-family:\s*times-roman}/\.FAMILY T/;
		$_ =~ s/{font-family:\s*times}/\.FAMILY T/;
		$_ =~ s/{font-family:\s*zapf-chancery}/\.FAMILY ZCM/;
		$_ =~ s/{font-family:\s*zapf}/\.FAMILY ZCM/;
		$_ =~ s/{font-family:\s*(.+)}/\.FAMILY $1/;
		
		#{fontstyle:}
		$_ =~ s/{font-style:\s*roman}/\.FT R/;
		$_ =~ s/{font-style:\s*r}/\.FT R/;
		$_ =~ s/{font-style:\s*italic}/\.FT I/;
		$_ =~ s/{font-style:\s*i}/\.FT I/;
		$_ =~ s/{font-style:\s*bold}/\.FT B/;
		$_ =~ s/{font-style:\s*b}/\.FT I/;
		$_ =~ s/{font-style:\s*bold-italic}/\.FT BI/;
		$_ =~ s/{font-style:\s*bolditalic}/\.FT BI/;
		$_ =~ s/{font-style:\s*bi}/\.FT I/;
		$_ =~ s/{font-style:\s*smallcaps}/\.FT SC/;
		$_ =~ s/{font-style:\s*sc}/\.FT BI/;
		
		#{fontsize:}
		$_ =~ s/{font-size:\s*(.+)}/\.PT_SIZE $1/;
		
		#{fontcolor:}
}

sub replaceLeading{
	#:: LINE SPACING/LEADING
	#{leading: 10/13} => sets PT_SIZE to 10 and .LS to 13 at same time
	$_ =~ s/{leading:\s*(.+)\/\s*(.+)}/\.PT_SIZE $1\n\.LS $2/;
	
	#{autoleading: [factor of] 2}  => maybe 
	
	#{linespacing: 13}
	$_ =~ s/{line-spacing:\s*(.+)}/\.LS $1/;
}

sub replaceJustification{
	#{justfication:left}
	$_ =~ s/{justification:\s*left}/\.QUAD LEFT/;
	$_ =~ s/{justify:\s*left}/\.QUAD LEFT/;
	$_ =~ s/{quad:\s*left}/\.QUAD LEFT/;
	$_ =~ s/{left-justified}/\.QUAD LEFT/;
	
	#{justfication:right}
	$_ =~ s/{justification:\s*right}/\.QUAD RIGHT/;
	$_ =~ s/{justify\s*right}/\.QUAD RIGHT/;
	$_ =~ s/{quad:\s*right}/\.QUAD RIGHT/;
	$_ =~ s/{right-justified}/\.QUAD RIGHT/;
	
	#{justification:center}
	$_ =~ s/{justification:\s*center}/\.QUAD CENTER/;
	$_ =~ s/{justify:\s*center}/\.QUAD CENTER/;
	$_ =~ s/{quad:\s*center}/\.QUAD CENTER/;
	$_ =~ s/{center-justified}/\.QUAD CENTER/;
	
	#{justification:full}
	$_ =~ s/{justification:\s*full}/\.QUAD JUSTIFIED/;
	$_ =~ s/{justify:\s*full}/\.QUAD JUSTIFIED/;
	$_ =~ s/{justify}/\.QUAD JUSTIFIED/;
	$_ =~ s/{justified}/\.QUAD JUSTIFIED/;
	$_ =~ s/{quad:\s*justified}/\.QUAD JUSTIFIED/;
	$_ =~ s/{full-justified}/\.QUAD JUSTIFIED/;
}

sub replaceParagraphLayout{
	#{paragraphindent: nx}
	$_ =~ s/{paragraph-indent:\s*(.+)}/\.PARA_INDENT $1/;
		
	#{paragraphspace: nx}
	$_ =~ s/{paragraph-spacing:\s*(.+)}/\.PARA_SPACE $1/;
	
	#{linelength:3i}
	$_ =~ s/{line-length:\s*(.+)}/\.LL $1/;
	$_ =~ s/{paragraph-line-length:\s*(.+)}/\.LL $1/; 
}

sub replaceKerning{
	#{kerning:on|off}
	$_ =~ s/{kerning:\s*on}/\.KERN/;
	$_ =~ s/{kerning-on}/\.KERN/;
	$_ =~ s/{kerning:\s*off}/\.KERN OFF/;
	$_ =~ s/{kerning-off}/\.KERN OFF/;
	
	# Inline pairwise kerning: F<-5>or the re<+5>cord.
	$_ =~ s/<-(\d+)>/\\\*\[BU $1\]/;
	$_ =~ s/<\+(\d+)>/\\\*\[FU $1\]/;

}
sub replaceLigatures{
	#{ligatures:on}
	#{ligatures:off}
	$_ =~ s/{ligatures:\s*on}/\.LIG/;
	$_ =~ s/{ligatures-on}/\.LIG/;
	$_ =~ s/{ligatures:\s*off}/\.LIG OFF/;
	$_ =~ s/{ligatures-off}/\.LIG OFF/;
}

sub replaceSmartquotes{
	#{smartquotes:on}
	#{smartquotes:off}
	$_ =~ s/{smartquotes:\s*on}/\.HY/;	
	$_ =~ s/{smartquotes-on}/\.HY/; 
	$_ =~ s/{smartquotes:\s*off}/\.HY OFF/;
	$_ =~ s/{smartquotes-off}/\.HY OFF/;
}

sub replaceHyphenation{
	#{hyphenation:on}
	#{hyphenation:off}
	$_ =~ s/{hyphenation:\s*on}/\.HY/;
	$_ =~ s/{hyphenation-on}/\.HY/; 
	$_ =~ s/{hyphenation:\s*off}/\.HY OFF/;
	$_ =~ s/{hyphenation-off}/\.HY OFF/;
	
	#{hyphenationlanguage:spanish}
	$_ =~ s/{hyphenation-language:\s*spanish}/\.hla es\n\.hpf hyphen\.es/;
	$_ =~ s/{hyphenation-language:\s*es}/\.hla es\n\.hpf hyphen\.es/;
	
	#{hyphenationmax:}
	$_ =~ s/{hyphenation-max-lines:\s*(.+)}/\.HY LINES $1/;
	$_ =~ s/{hyphenation-maxlines:\s*(.+)}/\.HY LINES $1/;
	
	#{hyphenationmargin:}
	$_ =~ s/{hyphenation-margin:\s*(.+)}/\.HY MARGIN $1/;
	
	#{hyphenationspace:}
	$_ =~ s/{hyphenation-space:\s*(.+)}/\.HY SPACE $1/;
	
	#{hyphenation:reset}
	$_ =~ s/{hyphenation:\s*reset}/\.HY DEFAULT/;
	$_ =~ s/{hyphenation-reset}/\.HY DEFAULT/;
	$_ =~ s/{hyphenation:\s*defaults}/\.HY DEFAULT/;
    $_ =~ s/{hyphenation-defaults}/\.HY DEFAULT/;
}

sub replaceSmartquotes{
	$_ =~ s/{smartquotes:\s*on}/\.SMARTQUOTES/;
	$_ =~ s/{smartquotes:\s*off}/\.SMARTQUOTES OFF/;
	$_ =~ s/{smartquotes:\s*danish}/\.SMARTQUOTES DA/;
	$_ =~ s/{smartquotes:\s*german}/\.SMARTQUOTES GE/;
	$_ =~ s/{smartquotes:\s*spanish}/\.SMARTQUOTES ES/;
	$_ =~ s/{smartquotes:\s*french}/\.SMARTQUOTES FR/;
	$_ =~ s/{smartquotes:\s*italian}/\.SMARTQUOTES IT/;
	$_ =~ s/{smartquotes:\s*dutch}/\.SMARTQUOTES NL/;
	$_ =~ s/{smartquotes:\s*norwegian}/\.SMARTQUOTES NO/;
	$_ =~ s/{smartquotes:\s*portugese}/\.SMARTQUOTES PT/;
	$_ =~ s/{smartquotes:\s*swedish}/\.SMARTQUOTES SV/;

	$_ =~ s/{smartquotes:\s*da}/\.SMARTQUOTES DA/;
	$_ =~ s/{smartquotes:\s*ge}/\.SMARTQUOTES GE/;
	$_ =~ s/{smartquotes:\s*es}/\.SMARTQUOTES ES/;
	$_ =~ s/{smartquotes:\s*fr}/\.SMARTQUOTES FR/;
	$_ =~ s/{smartquotes:\s*it}/\.SMARTQUOTES IT/;
	$_ =~ s/{smartquotes:\s*nl}/\.SMARTQUOTES NL/;
	$_ =~ s/{smartquotes:\s*no}/\.SMARTQUOTES NO/;
	$_ =~ s/{smartquotes:\s*pt}/\.SMARTQUOTES PT/;
	$_ =~ s/{smartquotes:\s*sv}/\.SMARTQUOTES SV/;
}
sub replaceCoverPage{
    if (/\[coverpage\]/){
        $_ =~ s/\[coverpage\]/\.PDF_BOOKMARK 1 "Cover Page"\n\.SP |4i-1v/;
        push(@elementStack, ".NEWPAGE\n.NEWPAGE");
    }
}
sub replaceTitlePage{
    if (/\[titlepage\]/){
        $_ =~ s/\[titlepage\]/\.PDF_BOOKMARK 1 "Title Page"\n\.SP |4i-1v/;
        push(@elementStack, ".NEWPAGE");
    }
}

sub replaceCopyrightPage{
    if (/\[copyright\]/){
        $_ =~ s/\[copyright\]/\.PDF_BOOKMARK 1 "Copyright"\n\.SP |4i-1v/;
        push(@elementStack, ".NEWPAGE");
    }
}  
sub replaceToc{
		if ($_ =~ s/\[tableofcontents\]//){
		   $hasToc = "true";
		   if ($tmlfile[$currentElement-1] =~ m/\.START/){
				$tmlfile[$currentElement-1] = ".AUTO_RELOCATE_TOC TOP\n.START\n";
		   }
		}
}
sub replaceEpigraph {
		if ($_ =~ s/\[epigraph\]/\.EPIGRAPH/){
		   push(@elementStack, ".EPIGRAPH OFF");
		}
}

sub replaceEpigraphBlock {
		if ($_ =~ s/\[epigraphblock\]/\.EPIGRAPH BLOCK/){
		   push(@elementStack, ".EPIGRAPH OFF");
		}
}

sub replaceChapter {
# IF [chapter] or [chapter xxx] appears on aline by itself, prepend [chapter] or [chapter xxx] to the start of the next line
if (m/\[chapter\s+(.+)\]\s*\n/) { $tmlfile[$currentElement+1] = "[chapter " . $1 ."] " . $tmlfile[$currentElement+1]; $_ = "#\n";}
if (m/\[chapter\]\s*\n/) { $tmlfile[$currentElement+1] = "[chapter] " . $tmlfile[$currentElement+1]; $_ = "#\n";}

# IF match [chapter], check if it's the first time. If yes do not put .COLLATE
if (m/\[chapter/) {    
    if ($firstChapter eq "true") {
        $firstChapter = "false";
        #[chapter 1] "Title"
        if (/\[chapter\s+(.+)\]\s*(".*?")/){#print "Matched [chapter 1] \"Title\"\n";
            $_ =~ s/\[chapter\s+(.+)\]\s*(".*?")/\.DOCTYPE CHAPTER\n\.CHAPTER $1\n\.CHAPTER_TITLE $2\n\.nr #CH_NUM 1\n\.START/;
        } elsif (/\[chapter\s+(.+)\]\s+([^"].+[^"])\s*\n/) {# print "Matched [chapter 1] Title\n";
            #[chapter 1] Title
            $_ =~ s/\[chapter\s+(.+)\]\s+([^"].+[^"])\s*\n/\.DOCTYPE CHAPTER\n\.CHAPTER $1\n\.CHAPTER_TITLE "$2"\n\.nr #CH_NUM 1\n\.START\n/;
        } elsif (/\[chapter\s+(.+)\]/) {#print "Matched [chapter 1]\n";
            #[chapter 1]
            $_ =~ s/\[chapter\s+(.+)\]/\.DOCTYPE CHAPTER\n\.CHAPTER $1\n\.CHAPTER_TITLE\n\.nr #CH_NUM 1\n\.START/;
        } elsif (/\[chapter\s+(.+)\]/) {#print "Matched [chapter 1] \"Title\"\n";
            #[chapter 1]
            $_ =~ s/\[chapter\s+(.+)\]/\.DOCTYPE CHAPTER\n\.CHAPTER $1\n\.CHAPTER_TITLE\n\.nr #CH_NUM 1\n\.START/;
        } elsif (/\[chapter\]\s*(".*?")/) {#print "Matched [chapter] \"Title\"\n";
            #[chapter] "Title"
            $_ =~ s/\[chapter\]\s*(".*?")/\.DOCTYPE CHAPTER\n\.CHAPTER_TITLE $1\n\.nr #CH_NUM 1\n\.START/;
        } elsif (/\[chapter\]\s+([^"].+[^"])\s*\n/) {#print "Matched [chapter] Title\n";
            #[chapter] Title
        $_ =~ s/\[chapter\]\s+([^"].+[^"])\s*\n/\.DOCTYPE CHAPTER\n\.CHAPTER_TITLE "$1"\n\.nr #CH_NUM 1\n\.START\n/;
        } elsif (/\[chapter\]/) {#print "Matched [chapter]\n";
            #[chapter]
            $_ =~ s/\[chapter\]/\.DOCTYPE CHAPTER\n\.CHAPTER_TITLE\n\.nr #CH_NUM 1\n\.START/;
        } else {
        }
		
#        $_ =~ s/\[chap\s*(.+)\]\s*(.+)/\.DOCTYPE CHAPTER\n\.CHAPTER $1\n\.CHAPTER_TITLE $2\n\.nr #CH_NUM 1\n\.START/;
#        $_ =~ s/\[chap\s*(.+)\]/\.DOCTYPE CHAPTER\n\.CHAPTER $1\n\.CHAPTER_TITLE\n\.nr #CH_NUM 1\n\.START/;
#        $_ =~ s/\[chap\]\s*(.+)/\.DOCTYPE CHAPTER\n\.CHAPTER_TITLE $1\n\.nr #CH_NUM 1\n\.START/;
#        $_ =~ s/\[chap\]/\.DOCTYPE CHAPTER\n\.CHAPTER_TITLE\n\.nr #CH_NUM 1\n\.START/;
    } else { 
        if (/\[chapter\s+(.+)\]\s*(".*?")/) {#print "Matched other [chapter 1] \"Title\"\n";
            #[chapter 1] "Title"
            $_ =~ s/\[chapter\s+(.+)\]\s*(".*?")/\.COLLATE\n\.CHAPTER $1\n\.CHAPTER_TITLE $2\n\.START/;
        } elsif (/\[chapter\s+(.+)\]\s+([^"].+[^"])\s*\n/) {#print "Matched other [chapter 1] Title\n";
            #[chapter 1] Title
            $_ =~ s/\[chapter\s+(.+)\]\s+([^"].+[^"])\s*\n/\.CHAPTER $1\n\.CHAPTER_TITLE "$2"\n\.START\n/;
        } elsif (/\[chapter\s+(.+)\]/) {#print "Matched other [chapter 1]\n";
            #[chapter 1]
            $_ =~ s/\[chapter\s+(.+)\]/\.COLLATE\n\.CHAPTER $1\n\.CHAPTER_TITLE\n.START/;
        } elsif (/\[chapter\]\s*(".*?")/) {#print "Matched other [chapter] \"Title\"\n";
            #[chapter] "Title"
            $_ =~ s/\[chapter\]\s*(".*?")/\.CHAPTER_TITLE $1\n\.START/;
        } elsif (/\[chapter\]\s+([^"].+[^"])\s*\n/) {#print  "Matched other [chapter] Title\n";
            #[chapter] Title
            $_ =~ s/\[chapter\]\s+([^"].+[^"])\s*\n/\.COLLATE\n\.CHAPTER_TITLE "$1"\n\.START\n/;
        } elsif (/\[chapter\]/) {#print "Matched other [chapter]\n";
            #[chapter]
            $_ =~ s/\[chapter\]/\.COLLATE\n\.CHAPTER_TITLE\n\.START/;
        } else {
        }

        
#        $_ =~ s/\[chap\s+(.+)\]\s*(".*?")/\.COLLATE\n\.CHAPTER $1\n\.CHAPTER_TITLE $2\n\.START/;
        #[chapter 1] Title
        #$_ =~ s/\[chap\s+(.+)\]\s+([^"].+[^"])\s*\n/\.CHAPTER $1\n\.CHAPTER_TITLE "$2"\n\.START\n/;
        #$_ =~ s/\[chap\s+(.+)\]/\.COLLATE\n\.CHAPTER $1\n\.CHAPTER_TITLE\n\.START/;
        #$_ =~ s/\[chap\]\s+(".+")/\.COLLATE\n\.CHAPTER_TITLE $1\n\.START/;
        #[chapter] Title
        #$_ =~ s/\[chap\]\s+([^"].+[^"])\s*\n/\.CHAPTER\n\.CHAPTER_TITLE "$1"\n\.START\n/;
        #$_ =~ s/\[chap\]/\.COLLATE\n\.CHAPTER_TITLE\n\.START/;
    }
} 
}

sub replaceSection {
		$_ =~ s/\[section\]/\.HEADING 1/;
		$_ =~ s/\[sec\]/\.HEADING 1/;
		$_ =~ s/\[heading 1\]/\.HEADING 1/;
		$_ =~ s/\[heading1\]/\.HEADING 1/;
		$_ =~ s/\[h1\]/\.HEADING 1/;
}

sub replaceSubsection {
		$_ =~ s/\[subsection\]/\.HEADING 2/;
		$_ =~ s/\[subsec\]/\.HEADING 2/;
		$_ =~ s/\[heading2\]/\.HEADING 2/;
		$_ =~ s/\[heading 2\]/\.HEADING 2/;
		$_ =~ s/\[h2\]/\.HEADING 2/;
}

sub replaceSubsubsection {
		$_ =~ s/\[subsubsection\]/\.HEADING 3/;
		$_ =~ s/\[subsubsec\]/\.HEADING 3/;
		$_ =~ s/\[heading3\]/\.HEADING 3/;
		$_ =~ s/\[heading 3\]/\.HEADING 3/;
		$_ =~ s/\[h3\]/\.HEADING 3/;
}

sub replaceBlockquote {
		if ($_ =~ s/\[blockquote\]/\.BLOCKQUOTE/){
		   push(@elementStack, ".BLOCKQUOTE OFF");
		}
}

sub replaceQuote {
		if( $_ =~ s/\[quote\]/\.QUOTE/){
			push(@elementStack, ".QUOTE OFF");
		}
}

sub replaceList {
		if( $_ =~ s/\[list:\s*digit\]/\.LIST DIGIT/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*dash\]/\.LIST DASH/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*bullet\]/\.LIST BULLET/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*alpha\]/\.LIST alpha/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*ALPHA\]/\.LIST ALPHA/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list\]/\.LIST DIGIT/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*(roman.*?)\]/\.LIST $1/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*(ROMAN.*?)\]/\.LIST $1/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*square\]/\.LIST USER \\[sq\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*hand\]/\.LIST USER \\[rh\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*arrow\]/\.LIST USER \\[->\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*dblarrow\]/\.LIST USER \\[rA\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*checkmark\]/\.LIST USER \\[OK\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:\s*user(.*?)\]/\.LIST USER "$1"/){
			push(@elementStack, ".LIST OFF");}
}
sub replaceListOptions {
        # if {start-at: } is used, start the list at the specified number.
        if (m/{start-at:\s*(.+)}/) {
            $listNumber = $1-1;
            $_ =~ s/{start-at:\s*(.+)}/\.nr #ENUMERATOR\\n\[#DEPTH\] $listNumber 1/;
        }
        if (m/{item-spacing:\s*(.+)}/) {
            $listNumber = $1-1;
            $_ =~ s/{item-spacing:\s*(.+)}/\.rn ITEM ITEM-old\n\.de ITEM\n\.sp $1\n\.ITEM-old\n\.\./;
            $_ =~ s/{list-item-spacing:\s*(.+)}/\.rn ITEM ITEM-old\n\.de ITEM\n\.sp $1\n\.ITEM-old\n\.\./;
        }
}
sub replaceListItem {
        $_ =~ s/^\s*?\*\s*(.*?)/\.ITEM\n$1/;
	
}

sub replaceEnd {
		if ($_ =~ m/\[end\]/){ 
			$end = shift(@elementStack);
			$_ =~ s/\[end\]/$end/;
		}
}

sub replaceParagraph {
		$_ =~ s/^\t/\.PP\n/;
}

sub replaceStartFinis(){
			$_ =~ s/\[start\]/\.START/;
			$_ =~ s/\[finis\]/\.FINIS/;
}

sub replaceFootnote(){
		if ($_ =~ m/\[\*(.*?)\]/){
			$_ =~ s/\[\*(.*?)\]/<footnote<$1>/g; # Replace [*...] with <footnote<...> 
			$_ =~ s/\s+<footnote<(.*?)>/<footnote<$1>/g; # Remove spaces before the footnote
			$_ =~ s/(\w*?)<footnote<(.*?)>/$1\\c<footnote<$2>/g; # Add \c to the last character before the footnote.
			$_ =~ s/<footnote<(.*?)>\./<footnote<$1>\\&\./g; # Add \& before the period so that groff sees it as a period.
		}
}

sub replaceEndnote(){
		if ($_ =~ m/\[.*?\*\]/){
			$_ =~ s/\[(.*?)\*\]/<endnote<$1>/g;
			$_ =~ s/\s+<endnote<(.*?)>/<endnote<$1>/g; # Remove spaces before the footnote
			$_ =~ s/(\w*?)<endnote<(.*?)>/$1\\c<endnote<$2>/g; # Add \c to the last character before the footnote.
			$_ =~ s/<endnote<(.*?)>\./<endnote<$1>\\&\./g; # Add \& before the period so that groff sees it as a period.
			$hasEndnotes = "true";
		}
}

sub replaceItalic(){
		# TODO: Replace *...with <italic< and process it parseCommands instead
		# Also replace ...* with >
		$_ =~ s/\*(.*?)\*/<italic<$1>/g;
}

sub replaceBold(){
		# TODO: Replace |...with <bold< and process it parseCommands instead
		# Also replace ...| with >
		$_ =~ s/\|(.*?)\|/<bold<$1>/g;  
}

sub replaceBoldItalic(){
		# TODO: Replace |*...with <bolditalic< and process it parseCommands instead
		# Also replace ...*| with >
		$_ =~ s/\|\*(.*?)\*\|/<bolditalic<$1>/g;  
}

sub replaceEnDash(){
		$_ =~ s/\s-\s/ \\[en\] /g;  
}

sub replaceEmDash(){
		$_ =~ s/--/\\[em\]/g;  
}

sub replaceSpecialChars{
 # Plus/minus (arithmetic) \[+-] 
 $_ =~ s/\|\+\/-\|/\\[\+-\]/g; 
 # Subtract (arithmetic) \[mi]
  $_ =~ s/\|-\|/\\[mi\]/g; 
 # Multiply (arithmetic) \[mu]
  $_ =~ s/\|x\|/\\[mu\]/g; 
 # Divide (arithmetic) \[di]
  $_ =~ s/\|\/\}/\\[di\]/g;  
 # Left double-quote \[lq] 
  $_ =~ s/\|lq\|/\\[lq\]/g; 
 # Right double-quote \[rq]
  $_ =~ s/\|rq\|/\\[rq\]/g; 
 # Open (left) single-quote \[oq]
  $_ =~ s/\|oq\|/\\[oq\]/g; 
 # Close (right) single-quote \[oq]
  $_ =~ s/\|oq\|/\\[oq\]/g; 
 # Bullet \[bu] 
  $_ =~ s/\|bu\|/\\[bu\]/g; 
  $_ =~ s/\|bullet\|/\\[bu\]/g; 
 #Ballot box \[sq]
  $_ =~ s/\|sq\|/\\[sq\]/g; 
  $_ =~ s/\|square\|/\\[sq\]/g; 
 # Checkmark \[OK]
  $_ =~ s/\|check\|/\\[OK\]/g; 
  $_ =~ s/\|checkmark\|/\\[OK\]/g; 
 # One-quarter \[14] 
  $_ =~ s/\|1\/4\|/\\[14\]/g; 
 # One-half \[12] 
  $_ =~ s/\|1\/2\|/\\[12\]/g; 
 # Three-quarters \[34] 
  $_ =~ s/\|3\/4\|/\\[34\]/g; 
 # Degree sign \[de] 
  $_ =~ s/\|de\|/\\[de\]/g; 
  $_ =~ s/\|deg\|/\\[de\]/g;
  $_ =~ s/\|degree\|/\\[de\]/g; 
  $_ =~ s/\|degrees\|/\\[de\]/g; 
 # Dagger \[dg] 
  $_ =~ s/\|dg\|/\\[dg\]/g; 
  $_ =~ s/\|dagger\|/\\[dg\]/g; 
 # Foot mark \[fm] 
  $_ =~ s/\|fm\|/\\[fm\]/g; 
  $_ =~ s/\|footmark\|/\\[fm\]/g; 
 # Cent sign \[ct] 
  $_ =~ s/\|ct\|/\\[ct\]/g; 
  $_ =~ s/\[cent\]/\\[ct\]/g; 
 # Registered trademark \[rg] 
  $_ =~ s/\|rg\|/\\[rg\]/g; 
  $_ =~ s/\|tm\|/\\[rg\]/g; 
  $_ =~ s/\|trademark\|/\\[rg\]/g; 
 # Copyright \[co] 
  $_ =~ s/\|co\|/\\[co\]/g;
  $_ =~ s/\|copyright\|/\\[co\]/g;
 # Section symbol \[se]
  $_ =~ s/\|se\|/\\[se\]/g; 
 # Foot and inch
 $_ =~ s/\|'\|/\\[foot\]/g; 
 $_ =~ s/\|"\|/\\[inch\]/g; 
 # Braces and brackets
 $_ =~ s/\|{\|/\{/g;
 $_ =~ s/\|lc\|/\{/g;
 $_ =~ s/\|}\|/\}/g; 
 $_ =~ s/\|rc\|/\}/g; 
 $_ =~ s/\|<\|/</g; 
 $_ =~ s/\|lt\|/</g; 
 $_ =~ s/\|>\|/>/g; 
 $_ =~ s/\|gt\|/>/g; 
 $_ =~ s/\|\[\|/\[/g; 
 $_ =~ s/\|ls\|/\[/g; 
 $_ =~ s/\|\]\|/\]/g; 
 $_ =~ s/\|rs\|/\]/g; 
}
sub replaceEllipses(){
		#$_ =~ s/\|\*(.*?)\*\|/\\\*\[BDI\]$1\\\*\[PREV\]/;  
}

sub replaceNewline(){
		# Replace empty lines => lines that start with \n
		$_ =~ s/^\n/\.\n/;
}

sub replaceNewPage(){
		$_ =~ s/\[newpage\]/\.NEWPAGE/;
}

sub replaceBlankPage(){
		$_ =~ s/\[blankpage\]/\.BLANKPAGE/;
}

sub replaceBlankline{
	$_ =~ s/\[blankline\]/\.SPACE/;
}
sub replaceComments{
		$_ =~ s/^\(!\)/\.\\"/;	
}
sub replaceChaptersOnOddPages{
    $_ =~ s/{chapters-on-odd-pages}/\.rn COLLATE COLLATE-OLD\n\.de COLLATE\n\. if o \.BLANKPAGE 1 DIVIDER\n\. COLLATE-OLD\n\.\./;
}
sub replaceHeaders{
    $_ =~ s/{headers-plain}/\..HEADER_PLAIN/;
    $_ =~ s/{plain-headers}/\..HEADER_PLAIN/;
    $_ =~ s/{header-font-family:\s*(.+)}/\.HEADER $1/;
    $_ =~ s/{header-font-style-left:\s*(.+)}/\.HEADER_FONT_LEFT $1/;
    $_ =~ s/{header-font-style-right:\s*(.+)}/\.HEADER_FONT_RIGHT $1/;
    $_ =~ s/{header-font-style-center:\s*(.+)}/\.HEADER_FONT_CENTER $1/;
    $_ =~ s/{header-font-family-left:\s*(.+)}/\.HEADER_FAMILY_LEFT $1/;
    $_ =~ s/{header-font-family-right:\s*(.+)}/\.HEADER_FAMILY_RIGHT $1/;
    $_ =~ s/{header-font-family-center:\s*(.+)}/\.HEADER_FAMILY_CENTER $1/;
    $_ =~ s/{header-string-left:\s*(.*?)}/\.HEADER_LEFT "$1"/;
    $_ =~ s/{header-string-right:\s*(.*?)}/\.HEADER_RIGHT "$1"/;
    $_ =~ s/{header-string-center:\s*(.*?)}/\.HEADER_CENTER "$1"/;
    $_ =~ s/{header-left-string:\s*(.*?)}/\.HEADER_LEFT "$1"/;
    $_ =~ s/{header-right-string:\s*(.*?)}/\.HEADER_RIGHT "$1"/;
    $_ =~ s/{header-center-string:\s*(.*?)}/\.HEADER_CENTER "$1"/;
}
sub replaceLanguage{
    $_ =~ s/{language:\s*spanish}/\.SMARTQUOTES ES\n\.hla es\n\.hpf hyphen\.es/;
}
sub parseCommands(){

#1. add the commands for opening group to an array
#2. Join the array to create  a string for the current command group
#3. Replace current token with string created above
#4. While doing 2, do 1 and 2 but for closing the commands - add to stack
#5. When > encountered - simply pop the stack and this will pop the string created to close all commands for that group.
#6. Replace current token '>" with the string just popped
#7. When no more tokens remain for the current line, reconstruct the current line by joining the tokenized line back into one string, and in which the <...<has been replaced with a string of all opening commands and > has been replaced with a string containing all correspondinf closing commands.
		$currentLine = $_;
		
		#Split current line into tokens
		@currentLine = split( /(<.*?<)/, $currentLine);	
		@currentLine = map { split( /(>)/, $_)} @currentLine;
		
		foreach $token (@currentLine){
			# Main: If token is <...<
			if (isCommandGroup($token) eq "true" ){
				# strip the < characters;
				$token =~ s/<//g;
				
				# Break the group into individual commands
				@commandGroup = getCommands($token);
				
				# Strip leading and trailing whitespace
				@commandGroup = stripspace(@commandGroup);
				
				# Now cycle through each command in the group
				foreach $command (@commandGroup){
					#print "Command: $command\n";
					# If the command has a value, we need to extract it and find its opposite to undo it.
					if (commandHasValue($command) eq "true")
					{
						#print "$command has a value...\n";
						$value = getValue($command);
						#print "Extracted value...$value\n";
						$revertValue = revertValue($value);
						#print "Revert value...$revertValue\n";
						# Generate the commandGroupOpen string and push its opposite to closeGroup
						if ($command =~ /bolder/)
						{ 
							$openGroup = $openGroup . ".SETBOLDER $value\n\\*[BOLDER]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[BOLDERX]");
						}
						elsif ($command =~ /slant/)
						{
							$openGroup = $openGroup . ".SETSLANT $value\n\\*[SLANT]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[SLANTX]");
						}
						elsif ($command =~ /condense/)
						{
							$openGroup = $openGroup . ".CONDENSE $value\n\\*[COND]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[CONDX]");
						}
						elsif ($command =~ /extend/)
						{
							$openGroup = $openGroup . ".EXTEND $value\n\\*[EXT]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[EXTX]");
						}
						elsif ($command =~ /caps/)
						{
							$openGroup = $openGroup . "\\*[SIZE $value]\\*[UC]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[SIZE]\\*[LC]");
						}
						elsif ($command =~ /size/)
						{
							$openGroup = $openGroup . "\\*[SIZE $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[SIZE]");
						}
						elsif ($command =~ /up/)
						{
							$openGroup = $openGroup . "\\*[UP $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[DOWN $value]");
						}
						elsif ($command =~ /down/)
						{
							$openGroup = $openGroup . "\\*[DOWN $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[UP $value]");
						}
						elsif ($command =~ /forward/)
						{
							$openGroup = $openGroup . "\\*[FWD $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[BCK $value]");
						}
						elsif ($command =~ /back/)
						{
							$openGroup = $openGroup . "\\*[BCK $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[FWD $value]");
						}
						elsif ($command =~ /^-/)
						{
							$openGroup = $openGroup . "\\*[SIZE $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[SIZE]");
						}elsif ($command =~ /^\+/)
						{
							$openGroup = $openGroup . "\\*[SIZE $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[SIZE]");
						}elsif ($command =~ /^\d.*?/)
						{
							$openGroup = $openGroup . "\\*[SIZE $value]"; 
							#print "$openGroup\n"; 
							push(@closeGroup, "\\*[SIZE]");
						}#end if(commandHasValue)
					# If command has no value		
					}else
					{
						if ($command eq "bolditalic" ){ $openGroup = $openGroup . "\\*[BDI]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "bi" ){ $openGroup = $openGroup . "\\*[BDI]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "italic"){ $openGroup = $openGroup . "\\*[IT]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "it"){ $openGroup = $openGroup . "\\*[IT]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "i"){ $openGroup = $openGroup . "\\*[IT]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "bold"){ $openGroup = $openGroup . "\\*[BD]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "bd" ){ $openGroup = $openGroup . "\\*[BD]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "b" ){ $openGroup = $openGroup . "\\*[BD]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command eq "monospaced"){ $openGroup = $openGroup . "\\*[CODE]"; push(@closeGroup,"\\*[CODE OFF]");}
						elsif ($command eq "mono"){ $openGroup = $openGroup . "\\*[CODE]"; push(@closeGroup,"\\*[CODE OFF]");}
						elsif ($command eq "m"){ $openGroup = $openGroup . "\\*[CODE]"; push(@closeGroup,"\\*[CODE OFF]");}
						elsif ($command eq "dropcap"){ $openGroup = $openGroup . ".DROPCAP "; push(@closeGroup," 2 COND 90\n");}
						elsif ($command =~ /smallcaps|sc/){ $openGroup = $openGroup . "\\f[SC]"; push(@closeGroup,"\\f[P]");}
						#elsif ($command =~ /condense|cond/){print "<condense>";push(@closeGroup,"</condense>");}
						elsif ($command eq "left" ){$openGroup = $openGroup . "\n.nf\n";push(@closeGroup,"\n.fi");}
						elsif ($command eq "right" ){$openGroup = $openGroup . "\n.rj 1000\n";push(@closeGroup,"\n.rj 0");}
						elsif ($command eq "center" ){$openGroup = $openGroup . "\n.ce 1000\n";push(@closeGroup,"\n.ce 0");}
						elsif ($command eq "uppercase" ){ $openGroup = $openGroup . "\\*[UC]"; push(@closeGroup,"\\*[LC]");}
						elsif ($command eq "caps" ){ $openGroup = $openGroup . "\\*[UC]"; push(@closeGroup,"\\*[LC]");}
						elsif ($command eq "uc" ){ $openGroup = $openGroup . "\\*[UC]"; push(@closeGroup,"\\*[LC]");}
						elsif ($command eq "lowercase" ){ $openGroup = $openGroup . "\\*[LC]"; push(@closeGroup,"\\*[UC]");}
						elsif ($command eq "lc" ){ $openGroup = $openGroup . "\\*[LC]"; push(@closeGroup,"\\*[UC]");}
						elsif ($command eq "footnote" ){ $openGroup = $openGroup . "\n.FOOTNOTE\n"; push(@closeGroup,"\n.FOOTNOTE OFF\n");}
						elsif ($command eq "endnote" ){ $openGroup = $openGroup . "\n.ENDNOTE\n"; push(@closeGroup,"\n.ENDNOTE OFF\n");}
					}#end if command has no value
				}#end foreach $command (@commandGroup)
				$newLine = $newLine . $openGroup; $openGroup = ""; 
				#print "After for each command in command group(should only contain openGroup): $newLine\n";
			# Main: If token is  >	
			}elsif ($token =~ />/)
			{ 
				#$token = join("", @closeGroup); 
				#$print $token; 
				$newLine = $newLine . join("", reverse(@closeGroup)); 
				@closeGroup=();
				#print "After >: $newLine\n";
			}
			# Main: If not <...< or >, regular text.
			else {
				$newLine = $newLine . $token;
				#print "After text: $newLine\n";
			}
		}#end foreach $token (@currentLine)
		#print "New current Line: $newLine\n";
		$_= $newLine; $newLine = "";
}

sub isCommandGroup{
        # Simply check if the token is in the format of <...<, return tru or false.
        $tkn = @_[0];
        #print "Tkn: $tkn\n";
	if ( $tkn =~ m/<.*?</){ #print "$tkn is a command group\n"; 
		return "true";}
	else {#print "$tkn is not a command group\n";
		return "false";}
}

sub getCommands{
	$tkn = @_[0];
	# Lets split the command group into individual commands
	# If there are commas, it means more than 1 command in the group
	# Otherwise there is only 1 command
	if ( $tkn =~ m/,/) 
	{ #print "$tkn has multiple commands...\n"; 
		@commands = split( /,/, $tkn );}
	else { #print "$tkn is a single command\n"; 
		@commands = $tkn;}
	return @commands;
}

sub stripspace{
	foreach $cmd (@_){$cmd =~ s/^\s+|\s+$//g;}
	return @_;

}

sub commandHasValue{
	$tkn = @_[0];
	# If there is a + or - (or none) followed by a numerical value, return true
	if ($tkn =~ m/[+-]?\d.*?/){ return "true";}
	elsif ($tkn =~ m/\d.*?/) { return "true";}
	else {return "false";}
}

sub getValue{
	$myval = @_[0]; 
	#if ($myval =~ /([+-]?\d.*?)/){ $myval = $1;}
	if ($myval =~ /([+]\d+(.*)?)/){ $myval = $1;}
	elsif ($myval =~ /([-]\d+(.*)?)/){ $myval = $1;}
	elsif ($myval =~ /(\d+(.*)?)/) { $myval = $1;}
	return $myval;
}

sub revertValue{
	$myval = @_[0];
	if ($myval =~ s/\-(\d.*?)/+$1/){ return $myval;}
	if ($myval =~ s/\+(\d.*?)/-$1/){ return $myval;}
	if ($myval =~ s/(\d.*?)/$1/){ return $myval;}
}

sub insertEndnotes{
	if ($hasEndnotes eq "true"){
		push(@tmlfile, ".ENDNOTES");
	}
}

sub insertToc{
	if ($hasToc eq "true"){
		push(@tmlfile, "\n.TOC");
	}
}

sub replaceBreak{
	  $_ =~ s/\[br\]/\n\.BR/g;
	  $_ =~ s/\[break\]/\n\.BR/g;
	  $_ =~ s/\[linebreak\]/\n\.BR/g;
	  
}
sub replaceConfigBlocks{
if (/{\s*(.+)\s*}/) {
    #If {typeset}, lets replace it now, otherwise it seems to cause problems with the rest of the logic here
    if ($1 eq "typeset") {
        $_ =~ s/{typeset}/\.PRINTSTYLE TYPESET/;
        next;
    }
    #Get the name of the string between {...}. We will match it against a set of keywords later
    $block = $1;
    $uppercaseblock = uc($block);
    #If {option: value}, do nothing, the command is already in its inline form.
    if (/:/) { 
    #Otherwise we need to convert the commands in the block to their inline form    
    } else {
        #Just generating a comment to identify the start of a config block
        $_ =~ s/{(.+)}/\.\\" START $uppercaseblock CONFIG/;
        #Go through each line in the block until \n and put the braces around the directives
        for ($i=$currentElement+1; $i < 100; $i++) {
            #If we encounter \n it means its the end of the block - quit this loop.
            if ($tmlfile[$i] eq "\n" ) {
                #Add a comment to identify the end of the block
                $tmlfile[$i] = ".\\\"" . " END $uppercaseblock CONFIG\n.\n";
                last;
            } else {
                #Prepend the string in the block to each of the config items: $string-spacing: value
                if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)/) {
                    if ( grep $_ eq $block, @blocktypes ) {
                        $tmlfile[$i] = "{$block-$1: $2}\n";
                    } else {$tmlfile[$i] = "{$1: $2}\n";}
                }
             }
         }
    }
}
}
