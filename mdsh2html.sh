#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #

  MAIN=$1
  TMPDIR=tmp
  OUTDIR=___/html

  HTMLNAME=`echo $1 | sed 's/[^a-zA-Z0-9 ]//g' | sed 's/http//g'`
  HTML=$OUTDIR/${HTMLNAME}.html

# --------------------------------------------------------------------------- #
# INTERACTIVE CHECKS 
# --------------------------------------------------------------------------- #
# if [ -f $PDF ]; then
#      echo "$PDF does exist"
#      read -p "overwrite ${PDF}? [y/n] " ANSWER
#      if [ X$ANSWER != Xy ] ; then echo "Bye"; exit 0; fi
# fi

  echo "converting $1"

# =========================================================================== #
# CONFIGURATION                                                               #
# --------------------------------------------------------------------------- #

  FUNCTIONSBASIC=lib/sh/basic.1504191646.functions
   FUNCTIONSPLUS=lib/sh/html.conversations.1504192033.functions
       FUNCTIONS=$TMPDIR/functions.tmp
  cat $FUNCTIONSBASIC $FUNCTIONSPLUS > $FUNCTIONS

  source $FUNCTIONS

# --------------------------------------------------------------------------- #
  PANDOCACTION="pandoc --ascii -r markdown -w html"
# --------------------------------------------------------------------------- #
# FOOTNOTES
# \footnote{the end is near, the text is here}
# --------------------------------------------------------------------------- #
  FOOTNOTEOPEN="FOOTNOTEOPEN$RANDOM{" ; FOOTNOTECLOSE="}FOOTNOTECLOSE$RANDOM"
# CITATIONS
# \cite{phillips:2004:vectoraesthetic}
# --------------------------------------------------------------------------- #
  CITEOPEN="CITEOPEN$RANDOM" ; CITECLOSE="CITECLOSE$RANDOM"
# \cite[1-8]{phillips:2004:vectoraesthetic}
# --------------------------------------------------------------------------- #
  CITEPOPEN="$CITEOPEN" ; CITEPCLOSE="$CITECLOSE"
# =========================================================================== #

# --------------------------------------------------------------------------- #
# ACTION HAPPENS HERE!
# --------------------------------------------------------------------------- #

  mdsh2src $MAIN

# --------------------------------------------------------------------------- #
# EDIT RAW/PANDOC HTML
# --------------------------------------------------------------------------- #

# REMOVE NEWLINES (EASIFY PARSING)
  sed -i ':a;N;$!ba;s/\n//g'                        $SRCDUMP
# UNNTEST BLOCKQUOTES
  sed -i 's/<blockquote><p>/<blockquote>/g'         $SRCDUMP
  sed -i 's/<\/p><\/blockquote>/<\/blockquote>/g'   $SRCDUMP
# NEWLINE FOR </p>
  sed -i 's/<\/p>/<\/p>\n/g'                        $SRCDUMP
# UNNEST <h1>
  sed -i -r '/^<p><h1>.*<\/h1><\/p>$/s/<[\/]?p>//g' $SRCDUMP
# 2 NEWLINES FOR <p
  sed -i 's/<p/\n\n<p/g'                            $SRCDUMP
# REMOVE EMPTY PARAGRAPHS
# sed -i 's/<p><\/p>//g'                            $SRCDUMP
# REMOVE EMPTY PARAGRAPHS EVEN WITH A CLASS
  sed -i -r '/^<p.*+><\/p>$/s/^.*$//g'              $SRCDUMP
# DELETE <p> AND </p> IF LINE STARTS AND ENDS WITH HTML COMMENT
  sed -i '/^<p><!--/s/--><\/p>$/-->\n/g'            $SRCDUMP 
  sed -i '/-->$/s/^<p><!--/\n<!--/g'                $SRCDUMP
# ADD NEWLINE AFTER </p>
  sed -i 's/<\/p>/&\n/g'                            $SRCDUMP
# DELETE CONSECUTIVE EMPTY LINES
  sed -i '/^$/N;/^\n$/D'                            $SRCDUMP
# MAKE <code> <tt>
  sed -i 's/<code>/<tt>/g'                          $SRCDUMP
  sed -i 's/<\/code>/<\/tt>/g'                      $SRCDUMP

# JUST REMOVE BIBLIOGRAPHY REFERENCES (SO FAR)
  sed -i "s/$CITEOPEN/\n&/g"     $SRCDUMP
  sed -i "s/$CITECLOSE/&\n/g"    $SRCDUMP
  sed -i "/^$CITEOPEN/s/^.*$//g" $SRCDUMP

# --------------------------------------------------------------------------- #
# MAKE FOOTNOTES
# --------------------------------------------------------------------------- #
  echo "<hr/>"           >> $SRCDUMP
  echo "<ol>"            >> $SRCDUMP
  COUNT=1
  for FOOTNOTE in `sed "s/$FOOTNOTEOPEN/\n&/g" $SRCDUMP | #
                   sed 's/ /5P4C3XX/g'                  | #
                   sed "s/$FOOTNOTECLOSE/&\n/"          | # 
                   grep "^$FOOTNOTEOPEN"`
   do
      ID=`echo $FOOTNOTE | md5sum | cut -c 1-8`
      FOOTNOTETXT=`echo $FOOTNOTE    | #
                   cut -d "{" -f 2   | #
                   cut -d "}" -f 1   | #
                   sed 's/5P4C3XX/ /g'`
      FOOTNOTE=`echo $FOOTNOTE       | #
                sed 's/5P4C3XX/ /g'  | #
                sed 's/\[/\\\[/g'    | #
                sed 's/|/\\|/g'`
      OLDFOOTNOTE=$FOOTNOTE
      NEWFOOTNOTE="<sup><a href=\"#$ID\">$COUNT</a><\/sup>"
      sed -i "s|$OLDFOOTNOTE|$NEWFOOTNOTE|g" $SRCDUMP
      echo "<li id=\"$ID\"> $FOOTNOTETXT </li>" >> $SRCDUMP
      COUNT=`expr $COUNT + 1`
  done
  echo "</ol>"           >> $SRCDUMP

  sed -i "s|$FOOTNOTECLOSE||g" $SRCDUMP # WORKAROUND (BUG!!)

# --------------------------------------------------------------------------- #
# WRITE HTML
  echo "<html><body>"    >  $HTML
  fold -s -w 75 $SRCDUMP >> $HTML
  echo "</body></html>"  >> $HTML

# DEBUG
# cp $HTML dev.html

# =========================================================================== #
# CLEAN UP

  rm $TMPDIR/*.*

exit 0;

