# create txt and html versions of example scripts
# $Id$

# the files to process
WS3FILES = $(wildcard *.ws3)

# some binaries we need
CP = cp -f
ENSCRIPT = enscript


all: text html

text:
	for a in $(WS3FILES:%.ws3=%); do $(CP) $$a.ws3 $${a}_ws3.txt; done

html:
	for a in $(WS3FILES:%.ws3=%); do $(ENSCRIPT) -h -B -t $$a --color -Etcl -B --language=html -o $$a.html $$a.ws3; done
