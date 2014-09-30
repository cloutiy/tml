# V. 1.0
# Release notes:
# - String for Metadata and heading titles must be enclosed in quotes.  Will fix that later.
# - Should not have spaces in element blocks [...] or [...:...]

# TODO:
# 1) Add &\ before period after footnote/endnote
# 2) Add .ENDNOTES at end of doc if endnotes are used.

#:::::::::::::::::: VARIABLES ::::::::::::::::::
@elementStack=();	#Keeps track of what the current element tag is
$hasEndnotes="";	#If we use [endnote], .ENDNOTES must be added at the end of the document
$hasToc="";			#If we use [tableofcontents], we must insert .TOC at the end of the document

#:::::::::::::::::: FILE I/O ::::::::::::::::::::
# Load the input TML document into an array of strings
open(FILE, $ARGV[0]) || die("Could not open $ARGV[0]\n");
@tmlfile = <FILE>;
close(FILE);

#:::::::::::::::::: MAIN PROGRAM ::::::::::::::::
# Go through each line of the input file and translate the TML Markup into Groff
foreach $_ (@tmlfile){
	includeFiles();
	replaceMetadata();
	replacePageLayout();
	replaceFonts();
	replaceMargins();
	replaceLeading();
	replaceJustification();
	replaceParagraphLayout();
	replaceKerning();
	replaceLigatures();
	replaceHyphenation();
	replaceSmartquotes();
	replaceToc();
	replaceChapter(); 
	replaceEpigraph();
	replaceEpigraphBlock();
	replaceSection();
	replaceSubsection();
	replaceBlockquote();
	replaceQuote();
	replaceList();
	replaceListItem();
	replaceEnd(); 
	replaceParagraph();
	replaceFootnote();
	replaceEndnote();
	replaceStartFinis();
	replaceBoldItalic();
	replaceItalic();
	replaceBold();
	replaceEnDash();
	replaceEmDash();
	replaceEllipses();
	replaceBlankLine();
	replaceNewPage();
	replaceBlankPage();
#	replaceCollate();
	replaceSpecialChars();
	replaceComments();
	replaceBreak();

	parseCommands();
}

	insertEndnotes();
	insertToc();

# Print out the MOM file.
foreach $_ (@tmlfile){print $_;}
#::::::::::::::::::::::::: END MAIN PROGRAM:::::::::::::::::::::::

#::::::::::::::::::::::::: FUNCTIONS :::::::::::::::::::::::::::::
sub includeFiles(){
	$/ = undef;
	if ($_ =~ m/\[include\]\s*?(.*?)\n/){;
		open(FILE, $1) || die("Could not open $1\n");
		$_ = <FILE>;
		close(FILE);
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
sub replacePageLayout{
		#TODO: Implement user defined sizes
		#:: Page sizes by name
		$_ =~ s/{papersize:letter}/\.PAPER LETTER/;
		$_ =~ s/{papersize:legal}/\.PAPER LEGAL/;
		$_ =~ s/{papersize:statement}/\.PAPER STATEMENT/;
		$_ =~ s/{papersize:tabloid}/\.PAPER TABLOID/;
		$_ =~ s/{papersize:ledger}/\.PAPER LEDGER/;
		$_ =~ s/{papersize:folio}/\.PAPER FOLIO/;
		$_ =~ s/{papersize:quarto}/\.PAPER QUARTO/;
		$_ =~ s/{papersize:trade}/\.PAGEWIDTH 6i\n.PAGELENGTH 9i/;
		
		$_ =~ s/{papersize:executive}/\.PAPER EXECUTIVE/;
		$_ =~ s/{papersize:10x14}/\.PAPER 10x14/;
		$_ =~ s/{papersize:a3}/\.PAPER A3/;
		$_ =~ s/{papersize:a4}/\.PAPER A4/;
		$_ =~ s/{papersize:a5}/\.PAPER A5/;
		$_ =~ s/{papersize:b4}/\.PAPER B4/;
		$_ =~ s/{papersize:b5}/\.PAPER B5/;
		$_ =~ s/{papersize:6x9}/\.PAGEWIDTH 6i\n.PAGELENGTH 9i/;
		
		$_ =~ s/{pagesize:letter}/\.PAPER LETTER/;
		$_ =~ s/{pagesize:legal}/\.PAPER LEGAL/;
		$_ =~ s/{pagesize:statement}/\.PAPER STATEMENT/;
		$_ =~ s/{pagesize:tabloid}/\.PAPER TABLOID/;
		$_ =~ s/{pagesize:ledger}/\.PAPER LEDGER/;
		$_ =~ s/{pagesize:folio}/\.PAPER FOLIO/;
		$_ =~ s/{pagesize:quarto}/\.PAPER QUARTO/;
		$_ =~ s/{pagesize:trade}/\.PAGEWIDTH 6i\n.PAGELENGTH 9i/;
		
		$_ =~ s/{pagesize:executive}/\.PAPER EXECUTIVE/;
		$_ =~ s/{pagesize:10x14}/\.PAPER 10x14/;
		$_ =~ s/{pagesize:a3}/\.PAPER A3/;
		$_ =~ s/{pagesize:a4}/\.PAPER A4/;
		$_ =~ s/{pagesize:a5}/\.PAPER A5/;
		$_ =~ s/{pagesize:b4}/\.PAPER B4/;
		$_ =~ s/{pagesize:b5}/\.PAPER B5/;
		$_ =~ s/{pagesize:6x9}/\.PAGEWIDTH 6i\n.PAGELENGTH 9i/;

		#:: Page width and height
		$_ =~ s/{pagewidth:(.*?)}/\.PAGEWIDTH $1/;
		$_ =~ s/{pageheight:(.*?)}/\.PAGELENGTH $1/;
		
		$_ =~ s/{paperwidth:(.*?)}/\.PAGEWIDTH $1/;
		$_ =~ s/{paperheight:(.*?)}/\.PAGELENGTH $1/;
		
		#TODO: Implement user defined sizes
}

sub replaceMargins{
		#{marginleft:nx}
		#{marginright:nx}
		#{margintop:nx}
		#{marginbottom:nx}
		#{margins:nx nx nx nx}
		$_ =~ s/{marginleft:(.*?)}/\.L_MARGIN $1/;
		$_ =~ s/{marginright:(.*?)}/\.R_MARGIN $1/;
		$_ =~ s/{margintop:(.*?)}/\.T_MARGIN $1/;
		$_ =~ s/{marginbottom:(.*?)}/\.B_MARGIN $1/;
		$_ =~ s/{margins:(.*?)\s(.*?)\s(.*?)\s(.*?)}/\.L_MARGIN $1\n\.R_MARGIN $2\n\.T_MARGIN $3\n\.B_MARGIN $4/;
}
sub replaceFonts{
		#{fontfamily:}
		$_ =~ s/{fontfamily:avant-garde}/\.FAMILY A/;
		$_ =~ s/{fontfamily:avantgarde}/\.FAMILY A/;
		$_ =~ s/{fontfamily:avant-garde}/\.FAMILY A/;
		$_ =~ s/{fontfamily:bookman}/\.FAMILY BM/;
		$_ =~ s/{fontfamily:helvetica}/\.FAMILY H/;
		$_ =~ s/{fontfamily:helvetica-narrow}/\.FAMILY HN/;
		$_ =~ s/{fontfamily:helveticanarrow}/\.FAMILY HN/;
		$_ =~ s/{fontfamily:new-century-schoolbook}/\.FAMILY N/;
		$_ =~ s/{fontfamily:newcenturyschoolbook}/\.FAMILY N/;
		$_ =~ s/{fontfamily:palatino}/\.FAMILY P/;
		$_ =~ s/{fontfamily:times-roman}/\.FAMILY T/;
		$_ =~ s/{fontfamily:times}/\.FAMILY T/;
		$_ =~ s/{fontfamily:zapf-chancery}/\.FAMILY ZCM/;
		$_ =~ s/{fontfamily:zapf}/\.FAMILY ZCM/;
		
		#{fontstyle:}
		$_ =~ s/{fontstyle:roman}/\.FT R/;
		$_ =~ s/{fontstyle:r}/\.FT R/;
		$_ =~ s/{fontstyle:italic}/\.FT I/;
		$_ =~ s/{fontstyle:i}/\.FT I/;
		$_ =~ s/{fontstyle:bold}/\.FT B/;
		$_ =~ s/{fontstyle:b}/\.FT I/;
		$_ =~ s/{fontstyle:bold-italic}/\.FT BI/;
		$_ =~ s/{fontstyle:bolditalic}/\.FT BI/;
		$_ =~ s/{fontstyle:bi}/\.FT I/;
		$_ =~ s/{fontstyle:smallcaps}/\.FT SC/;
		$_ =~ s/{fontstyle:sc}/\.FT BI/;
		
		#{fontsize:}
		$_ =~ s/{fontsize:(.*?)}/\.PT_SIZE $1/;
		
		#{fontcolor:}
}

sub replaceLeading{
	#:: LINE SPACING/LEADING
	#{leading: 10/13} => sets PT_SIZE to 10 and .LS to 13 at same time
	$_ =~ s/{leading:(.*?)\/(.*?)}/\.PT_SIZE $1\n\.LS $2/;
	
	#{autoleading: [factor of] 2}  => maybe 
	
	#{linespacing: 13}
	$_ =~ s/{linespacing:(.*?)}/\.LS $1/;
}

sub replaceJustification{
	#{justfication:left}
	$_ =~ s/{justification:left}/\.QUAD LEFT/;
	
	#{justfication:right}
	$_ =~ s/{justification:right}/\.QUAD RIGHT/;
	
	#{justification:center}
	$_ =~ s/{justification:center}/\.QUAD CENTER/;
	
	#{justification:full}
	$_ =~ s/{justification:full}/\.QUAD JUSTIFIED/;
}

sub replaceParagraphLayout{
	#{paragraphindent: nx}
	$_ =~ s/{paragraphindent:(.*?)}/\.PARA_INDENT $1/;
		
	#{paragraphspace: nx}
	$_ =~ s/{paragraphspace:(.*?)}/\.PARA_SPACE $1/;
	
	#{linelength:3i}
	$_ =~ s/{linelength:(.*?)}/\.LL $1/;	
}

sub replaceKerning{
#{kerning:on|off}
	$_ =~ s/{kerning:on}/\.KERN/;	
	$_ =~ s/{kerning:off(.*?)}/\.KERN OFF/;	

}
sub replaceLigatures{
#{ligatures:on}
#{ligatures:off}
	$_ =~ s/{ligatures:on}/\.LIG/;	
	$_ =~ s/{ligatures:off}/\.LIG OFF/;
}

sub replaceSmartquotes{
	#{smartquotes:on}
	#{smartquotes:off}
	$_ =~ s/{smartquotes:on}/\.HY/;	
	$_ =~ s/{smartquotes:off}/\.HY OFF/;
}

sub replaceHyphenation{
	#{hyphenation:on}
	#{hyphenation:off}
	$_ =~ s/{hyphenation:on}/\.HY/;	
	$_ =~ s/{hyphenation:off}/\.HY OFF/;	
	
	#{hyphenationlanguage:spanish}
	#{hyphenationmax:}
	$_ =~ s/{hyphenationmax:(.*?)}/\.HY $1/;	
	
	#{hyphenationmargin:}
	$_ =~ s/{hyphenationmargin:(.*?)}/\.HY $1/;
	
	#{hyphenationspace:}
	$_ =~ s/{hyphenationspace:(.*?)}/\.HY $1/;
	
	#{hyphenation:reset}
	$_ =~ s/{hyphenation:reset}/\.HY DEFAULT/;
}

sub replaceSmartquotes{
	$_ =~ s/{smartquotes:on}/\.SMARTQUOTES/;
	$_ =~ s/{smartquotes:off}/\.SMARTQUOTES OFF/;
	$_ =~ s/{smartquotes:danish}/\.SMARTQUOTES DA/;
	$_ =~ s/{smartquotes:german}/\.SMARTQUOTES GE/;
	$_ =~ s/{smartquotes:spanish}/\.SMARTQUOTES ES/;
	$_ =~ s/{smartquotes:french}/\.SMARTQUOTES FR/;
	$_ =~ s/{smartquotes:italian}/\.SMARTQUOTES IT/;
	$_ =~ s/{smartquotes:dutch}/\.SMARTQUOTES NL/;
	$_ =~ s/{smartquotes:norwegian}/\.SMARTQUOTES NO/;
	$_ =~ s/{smartquotes:portugese}/\.SMARTQUOTES PT/;
	$_ =~ s/{smartquotes:swedish}/\.SMARTQUOTES SV/;

	$_ =~ s/{smartquotes:da}/\.SMARTQUOTES DA/;
	$_ =~ s/{smartquotes:ge}/\.SMARTQUOTES GE/;
	$_ =~ s/{smartquotes:es}/\.SMARTQUOTES ES/;
	$_ =~ s/{smartquotes:fr}/\.SMARTQUOTES FR/;
	$_ =~ s/{smartquotes:it}/\.SMARTQUOTES IT/;
	$_ =~ s/{smartquotes:nl}/\.SMARTQUOTES NL/;
	$_ =~ s/{smartquotes:no}/\.SMARTQUOTES NO/;
	$_ =~ s/{smartquotes:pt}/\.SMARTQUOTES PT/;
	$_ =~ s/{smartquotes:sv}/\.SMARTQUOTES SV/;
}

sub replaceToc{
		if ($_ =~ s/\[tableofcontents\]//){
		   $hasToc = "true";print "Has toc\n";
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
		$_ =~ s/\[chapter\]/\.HEADING 1/;
		$_ =~ s/\[chap\]/\.HEADING 1/;
		$_ =~ s/\[heading1\]/\.HEADING 1/;
		$_ =~ s/\[heading 1\]/\.HEADING 1/;
		$_ =~ s/\[h1\]/\.HEADING 1/;
}

sub replaceSection {
		$_ =~ s/\[section\]/\.HEADING 2/;
		$_ =~ s/\[sec\]/\.HEADING 2/;
		$_ =~ s/\[heading 2\]/\.HEADING 2/;
		$_ =~ s/\[heading2\]/\.HEADING 2/;
		$_ =~ s/\[h2\]/\.HEADING 2/;
}

sub replaceSubsection {
		$_ =~ s/\[subsection\]/\.HEADING 3/;
		$_ =~ s/\[subsec\]/\.HEADING 3/;
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
		if( $_ =~ s/\[list:digit\]/\.LIST DIGIT/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:dash\]/\.LIST DASH/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:bullet\]/\.LIST BULLET/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:alpha\]/\.LIST alpha/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:ALPHA\]/\.LIST ALPHA/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list\]/\.LIST DIGIT/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:(roman.*?)\]/\.LIST $1/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:(ROMAN.*?)\]/\.LIST $1/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:square\]/\.LIST USER \\[sq\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:hand\]/\.LIST USER \\[rh\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:arrow\]/\.LIST USER \\[->\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:dblarrow\]/\.LIST USER \\[rA\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:checkmark\]/\.LIST USER \\[OK\]/){
			push(@elementStack, ".LIST OFF");}
		elsif( $_ =~ s/\[list:user(.*?)\]/\.LIST USER "$1"/){
			push(@elementStack, ".LIST OFF");}
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
		$_ =~ s/^\t/\n\.PP\n/;
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
 $_ =~ s/\[\+\/-\]/\\[\+-\]/g; 
 # Subtract (arithmetic) \[mi]
  $_ =~ s/\[-\]/\\[mi\]/g; 
 # Multiply (arithmetic) \[mu]
  $_ =~ s/\[x\]/\\[mu\]/g; 
 # Divide (arithmetic) \[di]
  $_ =~ s/\[\/\]/\\[di\]/g;  
 # Left double-quote \[lq] 
  $_ =~ s/\[lq\]/\\[lq\]/g; 
 # Right double-quote \[rq]
  $_ =~ s/\[rq\]/\\[rq\]/g; 
 # Open (left) single-quote \[oq]
  $_ =~ s/\[oq\]/\\[oq\]/g; 
 # Close (right) single-quote \[oq]
  $_ =~ s/\[oq\]/\\[oq\]/g; 
 # Bullet \[bu] 
  $_ =~ s/\[bu]/\\[bu\]/g; 
  $_ =~ s/\[bullet]/\\[bu\]/g; 
 #Ballot box \[sq]
  $_ =~ s/\[sq]/\\[sq\]/g; 
  $_ =~ s/\[square]/\\[sq\]/g; 
 # One-quarter \[14] 
  $_ =~ s/\[1\/4\]/\\[14\]/g; 
 # One-half \[12] 
  $_ =~ s/\[1\/2\]/\\[12\]/g; 
 # Three-quarters \[34] 
  $_ =~ s/\[3\/4\]/\\[34\]/g; 
 # Degree sign \[de] 
  $_ =~ s/\[de\]/\\[de\]/g; 
  $_ =~ s/\[deg\]/\\[de\]/g;
  $_ =~ s/\[degree\]/\\[de\]/g; 
 # Dagger \[dg] 
  $_ =~ s/\[dg\]/\\[dg\]/g; 
  $_ =~ s/\[dagger\]/\\[dg\]/g; 
 # Foot mark \[fm] 
  $_ =~ s/\[fm\]/\\[fm\]/g; 
  $_ =~ s/\[footmark\]/\\[fm\]/g; 
 # Cent sign \[ct] 
  $_ =~ s/\[ct\]/\\[ct\]/g; 
  $_ =~ s/\[cent\]/\\[ct\]/g; 
 # Registered trademark \[rg] 
  $_ =~ s/\[rg\]/\\[rg\]/g; 
  $_ =~ s/\[trademark\]/\\[rg\]/g; 
 # Copyright \[co] 
  $_ =~ s/\[co\]/\\[co\]/g;
  $_ =~ s/\[copyright\]/\\[co\]/g;
 # Section symbol \[se]
  $_ =~ s/\[se\]/\\[se\]/g; 
 # Foot and inch
 $_ =~ s/\['\]/\\[foot\]/g; 
 $_ =~ s/\["\]/\\[inch\]/g; 
 # Braces and brackets
 $_ =~ s/\[{\]/\{/g;
 $_ =~ s/\[lc\]/\{/g;
 $_ =~ s/\[}\]/\}/g; 
 $_ =~ s/\[rc\]/\}/g; 
 $_ =~ s/\[<\]/</g; 
 $_ =~ s/\[lt\]/</g; 
 $_ =~ s/\[>\]/>/g; 
 $_ =~ s/\[gt\]/>/g; 
 $_ =~ s/\[\[\]/\[/g; 
 $_ =~ s/\[ls\]/\[/g; 
 $_ =~ s/\[\]\]/\]/g; 
 $_ =~ s/\[rs\]/\]/g; 
}
sub replaceEllipses(){
		#$_ =~ s/\|\*(.*?)\*\|/\\\*\[BDI\]$1\\\*\[PREV\]/;  
}

sub replaceBlankLine(){
		$_ =~ s/^\n/\.\n/;
}

sub replaceNewPage(){
		$_ =~ s/\[newpage\]/\.NEWPAGE/;
}

sub replaceBlankPage(){
		#$_ =~ s/\[chapter\]/\.HEADING 1/;
}

sub replaceComments{
		$_ =~ s/^#/\\#/;	
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
						if ($command =~ /bolditalic|bi/ ){ $openGroup = $openGroup . "\\*[BDI]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command =~ /italic|it|i/ ){ $openGroup = $openGroup . "\\*[IT]"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command =~ /bold|bld|b/ ){ $openGroup = $openGroup . "\\*[BLD]"; push(@closeGroup,"\\*[PREV]");}
						#elsif ($command =~ /dropcap/){ $openGroup = $openGroup . ".DROPCAP"; push(@closeGroup,"\\*[PREV]");}
						elsif ($command =~ /smallcaps|sc/){ $openGroup = $openGroup . ".FT SC\n"; push(@closeGroup,"\n.FT\n");}
						#elsif ($command =~ /condense|cond/){print "<condense>";push(@closeGroup,"</condense>");}
						elsif ($command =~ /left/ ){$openGroup = $openGroup . ".LEFT\n";}
						elsif ($command =~ /right/ ){$openGroup = $openGroup . ".RIGHT\n";}
						elsif ($command =~ /center/ ){$openGroup = $openGroup . ".CENTER\n";}
						elsif ($command =~ /uppercase/ ){ $openGroup = $openGroup . "\\*[UC]"; push(@closeGroup,"\\*[LC]");}
						elsif ($command =~ /caps/ ){ $openGroup = $openGroup . "\\*[UC]"; push(@closeGroup,"\\*[LC]");}
						elsif ($command =~ /uc/ ){ $openGroup = $openGroup . "\\*[UC]"; push(@closeGroup,"\\*[LC]");}
						elsif ($command =~ /lowercase/ ){ $openGroup = $openGroup . "\\*[LC]"; push(@closeGroup,"\\*[UC]");}
						elsif ($command =~ /lc/ ){ $openGroup = $openGroup . "\\*[LC]"; push(@closeGroup,"\\*[UC]");}
						elsif ($command =~ /footnote/ ){ $openGroup = $openGroup . "\n.FOOTNOTE\n"; push(@closeGroup,"\n.FOOTNOTE OFF\n");}
						elsif ($command =~ /endnote/ ){ $openGroup = $openGroup . "\n.ENDNOTE\n"; push(@closeGroup,"\n.ENDNOTE OFF\n");}
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
