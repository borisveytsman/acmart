#
# Makefile for acmart package
#
# This file is in public domain
#
# $Id: Makefile,v 1.10 2016/04/14 21:55:57 boris Exp $
#

PACKAGE=acmart

SAMPLES = \
	samples/sample-manuscript.tex \
	samples/sample-acmsmall.tex \
	samples/sample-acmlarge.tex \
	samples/sample-acmtog.tex \
	samples/sample-sigconf.tex \
	samples/sample-sigconf-authordraft.tex \
	samples/sample-sigconf-xelatex.tex \
	samples/sample-sigplan.tex \
	samples/sample-sigchi.tex \
	samples/sample-sigchi-a.tex


PDF = $(PACKAGE).pdf ${SAMPLES:%.tex=%.pdf} acmguide.pdf

all:  ${PDF}


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

samples/%: %
	cp $^ samples

samples/$(PACKAGE).cls: $(PACKAGE).cls
samples/ACM-Reference-Format.bst: ACM-Reference-Format.bst

samples/%.pdf:  samples/%.tex   samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst
	cd $(dir $@) && pdflatex $(notdir $<)
	- cd $(dir $@) && bibtex $(notdir $(basename $<))
	cd $(dir $@) && pdflatex $(notdir $<)
	cd $(dir $@) && pdflatex $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && pdflatex $(notdir $<); done

samples/sample-sigconf-xelatex.pdf:  samples/sample-sigconf-xelatex.tex   samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst
	cd $(dir $@) && xelatex $(notdir $<)
	- cd $(dir $@) && bibtex $(notdir $(basename $<))
	cd $(dir $@) && xelatex $(notdir $<)
	cd $(dir $@) && xelatex $(notdir $<)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(basename $<).log) \
	  do cd $(dir $@) && xelatex $(notdir $<); done

samples/sample-manuscript.pdf \
samples/sample-acmsmall.pdf \
samples/sample-acmlarge.pdf \
samples/sample-acmtog.pdf: samples/samplebody-journals.tex

samples/sample-sigconf.pdf \
samples/sample-sigconf-authordraft.pdf \
samples/sample-sigconf-xelatex.pdf \
samples/sample-sigplan.pdf \
samples/sample-sigchi.pdf: samples/samplebody-conf.tex


.PRECIOUS:  $(PACKAGE).cfg $(PACKAGE).cls


clean:
	$(RM)  $(PACKAGE).cls *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi \
	samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst \
	samples/*.log samples/*.aux samples/*.out \
	samples/*.bbl samples/*.blg samples/*.cut

distclean: clean
	$(RM) $(PDF) samples/*-converted-to.pdf

#
# Archive for the distribution. Includes typeset documentation
#
archive:  all clean
	COPYFILE_DISABLE=1 tar -C .. -czvf ../$(PACKAGE).tgz --exclude '*~' --exclude '*.tgz' --exclude '*.zip'  --exclude CVS --exclude '.git*' $(PACKAGE); mv ../$(PACKAGE).tgz .

zip:  all clean
	zip -r  $(PACKAGE).zip * -x '*~' -x '*.tgz' -x '*.zip' -x CVS -x 'CVS/*'

documents.zip: all
	zip $@ acmart.pdf acmguide.pdf samples/sample-*.pdf *.cls *.bst
