# Em v.0.1.6
# Adding PP logic
# 



# Open the file specified at command line 
open(FILE, $ARGV[0]) || die("Could not open $ARGV[0]\n");
@tmlfile = <FILE>;
close(FILE);

# GLOBALS
$current = 0;           #always points to the current line
$first_chapter = "yes"; #Will tell us if this is the first time [chapter] is used
$first_section ="yes";
$is_quote ="no";
%needToResetHeadingStyle = undef;
%headingStyle = undef;
$currentHeadingLevel = undef;
$footnotes = undef; # A container for all footnotes.
$toc_cnt =0;
$ftn_cnt = 0; # Footnote counter
$hasToc = undef;  # A flag that identifies if the doc has [contents]. If so we need to add .TOC at very end of output file.
$hasFootnotes = undef;
$dropcap_condense_factor = "none";
$dropcap_expand_factor = "none";
$dropcap_modification = "none";
$dropcap_span = "none";

# Global List Options
%listConfig = undef;

# documentListOptions{space-before} =
# documentChapterOptions{size} = 
# documentSectionOptions =
print "DEBUG -> # of lines in input file: $#tmlfile\n";
for ($current = 0; $current < $#tmlfile+1 ; $current++){
    print "($current) $tmlfile[$current]";
    
    # Tags
    if ($tmlfile[$current] =~       /\[\s*cover(.*)\s*\]/)      { processTag("cover");      coverOptions();}
    elsif ($tmlfile[$current] =~    /\\[.+]/)                   { push(@tmlout, $tmlfile[$current])} # if the tag is escaped, leave it be.
    elsif ($tmlfile[$current] =~    /\[\s*title(.*)\s*\]/)      { processTag("title");      titleOptions();} 
    elsif ($tmlfile[$current] =~    /\[\s*copyright(.*)\s*\]/)  { processTag("copyright");  copyrightOptions();}
    elsif ($tmlfile[$current] =~    /\[\s*introduction(.*)\s*\]/)  { processTag("introduction");  sectionOptions(); }
    elsif ($tmlfile[$current] =~    /\[\s*preface(.*)\s*\]/)    { processTag("preface");    sectionOptions();}
    elsif ($tmlfile[$current] =~    /\[\s*foreword(.*)\s*\]/)   { processTag("foreword");   sectionOptions();}
    elsif ($tmlfile[$current] =~    /\[\s*acknowledgements(.*)\s*\]/)  { processTag("acknowledgements");  sectionOptions();}
    elsif ($tmlfile[$current] =~    /\[\s*section(.*)\s*\]/)    { processTag("section");    sectionOptions();insertPP();}
    elsif ($tmlfile[$current] =~    /\[\s*contents(.*)\s*\]/)   { processTag("contents");}
    elsif ($tmlfile[$current] =~    /\[\s*chapter(.*)\s*\]/)    { processTag("chapter");    chapterOptions(); insertPP();}
    elsif ($tmlfile[$current] =~    /\[\s*epigraph\s*\]/)   { processTag("epigraph");   epigraphOptions();}
    elsif ($tmlfile[$current] =~/\[\s*epigraph.?block(.*)\s*\]/) { processTag("epigraphblock"); epigraphBlockOptions();}
    elsif ($tmlfile[$current] =~    /\[\s*h(.*)\s*\]/)          { processTag("heading");insertPP();}
    elsif ($tmlfile[$current] =~    /\[\s*ph(.*)\s*\]/)   { processTag("parahead");}
    elsif ($tmlfile[$current] =~    /\[\s*block.?quote(.*)\s*\]/) { processTag("blockquote"); blockquoteOptions();}
    elsif ($tmlfile[$current] =~    /\[\s*quote(.*)\s*\]/)      { processTag("quote");      quoteOptions(); $is_quote="yes"; }
    elsif ($tmlfile[$current] =~    /\[\s*list(.*)\s*\]/)       { processTag("list"); }
    elsif ($tmlfile[$current] =~    /\[\s*comment\s*\]/)        { processTag("comment"); }
    elsif ($tmlfile[$current] =~    /\[\s*footnote\s*\]/)       { processTag("footnote");}
    elsif ($tmlfile[$current] =~    /\[\s*end\s*\]/)            { processTag("end");}
    elsif ($tmlfile[$current] =~    /^\[.\]/)                 { processTag("dropcap");}
    
    # Includes
    elsif ($tmlfile[$current] =~    /\{\s*include\s*\}/)        { include();}
    
    # Aliases
    elsif ($tmlfile[$current] =~    /\{\s*alias(es)\s*\}/)     { aliases();}
    
    # Strings
    elsif ($tmlfile[$current] =~    /\{\s*strings\s*\}/)     { strings();}
    
    # Dropcaps
    elsif ($tmlfile[$current] =~    /\{\s*dropcaps?\s*\}/)     { dropcapConfig();}
    
    # Config Blocks
    elsif ($tmlfile[$current] =~    /\\{.+}/)                   { push(@tmlout, $tmlfile[$current])} # if the config is escaped, leave it be.
    elsif ($tmlfile[$current] =~    /\{\s*document\s*\}/)       { documentConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*page\s*\}/)           { pageConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*headers\s*\}/)       { headerConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*margins\s*\}/)       { marginConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*footers\s*\}/)       { footerConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*chapters\s*\}/)      { chapterConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*h(.)\s*\}/)           { headingConfig($1);}
    elsif ($tmlfile[$current] =~    /\{\s*ph*\s*\}/)         { paraheadConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*epigraphs\s*\}/)     { epigraphConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*epigraph.?blocks*\s*\}/){ epigraphBlockConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*paragraphs\s*\}/)    { paragraphConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*block.?quotes\s*\}/)   { blockquoteConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*quotes\s*\}/)        { quoteConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*footnotes\s*\}/)     { footnoteConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*endnotes\s*\}/)      { endnoteConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*contents\s*\}/)      { tocConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*lists\s*\}/)         { listConfig();}
    
    # Kerning
    elsif ($tmlfile[$current] =~    /\{\s*kerning:/)           { kerningConfig();}
    
    # Ligatures
    elsif ($tmlfile[$current] =~    /\{\s*ligatures:/)         { ligatureConfig();}
    
    # Pagination
    elsif ($tmlfile[$current] =~    /\{\s*pagination\s*}/)        { paginationConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*pagination:\s*on\s*}/)  { push(@tmlout, "\.PAGINATE\n");}
    elsif ($tmlfile[$current] =~    /\{\s*pagination:\s*off\s*}/) { push(@tmlout, "\.PAGINATE OFF\n");}
    elsif ($tmlfile[$current] =~    /\{\s*page\s#(.*?)\s*}/)      { push(@tmlout, "\.PAGENUMBER $1\n");} 
    
    # Hyphenation
    elsif ($tmlfile[$current] =~    /\{\s*hyphenation\s*}/)       { hyphenationConfig();}
    elsif ($tmlfile[$current] =~    /\{\s*hyphenation:\s*on\s*}/) { push(@tmlout, "\.HY\n");}
    elsif ($tmlfile[$current] =~    /\{\s*hyphenation:\s*off\s*}/){ push(@tmlout, "\.HY OFF\n");}
   
    # Quadding (Aligning + fill)
    elsif ($tmlfile[$current] =~    /\{\s*quad:\s*left\s*}/){ push(@tmlout, "\.QUAD L\n");}
    elsif ($tmlfile[$current] =~    /\{\s*quad:\s*left\s*}/){ push(@tmlout, "\.QUAD R\n");}
    elsif ($tmlfile[$current] =~    /\{\s*quad:\s*left\s*}/){ push(@tmlout, "\.QUAD C\n");}
    elsif ($tmlfile[$current] =~    /\{\s*quad:\s*left\s*}/){ push(@tmlout, "\.QUAD J\n");}
    elsif ($tmlfile[$current] =~    /\{\s*justify\s*}/)     { push(@tmlout, "\.QUAD J\n");}
    
    # Alignment (Aligning without filling)
    elsif ($tmlfile[$current] =~    /\{\s*align:\s*left\s*}/)   { push(@tmlout, "\.LEFT\n");}
    elsif ($tmlfile[$current] =~    /\{\s*align:\s*right\s*}/)  { push(@tmlout, "\.RIGHT\n");}
    elsif ($tmlfile[$current] =~    /\{\s*align:\s*center\s*}/) { push(@tmlout, "\.CENTER\n");}
    elsif ($tmlfile[$current] =~    /\{\s*left\s*}/)            { push(@tmlout, "\.LEFT\n");}
    elsif ($tmlfile[$current] =~    /\{\s*right\s*}/)           { push(@tmlout, "\.RIGHT\n");}
    elsif ($tmlfile[$current] =~    /\{\s*center\s*}/)          { push(@tmlout, "\.CENTER\n");}
    
    # Blank line
    elsif ($tmlfile[$current] eq "\n") {
        if ($is_quote eq "yes"){push(@tmlout, "\.SPACE\n");}
        else { push(@tmlout, "=======\n");}
    }
    else {push(@tmlout, $tmlfile[$current])}
}



print "------------------Main------------------\n";
insertFootnotes();
insertToc();
pairKerning();

# Replace inline formatting (maybe put the loop inside the function).
for ($current = 0; $current < $#tmlout ; $current++){
  inlineFormatting();
}
printtml(); 


sub insertPP{
  push(@tmlout, "\.PP\n");
}

#//////////////////////////
#*************************
# PRINT TML 
#*************************
sub printtml{ 
  for (my $i = 0; $i < $#tmlout+1 ; $i++){ 
    #print "[$i] $tmlout[$i]";
    print "$tmlout[$i]";
  }
}

#//////////////////////////
#**************************
# PAGINATION CONFIG
#*************************
sub paginationConfig {
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %style = (
roman    =>  "roman",
ROMAN   =>  "ROMAN",
alpha  =>  "alpha",
ALPHA =>  "ALPHA",
digit =>  "DIGIT",
);

my %position = (
bottomleft    =>  "BOTTOM LEFT",
bottomright   =>  "BOTTOM RIGHT",
bottomcenter  =>  "BOTTOM CENTER",
topleft    =>  "TOP LEFT",
topright   =>  "TOP RIGHT",
topcenter  =>  "TOP CENTER",
);

#{pagination} doesn't interest us, move to next line.
$current +=1;

push(@tmlout, "\.\n\.\\# Pagination Style #\n");
print "DEBUG -> Entering paginationConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

# Don't hyphenate page numbers by default
push(@tmlout,   "\.PAGENUM_HYPHENS OFF\n"); 

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.PAGENUM_FAMILY $2\n");
        }elsif ($1 eq "font")   {push(@tmlout,   "\.PAGENUM_FONT $font{$2}\n");
        }elsif ($1 eq "position") {
          $pos = $2;
          $pos =~ s/-//;
          push(@tmlout, "\.PAGENUM_POS $position{$pos}\n");
        }elsif ($1 eq "size")   {push(@tmlout,   "\.PAGENUM_SIZE $2\n");
        }elsif ($1 eq "color")  {push(@tmlout,   "\.PAGENUM_COLOR $2\n");
        }elsif ($1 eq "style")  {push(@tmlout,   "\.PAGENUM_STYLE $style{$2}\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {pagination}\n");}
        
    # Options that don't require arguments
    }elsif ($tmlfile[$i] =~ /\s*hyphenate-page-numbers\s*/) {
        push(@tmlout,   "\.PAGENUM_HYPHENS\n"); 
    }elsif ($tmlfile[$i] =~ /\s*on-first-page\s*/) {
        push(@tmlout,   "\.PAGENUM_ON_FIRST_PAGE\n");
     
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving paginationConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# HYPHENATION CONFIG
#*************************
sub hyphenationConfig {
my $i = 0;
my $title = "";

#{hyphenation} doesn't interest us, move to next line.
$current +=1;

push(@tmlout, "\.\n\.\\# Hyphenation Parameters #\n");
print "DEBUG -> Entering hyphenationConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
        }elsif ($1 eq "max-consecutive-lines") { push(@tmlout,   "\.HY MAX $2\n");
        }elsif ($1 eq "margin")   {push(@tmlout,   "\.HY MAX $2\n");
        }elsif ($1 eq "space")   {push(@tmlout,   "\.HY SPACE $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {hyphenation}\n");}
            
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        
        # Turn hyphenation on
        push(@tmlout,   "\.HY\n"); 
        print "DEBUG -> Leaving hyphenationConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# PAIR KERNING
#*************************
sub pairKerning {

# Go through each line and replace Inline pairwise kerning: F<-5>or the re<+5>cord.
for ($current = 0; $current < $#tmlout ; $current++){
  $tmlout[$current] =~ s/<-(\d+)>/\\\*\[BU $1\]/;
  $tmlout[$current] =~ s/<\+(\d+)>/\\\*\[FU $1\]/;
}#ENDFOR
}#ENDSUB

#//////////////////////////
#**************************
# INSERT TOC
# Appends .TOC to the end of the doc if [contents] was used.
#*************************
sub insertToc{
  if ($hasToc eq "true") { push(@tmlout, "\.TOC\n");}
}

#//////////////////////////
#**************************
# INSERT FOOTNOTES
# Finds instances of [*] and replaces them with .FOOTNOTE...footnote...FOOTNOTE END
#*************************
sub insertFootnotes {

# If there are not footnotes, just leave
if ($hasFootnotes ne "yes"){return;}

# Initiate a counter to index though the footnote list that we collected earlier.
 my $ftn_cnt = 0;

# For each line in the output file...
for ($current = 0; $current < $#tmlout ; $current++){
  $tmlout[$current] =~ s/\s*\[\*\]/\[\*\]/g;          # Remove spaces before the footnote
  $tmlout[$current] =~ s/(\w*?)\[\*\]/$1\\c\[\*\]/g;  # Add \c to the last character before the footnote.
  $tmlout[$current] =~ s/\[\*\]\./\[\*\]\\&\./g;      # Add \& before the period so that groff sees it as a period.
  
  # Now we will split up the line by the [*] pattern.
  $currentline = $tmlout[$current];
  @templine = split /(\[\*\])/, $currentline;
  foreach $line (@templine) {print "DEBUG-> FOOTNOTE ARRAY -> $line\n";}
    
  # We split up the line by [*], so now we should have [*] as array items, should they exist
  for (my $i = 0; $i<100;$i++){
    # If [*], replace it with .FOOTNOTE\n<note body>.\FOOTNOTE OFF\n"
    if ($templine[$i] eq "[*]"){
      $templine[$i] = "\n\.FOOTNOTE\n$footnotes[$ftn_cnt]\.FOOTNOTE OFF\n";
      
      # Increase the note counter
      $ftn_cnt +=1;
    }
  }# end foreach
  # Replace the current line with the line which now has the footnote body
  $tmlout[$current] = join("", @templine);
   
}# endfor
  # Throw an error if there is a mismatching number of [*] and [footnote]
  print "DEBUG -> fn_cnt: $fn_cnt, ftn_cnt: $ftn_cnt\n";
  if ($fn_cnt ne $ftn_cnt) {print "ERROR -> the number of [*] and corresponding [footnote] don't match.\n"; exit;}
}# endsub


#//////////////////////////
#**************************
# DROPCAP CONFIG 
#**************************
sub dropcapConfig{
my $i = 0;
my $title = "";

my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);


# {dropcaps} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Dropcap Style #\n");
print "DEBUG -> Entering dropcapConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.DROPCAP_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.DROPCAP_FONT $font{$2}\n");
        }elsif ($1 eq "adjust") {push(@tmlout,   "\.DROPCAP_ADJUST $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.DROPCAP_COLOR $2\n");
        }elsif ($1 eq "gutter") {push(@tmlout,   "\.DROPCAP_GUTTER $2\n");
        }elsif ($1 eq "condense%") { $dropcap_modification = "COND"; $dropcap_expand_factor = $2;
        }elsif ($1 eq "expand%") { $dropcap_modification = "EXT"; $dropcap_expand_factor = $2;
        }elsif ($1 eq "linespan") { $dropcap_span = $2;
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {dropcaps}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving dropcapsConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# TOC PAGE NUMBER CONFIG
# Sets up the options and formatting for the TOC
#*************************
sub tocPageNumberConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#page-numbers' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# TOC Entry Page Numbering Style #\n");
print "DEBUG -> Entering tocPageNumberConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.TOC_PN_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.TOC_PN_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.TOC_PN_SIZE $2\n");
        }elsif ($1 eq "padding") {push(@tmlout,   "\.TOC_PADDING $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {toc#page-numbers}\n");}
        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving tocPageNumberConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# TOC ENTRY CONFIG
# Sets up the options and formatting for the TOC
#*************************
sub tocEntryConfig{
my $headingLevel = @_[0];
my $i = 0;
my $title = "";
my @style;
my %number_style = (
full => "FULL",
truncate => "TRUNCATE",
none => "NONE",
);
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#hx' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# TOC Entry Level $headingLevel Style #\n");
print "DEBUG -> Entering tocEntryConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

# Push the heading style level.
push(@tmlout,   "\.TOC_ENTRY_TYLE $headingLevel");

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@style,   " \\\nFAMILY $2");
        }elsif ($1 eq "font") {push(@style,   " \\\nFONT $font{$2}");
        }elsif ($1 eq "size") {push(@style,   " \\\nSIZE $2");
        }elsif ($1 eq "indent") {push(@style,   " \\\nINDENT $2");
        }elsif ($1 eq "color") {push(@style,   " \\\nCOLOR $2");
        }elsif ($1 eq "prefix-number-style") {push(@style,   " \\\nTOC_ENTRY_NUMBERS $number_style{$2}");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {toc#entry}\n");}

    # Options that don't need arguments
    }elsif ($tmlfile[$i] =~ /\s*caps\s*/) {
        push(@style,   " \\\nCAPS");
    }elsif ($tmlfile[$i] =~ /\s*no-caps\s*/) {
        push(@style,   " \\\nNO_CAPS");
    #Else there are no more options
    }else {
        # Create the style as a string and save it.
        push(@style, "\n");
        #$headingStyle[$headingLevel] = join("", @style);
        
        # Now also add it to the output file
        push(@tmlout, @style);
        
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving tocTitleConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# TOC HEADER CONFIG
# Sets up the options and formatting for the TOC
#*************************
sub tocHeaderConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# '#header' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# TOC Header Style #\n");
print "DEBUG -> Entering tocHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "string") {push(@tmlout,   "\.TOC_HEADER_STRING \"$2\"\n");
        }elsif ($1 eq "family") {push(@tmlout,   "\.TOC_HEADER_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.TOC_HEADER_FONT $font{$2}\n");
        }elsif ($1 eq "vertical-position") {push(@tmlout,   "\.TOC_HEADER_POSITION $2\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.TOC_HEADER_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.TOC_HEADER_COLOR $2\n");
        }elsif ($1 eq "quad") {push(@tmlout,   "\.TOC_HEADER_QUAD $quad{$2}\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {toc#header}\n");}
        
    # Options that don't require arguments
    }elsif ($tmlfile[$i] =~ /\s*caps\s*/) {
        push(@tmlout,   "\.TOC_HEADER_CAPS $2\n"); 
    }elsif ($tmlfile[$i] =~ /\s*smallcaps\s*/) {
        push(@tmlout,   "\.TOC_HEADER_SMALLCAPS $2\n");
    }elsif ($tmlfile[$i] =~ /\s*underline\s*/) {
        push(@tmlout,   "\.TOC_HEADER_UNDERLINE $2\n");
    }elsif ($tmlfile[$i] =~ /\s*no-caps\s*/) {
        push(@tmlout,   "\.TOC_HEADER_NO_CAPS $2\n"); 
    }elsif ($tmlfile[$i] =~ /\s*no-smallcaps\s*/) {
        push(@tmlout,   "\.TOC_HEADER_NO_SMALLCAPS $2\n");
    }elsif ($tmlfile[$i] =~ /\s*no-underline\s*/) {
        push(@tmlout,   "\.TOC_HEADER_NO_UNDERLINE $2\n");        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving tocHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# TOC TITLE CONFIG
# Sets up the options and formatting for the TOC
#*************************
sub tocTitleConfig{
#my $headingLevel = @_[0];
my $i = 0;
my $title = "";
my @style;
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# '#titles' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# TOC Title Style #\n");
print "DEBUG -> Entering tocTitleConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

# Push the heading style level.
push(@tmlout,   "\.TOC_TITLE_STYLE");

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@style,   " \\\nFAMILY $2");
        }elsif ($1 eq "font") {push(@style,   " \\\nFONT $font{$2}");
        }elsif ($1 eq "size") {push(@style,   " \\\nSIZE $2");
        }elsif ($1 eq "indent") {push(@style,   " \\\nINDENT $2");
        }elsif ($1 eq "color") {push(@style,   " \\\nCOLOR $2");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {toc#title}\n");}
 
    # Options that don't require arguments
    }elsif ($tmlfile[$i] =~ /\s*caps\s*/) {
        push(@style,   " \\\nCAPS"); 
    }elsif ($tmlfile[$i] =~ /\s*no-caps\s*/) {
        push(@style,   " \\\nNO_CAPS"); 
        
    #Else there are no more options
    }else {
        # Create the style as a string and save it.
        push(@style, "\n");
        #$headingStyle[$headingLevel] = join("", @style);
        
        # Now also add it to the output file
        push(@tmlout, @style);
        
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving tocTitleConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# TOC GENERAL CONFIG
# Sets up the options and formatting for the TOC
#*************************
sub tocGeneralConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %pagination = (
digit =>  "digit",
roman =>  "roman",
ROMAN =>  "ROMAN",
alpha =>  "alpha",
ALPHA =>  "ALPHA",
none  =>  "\.TOC_PAGENUM_STYLE" 
);

# '#header' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# TOC General Style #\n");
print "DEBUG -> Entering tocGeneralConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.TOC_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.TOC_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.TOC_SIZE $2\n");
        }elsif ($1 eq "pagination-style") {
            if ($2 eq "none") {
              push(@tmlout,   "\.PAGINATE_TOC OFF\n");
            } else {
              push(@tmlout,   "\.TOC_PAGENUM_STYLE $pagination{$2}\n");}
        }elsif ($1 eq "lead") {push(@tmlout,   "\.TOC_LEAD $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.TOC_COLOR $2\n");
        #}elsif ($1 eq "recto-verso") {push(@tmlout,   "\.TOC_RECTO \"$2\"\n");
        }elsif ($1 eq "indent") {push(@tmlout,   "\.TOC_INDENT \"$2\"\n");
        }elsif ($1 eq "quad") {push(@tmlout,   "\.TOC_QUAD \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {toc#general}\n");}
        
    # Options that don't require values
    }elsif ($tmlfile[$i] =~ /\s*no-pagination\s*/) {
        push(@tmlout,   "\.PAGINATE_TOC OFF\n");
    }elsif ($tmlfile[$i] =~ /\s*recto-verso\s*/) {
        push(@tmlout,   "\.TOC_RV_SWITCH\n");
    }elsif ($tmlfile[$i] =~ /\s*spaced-entries\s*/) {
        push(@tmlout,   "\.SPACE_TOC_ITEMS\n");    
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving tocGeneralConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# TOC CONFIG
# Sets up the options and formatting for the TOC
#*************************
sub tocConfig{
my $i = 0;
my $title = "";

# {contents} is of no interest to us, move to the next line to scan for options
$current+=1;

print "DEBUG -> Entering tocConfig(): current($current) line now: $tmlfile[$current]";

for ( $toc_cnt = $current; $toc_cnt<100; $toc_cnt++) {
    print "DEBUG -> tmlfile[$toc_cnt]: $tmlfile[$toc_cnt]";
    print "DEBUG -> tmlfile[$current]: $tmlfile[$current]";
    # Will need to figure how to deal with the loop counters.
    # If #general
    if ($tmlfile[$toc_cnt] =~ /\s*#general\s*/) {
      print "Found #general\n";
      tocGeneralConfig();
    }
    
    # If #header
    elsif ($tmlfile[$toc_cnt] =~ /\s*#header\s*/ ) {
      print "Found #header\n";
      tocHeaderConfig();
    }
    # If #titles
    elsif ($tmlfile[$toc_cnt] =~ /\s*#titles\s*/){
      print "Found #titles\n";
      tocTitleConfig();
    }
    #if #hx
    elsif ($tmlfile[$toc_cnt] =~ /\s*#h(.)\s*/){
      print "Found #hx\n";
      tocEntryConfig($1);
    }
    #if #entry-page-numbers
    elsif ($tmlfile[$toc_cnt] =~ /\s*#entry-page-numbers\s*/){
      print "Found #page-numbers\n";
      tocPageNumberConfig();
      
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $toc_cnt-1;
        print "DEBUG -> Leaving tocConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# COLLECT FOOTNOTES
# Goes throught the input file and collect instances of [footnote] into a list.
# Later when we encounter [*], the text of the footnote will be substituted in place of [*].
#*************************
sub collectFootnote{
print "DEBUG -> Entering COLLECT FOOTNOTES -> current line now ($current): $tmlfile[$current]";
# [footnote] doesnt interest us, so move to the next line
$current+=1;

# Collect all the lines until we encounter [end]
for (my $i = $current; $i<1000; $i++){
  # If we encounter [end] get out of this loop.
  if ($tmlfile[$i] =~ /\[end\]/){ last;} 

    # Collect the footnote, appending each line to the string.
    #print "current footnote #: $fn_cnt\n";
    $footnotes[$fn_cnt] = $footnotes[$fn_cnt] . $tmlfile[$i];
    #print "gathered:" . $footnotes[$fn_cnt] ."\n";
}#endfor
# Increment the footnote counter
$fn_cnt += 1;

# Move the current line pointer to [end]
$current = $current + $i+1;
print "DEBUG leaving COLLECT FOOTNOTES -> current line now ($current): $tmlfile[$current]";
print "Collected these footnotes:\n";
print "--------------------------\n";
foreach $note (@footnotes) {print "\n.FOOTNOTE\n" . $note . ".FOOTNOTE END";}
}#endsub



#//////////////////////////
#**************************
# PROCESS TAG
#*************************
sub processTag{
my $tag = @_[0];
$is_local_options = "yes";

if ($tag eq "blockquote") {
    push(@tmlout, "\.BLOCKQUOTE\n");
    #push(@tag_stack, "\.BLOCKQUOTE OFF\n");
    push(@tag_stack, "\.BLOCKQUOTE OFF\n.PP\n");
    $current+=1;
    
}elsif ($tag eq "quote") {
    push(@tmlout, "\.QUOTE\n");
    #push(@tag_stack, "\.QUOTE OFF\n");
    push(@tag_stack, "\.QUOTE OFF\n.PP\n");
    $current+=1;
    
}elsif ($tag eq "dropcap") {
    my $templine = $tmlfile[$current];
    
    # Break the line into 2 parts: 1) The dropcap letter 2) the rest of the line.
    $templine =~ /^\[(.)\](.*\n)/;
    $dropcap_letter = $1;
    my $rest_of_line = $2;
    print "DEBUG -> Rest of line is: $rest_of_line";
    
    # Lets create the dropcap command string and options, if they apply.
    my $dropcap_command = "\.DROPCAP " . $dropcap_letter;
    
    # Was number of lines to span specified?
    if ($dropcap_span ne "none") { 
      $dropcap_command = $dropcap_command . " $dropcap_span";
    }
    
    # Was a modification (expansion/condense) specified?
    if ($dropcap_modification ne "none") { 
      $dropcap_command = $dropcap_command . " " . $dropcap_modification . " " . $dropcap_expand_factor;
    }
    
    # Push the dropcap command and rest of line onto the outfile array
    push(@tmlout, "$dropcap_command\n");
    push(@tmlout, $rest_of_line);
    $current+=1;

}elsif ($tag eq "comment") {
    push(@tmlout, "\.COMMENT\n");
    push(@tag_stack, "\.COMMENT OFF\n");
    $current+=1;
    
}elsif ($tag eq "list") {
    listTag();
    #$current+=1;
     
}elsif ($tag eq "epigraph") {
    push(@tmlout, "\.EPIGRAPH\n");
    #push(@tag_stack, "\.EPIGRAPH OFF\n");
    push(@tag_stack, "\.EPIGRAPH OFF\n.PP\n");
    $current+=1;
    
}elsif ($tag eq "epigraphblock") {
    push(@tmlout, "\.EPIGRAPH BLOCK\n");
    #push(@tag_stack, "\.EPIGRAPH OFF\n");
    push(@tag_stack, "\.EPIGRAPH OFF\n.PP\n");
    $current+=1;
    
}elsif ($tag eq "cover") {
    push(@tmlout, "\.PDF_BOOKMARK 1 \"Cover Page\"\n"); 
    push(@tmlout, "\.SP |4i-1v/\n");
    push(@tag_stack, ".NEWPAGE\n\.NEWPAGE\n");
    $current+=1;
    
}elsif ($tag eq "title") {
    push(@tmlout, "\.PDF_BOOKMARK 1 \"Title Page\"\n");
    push(@tmlout, "\.SP |4i-1v/\n");
    push(@tag_stack, ".NEWPAGE\n");
    $current+=1;
    
}elsif ($tag eq "copyright") {
    push(@tmlout, "\.PDF_BOOKMARK 1 \"Copyright Page\"\n"); 
    push(@tmlout, "\.SP |4i-1v/\n");
    push(@tag_stack, ".NEWPAGE\n");
    $current+=1;

}elsif ($tag eq "contents") {
    $hasToc = "true";
    push(@tmlout, "\.AUTO_RELOCATE_TOC TOP\n"); 
    $current+=1;
   
}elsif ($tag eq "introduction") {
   introduction();
   
}elsif ($tag eq "preface") {
   preface();

}elsif ($tag eq "foreword") {
   foreword();

}elsif ($tag eq "acknowledgements") {
   acknowledgements();   
   
}elsif ($tag eq "section") {
   sectionTitle();
   
}elsif ($tag eq "chapter") {
   chapterTitle();
   
}elsif ($tag eq "heading") {
   headingTitle();
   
}elsif ($tag eq "parahead") {
   paraheadTitle();
   #No need for line below since already done in parahead function.
   #push(@tmlout, "\.PP");

}elsif ($tag eq "footnote") {
   $hasFootnotes = "yes";
   collectFootnote();
  
}elsif ($tag eq "end") {

    #If the tag being ended is quote, set it to "no" so that next time '\n' is encountered, it is not converted to .SPACE
    if($is_quote eq "yes"){$is_quote = "no";}
    push(@tmlout, pop(@tag_stack));
    #$current+=1;
}
}

#/////////////////////////////////
#*********************************
# LIST TAG 
#*********************************
sub listTag {
my %list = null;
my $listLength = 0;
my %listOptions = null;
my $canAddItemSpacing = "";
    
    # If list style, starting value and options specified
    if ($tmlfile[$current] =~ /\[\s*list\s*(.+)\s*\]/) {
       
       # Get the list style, enumerator, prefix, etc...
       %list = getListStyle($1);       
    }
    
    # If list options not specified in tag
    elsif ($tmlfile[$current] =~ /[\s*list\s*]/) {
      # Check if any default list type was specified as global.
      # check here
      
      # $list = getListStyle($tmlfile[$current]);
      # if $list{"type"} specified, use that
      # If $list{"type"} not specified
      
      #This logic will be wya more complicated than I thought.
    }
    
    %listOptions = getListOptions();
    print "DEBUG -> ListOptions contains: " . %listOptions . "\n";
    
 
    # If the list type is roman or ROMAN, we need to scan ahead to count how many items in list
    if ( $list{"type"} eq "roman" or $list{"type"} eq "ROMAN") {
      
        # Just cycles through, counting -, * or @ , skipping any nested lists.
        $listLength = getListLength();
        $listLength = $list{"startValue"} + $listLength;
        print "DEBUG -> List has $listLength items.\n";
    }
      
    # Create the list definiton string
    # Make this a sub createListDefinitionString(%list);
    # Also, if any style options were specified in listOptions, those should be the ones used for generating the string
    my $listDefinitionString = "\.LIST";
    if ($list{"type"}) {$listDefinitionString = $listDefinitionString . " " . $list{"type"}}
    if ($list{"type"} eq "roman" or $list{"type"} eq "ROMAN") {
      $listDefinitionString = $listDefinitionString . $listLength;}
    if ($list{"enumerator"}) {$listDefinitionString = $listDefinitionString . " " . $list{"enumerator"}}
    if ($list{"prefix"}) {$listDefinitionString = $listDefinitionString . " " . $list{"prefix"}}
    $listDefinitionString = $listDefinitionString . "\n";
    #print "Will push: $listDefinitionString";
      
    # If space-before was specified
    if ($listOptions{"spaceBefore"}) {
      push(@tmlout, $listOptions{"spaceBefore"});
    }
      
    # If space-before was not specified, was it specified as global config?
    #elsif ($listConfig{"spaceBefore"}) {
    #  print "Will push " . "\.SPACE " . $listOptions{"spaceBefore"} ."\n";
    #} 
    
    # push the list definition string
    push(@tmlout, $listDefinitionString);

    # If indent was specified
    if ($listOptions{"indent"}) {
      $indentString = "\.SHIFT_LIST " . $listOptions{"indent"} ."\n";
      push(@tmlout,$indentString);
    }
      
    # Should now be pointing at the first item of the list
    # We need to use $current in the loop in case we call recursively, we need $current to keep incrementing
    for ($current; $current < $#tmlfile; $current++) {
    
      # If we encounter [list], call recursively
      if ($tmlfile[$current] =~ /\[\s*list.*?\]/) {
        listTag();
        print "DEBUG -> Have returned from nested list. Current at $tmlfile[$current]";
        $current +=1;
      }
      
      # If we encounter [end], reset options to global list config and return to calling sub
      if ($tmlfile[$current] =~ /\[\s*end\s*\]/) {
        #resetListOptions();
        print "DEBUG -> Found [end], exiting listTag()\n";
        last;
      }
      
      # If *, - or @, push ITEM
      if ($tmlfile[$current] =~ /\s*[\@\*\-]\s*(.*)/) {
        
        # If item spacing was specified, insert it.
        if ($listOptions{"itemSpacing"} and $canAddItemSpacing) {
          push(@tmlout, $listOptions{"itemSpacing"});
        }
        print "DEBUG -> Item: $1\n";
        # Push the item
        push(@tmlout, "\.ITEM\n$1\n");
        
        # If this was the first item, set a flag that we can insert spaces between items.
        $canAddItemSpacing = "yes";
        
      }# ENDIF @, *, -
    }# ENDFOR
    
    # Close the list
    push(@tmlout, "\.LIST OFF\n");
    
    # If space-after was specified, insert it.
    if ($listOptions{"spaceAfter"}) {
      push(@tmlout, $listOptions{"spaceAfter"});
    }        
}# ENDSUB

#/////////////////////////////////
#*********************************
# GET LIST LENGTH 
#*********************************
sub getListLength{
my $numberOfItems = 0;

# Just look ahead until end of list and count how many items
for ($i = $current; $i<1000; $i++){

  # If line starts with -, * or @, increment number of items
  if ($tmlfile[$i] =~ /^\s*[\*\@-]/) {
    $numberOfItems +=1;
  
  # If we encounter a nested [list], skip it until [end]
  # This will likely need to be a seprate function that can be called recursively for multiple nested lists.
  }elsif ($tmlfile[$i] =~ /\[\s*list.*?\]/) {
    #print "Found nested [list], skipping...\n";
    for ($j = $i; $j<1000; $j++){
      if ($tmlfile[$j] =~ /\[end\]/) {
        #print "Found [end] of nested list\n";
        $i = $j;
        last;
      }
    }
  }# ENDIF [list]
  
  # If we encounter [end] return the number of items found
  elsif ($tmlfile[$i] =~ /\[end\]/) {
    return $numberOfItems-1;
  }
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# GET LIST STYLE 
#*********************************
sub getListStyle{

my $listOptions = @_[0];

my %list = (
    type => "",
    startValue => "",
    prefix => "",
    enumerator => ""
);

my $last = 0;
#print "Entered getListStyle()...\n";
#print "Passed in the following string: $listOptions\n";

    # Convert the option string into an array.
    @listOptions = split(//, $listOptions);
        
    # If the first char is a digit, alpha, dash or asterisk, set the list type
    if($listOptions[0] =~ /[0-9]+/)        { $list{"type"} = "digit"; }
    elsif($listOptions[0] =~ /[a-zA-Z]+/)  { $list{"type"} = "alpha"; }
    elsif($listOptions[0] =~ /-/)          { $list{"type"} = "dash"; }
    elsif($listOptions[0] =~ /\*/)         { $list{"type"} = "bullet"; }
        
    # Otherwise this means we found a prefix.
    else {
        # Set the prefix
        $list{"prefix"} = $listOptions[0];     
        print "DEBUG -> Found a prefix: " . $list{"prefix"} . "\n";
            
        # Remove the prefix from the list
        shift(@listOptions);
        }
        
    # Get the length of the array
    $last = $#listOptions;
        
    # If the last char is a digit, alpha, dash or asterisk, do othing
    if($listOptions[$last] =~ /[0-9]+/)        { }
    elsif($listOptions[$last] =~ /[a-zA-Z]+/)  { }
    elsif($listOptions[$last] =~ /-/)          { }
    elsif($listOptions[$last] =~ /\*/)         { }
        
    # Otherwise this means we found an enumerator.
    else {
            
        # Set the enumerator
        $list{"enumerator"} = $listOptions[$last];
        print "DEBUG -> Found an enumerator: " . $list{"enumerator"} . "\n";

        # Remove the enumerator from the list
        pop(@listOptions);
        }
        
    # At this point we have removed prefix and enumerator
        
    # If the first char is i, v, or x, list type is roman
    if ($listOptions[0] =~ /[ixv]/) { $list{"type"} = "roman"; }
        
    # If the first char is I, V, or X, list type is ROMAN
    if ($listOptions[0] =~ /[IXV]/) { $list{"type"} = "ROMAN"; }
        
    if ($listOptions[0] =~ /[ixv]/i) {
            
        # Add each roman number into arabic balue
        foreach $number (@listOptions) {
                
            # If i, add 1
            if ($number =~ /i/i) {
                $list{"startValue"} = $list{"startValue"} + 1;
            }
                
            # If x, add 10
            elsif ($number =~ /x/i) {
                $list{"startValue"} = $list{"startValue"} + 10;
            }
                
            # If v add, 5
            elsif ($number =~ /v/i) {
                $list{"startValue"} = $list{"startValue"} + 5;
            }# ENDIF
                
        }# ENDFOREACH
        print "DEBUG -> List is ". $list{"type"} . " starting at " . $list{"startValue"} . "\n";
    }#ENDIF $listOptions[0] =~ /[ixv]/i
        
    # IF however list is alphabetic
    elsif ($listOptions[0] =~ /[a-z]/i) {
        
        # Convert the array back into scalar 
        $listOptions = join("", @listOptions);
        
        # If is a-z, list type is alpha
        if ($listOptions =~ /[a-z]/) { $list{"type"} = "alpha"; }
        
        # If is I, V, or X, list type is ALPHA
        if ($listOptions =~ /[A-Z]/) { $list{"type"} = "ALPHA"; }
        
        # Assign a numerical value to each letter; will set the start value of list
        # Make this a separate function
        if ($listOptions =~ /[a-z]/i) {        
            if ($listOptions =~ /a/i) { $list{"startValue"} = 1;}
            if ($listOptions =~ /b/i) { $list{"startValue"} = 2;}
            if ($listOptions =~ /c/i) { $list{"startValue"} = 3;}
            if ($listOptions =~ /d/i) { $list{"startValue"} = 4;}                
            if ($listOptions =~ /e/i) { $list{"startValue"} = 5;}
            if ($listOptions =~ /f/i) { $list{"startValue"} = 6;}
            if ($listOptions =~ /g/i) { $list{"startValue"} = 7;}
            if ($listOptions =~ /h/i) { $list{"startValue"} = 8;}   
            if ($listOptions =~ /i/i) { $list{"startValue"} = 9;}
            if ($listOptions =~ /g/i) { $list{"startValue"} = 10;}
            if ($listOptions =~ /k/i) { $list{"startValue"} = 11;}
            if ($listOptions =~ /l/i) { $list{"startValue"} = 12;}                   
            if ($listOptions =~ /m/i) { $list{"startValue"} = 13;}
            if ($listOptions =~ /n/i) { $list{"startValue"} = 14;}
            if ($listOptions =~ /o/i) { $list{"startValue"} = 15;}
            if ($listOptions =~ /p/i) { $list{"startValue"} = 16;}   
            if ($listOptions =~ /q/i) { $list{"startValue"} = 17;}
            if ($listOptions =~ /r/i) { $list{"startValue"} = 18;}
            if ($listOptions =~ /s/i) { $list{"startValue"} = 19;}
            if ($listOptions =~ /t/i) { $list{"startValue"} = 20;}   
            if ($listOptions =~ /u/i) { $list{"startValue"} = 21;}
            if ($listOptions =~ /v/i) { $list{"startValue"} = 22;}
            if ($listOptions =~ /w/i) { $list{"startValue"} = 23;}
            if ($listOptions =~ /x/i) { $list{"startValue"} = 24;}   
            if ($listOptions =~ /y/i) { $list{"startValue"} = 25;}
            if ($listOptions =~ /z/i) { $list{"startValue"} = 26;}                
        }       
        print "DEBUG -> List is ". $list{"type"} . " starting at " . $list{"startValue"} . "\n";
    }#ENDIF $listOptions[0] =~ /[a-z]/i
        
    # If list is numerical
    elsif ($listOptions[0] =~ /[0-9]/) {
        
        # Convert the array back into scalar 
        $listOptions = join("", @listOptions);
            
        # Set the list type
        $list{"type"} = "digit";
        
        # Set the list start value
        $list{"startValue"} = $listOptions;
        print "DEBUG -> List is ". $list{"type"} . " starting at " . $list{"startValue"} . "\n";    
    } #ENDIF $listOptions[0] =~ /[0-9]/     
    
    # Move the line pinter to the next line
    $current +=1;
    
    # Return the list options back to the calling function
    return %list;
}


#/////////////////////////////////
#*********************************
# COVER OPTIONS 
#*********************************
sub coverOptions {
my $i = 0;
my $title = "";
    
print "DEBUG -> Entering coverOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,    "\.FAMILY \"$2\"\n");
        }elsif ($1 eq "font") {push(@tmlout,      "\.FONT \"$2\"\n");
        }elsif ($1 eq "size") {push(@tmlout, "\.SIZE \"$2\"\n");
        }elsif ($1 eq "autolead") {push(@tmlout,     "\.AUTOLEAD \"$2\"\n");
        }elsif ($1 eq "quad") {push(@tmlout,     "\.QUAD \"$2\"\n");
        }elsif ($1 eq "indent") {push(@tmlout,     "\.INDENT \"$2\"\n");
        }elsif ($1 eq "color") {push(@tmlout,"\.COLOR \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [cover]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving coverOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# TITLE OPTIONS 
#*********************************
sub titleOptions {
my $i = 0;
my $title = "";
    
print "DEBUG -> Entering titleOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,    "\.FAMILY \"$2\"\n");
        }elsif ($1 eq "font") {push(@tmlout,      "\.FONT \"$2\"\n");
        }elsif ($1 eq "size") {push(@tmlout, "\.SIZE \"$2\"\n");
        }elsif ($1 eq "autolead") {push(@tmlout,     "\.AUTOLEAD \"$2\"\n");
        }elsif ($1 eq "quad") {push(@tmlout,     "\.QUAD \"$2\"\n");
        }elsif ($1 eq "indent") {push(@tmlout,     "\.INDENT \"$2\"\n");
        }elsif ($1 eq "color") {push(@tmlout,"\.COLOR \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [title]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving titleOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# COPYRIGHT OPTIONS 
#*********************************
sub copyrightOptions {
my $i = 0;
my $title = "";
    
print "DEBUG -> Entering copyrightOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,    "\.FAMILY \"$2\"\n");
        }elsif ($1 eq "font") {push(@tmlout,      "\.FONT \"$2\"\n");
        }elsif ($1 eq "size") {push(@tmlout, "\.SIZE \"$2\"\n");
        }elsif ($1 eq "autolead") {push(@tmlout,     "\.AUTOLEAD \"$2\"\n");
        }elsif ($1 eq "quad") {push(@tmlout,     "\.QUAD \"$2\"\n");
        }elsif ($1 eq "indent") {push(@tmlout,     "\.INDENT \"$2\"\n");
        }elsif ($1 eq "color") {push(@tmlout,"\.COLOR \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [copyright]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving copyrightOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# SECTION OPTIONS 
#*********************************
sub sectionOptions {
my $i = 0;
my $title = "";
    
print "DEBUG -> Entering sectionOptions(): current($current) line now: $tmlfile[$current]";
  
for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
    
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
        
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
            push(@tmlout, $title);
        }elsif ($1 eq "subtitle") {push(@tmlout,    "\.SUBTITLE \"$2\"\n");
        }elsif ($1 eq "author") {push(@tmlout,      "\.AUTHOR \"$2\"\n");
        }elsif ($1 eq "attribution") {push(@tmlout, "\.ATTRIBUTION \"$2\"\n");
        }elsif ($1 eq "editor") {push(@tmlout,      "\.EDITOR \"$2\"\n");
        }elsif ($1 eq "title-family") {push(@tmlout,"\.TITLE_FAMILY \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [section]\n");} 
                
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving sectionOptions(): current($current) line now: $tmlfile[$current]";
        push(@tmlout, "\.START\n");
        return;
   } #ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# CHAPTER OPTIONS 
#*********************************
sub chapterOptions {
my $i = 0;
my $title = "";

    
print "DEBUG -> Entering chapterOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "subtitle")       {push(@tmlout,  "\.SUBTITLE \"$2\"\n");
        }elsif ($1 eq "author")         {push(@tmlout,  "\.AUTHOR \"$2\"\n");
        }elsif ($1 eq "toc-entry")      {push(@tmlout,  "\.TOC_TITLE_ENTRY \"$2\"\n");
        }elsif ($1 eq "header-title")      {push(@tmlout,  "\.HEADER_TITLE \"$2\"\n");
        }elsif ($1 eq "attribution")    {push(@tmlout,  "\.ATTRIBUTION \"$2\"\n");
        }elsif ($1 eq "editor")         {push(@tmlout,  "\.EDITOR \"$2\"\n");
        }elsif ($1 eq "title-family")   {push(@tmlout,  "\.CHAPTER_TITLE_FAMILY $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [chapter]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving chapterOptions(): current($current) line now: $tmlfile[$current]";
        push(@tmlout, "\.START\n");
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# EPIGRAPH OPTIONS 
#*********************************
sub epigraphOptions {
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);


print "DEBUG -> Entering epigraphOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family")     {push(@tmlout,  "\.FAMILY $2\n");
        }elsif ($1 eq "font")       {push(@tmlout,  "\.FONT $font{$2}\n");
        }elsif ($1 eq "size")       {push(@tmlout,  "\.SIZE $2\n");
        }elsif ($1 eq "lead")   {push(@tmlout,  "\.AUTOLEAD $2\n");
        }elsif ($1 eq "indent")     {push(@tmlout,  "\.INDENT $2\n");
        }elsif ($1 eq "color")      {push(@tmlout,  "\.COLOR $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [epigraph]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving epigraphOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# EPIGRAPH BLOCK OPTIONS 
#*********************************
sub epigraphBlockOptions {
my $i = 0;
my $title = "";

my %font = (
bold  =>  "B",
b     =>  "B",
italic =>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);


print "DEBUG -> Entering epigraphBlockOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family")     {push(@tmlout,  "\.FAMILY $2\n");
        }elsif ($1 eq "font")       {push(@tmlout,  "\.FONT $font{$2}\n");
        }elsif ($1 eq "size")       {push(@tmlout,  "\.SIZE $2\n");
        }elsif ($1 eq "autolead")   {push(@tmlout,  "\.AUTOLEAD $2\n");
        }elsif ($1 eq "quad")       {push(@tmlout,  "\.QUAD $quad{$2}\n");
        }elsif ($1 eq "indent")     {push(@tmlout,  "\.INDENT $2\n");
        }elsif ($1 eq "color")      {push(@tmlout,  "\.COLOR $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [epigraphblock]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving epigraphBlockOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#/////////////////////////////////
#*********************************
# BLOCKQUOTE OPTIONS 
#*********************************
sub blockquoteOptions {
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

    
print "DEBUG -> Entering blockquoteOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,    "\.FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,      "\.FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,      "\.SIZE $2\n");
        }elsif ($1 eq "autolead") {push(@tmlout,  "\.AUTOLEAD $2\n");
        }elsif ($1 eq "quad") {push(@tmlout,      "\.QUAD $quad{$2}\n");
        }elsif ($1 eq "indent") {push(@tmlout,    "\.INDENT $2\n");
        }elsif ($1 eq "color") {push(@tmlout,     "\.COLOR $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [blockquote]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving blockquoteOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#*********************************
# QUOTE OPTIONS 
#*********************************
sub quoteOptions {
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);
    
print "DEBUG -> Entering quoteOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,    "\.FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,      "\.FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,      "\.SIZE $2\n");
        }elsif ($1 eq "autolead") {push(@tmlout,  "\.AUTOLEAD $2\n");
        }elsif ($1 eq "quad") {push(@tmlout,      "\.QUAD $quad{$2}\n");
        }elsif ($1 eq "indent") {push(@tmlout,     "\.INDENT $2\n");
        }elsif ($1 eq "color") {push(@tmlout,     "\.COLOR $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [quote]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving quoteOptions(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#*********************************
# LIST OPTIONS 
#*********************************
sub getListOptions {
my $i = 0;
my $title = "";
my %listOptions = (
  type => "",
  startValue => "",
  prefix => "",
  enumerator => "",
  spaceBefore => "",
  spaceAfter => "",
  itemSpacing => "",
  padding => "",
  family => "",
  font => "",
  size => "",
  autolead => "",
  quad => "",
  indent => "",
  auto-indent => "",
  color => "",
  exist => "",
);

print "DEBUG -> Entering listOptions(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
    
        # Flag that options exist so that the calling sub can process accordingly.
        $listOptions{"exist"} = "yes";
        
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "type")         { $listOptions{"type"} =        "$2";                
        }elsif ($1 eq "start-at")     { $listOptions{"startValue"} =  "$2";   
        }elsif ($1 eq "prefix")       { $listOptions{"prefix"} =      "$2";         
        }elsif ($1 eq "enumerator")   { $listOptions{"enumerator"} =  "$2";                
        }elsif ($1 eq "space-before") { $listOptions{"spaceBefore"} = "\.SPACE $2\n";   
        }elsif ($1 eq "space-after")  { $listOptions{"spaceAfter"} =  "\.SPACE $2\n";         
        }elsif ($1 eq "item-spacing") { $listOptions{"itemSpacing"} = "\.SPACE $2\n";
        }elsif ($1 eq "padding")      { $listOptions{"padding"} =     "$2"; 
        }elsif ($1 eq "family")       { $listOptions{"family"} =      "\.FAMILY $2";        
        }elsif ($1 eq "font")         { $listOptions{"font"} =        "\.FONT $2";
        }elsif ($1 eq "size")         { $listOptions{"size"} =        "\.SIZE $2";
        }elsif ($1 eq "autolead")     { $listOptions{"autolead"} =    "\.AUTOLOEAD $2";
        }elsif ($1 eq "quad")         { $listOptions{"quad"} =        "\.QUAD $2";
        }elsif ($1 eq "indent")       { $listOptions{"indent"} =      "$2";
        }elsif ($1 eq "auto-indent")  { $listOptions{"auto-indent"} = "$2";        
        }elsif ($1 eq "color")        { $listOptions{"color"} =       "\.COLOR $2";
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for [list]\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i;
        print "DEBUG -> Leaving listOptions(): current($current) line now: $tmlfile[$current]";
        return %listOptions;
    }# ENDIF
}# ENDFOR
return %listOptions;
}# ENDSUB

#//////////////////////////
#*********************************
# LIST CONFIG
#*********************************
sub listConfig {
my $i = 0;
my $title = "";
my %listOptions = (
  type => "",
  startValue => "",
  prefix => "",
  enumerator => "",
  spaceBefore => "",
  spaceAfter => "",
  itemSpacing => "",
  padding => "",
  family => "",
  font => "",
  size => "",
  autolead => "",
  quad => "",
  indent => "",
  auto-indent => "",
  color => "",
  exist => "",
);

print "DEBUG -> Entering listConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
    
        # Flag that options exist so that the calling sub can process accordingly.
        $listOptions{"exist"} = "yes";
        
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "type")         { $listConfig{"type"} =        "$2";                
        }elsif ($1 eq "start-at")     { $listConfig{"startValue"} =  "$2";   
        }elsif ($1 eq "prefix")       { $listConfig{"prefix"} =      "$2";         
        }elsif ($1 eq "enumerator")   { $listConfig{"enumerator"} =  "$2";                
        }elsif ($1 eq "space-before") { $listConfig{"spaceBefore"} = "\.SPACE $2\n";   
        }elsif ($1 eq "space-after")  { $listConfig{"spaceAfter"} =  "\.SPACE $2\n";         
        }elsif ($1 eq "item-spacing") { $listConfig{"itemSpacing"} = "\.SPACE $2\n";
        }elsif ($1 eq "padding")      { $listConfig{"padding"} =     "$2"; 
        }elsif ($1 eq "family")       { $listConfig{"family"} =      "\.FAMILY $2";        
        }elsif ($1 eq "font")         { $listConfig{"font"} =        "\.FONT $2";
        }elsif ($1 eq "size")         { $listConfig{"size"} =        "\.SIZE $2";
        }elsif ($1 eq "autolead")     { $listConfig{"autolead"} =    "\.AUTOLOEAD $2";
        }elsif ($1 eq "quad")         { $listConfig{"quad"} =        "\.QUAD $2";
        }elsif ($1 eq "indent")       { $listConfig{"indent"} =      "$2";
        }elsif ($1 eq "auto-indent")  { $listConfig{"auto-indent"} = "$2";        
        }elsif ($1 eq "color")        { $listConfig{"color"} =       "\.COLOR $2";
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {list}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i;
        print "DEBUG -> Leaving listConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
return;
}# ENDSUB

#//////////////////////////
#**************************
# INTRODUCTION
#**************************
sub introduction{
my $title ="";
my $link ="none";
my $chapter_number="none";
my $section_number="none";
    
print "Entered introduction() with current ($current), $tmlfile[$current]";
    
#If the first time [section] is used, we need to insert DOCTYPE CHAPTER and #CH_NUM 1
if ($first_section eq "yes") {
    $first_section = "no";
}elsif ($first_chapter eq "no") {
    push(@tmlout,  "\.COLLATE\n");
}else {
    push(@tmlout,  "\.COLLATE\n");
}
#---------------------------------------------------        

#If title is on same line as [introduction]
if ($tmlfile[$current] =~ /\[\s*introduction\s*\]/) {
                       
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    $title = "\.TITLE \"Introduction\"\n";
            
    #Insert TITLE;
    push(@tmlout,  $title);
            
    #Move line pointer to next line
    $current+=1;
}
    print "DEBUG -> Leaving introduction() with current ($current), $tmlfile[$current]";
}# ENDSUB


#//////////////////////////
#**************************
# INTRODUCTION
#**************************
sub preface{
my $title ="";
my $link ="none";
my $chapter_number="none";
my $section_number="none";
    
print "Entered preface() with current ($current), $tmlfile[$current]";
    
#If the first time [section] is used, we need to insert DOCTYPE CHAPTER and #CH_NUM 1
if ($first_section eq "yes") {
    $first_section = "no";
}elsif ($first_chapter eq "no") {
    push(@tmlout,  "\.COLLATE\n");
}else {
    push(@tmlout,  "\.COLLATE\n");
}
#---------------------------------------------------        

#If title is on same line as [introduction]
if ($tmlfile[$current] =~ /\[\s*preface\s*\]/) {
                       
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    $title = "\.TITLE \"Preface\"\n";
            
    #Insert TITLE;
    push(@tmlout,  $title);
            
    #Move line pointer to next line
    $current+=1;
}
    print "DEBUG -> Leaving preface() with current ($current), $tmlfile[$current]";
}# ENDSUB

#//////////////////////////
#**************************
# INTRODUCTION
#**************************
sub foreword{
my $title ="";
my $link ="none";
my $chapter_number="none";
my $section_number="none";
    
print "Entered foreword() with current ($current), $tmlfile[$current]";
    
#If the first time [section] is used, we need to insert DOCTYPE CHAPTER and #CH_NUM 1
if ($first_section eq "yes") {
    $first_section = "no";
}elsif ($first_chapter eq "no") {
    push(@tmlout,  "\.COLLATE\n");
}else {
    push(@tmlout,  "\.COLLATE\n");
}
#---------------------------------------------------        

#If title is on same line as [introduction]
if ($tmlfile[$current] =~ /\[\s*foreword\s*\]/) {
                       
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    $title = "\.TITLE \"Foreword\"\n";
            
    #Insert TITLE;
    push(@tmlout,  $title);
            
    #Move line pointer to next line
    $current+=1;
}
    print "DEBUG -> Leaving foreword() with current ($current), $tmlfile[$current]";
}# ENDSUB

#//////////////////////////
#**************************
# INTRODUCTION
#**************************
sub acknowledgements{
my $title ="";
my $link ="none";
my $chapter_number="none";
my $section_number="none";
    
print "Entered acknowledgements() with current ($current), $tmlfile[$current]";
    
#If the first time [section] is used, we need to insert DOCTYPE CHAPTER and #CH_NUM 1
if ($first_section eq "yes") {
    $first_section = "no";
}elsif ($first_chapter eq "no") {
    push(@tmlout,  "\.COLLATE\n");
}else {
    push(@tmlout,  "\.COLLATE\n");
}
#---------------------------------------------------        

#If title is on same line as [introduction]
if ($tmlfile[$current] =~ /\[\s*acknowledgements\s*\]/) {
                       
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    $title = "\.TITLE \"acknowledgements\"\n";
            
    #Insert TITLE;
    push(@tmlout,  $title);
            
    #Move line pointer to next line
    $current+=1;
}
    print "DEBUG -> Leaving acknowledgements() with current ($current), $tmlfile[$current]";
}# ENDSUB

#//////////////////////////
#**************************
# SECTION TITLE 
#**************************
sub sectionTitle{
my $title ="";
my $link ="none";
my $chapter_number="none";
my $section_number="none";
    
print "Entered sectionTitle() with current ($current), $tmlfile[$current]";

#If [chapter number:link]
if ($tmlfile[$current] =~ /\[section\s+(.+):\s*(.+)\s*\]/){
    $section_number = "\.SECTION \"$1\"\n";
    $link = "\.PDF_LINK \"$2\"\n";
}

#If [chapter number]
elsif ($tmlfile[$current] =~ /\[section\s+(.+)\s*\]/){
    $section_number = "\.SECTION \"$1\"\n";
}
    
# If [chapter: link]
elsif ($tmlfile[$current] =~ /\[\s*section\s*:\s*(.+)\s*\]/ ) {
    $link = "\.PDF_LINK \"$1\"\n";
}
 #------------------------------------------------       
#If the first time [section] is used, we need to insert DOCTYPE CHAPTER and #CH_NUM 1
if ($first_section eq "yes") {
    $first_section = "no";
}elsif ($first_chapter eq "no") {
    push(@tmlout,  "\.COLLATE\n");
}else {
    push(@tmlout,  "\.COLLATE\n");
}
#---------------------------------------------------        

#If title is on same line as [chapter]
if ($tmlfile[$current] =~ /\[\s*section(.*?)\s*\]\s*(.+)\s*/) {
            
    #If there is a :link, insert it after .COLLATE
    if ($link ne "none") {
        push(@tmlout,  $link);
    }
            
    #If there is a chapter number, insert it after .COLLATE
    if ($section_number ne "none") {
        push(@tmlout,  $section_number);$section_number="none";
    }
            
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    #If Title1/Title 2
    if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
    
    #If Only one Title
    elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
            
    #Insert TITLE;
    push(@tmlout,  $title);
            
    #Move line pointer to next line
    $current+=1;
}
#If title is on line separate from [section]
elsif ($tmlfile[$current] =~ /\[\s*section(.*?)\s*\]\s*\n/) {
            
    #If there is a :link, insert it after .COLLATE
    if ($link ne "none") {
        push(@tmlout,  $link);
    }
            
    #If there is a chapter number, insert it after .COLLATE
    if ($section_number ne "none") {
        push(@tmlout,  $section_number);$section_number="none";
    }
            
    $j=0;
            
    #Go through each line after [section] until we hit a option: value or blank line
    for (my $i= $current+1;$i<100;$i++){
    
        #If an option: value or a blank line, stop looking for titles.
        if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {last;}
        if ($tmlfile[$i] eq "\n") {last;}
                
        #If there is one 1 line after [section], this is the first TITLE string
        if ($j eq 0) {
            $title1 = $tmlfile[$i];
            chomp($title1);
        }
                
        #If there are 2 lines of text after [section], this is the second TITLE string
        elsif ($j eq 1) {
            $title2 = $tmlfile[$i];
            chomp($title2);
        }
        $j +=1;
        $current = $current + $j; 
    }
            
    #If there is 1 TITLE string
    if($j eq 1) {
    
        #Get the title(s), remove \n and spaces.
        $title = $title1;chomp($title);trim($title);
            
        #If Title1/Title 2
        if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
            
        #If Only one Title
        elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                
        #Replace the current line with the .TITLE string
        push(@tmlout,  $title);
    }
    
    #If there is 2 TITLE string
    elsif($j eq 2) {
        
        #Create the TITLE string
        $title = ".\TITLE \"$title1\" \"$title2\"\n";

        #Replace the first line with TITLE "Title 1" "Title 2"
        push(@tmlout,  $title);          
    }
    $current+=1;
}# ENDIF
    print "DEBUG -> Leaving sectionTitle() with current ($current), $tmlfile[$current]";
}# ENDSUB


#//////////////////////////
#**************************
# CHAPTER TITLE 
#**************************
sub chapterTitle{
my $title ="";
my $link ="none";
my $chapter_number="none";
my $section_number="none";
    
print "Entered chapterTitle() with current ($current), $tmlfile[$current]";

#If [chapter number:link]
if ($tmlfile[$current] =~ /\[chapter\s+(.+):\s*(.+)\s*\]/){
    $chapter_number = "\.CHAPTER \"$1\"\n";
    $link = "\.PDF_LINK \"$2\"\n";
}
        
#If [chapter number]
elsif ($tmlfile[$current] =~ /\[chapter\s+(.+)\s*\]/){
    $chapter_number = "\.CHAPTER \"$1\"\n";
}
    
# If [chapter: link]
elsif ($tmlfile[$current] =~ /\[\s*chapter\s*:\s*(.+)\s*\]/ ) {
    $link = "\.PDF_LINK \"$1\"\n";
}
 #------------------------------------------------       

#If the first time [chapter] is used, we need to insert DOCTYPE CHAPTER and #CH_NUM 1
if ($first_chapter eq "yes") {
    push(@tmlout,  "\.DOCTYPE CHAPTER\n");
    push(@tmlout,  "\.nr #CH_NUM 1\n");
    $first_chapter = "no";
}else {
    push(@tmlout,  "\.COLLATE\n");
}
#---------------------------------------------------        

#If title is on same line as [chapter]
if ($tmlfile[$current] =~ /\[\s*chapter(.*?)\s*\]\s*(.+)\s*/) {
            
    #If there is a :link, insert it after .COLLATE
    if ($link ne "none") {
        push(@tmlout,  $link);
    }
            
    #If there is a chapter number, insert it after .COLLATE
    if ($chapter_number ne "none") {
        push(@tmlout,  $chapter_number);$chapter_number="none";
    }
            
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    #If Title1/Title 2
    if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
        
    #If Only one Title
    elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
            
    #Insert TITLE;
    push(@tmlout,  $title);
            
    #Move line pointer to next line
    $current+=1;
}

#If title is on line separate from [chapter]
elsif ($tmlfile[$current] =~ /\[\s*chapter(.*?)\s*\]\s*\n/) {
            
    #If there is a :link, insert it after .COLLATE
    if ($link ne "none") {
        push(@tmlout,  $link);
    }
            
    #If there is a chapter number, insert it after .COLLATE
    if ($chapter_number ne "none") {
        push(@tmlout,  $chapter_number);$chapter_number="none";
    }
            
    $j=0;
            
    #Go through each line after [section] until we hit a option: value or blank line
    for (my $i= $current+1;$i<100;$i++){
    
        #If an option: value or a blank line, stop looking for titles.
        if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {last;}
        if ($tmlfile[$i] eq "\n") {last;}
                
        #If there is one 1 line after [section], this is the first TITLE string
        if ($j eq 0) {
            $title1 = $tmlfile[$i];
            chomp($title1);
        }
                
        #If there are 2 lines of text after [section], this is the second TITLE string
        elsif ($j eq 1) {
            $title2 = $tmlfile[$i];
            chomp($title2);
        }
        
        $j +=1;
        $current = $current + $j; 
    }
            
    #If there is 1 TITLE string
    if($j eq 1) {
    
        #Get the title(s), remove \n and spaces.
        $title = $title1;chomp($title);trim($title);
            
        #If Title1/Title 2
        if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.CHAPTER_TITLE \"$1\" \"$2\"\n";}
        
        #If Only one Title
        elsif ($title =~ /(.+)/){$title = "\.CHAPTER_TITLE \"$1\"\n"; }
                
            #Replace the current line with the .TITLE string
            push(@tmlout,  $title);
    }
    
    #If there is 2 TITLE string
    elsif($j eq 2) {
        #Create the TITLE string
        $title = ".\CHAPTER_TITLE \"$title1\" \"$title2\"\n";

        #Replace the first line with TITLE "Title 1" "Title 2"
        push(@tmlout,  $title);
    }
    $current+=1;
}# ENDIF    
    print "DEBUG -> Leaving chapterTitle() with current ($current), $tmlfile[$current]";
}# ENDSUB

#//////////////////////////
#**************************
# HEADING TITLE 
#**************************
sub headingTitle{
my $title ="";
my $link ="";
my $headingLevel = "none";
my $parahead="none";
my $headingString = "";
my $isParahead ="";
    
print "DEBUG -> Entered headingTitle() with current ($current), $tmlfile[$current]";

# If [heading: link]
if ($tmlfile[$current] =~ /\[\s*h(.)\s*:\s*(.+)\s*\]/ ) {
    $headingLevel = $1;
    $link = "NAMED \"$1\"\n";
}
elsif ($tmlfile[$current] =~ /\[\s*h(.)\s*\]\s*(.+)\s*/) {
    $headingLevel = $1;
}

# If this heading level was used as a parahead, we need to reset the style for this heading level
if ($needToResetHeadingStyle[$headingLevel]) {
  if ($headingStyle[$headingLevel]){
    push(@tmlout, "\.HEADING_STYLE $headingLevel");
    push(@tmlout, $headingStyle[$headingLevel]);
    $needToResetHeadingStyle[$headingLevel] = "";
  }
}

#If title is on same line as [heading]
if ($tmlfile[$current] =~ /\[\s*h(.)\s*\]\s*(.+)\s*/) {
    $headingLevel = $1;
     
    #Get the title(s), remove \n and spaces.
    $title = $2;chomp($title);trim($title);
            
    #If Title1/Title 2
    if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\"$1\" \"$2\"\n";}
        
    #If Only one Title
    elsif ($title =~ /(.+)/){$title = "\"$1\"\n"; }
       
    #Create the heading title string
    $headingString = "\.HEADING " . $headingLevel;
    
    if ($link) { $headingString = $headingString . " $link ";}
    $headingString = $headingString . " " . $title;
    
    print "DEBUG ->Heading string is $headingString";
    
    push(@tmlout,  $headingString);
            
    #Move line pointer to next line
    $current+=1;
}

#If title is on line separate from [heading]
elsif ($tmlfile[$current] =~ /\[\s*h(.*?)\s*\]\s*\n/) {

  # If this heading level was used as a parahead, we need to reset the style for this heading level
  if ($needToResetHeadingStyle[$headingLevel]) {
    if ($headingStyle[$headingLevel]){
      push(@tmlout, "\.HEADING_STYLE $headingLevel");
      push(@tmlout, $headingStyle[$headingLevel]);
      $needToResetHeadingStyle[$headingLevel] = "";
    }
  }

  $j=0;
            
  #Go through each line after [section] until we hit a option: value or blank line
  for (my $i= $current+1;$i<100;$i++){
    
      #If an option: value or a blank line, stop looking for titles.
      if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {last;}
      if ($tmlfile[$i] eq "\n") {last;}
                
      #If there is one 1 line after [section], this is the first TITLE string
      if ($j eq 0) {
          $title1 = $tmlfile[$i];
          chomp($title1);
      }
                
      #If there are 2 lines of text after [section], this is the second TITLE string
      elsif ($j eq 1) {
          $title2 = $tmlfile[$i];
          chomp($title2);
      }
        
      $j +=1;
      $current = $current + $j; 
  }# ENDFOR
            
  #If there is 1 TITLE string
  if($j eq 1) {
    
      #Get the title(s), remove \n and spaces.
      $title = $title1;chomp($title);trim($title);
            
      #If Title1/Title 2
      if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\"$1\" \"$2\"\n";}
        
      #If Only one Title
      elsif ($title =~ /(.+)/){ $title = "\"$1\"\n"; }
    
      #Create the heading title string
      $headingString = "\.HEADING " . $headingLevel;
      if ($link) { $headingString = $headingString . " link ";}
      $headingString = $headingString . " " . $title;
    
      push(@tmlout,  $headingString);
  }
    
  #If there is 2 TITLE string
  elsif($j eq 2) {
    #Create the TITLE string
    $title = "\"$title1\" \"$title2\"\n";

    #Create the heading title string
    $headingString = "\.HEADING " . $headingLevel;
    if ($link) { $headingString = $headingString  . " link ";}
    $headingString = $headingString . " " . $title;
    
    push(@tmlout,  $headingString);
  }
  
  $current+=1;
}# ENDIF    
  # We need to keep track of the heading level for use in [parahead]
  $currentHeadingLevel = $headingLevel;
  $current-=1;
  print "DEBUG -> in headingTitle, heading level is $currentHeadingLevel\n";
  print "DEBUG -> Leaving headingTitle() with current ($current), $tmlfile[$current]";
}# ENDSUB

#//////////////////////////
#**************************
# PARAHEAD 
#**************************
sub paraheadTitle{
my $title ="";
my $link ="";
my $headingLevel = "none";
my $parahead="none";
my $headingString = "";
my $isParahead ="";
    
print "DEBUG -> Entered paraheadTitle() with current ($current), $tmlfile[$current]";
print "DEBUG -> in paraheadTitle, heading level is $currentHeadingLevel\n";

$currentHeadingLevel = $currentHeadingLevel + 1;

#If [heading parahead:link]
if ($tmlfile[$current] =~ /\[ph\s+(.+):\s*(.+)\s*\]/){
    $title = $1;
    $link = "NAMED \"$2\"";
    $isParahead = "yes";
}
        
#If [heading parahead]
elsif ($tmlfile[$current] =~ /\[ph\s+(.+)\s*\]/){
    $title = $1;
    $isParahead = "yes";
}

# Push the heading style for the current heading level.
push(@tmlout, "\.HEADING_STYLE $currentHeadingLevel");
push(@tmlout, $headingStyle[$parahead]);

# Push .PP, since parahead must be after a PP
push(@tmlout, "\.PP\n");

print "DEBIG -> parahead title is $title\n";

#Insert the parahead
$headingString = "\.HEADING " . $currentHeadingLevel;
if ($isParahead) { $headingString = $headingString . " PARAHEAD"; }
if ($link) { $headingString = $headingString . " $link"; }
$headingString = $headingString . " \"$title\"\n";
push(@tmlout, $headingString);

# Remove [parahead]
$tmlfile[$current] =~ s/\[ph(.+)\]//;

$needToResetHeadingStyle[$currentHeadingLevel] = "yes";
print "DEBUG -> in paraheadTitle, will need to reset heading style $currentHeadingLevel\n";

$currentHeadingLevel = "";

# Will have to figure out what to do with the line.
$current+=1;
    print "DEBUG -> Leaving paraheadTitle() with current ($current), $tmlfile[$current]";
}# ENDSUB


#//////////////////////////
#**************************
# DOCUMENT CONFIG 
#**************************
sub documentConfig{
my $i = 0;
my $title = "";

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Document Metadata #\n");
print "DEBUG -> Entering documentConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2; $title =~ s/^\s+|\s+$//g;chomp($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "subtitle") {
            $title = $2; $title =~ s/^\s+|\s+$//g;chomp($title); 
            push(@tmlout,    "\.SUBTITLE \"$title\"\n");
        }elsif ($1 eq "author") {push(@tmlout,      "\.AUTHOR \"$2\"\n");
        }elsif ($1 eq "draft") {push(@tmlout,       "\.DRAFT \"$2\"\n");
        }elsif ($1 eq "revision") {push(@tmlout,    "\.REVISION \"$2\"\n");
        }elsif ($1 eq "pdf-title") {push(@tmlout,     "\.PDF_TITLE \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {document}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving documentConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# PAGE CONFIG 
#**************************
sub pageConfig{
my $i = 0;
my $title = "";
my %page_sizes = (
letter => "\.PAPER LETTER",
legal =>  "\.PAPER LEGAL",
statement => "\.PAPER STATEMENT",
tabloid => "\.PAPER TABLOID",
ledger => "\.PAPER LEDGER",
folio => "\.PAPER FOLIO",
quarto => "\.PAPER QUARTO",
trade=> "\.PAGEWIDTH 6i\n.PAGELENGTH 9i",
executive=> "\.PAPER EXECUTIVE",
'10x14'=> "\.PAPER 10x14",
a3=> "\.PAPER A3",
a4=> "\.PAPER A4",
a5=> "\.PAPER A5",
b4=> "\.PAPER B4",
b5=> "\.PAPER B5",
'6x9'=> "\.PAGEWIDTH 6i\n.PAGELENGTH 9i",
);

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Page Style #\n");
print "DEBUG -> Entering pageConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "size") {push(@tmlout,    "$page_sizes{$2}\n");
        }elsif ($1 eq "width") {push(@tmlout,   "\.PAGEWIDTH $2\n");
        }elsif ($1 eq "height") {push(@tmlout,  "\.PAGELENGTH $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {page}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving pageConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# GENERAL HEADER CONFIG 
#**************************
sub generalHeaderConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#genral' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# General Header Style #\n");
print "DEBUG -> Entering generalHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.HEADER_FAMILY $2\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.HEADER_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.HEADER_COLOR $2\n");
        }elsif ($1 eq "margin") {push(@tmlout,   "\.HEADER_MARGIN $2\n");
        }elsif ($1 eq "gap") {push(@tmlout,   "\.HEADER_GAP $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {headers#general}\n");}
        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving generalHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# LEFT HEADER CONFIG 
#**************************
sub leftHeaderConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#genral' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# Left Header Style #\n");
print "DEBUG -> Entering leftHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.HEADER_LEFT_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.HEADER_LEFT_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.HEADER_LEFT_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.HEADER_LEFT_COLOR $2\n");
        }elsif ($1 eq "string") {push(@tmlout,   "\.HEADER_LEFT_STRING $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {headers#left}\n");}
    
    # Options with no args
    }elsif ($tmlfile[$i] =~ /\s*smallcaps\s*/) {
        push(@tmlout,   "\.HEADER_LEFT_SMALLCAPS\n");    
    }elsif ($tmlfile[$i] =~ /\s*caps\s*/) {
        push(@tmlout,   "\.HEADER_LEFT_CAPS\n");  
        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving leftHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# RIGHT HEADER CONFIG 
#**************************
sub rightHeaderConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#genral' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# Right Header Style #\n");
print "DEBUG -> Entering rightHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.HEADER_RIGHT_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.HEADER_RIGHT_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.HEADER_RIGHT_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.HEADER_RIGHT_COLOR $2\n");
        }elsif ($1 eq "string") {push(@tmlout,   "\.HEADER_RIGHT_STRING $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {headers#right}\n");}
    
    # Options with no args
    }elsif ($tmlfile[$i] =~ /\s*smallcaps\s*/) {
        push(@tmlout,   "\.HEADER_RIGHT_SMALLCAPS\n");    
    }elsif ($tmlfile[$i] =~ /\s*caps\s*/) {
        push(@tmlout,   "\.HEADER_RIGHT_CAPS\n");  
        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving rightHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# CENTER HEADER CONFIG 
#**************************
sub centerHeaderConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#genral' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# Center Header Style #\n");
print "DEBUG -> Entering centerHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.HEADER_CENTER_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.HEADER_CENTER_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.HEADER_CENTER_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.HEADER_CENTER_COLOR $2\n");
        }elsif ($1 eq "string") {push(@tmlout,   "\.HEADER_CENTER_STRING $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {headers#center}\n");}
    
    # Options with no args
    }elsif ($tmlfile[$i] =~ /\s*smallcaps\s*/) {
        push(@tmlout,   "\.HEADER_CENTER_SMALLCAPS\n");    
    }elsif ($tmlfile[$i] =~ /\s*caps\s*/) {
        push(@tmlout,   "\.HEADER_CENTER_CAPS\n");  
        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving centerHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# CENTER HEADER CONFIG 
#**************************
sub headerRuleConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

# '#genral' is of no interest to us, move to the next line to scan for options
$toc_cnt+=1;

push(@tmlout, "\.\n\.\\# Header Rule Style #\n");
print "DEBUG -> Entering headerRuleConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";

for ( $i = $toc_cnt; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "weight") {push(@tmlout,   "\.HEADER_RULE_WEIGHT $2\n");
        }elsif ($1 eq "gap") {push(@tmlout,   "\.HEADER_RULE_GAP $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.HEADER_RULE_COLOR $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {headers#rule}\n");}
    
    # Options with no args
    }elsif ($tmlfile[$i] =~ /\s*none\s*/) {
        push(@tmlout,   "\.HEADER_RULE OFF\n");     
        
    # No more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $toc_cnt = $i-1;
        print "DEBUG -> Leaving headerRuleHeaderConfig(): current($toc_cnt) line now: $tmlfile[$toc_cnt]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# HEADER CONFIG
# Sets up the options and formatting headers
#*************************
sub headerConfig{
my $i = 0;
my $title = "";

# {contents} is of no interest to us, move to the next line to scan for options
$current+=1;

print "DEBUG -> Entering headerConfig(): current($current) line now: $tmlfile[$current]";

for ( $toc_cnt = $current; $toc_cnt<100; $toc_cnt++) {
    print "DEBUG -> tmlfile[$toc_cnt]: $tmlfile[$toc_cnt]";
    print "DEBUG -> tmlfile[$current]: $tmlfile[$current]";
    # Will need to figure how to deal with the loop counters.
    # If #general
    if ($tmlfile[$toc_cnt] =~ /\s*#general\s*/) {
      print "Found #general\n";
      generalHeaderConfig();
    }
    
    # If #header
    elsif ($tmlfile[$toc_cnt] =~ /\s*#left\s*/ ) {
      print "Found #header\n";
      leftHeaderConfig();
    }
    # If #titles
    elsif ($tmlfile[$toc_cnt] =~ /\s*#right\s*/){
      print "Found #titles\n";
      rightHeaderConfig();
    }
    #if #hx
    elsif ($tmlfile[$toc_cnt] =~ /\s*#center\s*/){
      print "Found #hx\n";
      centerHeaderConfig($1);
    }
    #if #entry-page-numbers
    elsif ($tmlfile[$toc_cnt] =~ /\s*#rule\s*/){
      print "Found #page-numbers\n";
      headerRuleConfig();
      
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $toc_cnt-1;
        print "DEBUG -> Leaving headerConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# MARGIN CONFIG 
#**************************
sub marginConfig{
my $i = 0;
my $title = "";

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Margin Style #\n");
print "DEBUG -> Entering marginConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "left") {push(@tmlout,    "\.L_MARGIN $2\n");
        }elsif ($1 eq "right") {push(@tmlout,   "\.R_MARGIN $2\n");
        }elsif ($1 eq "bottom") {push(@tmlout,   "\.B_MARGIN $2\n");
        }elsif ($1 eq "top") {push(@tmlout,   "\.T_MARGIN $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {margins}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving marginConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# CHAPTER CONFIG 
#**************************
sub chapterConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Chapter Style #\n");
print "DEBUG -> Entering chapterConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "string") {push(@tmlout,   "\.CHAPTER_STRING \"$2\"\n");
        }elsif ($1 eq "family") {push(@tmlout,   "\.CHAPTER_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.CHAPTER_FONT $font{$2}\n");
        }elsif ($1 eq "quad") {push(@tmlout,   "\.CHAPTER_QUAD $quad{$2}\n");
        }elsif ($1 eq "title-family") {push(@tmlout,   "\.CHAPTER_TITLE_FAMILY $2\n");
        }elsif ($1 eq "title-font") {push(@tmlout,   "\.CHAPTER_TITLE_FONT $font{$2}\n");
        }elsif ($1 eq "title-quad") {push(@tmlout,   "\.CHAPTER_TITLE_QUAD $quad{$2}\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {chapters}\n");}

    # Options with no args
    }elsif ($tmlfile[$i] =~ /\s*start-on-odd-pages\s*/) {
        push(@tmlout, "\.rn COLLATE COLLATE-OLD\n\.de COLLATE\n\. if o \.BLANKPAGE 1 DIVIDER\n\. COLLATE-OLD\n\.\.\n");
    
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving chapterConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# HEADING CONFIG 
#**************************
sub headingConfig{
my $headingLevel = @_[0];
my $i = 0;
my $title = "";
my @style;
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);


# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Heading $headingLevel Style #\n");
print "DEBUG -> Entering headingConfig(): current($current) line now: $tmlfile[$current]";

# Push the heading style level.
push(@tmlout,   "\.HEADING_STYLE $headingLevel");

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@style,   " \\\nFAMILY $2");
        }elsif ($1 eq "font") {push(@style,   " \\\nFONT $font{$2}");
        }elsif ($1 eq "size") {push(@style,   " \\\nSIZE $2");
        }elsif ($1 eq "color") {push(@style,   " \\\nCOLOR $2");
        }elsif ($1 eq "underscore") {push(@style,,   " \\\nUNDERSCORE $2");
        }elsif ($1 eq "underscore2") {push(@style,   " \\\nUNDERSCORE2 $2");
        }elsif ($1 eq "adjust") {push(@style,   " \\\nBASELINE_ADJUST $2");
        }elsif ($1 eq "color") {push(@style,   " \\\nCOLOR $2");
        }elsif ($1 eq "quad") {push(@style,   " \\\nQUAD $quad{$2}");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {h" . $headingLevel . "}\n");}

    # Options with no args
    }elsif ($tmlfile[$i] =~ /smallcaps/) {
        push(@style,   " \\\nSMALLCAPS");
    }elsif ($tmlfile[$i] =~ /no-caps/) {
        push(@style,   " \\\nNO_CAPS");
    }elsif ($tmlfile[$i] =~ /caps/) {
        push(@style,   " \\\nCAPS");
    }elsif ($tmlfile[$i] =~ /no-smallcaps/) {
        push(@style,   " \\\nNO_SMALLCAPS");
    }elsif ($tmlfile[$i] =~ /space-after/) {
        push(@style,   " \\\nSPACE_AFTER");
    }elsif ($tmlfile[$i] =~ /no-space-after/) {
        push(@style,   " \\\nNO_SPACE_AFTER");      
    }elsif ($tmlfile[$i] =~ /numbered/) {
        push(@style,   " \\\nNUMBER");
    }elsif ($tmlfile[$i] =~ /no-number/) {
        push(@style,   " \\\nNO_NUMBER");      
                   
    #Else there are no more options
    }else {
        # Create the style as a string and save it.
        push(@style, "\n");
        $headingStyle[$headingLevel] = join("", @style);
        
        # Now also add it to the output file
        push(@tmlout, @style);
        
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving headingConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# PARAHEAD CONFIG 
#**************************
sub paraheadConfig{
my $i = 0;
my $title = "";
my @style;
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

print "DEBUG -> Entering paraheadConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@style,   " \\\nFAMILY $2");
        }elsif ($1 eq "font") {push(@style,   " \\\nFONT $font{$2}");
        }elsif ($1 eq "size") {push(@style,  " \\\nSIZE $2");
        }elsif ($1 eq "color") {push(@style,   " \\\nCOLOR $2");
        }elsif ($1 eq "underscore") {push(@style,   " \\\nUNDERSCORE $2");
        }elsif ($1 eq "underscore2") {push(@style,   " \\\nUNDERSCORE2 $2");
        }elsif ($1 eq "adjust") {push(@style,   " \\\nBASELINE_ADJUST $2");
        }elsif ($1 eq "color") {push(@style,   " \\\nCOLOR $2");
        }elsif ($1 eq "quad") {push(@style,   " \\\nQUAD $quad{$2}");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {parahead}\n");}

    # Options with no args
    }elsif ($tmlfile[$i] =~ /smallcaps/) {
        push(@style,   " \\\nSMALLCAPS");
    }elsif ($tmlfile[$i] =~ /no-caps/) {
        push(@style,   " \\\nNO_CAPS");
    }elsif ($tmlfile[$i] =~ /caps/) {
        push(@style,   " \\\nCAPS");
    }elsif ($tmlfile[$i] =~ /no-smallcaps/) {
        push(@style,   " \\\nNO_SMALLCAPS");
    }elsif ($tmlfile[$i] =~ /space-after/) {
        push(@style,   " \\\nSPACE_AFTER");
    }elsif ($tmlfile[$i] =~ /no-space-after/) {
        push(@style,   " \\\nNO_SPACE_AFTER");      
    }elsif ($tmlfile[$i] =~ /numbered/) {
        push(@style,   " \\\nNUMBER");
    }elsif ($tmlfile[$i] =~ /no-number/) {
        push(@style,   " \\\nNO_NUMBER"); 
        
    #Else there are no more options
    }else {
        # Create the style as a string and save it.
        push(@style, "\n");
        $headingStyle["parahead"] = join("", @style);
        
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving paraheadConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB



#//////////////////////////
#**************************
# EPIGRAPH CONFIG 
#**************************
sub epigraphConfig{
my $i = 0;
my $title = "";

my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);


# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Epigraph Style #\n");
print "DEBUG -> Entering epigraphConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.EPIGRAPH_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.EPIGRAPH_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.EPIGRAPH_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.EPIGRAPH_COLOR $2\n");
        }elsif ($1 eq "lead") {push(@tmlout,   "\.EPIGRAPH_AUTOLEAD $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {epigraphs}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving epigraphConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# EPIGRAPH BLOCK CONFIG 
#**************************
sub epigraphBlockConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Epigraph Block Style #\n");
print "DEBUG -> Entering epigraphblockConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.EPIGRAPH_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.EPIGRAPH_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.EPIGRAPH_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.EPIGRAPH_COLOR $2\n");
        }elsif ($1 eq "lead") {push(@tmlout,   "\.EPIGRAPH_AUTOLEAD $2\n");
        }elsif ($1 eq "indent") {push(@tmlout,   "\.EPIGRAPH_INDENT $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {epigraphblocks}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving epigraphblockConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# BLOCKQUOTE CONFIG 
#**************************
sub blockquoteConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Blockquote Style #\n");
print "DEBUG -> Entering blockquoteConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.BLOCKQUOTE_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.BLOCKQUOTE_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.BLOCKQUOTE_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.BLOCKQUOTE_COLOR $2\n");
        }elsif ($1 eq "lead") {push(@tmlout,   "\.BLOCKQUOTE_AUTOLEAD $2\n");
        }elsif ($1 eq "indent") {push(@tmlout,   "\.BLOCKQUOTE_INDENT $2\n");
        }elsif ($1 eq "quad") {push(@tmlout,   "\.BLOCKQUOTE_QUAD $quad{$2}\n");
        #}elsif ($1 eq "padding") {push(@tmlout,   "\.INSERT CODE HERE \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {blockquotes}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving blockquoteConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# QUOTE CONFIG 
#**************************
sub quoteConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Quote Style #\n");
print "DEBUG -> Entering quoteConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.QUOTE_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.QUOTE_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.QUOTE_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.QUOTE_COLOR $2\n");
        }elsif ($1 eq "lead") {push(@tmlout,   "\.QUOTE_AUTOLEAD $2\n");
        }elsif ($1 eq "indent") {push(@tmlout,   "QUOTE_INDENT $2\n");
        }elsif ($1 eq "quad") {push(@tmlout,   "\.QUOTE_QUAD $quad{$2}\n");
        #}elsif ($1 eq "padding") {push(@tmlout,   "\.INSERT CODE HERE \"$2\"\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {quotes}\n");}
            
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving quoteConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# FOOTNOTE CONFIG 
#**************************
sub footnoteConfig{
my $i = 0;
my $title = "";
my %font = (
bold  =>  "B",
b     =>  "B",
italic=>  "I",
i     =>  "I",
bold-italic=> "BI",
bi    =>  "BI",
roman =>  "R",
r     =>  "R",
);

my %quad = (
left    =>  "LEFT",
right   =>  "RIGHT",
center  =>  "CENTER",
justify =>  "JUSTIFY",
);

my %marker = (
star    =>  "STAR",
number   =>  "NUMBER",
);


# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Footnote Style #\n");
print "DEBUG -> Entering footnoteConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "family") {push(@tmlout,   "\.FOOTNOTE_FAMILY $2\n");
        }elsif ($1 eq "font") {push(@tmlout,   "\.FOOTNOTE_FONT $font{$2}\n");
        }elsif ($1 eq "size") {push(@tmlout,   "\.FOOTNOTE_SIZE $2\n");
        }elsif ($1 eq "color") {push(@tmlout,   "\.FOOTNOTE_COLOR $2\n");
        }elsif ($1 eq "lead") {push(@tmlout,   "\.FOOTNOTE_AUTOLEAD $2\n");
        }elsif ($1 eq "quad") {push(@tmlout,   "\.FOOTNOTE_QUAD $quad{$2}\n");
        }elsif ($1 eq "padding") {push(@tmlout,   "\.FOOTNOTE_NUMBER_PLACEHOLDER $2\n");
        }elsif ($1 eq "marker") {push(@tmlout,   "\.FOOTNOTE_MARKER_STYLE $marker{$2}\n");
        }elsif ($1 eq "spacing") {push(@tmlout,   "\.FOOTNOTE_SPACING $2\n");
        }elsif ($1 eq "rule-weight") {push(@tmlout,   "\.FOOTNOTE_RULE_WEIGHT $2\n");
        }elsif ($1 eq "rule-length") {push(@tmlout,   "\.FOOTNOTE_RULE_LENGTH $2\n");
        }elsif ($1 eq "rule-adjust") {push(@tmlout,   "\.FOOTNOTE_RULE_ADJ $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {footnotes}\n");}
    
    # Options with no arguments
    }elsif ($tmlfile[$i] =~ /\s*reset-on-new-page\s*/) {
      push(@tmlout,   "\.RESET_FOOTNOTE_NUMBER PAGE\n");
    }elsif ($tmlfile[$i] =~ /\s*no-rule\s*/) {
      push(@tmlout,   "\.FOOTNOTE_RULE OFF\n");
    
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving footnoteConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB

#//////////////////////////
#**************************
# PARAGRAPH CONFIG 
#**************************
sub paragraphConfig{
my $i = 0;
my $title = "";

# {document} is of no interest to us, move to the next line to scan for options
$current+=1;

push(@tmlout, "\.\\# Paragraph Style #\n");
print "DEBUG -> Entering paragraphConfig(): current($current) line now: $tmlfile[$current]";

for ( $i = $current; $i<100; $i++) {
    #print "tmlfile[$i]: $tmlfile[$i]";
    if ($tmlfile[$i] =~ /\s*(.+):\s*(.+)\s*/) {
        if ($1 eq "title") {
            #Get the title(s), remove \n and spaces.
            $title = $2;chomp($title);trim($title);
            
            #If Title1/Title 2
            if ($title =~ /(.+)\s*\/\s*(.+)/){$title = "\.TITLE \"$1\" \"$2\"\n";}
                    
            #If Only one Title
            elsif ($title =~ /(.+)/){$title = "\.TITLE \"$1\"\n"; }
                push(@tmlout,  $title);
        }elsif ($1 eq "indent") {push(@tmlout,   "\.PARA_INDENT $2\n");
        }elsif ($1 eq "space") {push(@tmlout,   "\.PARA_SPACE $2\n");
        }else {$error_line = $i+1;die("ERROR on line [$error_line] -> \'$1\' is not a valid option for {paragraphs}\n");}

    # Options with no args
    }elsif ($tmlfile[$i] =~ /\s*indent-first-paragraphs\s*/) {push(@tmlout,   "\.INDENT_FIRST_PARAS\n");
    
    #Else there are no more options
    }else {
        #Update the current line counter to point to the last line where an option was found
        $current = $i-1;
        print "DEBUG -> Leaving paragraphConfig(): current($current) line now: $tmlfile[$current]";
        return;
    }# ENDIF
}# ENDFOR
}# ENDSUB


#//////////////////////////
#**************************
# ALIASE CONFIG
#**************************
sub aliases {
$j=0;

print "DEBUG -> Entering aliasConfig(): current($current) line now: $tmlfile[$current]";

# Move to line after {aliases}
$current+=1;

# Load instances of alias = synonym into an array
for ($i=$current;$i<100;$i++){
    if ($tmlfile[$i] =~ /(.+[^\s])\s*=\s*(.+)/){
        $alias[$j]= trim($1);
        $synonym[$j]= trim($2);
        $j+=1;
    }else {
        last;
    }# ENDIF
}# ENDFOR

# Move the pointer to the last alias = synonym
$current = $i;

print "DEBUG -> Going to scan for aliases...: current($current) line now: $tmlfile[$current]";

# For each line in the input file...
for ($i=$current;$i<$#tmlfile+1; $i++) {

    # If any of the aliases are found within {..}, [...] or <...<, replace them with their synonym.
    foreach ($j=0; $j<$#alias+1;$j++) {
    
        # The regex to match the alias within [...], <...< and {...}
        $re_alias = "([{\\[<].*?)" . $alias[$j] . "(.*?[\\]}<])";
        
        # If the alias is found, do the substitution
        if ($tmlfile[$i] =~ /$re_alias/) {
            $re_synonym = $1 . $synonym[$j] . $2;
            $tmlfile[$i] =~ s/$re_alias/$re_synonym/g;
        }# ENDIF
    }# ENDFOR
}# ENDFOR
print "DEBUG -> Leaving aliasConfig(): current($current) line now: $tmlfile[$current]";
}# ENDSUB

#//////////////////////////
#**************************
# STRINGS CONFIG
#**************************
sub strings {
$j=0;

print "DEBUG -> Entering strings(): current($current) line now: $tmlfile[$current]";

# Move to line after {strings}
$current+=1;

# Load instances of string = synonym into an array
for ($i=$current;$i<100;$i++){
    if ($tmlfile[$i] =~ /(.+[^\s])\s*=\s*(.+)/){
        $string[$j]= trim($1);
        $expanded_string[$j]= trim($2);
        print "DEBUG -> string $string[$j] will expand to $expanded_string[$j]\n";
        $j+=1;
    }else {
        last;
    }# ENDIF
}# ENDFOR

# Move the pointer to the last string = synonym
$current = $i;

print "DEBUG -> Going to scan for string...: current($current) line now: $tmlfile[$current]";

# For each line in the input file...
for ($i=$current;$i<$#tmlfile+1; $i++) {

    # If any of the strings are found
    foreach ($j=0; $j<$#string+1;$j++) {
    
        # The regex to match anywhere in the current line
        $re_alias = $string[$j];
        print "DEBUG -> scanning for \"$string[$j]\"\n";
        
        # Do the substitution
        $re_synonym = $expanded_string[$j];
        print "DEBUG -> Replacing $re_alias with \"$re_synonym\"\n";
        $tmlfile[$i] =~ s/$re_alias/$re_synonym/g;
    }# ENDFOR
}# ENDFOR
print "DEBUG -> Leaving strings(): current($current) line now: $tmlfile[$current]";
}# ENDSUB




#//////////////////////////
#**************************
# INCLUDE
#**************************
sub include {
$j=0;
my @allFiles;

print "DEBUG -> Entering include(): current($current) line now: $tmlfile[$current]";

# Move to line after {include}
$current+=1;

# Load instances of alias = synonym into an array
for ($i=$current;$i<100;$i++){
    if ($tmlfile[$i] eq "\n"){
        last;
    }else {
    
        # Get the file name
        $filename = $tmlfile[$i];
        
        # Open the file 
        open(FILE, $filename) || die("Could not open $filename\n");
        @includeFile = <FILE>;
        close(FILE);
        
        # Append the file into the temporary file array
        push(@allFiles, @includeFile);
        
        # Since blank lines delineate when to start and stop processing, 
        # Add a blank line in after the last line of the last inserted file, and before the next file to insert
        push(@allFiles, "\n");
    }# ENDIF
}# ENDFOR

#print @allFiles;

# Move the pointer to the last file name
$current = $i;

# Remove the last "\n" that was inserted..or else we will have a "\n" too many.
pop(@allFiles);

# Insert the included files into the main tmlfile
splice(@tmlfile, $current, 0, @allFiles);

print "DEBUG -> Leaving include(): current($current) line now: $tmlfile[$current]";

# Backup the line pointer since it will be incremented in the next loop iteration
$current-=1;

}# ENDSUB



#//////////////////////////
#**************************
# KERNING CONFIG
#**************************
sub kerningConfig {
  print "DEBUG -> Entering kerningConfig()...\n";
  #{kerning:on|off}
  if ($tmlfile[$current] =~ /{\s*kerning:\s*on\s*}/)  {push(@tmlout, "\.KERN\n");}
  if ($tmlfile[$current] =~ /{\s*kerning:\s*off\s*}/) {push(@tmlout, "\.KERN OFF\n");}
  print "DEBUG -> Leaving kerningConfig()...\n";
}#ENDSUB


#//////////////////////////
#**************************
# LIGATURE CONFIG
#**************************
sub ligatureConfig {
  print "DEBUG -> Entering ligatureConfig()...\n";
  #{kerning:on|off}
  if ($tmlfile[$current] =~ /{\s*ligatures:\s*on\s*}/)  {push(@tmlout, "\.LIG\n");}
  if ($tmlfile[$current] =~ /{\s*ligatures:\s*off\s*}/) {push(@tmlout, "\.LIG OFF\n");}
  print "DEBUG -> Leaving ligatureConfig()...\n";
}#ENDSUB

#//////////////////////////
#**************************
# INLINE FORMATTING
#**************************
sub inlineFormatting(){
#1. add the commands for opening group to an array
#2. Join the array to create  a string for the current command group
#3. Replace current token with string created above
#4. While doing 2, do 1 and 2 but for closing the commands - add to stack
#5. When > encountered - simply pop the stack and this will pop the string created to close all commands for that group.
#6. Replace current token '>" with the string just popped
#7. When no more tokens remain for the current line, reconstruct the current line by joining the tokenized line back into one string, and in which the <...<has been replaced with a string of all opening commands and > has been replaced with a string containing all correspondinf closing commands.
    $currentLine = $tmlout[$current];
    $i = 2;
    
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
              $openGroup = $openGroup . "\n.SETBOLDER $value\n\\*[BOLDER]"; 
              #print "$openGroup\n"; 
              push(@closeGroup, "\\*[BOLDERX]");
            }
            elsif ($command =~ /slant/)
            {
              $openGroup = $openGroup . "\n.SETSLANT $value\n\\*[SLANT]"; 
              #print "$openGroup\n"; 
              push(@closeGroup, "\\*[SLANTX]");
            }
            elsif ($command =~ /condense/)
            {
              $openGroup = $openGroup . "\n.CONDENSE $value\n\\*[COND]"; 
              #print "$openGroup\n"; 
              push(@closeGroup, "\\*[CONDX]");
            }
            elsif ($command =~ /extend/)
            {
              $openGroup = $openGroup . "\n.EXTEND $value\n\\*[EXT]"; 
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
            elsif ($command =~ /family/) # Need to fix this since sub getValue doesn't look for arguments of type string
            {
              $openGroup = $openGroup . "\\*[FAM $value]"; 
              #print "$openGroup\n"; 
              push(@closeGroup, "\\*[PREV]");
            }
            elsif ($command =~ /^-/)
            {
              $openGroup = $openGroup . "\\*[SIZE $value]"; 
              #print "$openGroup\n"; 
              push(@closeGroup, "\\*[SIZE]");
            }
            elsif ($command =~ /^\+/)
            {
              $openGroup = $openGroup . "\\*[SIZE $value]"; 
              #print "$openGroup\n"; 
              push(@closeGroup, "\\*[SIZE]");
            }
            elsif ($command =~ /^\d.*?/)
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
      # Main: If token is  >  
      }elsif ($token =~ />/)
      {   #If the > is escaped with '\' as determined
                if ($escaped eq "yes") {
                    $escaped = "no"; 
                    $token = "\>";
                    $newLine = $newLine . $token;
                }else{
                #If the previous token ends with escape '\', replace with '\>'
                #if ($currentLine[$i] =~ /\\$/) {
                #    $token = "\>";
                #    $newLine = $newLine . $token;
                #    print "NEW: $newLine\n"; 
                #} else {
                    $newLine = $newLine . join("", reverse(@closeGroup)); 
                    @closeGroup=();
        #}
        }
      }
      # Main: If not <...< or >, regular text.
      else {
                #If the text ends with '\', meaning '\>' flag it so that we don't pop the stack next time we see a >. 
                #if it's escaped it's literal > that we need to print out.
                if ($token =~ /\\$/) {$escaped = "yes"}
        $newLine = $newLine . $token;
      }
    }#end foreach $token (@currentLine)
    $tmlout[$current]= $newLine; $newLine = "";
    $i +=1;
}

sub isCommandGroup{
        # Simply check if the token is in the format of <...<, return tru or false.
        $tkn = @_[0];
        #print "Tkn: $tkn\n";
    if ($tkn =~ m/\\</) {return "false";}
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



#//////////////////////////
#**************************
# TRIM 
#**************************
sub ltrim { my $s = shift; $s =~ s/^\s+//; return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//; return $s };
sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
