#
# Makefile for acmart package
#
# This file is in public domain
#
# $Id: Makefile,v 1.10 2016/04/14 21:55:57 boris Exp $
#

PACKAGE=acmart


PDF = $(PACKAGE).pdf acmguide.pdf

BIBLATEXFILES= $(wildcard *.bbx) $(wildcard *.cbx) $(wildcard *.dbx) $(wildcard *.lbx)
SAMPLEBIBLATEXFILES=$(patsubst %,samples/%,$(BIBLATEXFILES))

all:  ${PDF} ALLSAMPLES

%.pdf:  %.dtx   $(PACKAGE).cls
	pdflatex $<
	- bibtex $*
	pdflatex $<
	- makeindex -s gind.ist -o $*.ind $*.idx
	- makeindex -s gglo.ist -o $*.gls $*.glo
	pdflatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do pdflatex $<; done


acmguide.pdf: $(PACKAGE).dtx $(PACKAGE).cls
	pdflatex -jobname acmguide $(PACKAGE).dtx
	- bibtex acmguide
	pdflatex -jobname acmguide $(PACKAGE).dtx
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' acmguide.log) \
	do pdflatex -jobname acmguide $(PACKAGE).dtx; done

%.cls:   %.ins %.dtx
	pdflatex $<


ALLSAMPLES: $(SAMPLEBIBLATEXFILES)
	cd samples; pdflatex samples.ins; cd ..
	for texfile in samples/*.tex; do \
		pdffile=$${texfile%.tex}.pdf; \
		${MAKE} $$pdffile; \
	done

samples/%: %
	cp $^ samples


samples/$(PACKAGE).cls: $(PACKAGE).cls
samples/ACM-Reference-Format.bst: ACM-Reference-Format.bst

samples/abbrev.bib: ACM-Reference-Format.bst
	perl -pe 's/MACRO ({[^}]*}) *\n/MACRO \1/' ACM-Reference-Format.bst \
	| grep MACRO | sed 's/MACRO {/@STRING{/' \
	| sed 's/}  *{/ = /' > samples/abbrev.bib 


samples/%.bbx: %.bbx
samples/%.cbx: %.cbx
samples/%.dbx: %.dbx
samples/%.lbx: %.lbx

samples/%.pdf:  samples/%.tex   samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	- cd $(dir $@) && bibtex $(notdir $(basename $<))
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && pdflatex-dev $(notdir $<); done

samples/sample-sigconf-biblatex.pdf: samples/sample-sigconf-biblatex.tex $(SAMPLEBIBLATEXFILES)
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	- cd $(dir $@) && biber $(notdir $(basename $<))
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && pdflatex-dev $(notdir $<); done

samples/sample-acmsmall-biblatex.pdf: samples/sample-acmsmall-biblatex.tex $(SAMPLEBIBLATEXFILES)
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	- cd $(dir $@) && biber $(notdir $(basename $<))
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	cd $(dir $@) && pdflatex-dev $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && pdflatex-dev $(notdir $<); done

samples/sample-xelatex.pdf:  samples/sample-xelatex.tex   samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst
	cd $(dir $@) && xelatex-dev $(notdir $<)
	- cd $(dir $@) && bibtex $(notdir $(basename $<))
	cd $(dir $@) && xelatex-dev $(notdir $<)
	cd $(dir $@) && xelatex-dev $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && xelatex-dev $(notdir $<); done

samples/sample-lualatex.pdf:  samples/sample-lualatex.tex   samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst
	cd $(dir $@) && lualatex-dev $(notdir $<)
	- cd $(dir $@) && bibtex $(notdir $(basename $<))
	cd $(dir $@) && lualatex-dev $(notdir $<)
	cd $(dir $@) && lualatex-dev $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && lualatex-dev $(notdir $<); done



.PRECIOUS:  $(PACKAGE).cfg $(PACKAGE).cls

docclean:
	$(RM)  *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi \
	samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst \
	samples/*.log samples/*.aux samples/*.out \
	samples/*.bbl samples/*.blg samples/*.cut \
	samples/*.run.xml samples/*.bcf $(SAMPLEBIBLATEXFILES)


clean: docclean
	$(RM)  $(PACKAGE).cls \
	samples/*.tex

distclean: clean
	$(RM)  *.pdf samples/sample-*.pdf

#
# Archive for the distribution. Includes typeset documentation
#
archive:  all clean
	COPYFILE_DISABLE=1 tar -C .. -czvf ../$(PACKAGE).tgz --exclude '*~' --exclude '*.tgz' --exclude '*.zip'  --exclude CVS --exclude '.git*' $(PACKAGE); mv ../$(PACKAGE).tgz .

zip:  all clean
	zip -r  $(PACKAGE).zip * -x '*~' -x '*.tgz' -x '*.zip' -x CVS -x 'CVS/*'

documents.zip: all docclean
	zip -r $@ acmart.pdf acmguide.pdf samples *.cls ACM-Reference-Format.*

.PHONY: all ALLSAMPLES docclean clean distclean archive zip
