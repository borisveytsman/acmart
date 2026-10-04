#
# Makefile for acmart package
#
# This file is in public domain
#

PACKAGE=acmart


PDF = $(PACKAGE).pdf acmguide.pdf


all:  ${PDF}
	cd samples && ${MAKE} $@

%.pdf:  %.dtx   $(PACKAGE).cls
	lualatex $<
	- bibtex $*
	lualatex $<
	- makeindex -s gind.ist -o $*.ind $*.idx
	- makeindex -s gglo.ist -o $*.gls $*.glo
	lualatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do lualatex $<; done


acmguide.pdf: $(PACKAGE).dtx $(PACKAGE).cls
	lualatex -jobname acmguide $(PACKAGE).dtx
	- bibtex acmguide
	lualatex -jobname acmguide $(PACKAGE).dtx
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' acmguide.log) \
	do lualatex -jobname acmguide $(PACKAGE).dtx; done

%.cls:   %.ins %.dtx
	lualatex $<


tagged:
	${MAKE} acmart.cls && cd samples && ${MAKE} acmsmall-tagged.pdf && ${MAKE} sigconf-tagged.pdf




.PRECIOUS:  $(PACKAGE).cfg $(PACKAGE).cls $(PACKAGE)-tagged.cls

docclean:
	$(RM)  *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi
	cd samples && ${MAKE} $@


clean: docclean
	$(RM)  $(PACKAGE).cls $(PACKAGE)-tagged.cls 
	cd samples && ${MAKE} $@

distclean: clean
	$(RM)  *.pdf 
	cd samples && ${MAKE} $@

#
# Archive for the distribution. Includes typeset documentation
#
archive:  all clean
	COPYFILE_DISABLE=1 tar -C .. -czvf ../$(PACKAGE).tgz --exclude '*~' --exclude '*.tgz' --exclude '*.zip'  --exclude CVS --exclude '.git*' --exclude LICENSE $(PACKAGE); mv ../$(PACKAGE).tgz .

# distros
distros: all docclean
	zip -r acm-distro.zip  \
	acmart.pdf acmguide.pdf samples *.cls ACM-Reference-Format.* LICENSE \
	--exclude samples/sample-acmengage*
	zip -r acmengage-distro.zip samples/sample-acmengage* LICENSE \
	samples/*.bib \
	acmart.pdf acmguide.pdf  *.cls ACM-Reference-Format.*

acmcp.zip: all acmart.cls
	zip $@ $+

