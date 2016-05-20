export builddir ?= $(CURDIR)/build
export tmpdir ?= $(builddir)/tmp
export tmpmedia ?= $(tmpdir)/media
export tmpscriptdir ?= $(tmpdir)/scripts
export tmpdocdir ?= $(tmpdir)/docs
export distdir ?= $(builddir)/distributions
export tmprender ?= $(builddir)/render
export testdir ?= $(builddir)/test
export depsdir ?= $(builddir)/deps
#
export prefix ?= $(builddir)
export scriptdir ?= $(prefix)/scripts
export mediadir ?= $(prefix)/media
export docdir ?= $(prefix)/docs
#
srcdir ?= $(CURDIR)/src
scriptsrc ?= $(srcdir)/scripts
testsrc ?= $(srcdir)/test
assetprops ?=$(srcdir)/asset.properties

VERSION := $(shell cat $(CURDIR)/DDF_VERSION)
DISTNAME = cons3rt-ddf-$(VERSION)-windows.zip
DDF_DIST_REMOTE_FILE=https://github.com/codice/ddf/releases/download/ddf-$(VERSION)/ddf-$(VERSION).zip
DDF_LICENSE_REMOTE_FILE=https://raw.githubusercontent.com/codice/ddf/2.9.x/LICENSE.md
DDF_DOC_REMOTE_FILE=http://codice.org/ddf/documentation.html

all: build

clean:
	rm -rf $(tmpscriptdir)
	rm -rf $(tmpdir)/asset.properties
	rm -rf $(distdir)
	rm -rf $(tmpscriptdir)/DDF_VERSION

clean_all:
	rm -rf $(builddir)

dirs:
	mkdir -p $(builddir)
	mkdir -p $(tmpdir)
	mkdir -p $(tmpmedia)
	mkdir -p $(tmpscriptdir)
	mkdir -p $(tmpdocdir)
	mkdir -p $(distdir)
	mkdir -p $(tmprender)
	mkdir -p $(depsdir)

deps: ddf-media

ddf-media:
	[ -s $(tmpmedia)/ddf-$(VERSION).zip ] || curl -L -o $(tmpmedia)/ddf-$(VERSION).zip $(DDF_DIST_REMOTE_FILE)

build: dirs deps copy_scripts copy_props copy_versionfile copy_docs zip

copy_scripts:
	cp $(scriptsrc)/*.bat $(tmpscriptdir)
	cp $(scriptsrc)/*.ps1 $(tmpscriptdir)

copy_props:
	cp $(assetprops) $(tmpdir)

copy_docs:
	export GRIPURL=$(tmprender)
	[ -s $(tmpdocdir)/LICENSE.html ] || (curl -L -o $(tmprender)/LICENSE.md $(DDF_LICENSE_REMOTE_FILE) && grip $(tmprender)/LICENSE.md --export $(tmpdocdir)/LICENSE.html)
	[ -s $(tmpdocdir)/README.html ] || curl -L -o $(tmpdocdir)/README.html $(DDF_DOC_REMOTE_FILE)

copy_versionfile:
	cp DDF_VERSION $(tmpscriptdir)/

zip:
	rm -rf $(distdir)/* && cd $(tmpdir) && zip -r $(distdir)/$(DISTNAME) ./*

test: build
	[ ! -s $(testdir) ] || rm -rf $(testdir) && mkdir -p $(testdir)
	unzip $(distdir)/$(DISTNAME) -d $(testdir)
	cp $(testsrc)/*.ps1 $(testdir)
	Vagrant up && Vagrant destroy -f
