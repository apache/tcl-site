# nca-115-2
#

.SUFFIXES: .ws3 .html .syp .pre .sample


# WEBSH3 = websh3.0b3
# WEBSH3 = /home/hefti/projects/nca-073-9/src/unix/websh3.0b2p5
WEBSH3 = websh3.0b3


APACHE13 = /home/hefti/playground/installed/apache-1.3

SYP      = ../../syp.tcl
WS32HTML =  ../../ws32html.ws3


examples := helloworld.sample \
	dispatch.sample \
	logging.sample \
	logging2.sample \
	cookie.sample \
	embed.sample \
	wsp.sample \
	form.sample \
	encrypt.sample \
	filecontext.sample

examples_html := $(examples:.sample=.html)

examples_exe := $(examples:.sample=)

images := bg.gif \
history.gif \
states.gif \
stunt.gif \
weblog.gif \
ws3arch.gif \
ws3ov.gif \
lifetime.gif \
classes.gif \
filters.gif \
idflow.gif \
transactions.gif

talk: $(examples_html) config_file.html wsphandler.html ncaintro.syp
	$(WEBSH3) $(SYP) ncaintro.syp ncaintro.html -template template.html -split 1

all:  talk


install: all
## examples: code
	@for i in $(examples_exe); \
	do \
	cp $$i.sample $(APACHE13)/htdocs/$$i.ws3; \
	done
	mv $(APACHE13)/htdocs/wsp.ws3 $(APACHE13)/htdocs/wsp.wsp
	@for i in $(images); \
	do \
	cp $$i $(APACHE13)/htdocs/$$i; \
	done
	cp start.html $(APACHE13)/htdocs
	cp ncaintro*.html $(APACHE13)/htdocs
	cp samples.css $(APACHE13)/htdocs
	cp embed.sample $(APACHE13)/htdocs/embed.ws3

clean:
	rm ncaintro*.html
	rm $(examples_html)
	rm config_file.html wsphandler.html

.sample.html: 
	@echo "  == Building $@ =="
	$(WEBSH3) $(WS32HTML) $< > $@
