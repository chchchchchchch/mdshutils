#!/bin/bash

# THIS IS A FRAGILE SYSTEM, HANDLE WITH CARE.                                #
# --------------------------------------------------------------------------- #

  MAIN=`echo $1 | cut -d ":" -f 2-`
  TMPDIR=../../tmp
  OUTDIR=.
  STYLE=../../lib/style/01.odt

  ODTNAME=`echo $1 | cut -d ":" -f 1`
  ODT=$OUTDIR/${ODTNAME}.odt

  TMPTEX=$TMPDIR/tmp.tex

  echo "converting $1"

# =========================================================================== #
# CONFIGURATION                                                               #
# --------------------------------------------------------------------------- #

  FUNCTIONSBASIC=../../lib/sh/basic.functions
   FUNCTIONSPLUS=odt.functions
       FUNCTIONS=$TMPDIR/functions.tmp
  cat $FUNCTIONSBASIC $FUNCTIONSPLUS > $FUNCTIONS

  source $FUNCTIONS

# --------------------------------------------------------------------------- #
  PANDOCACTION="pandoc --ascii -r markdown -w latex"
# --------------------------------------------------------------------------- #
# FOOTNOTES
# \footnote{the end is near, the text is here}
# --------------------------------------------------------------------------- #
  FOOTNOTEOPEN="\footnote{" ; FOOTNOTECLOSE="}"
# CITATIONS
# \cite{phillips:2004:vectoraesthetic}
# --------------------------------------------------------------------------- #
  CITEOPEN="\cite{" ; CITECLOSE="}"
# \cite[1-8]{phillips:2004:vectoraesthetic}
# --------------------------------------------------------------------------- #
  CITEPOPEN="\cite" ; CITEPCLOSE="$CITECLOSE"
# =========================================================================== #

# --------------------------------------------------------------------------- #
# ACTION HAPPENS HERE!
# --------------------------------------------------------------------------- #

  mdsh2src $MAIN

# --------------------------------------------------------------------------- #
# GET REFERENCE FILE 
# --------------------------------------------------------------------------- #
  BIBURL=http://pad.constantvzw.org/p/references.bib/1099/export/txt
  wget --no-check-certificate -O ${TMPDIR}/ref.bib $BIBURL > /dev/null 2>&1
 
  echo "\begin{document}"        >  $TMPTEX
  cat   $SRCDUMP                 >> $TMPTEX
  if [ `grep "\cite{" $TMPTEX | wc -l` -gt 0 ]; then
  echo "\section{Bibliography}"  >> $TMPTEX
  fi
  echo "\end{document}"          >> $TMPTEX

  pandoc -f latex -t odt              \
         --reference-odt=$STYLE        \
         --bibliography $TMPDIR/ref.bib \
         -o $ODT $TMPTEX

# =========================================================================== #
# CLEAN UP

# rm $TMPDIR/*.*



exit 0;

