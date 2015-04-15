#!/bin/bash

#  THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #
#                                                                             #
#  Copyright (C) 2015 LAFKON/Christoph Haag                                   #
#                                                                             #
#  mdsh2html.sh is free software: you can redistribute it and/or modify       #
#  it under the terms of the GNU General Public License as published by       #
#  the Free Software Foundation, either version 3 of the License, or          #
#  (at your option) any later version.                                        #
#                                                                             #
#  mdsh2html.sh is distributed in the hope that it will be useful,            #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                       #
#  See the GNU General Public License for more details.                       #
#                                                                             #
# --------------------------------------------------------------------------- #

  OUTDIR=___/html
  PDFDIR=tmp ; TMPDIR=tmp
  URLS=lib/urls/conversations_01.list


  EMPTYLINE="EMPTY-LINE-EMPTY-LINE-EMPTY-LINE-TEMPORARY-NOT"
# --------------------------------------------------------------------------- #
  FNCTSBASIC=lib/sh/html.functions
  FUNCTIONS=$TMPDIR/collect.functions

  cat $FNCTSBASIC  >  $FUNCTIONS
# APPEND OPTIONAL FUNCTION SET (IF GIVEN)
  if [[ ! -z "$1" ]]; then cat $1 >> $FUNCTIONS ; fi
# --------------------------------------------------------------------------- #
# INCLUDE FUNCTIONS
# --------------------------------------------------------------------------- #
  source $FUNCTIONS

# --------------------------------------------------------------------------- #
# ACTION HAPPENS HERE!
# =========================================================================== #

  for URL in `cat $URLS`
   do
     echo $URL
     HTMLNAME=`echo $URL | rev | cut -d "/" -f 4 | rev`
     HTML=${OUTDIR}/${HTMLNAME}.html
     MAIN=$URL

     TEXBODY=$TMPDIR/$RANDOM.tex
     TMPTEX=$TEXBODY
     if [ -f $TMPTEX ]; then rm $TMPTEX ; fi

     mdsh2TeX $MAIN

# =========================================================================== #

     echo "<html><body>" >  $HTML
     cat $TEXBODY        >> $HTML
     echo "</p>"         >> $HTML

# --------------------------------------------------------------------------- #
# FOOTNOTES
# --------------------------------------------------------------------------- #

     echo "<hr/>"   >> $HTML
     echo "<ol>"    >> $HTML

     COUNT=1
     for FOOTNOTE in `sed 's/\[\^]{/\n&/g' $HTML | #
                      sed 's/ /5P4C3XX/g'         | #
                      sed 's/}/&\n/'              | # 
                      grep "^\[\^]{"`
      do
          ID=`echo $FOOTNOTE | md5sum | cut -c 1-8`

          FOOTNOTETEXT=`echo $FOOTNOTE  | #
                        cut -d "{" -f 2 | #
                        cut -d "}" -f 1 | #
                        sed 's/5P4C3XX/ /g'`       

          FOOTNOTE=`echo $FOOTNOTE       | #
                    sed 's/5P4C3XX/ /g'  | #
                    sed 's/\[/\\\[/g'    | #
                    sed 's/|/\\|/g'`

          OLDFOOTNOTE=$FOOTNOTE
          NEWFOOTNOTE="<sup><a href=\"#$ID\">$COUNT</a><\/sup>"
          sed -i "s|$OLDFOOTNOTE|$NEWFOOTNOTE|g" $HTML

          echo "<li id=\"$ID\"> $FOOTNOTETEXT </li>" >> $HTML

          COUNT=`expr $COUNT + 1` 
     done

     echo "</ol>"          >> $HTML

     echo "</body></html>" >> $HTML

  done

# =========================================================================== #

# --------------------------------------------------------------------------- #
# CLEAN UP
# --------------------------------------------------------------------------- #
  rm $TMPDIR/*.*

exit 0;

