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

  OUTDIR=___/odt
  PDFDIR=tmp ; TMPDIR=tmp
  HTML=$OUTDIR/out.html
  URLS=lib/urls/conversations_01.list

  EMPTYLINE="EMPTY-LINE-EMPTY-LINE-EMPTY-LINE-TEMPORARY-NOT"
# --------------------------------------------------------------------------- #
  FNCTSBASIC=lib/sh/odt.functions
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
      ODTNAME=`echo $URL | rev | cut -d "/" -f 4 | rev`
      ODT=$OUTDIR/${ODTNAME}.odt
      MAIN=$URL
      TEXBODY=$TMPDIR/$RANDOM.tex
      TMPTEX=$TEXBODY
      if [ -f $TMPTEX ]; then rm $TMPTEX ; fi
    
      mdsh2TeX $MAIN
    
      cat $TEXBODY           | #
      sed "s/$EMPTYLINE/ /g" > $HTML
      pandoc -f latex -t odt -o $ODT $HTML
      rm $HTML

  done
# =========================================================================== #

# --------------------------------------------------------------------------- #
# CLEAN UP
# --------------------------------------------------------------------------- #
  rm $TMPDIR/*.*



exit 0;




