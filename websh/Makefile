# Makefile -- preliminary make file
# nca-115-2
#
# (c) 1999 netcetera AG (simon.hefti@netcetera.ch)
#
# $Id$

.SUFFIXES: .ws3 .html .syp .pre .sample

WEBSH3 = /usr/lib/cgi-bin/websh3.10

WEBHOME = /wwwdev/websh

sources := contact.ws3 \
copyright.ws3 \
docu.ws3 \
download.ws3 \
error.ws3 \
examples.ws3 \
index.ws3 \
privacy.ws3 \
product.ws3 \
quickref.ws3 \
ressources.ws3 \
subscribe.ws3 \
support.ws3 faq.ws3 \
tutorial.ws3 \
unsubscribe.ws3	\
whitepaper.ws3

examples := helloworld.sample \
	dispatch_1.sample \
	session_form.sample \
	memory.sample \
	cookie.sample \
	image.sample \
	emailform.sample \
	upload.sample

examples_html := $(examples:.sample=.html)

examples_exe := $(examples:.sample=)

objects := $(sources:.ws3=.html)

talk_ncaintro := $(wildcard talks/ncaintro/*.html) \
talks/ncaintro/bg.gif \
talks/ncaintro/ws3arch.gif \
talks/ncaintro/ws3ov.gif \
talks/ncaintro/weblog.gif \
talks/ncaintro/classes.gif \
talks/ncaintro/lifetime.gif \
talks/ncaintro/filters.gif \
talks/ncaintro/stunt.gif \
talks/ncaintro/transactions.gif \
talks/ncaintro/idflow.gif \



all:	$(objects) websh.com.gen
	@echo == main. Target: all ==
## make sure example code is up-to-date
#	websh3 fontifyws3.tcl /wwwdev/websh/cgi-bin/examples/helloworld > \
#	  /wwwdev/websh/docs/helloworld.html; \
#	  chmod ugo-rwxst,ugo+r,u+w /wwwdev/websh/docs/helloworld.html
#	websh3 fontifyws3.tcl /wwwdev/websh/cgi-bin/examples/dispatch_1 > \
#	  /wwwdev/websh/docs/dispatch_1.html; \
#	  chmod ugo-rwxst,ugo+r,u+w /wwwdev/websh/docs/dispatch_1.html
#	cat /wwwdev/websh/bugdb/bin/wrapper /wwwdev/websh/bugdb/lib/sdb.ws3 > tmp_code; \
#	  websh3 fontifyws3.tcl tmp_code > /wwwdev/websh/docs/bugdb.html; \
#	  chmod ugo-rwxst,ugo+r,u+w /wwwdev/websh/docs/bugdb.html

samples: $(examples_html)
	@echo == main. Target: samples ==
	@echo $(examples_html)

pdf:	quickref.syp quickref_pdf_head.html whitepaper.syp whitepaper_pdf_head.html 
	$(WEBSH3) syp.tcl quickref.syp tmp
	cat quickref_pdf_head.html tmp > quickref_pdf.html
	$(WEBSH3) syp.tcl whitepaper.syp tmp
	cat whitepaper_pdf_head.html tmp > whitepaper_pdf.html

txt:	quickref.syp  whitepaper.syp
	$(WEBSH3) syp.tcl quickref.syp -tr syp2txt.tcl tmp
	cat quickref_head.txt tmp > websh30b2-quickref.txt
	$(WEBSH3) syp.tcl whitepaper.syp -tr syp2txt.tcl tmp
	cat whitepaper_head.txt tmp > websh30b2-whitepaper.txt

install:
	@install.tcl websh.com.gen $(WEBHOME)/lib/websh.com.gen ugo+r
	@install.tcl bugsubmit $(WEBHOME)/cgi-bin/bugsubmit ugo+rx
	@for i in $(objects) websh.css buttons.js; \
	do \
	install.tcl $$i $(WEBHOME)/docs/$$i ugo+r; \
	done
## examples: txt doc
	@for i in websh30b2-whitepaper.* websh30b2-quickref.* ; \
	do \
	install.tcl $$i $(WEBHOME)/docs/downloaddir/$$i ugo+r; \
	done
## examples: html
	@for i in $(examples_html); \
	do \
	install.tcl $$i $(WEBHOME)/docs/examples/$$i ugo+r; \
	done
## examples: code
	@for i in $(examples_exe); \
	do \
	install.tcl $$i.sample $(WEBHOME)/cgi-bin/examples/$$i ugo+rx; \
	install.tcl $$i.sample $(WEBHOME)/docs/examples/$$i.ws3 ugo+r; \
	done
## images
	@for i in images/*.* titles/*.* buttons/*.*; \
	do \
	install.tcl $$i $(WEBHOME)/docs/$$i ugo+r; \
	done
## talks: ncaintro
	@for i in $(talk_ncaintro); \
	do \
	install.tcl $$i $(WEBHOME)/docs/$$i ugo+r; \
	done


clean:
	@echo == main. Target: clean ==
	rm -f $(objects) $(examples_html)
	rm -f faq.pre whitepaper.pre tutorial.pre quickref.pre
	rm -f tmp quickref.txt whitepaper.txt quickref_pdf.html
	rm -f tmp quickref_pdf.html whitepaper_pdf.html


faq.ws3: faq.pre
faq.pre: faq.syp

whitepaper.ws3: whitepaper.pre
whitepaper.pre: whitepaper.syp

#tutorial.ws3: tutorial.pre
#tutorial.pre: tutorial.syp

quickref.ws3: quickref.pre
quickref.pre: quickref.syp

examples.ws3: examples.pre
examples.pre: examples.syp

.ws3.html: websh.com.gen
	@echo "  == Building $@ =="
	$(WEBSH3) $< > $@


.syp.pre: websh.com.gen
	@echo "  == Building $@ =="
	$(WEBSH3) syp.tcl $< $@

.sample.html: 
	@echo "  == Building $@ =="
	$(WEBSH3) ws32html.ws3 $< > $@

#helloworld.html: helloworld.sample
#dispatch_1.html: dispatch_1.sample
#session_form.html: session_form.sample