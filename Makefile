
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

.DELETE_ON_ERROR:


build_dir   = build
lib_dir     = lib
root_dir   := $(shell pwd)
source_dir  = src

xsl1_name              = docbook-xsl-snapshot
xsl1_zip               = $(xsl1_name).zip
xsl1_url               = https://github.com/docbook/xslt10-stylesheets/releases/download/snapshot%2F2020-06-03/$(xsl1_zip)
xsl1_epub3_stylesheet  = $(root_dir)/$(lib_dir)/$(xsl1_name)/epub3/chunk.xsl
xsl1_xhtml5_stylesheet = $(root_dir)/$(lib_dir)/$(xsl1_name)/xhtml5/docbook.xsl
xsl1_markerfile        = $(lib_dir)/$(xsl1_name)/VERSION

xsl2_version    = 2.6.0
xsl2_name       = docbook-xslt2-$(xsl2_version)
xsl2_zip        = $(xsl2_name).zip
xsl2_url        = https://github.com/docbook/xslt20-stylesheets/releases/download/$(xsl2_version)/$(xsl2_zip)
xsl2_stylesheet = $(root_dir)/$(source_dir)/xsl/$(xsl2_name)/xslt/base/html/html.xsl
xsl2_markerfile = $(lib_dir)/$(xsl2_name)/README.md
xsl2_stylesheet = $(lib_dir)/$(xsl2_name)/xslt/base/html/index.xsl

xsl_tng_version     = 2.5.0
xsl_tng_name        = docbook-xslTNG-$(xsl_tng_version)
xsl_tng_zip         = $(xsl_tng_name).zip
xsl_tng_url         = https://github.com/docbook/xslTNG/releases/download/$(xsl_tng_version)/$(xsl_tng_zip)
xsl_tng_stylesheet  = $(lib_dir)/$(xsl_tng_name)/xslt/docbook.xsl
xsl_tng_cmd_docbook = $(lib_dir)/$(xsl_tng_name)/bin/docbook
xsl_tng_resources   = $(lib_dir)/$(xsl_tng_name)/resources

assembly_name = assembly-2_0_1
assembly_zip  = $(assembly_name).zip
assembly_url  = https://www.xmlmind.com/xmleditor/_assembly/$(assembly_zip)
assembly_jar  = $(lib_dir)/$(assembly_name)/lib/assembly.jar

saxon12_zip=saxon-resources-12.zip
saxon12_url=https://downloads.saxonica.com/resources/$(saxon12_zip)

saxon12_5_zip=SaxonHE12-5J.zip
saxon12_5_url=https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE12-5/$(saxon12_5_zip)

identity_stylesheet=src/xslt/identity.xslt
deploy_dir=DOC


.PHONEY: build
build: \
build.epub3 \
build.html5 \
build.markdown

.PHONEY: build.epub3
build.epub3: \
$(build_dir)/DevOps_Manual/EPUB3/DevOps_Manual.epub3

.PHONEY: build.markdown
build.markdown: \
$(build_dir)/QuickReference/Hugo/QuickReference.md

.PHONEY: build.html
build.html: \
build.html5

.PHONEY: build.html5
build.html5: \
$(build_dir)/DevOps_Manual/HTML5/DevOps_Manual.xhtml \
$(build_dir)/DevOps_Manual/HTML5-assembly/DevOps_Manual.xhtml \
$(build_dir)/QuickReference/HTML5-Hugo/QuickReference.html \
$(build_dir)/QuickReference/HTML5/QuickReference.html \
$(build_dir)/Release_Process/HTML5/index.xhtml \
$(build_dir)/Website/alpha/index.html \
$(build_dir)/Website/index.html

.PHONEY: build.yaml
build.yaml: \
$(build_dir)/QuickReference/YAML/QuickReference.yml

.PHONEY: build.doc.DevOps_Manual
build.doc.DevOps_Manual: \
$(build_dir)/DevOps_Manual/EPUB3/DevOps_Manual.epub3 \
$(build_dir)/DevOps_Manual/HTML5-assembly/DevOps_Manual.xhtml \
$(build_dir)/DevOps_Manual/HTML5/DevOps_Manual.xhtml

.PHONEY: build.doc.QuickReference
build.doc.QuickReference: \
$(build_dir)/QuickReference/HTML5-Hugo/QuickReference.html \
$(build_dir)/QuickReference/HTML5/QuickReference.html \
$(build_dir)/QuickReference/Hugo/QuickReference.md \
$(build_dir)/QuickReference/YAML/QuickReference.yml

.PHONEY: build.doc.Release_Process
build.doc.Release_Process: \
$(build_dir)/Release_Process/HTML5/index.xhtml

.PHONEY: build.doc.Website
build.doc.Website: \
$(build_dir)/Website/alpha/index.html \
$(build_dir)/Website/index.html

# broken: maybe not important now
deploy : \
$(deploy_dir)/QuickReference.html \
$(deploy_dir)/QuickReference-Hugo.md

.PHONEY : clean
clean :
	rm --force --recursive $(build_dir)

#
# epub format
#

$(build_dir)/DevOps_Manual/EPUB3/DevOps_Manual.epub3 : \
$(build_dir)/DevOps_Manual/EPUB3/mimetype
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; zip -X0 $$(basename $@) mimetype
	cd $$(dirname $@) ; zip -r -X9 $$(basename $@) META-INF OEBPS


$(build_dir)/DevOps_Manual/EPUB3/mimetype : \
$(build_dir)/DevOps_Manual/DocBook5/DevOps_Manual.xml
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc $(xsl1_epub3_stylesheet) ../DocBook5/$$(basename $<)


#
# xhtml5 format
#


$(build_dir)/DevOps_Manual/HTML5/DevOps_Manual.xhtml : \
$(build_dir)/DevOps_Manual/DocBook5/DevOps_Manual.xml
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc --output $$(basename $@) $(xsl1_xhtml5_stylesheet) ../DocBook5/$$(basename $<)


#
# DocBook5 intermediate output
#


$(build_dir)/DevOps_Manual/DocBook5/DevOps_Manual.xml : \
$(source_dir)/DevOps_Manual/DevOps_Manual.xml \
$(source_dir)/DevOps_Manual/Topics/SSH/verify_key_passphrase.xml \
$(source_dir)/Biblioentries/S/SO_4411457.xml
	@ mkdir --parents $$(dirname $@)
	xsltproc --output $@ --xinclude $(identity_stylesheet) $<


#
# DevOps assembly
#

$(build_dir)/DevOps_Manual/HTML5-assembly/DevOps_Manual.xhtml : \
$(build_dir)/DevOps_Manual/DocBook5/realized.xml \
$(xsl1_markerfile)
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc --output $$(basename $@) $(xsl1_xhtml5_stylesheet) $(root_dir)/$<


$(build_dir)/DevOps_Manual/DocBook5/realized.xml : \
$(source_dir)/DevOps_Manual/assembly.xml \
$(source_dir)/DevOps_Manual/Topics/SSH/add_passphrase_to_key.xml \
$(source_dir)/DevOps_Manual/Topics/SSH/verify_key_passphrase.xml \
$(source_dir)/Biblioentries/M/MAN_ssh-keygen.xml \
$(source_dir)/Biblioentries/S/SO_4411457.xml \
$(assembly_jar)
	@ mkdir --parents $$(dirname $@)
	java -jar $(assembly_jar) $< $@


#
# deploy_dir files
#

$(deploy_dir)/% : $(build_dir)/%
	@ mkdir --parents $$(dirname $@)
	cp --archive $< $@

#
# QuickReference
#

$(build_dir)/QuickReference/HTML5/QuickReference.html: \
$(build_dir)/QuickReference/AsciiDoc/QuickReference.adoc
	@ mkdir --parents $$(dirname $@)
	asciidoc --backend html5 --doctype article --out-file $@ $<

$(build_dir)/QuickReference/HTML5-Hugo/QuickReference.html: \
$(build_dir)/QuickReference/AsciiDoc/QuickReference.adoc \
$(build_dir)/QuickReference/HTML5-Hugo/css/style.min.css
	@ mkdir --parents $$(dirname $@)
	asciidoc -a linkcss -a stylesdir=css -a stylesheet=style.min.css --backend html5 --doctype article --out-file $@ $<

$(build_dir)/QuickReference/HTML5-Hugo/css/style.min.css: \
$(source_dir)/css/hugo-loveit.css
	@ mkdir --parents $$(dirname $@)
	cp --archive $< $@

$(build_dir)/QuickReference/AsciiDoc/QuickReference.adoc: \
$(build_dir)/QuickReference/YAML/QuickReference.yml \
$(source_dir)/QuickReference/index.tt
	@ mkdir --parents $$(dirname $@)
	carton exec -- tpage --define data_file="$<" --eval_perl $(source_dir)/QuickReference/index.tt > $@

$(build_dir)/QuickReference/Hugo/QuickReference.md: \
$(build_dir)/QuickReference/YAML/QuickReference.yml \
$(source_dir)/QuickReference/index.tt
	@ mkdir --parents $$(dirname $@)
	carton exec -- tpage --define data_file="$<" --define format=markdown --eval_perl $(source_dir)/QuickReference/index.tt > $@

$(build_dir)/QuickReference/YAML/QuickReference.yml: \
$(source_dir)/QuickReference/data.pl \
$(source_dir)/QuickReference/data.yml
	@ mkdir --parents $$(dirname $@)
	carton exec -- perl $^ > $@

.PHONEY: prepare.tool.xslt.docbook.xsl1
prepare.tool.xslt.docbook.xsl1: $(xsl1_markerfile)

$(xsl1_markerfile): \
$(lib_dir)/$(xsl1_zip)
	cd $$(dirname $<) ; unzip -q -o $$(basename $<)
	@ touch $@

$(lib_dir)/$(xsl1_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ --quiet $(xsl1_url)

.PHONEY: prepare.tool.xslt.docbook.xsl2
prepare.tool.xslt.docbook.xsl2: $(xsl2_markerfile)

$(xsl2_markerfile): \
$(lib_dir)/$(xsl2_zip)
	cd $$(dirname $<) ; unzip -q -o $$(basename $<)
	touch $@

$(lib_dir)/$(xsl2_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ --quiet $(xsl2_url)

.PHONEY: prepare.tool.xslt.docbook.tng
prepare.tool.xslt.docbook.tng: $(xsl_tng_cmd_docbook)

$(build_dir)/$(xsl_tng_name)/resources/.done: \
$(xsl_tng_cmd_docbook)
	@ mkdir --parents $$(dirname $@)
	cp --archive --recursive $(xsl_tng_resources) $(shell dirname $(shell dirname $@))
	@ touch $@

$(xsl_tng_cmd_docbook): \
$(lib_dir)/$(xsl_tng_zip)
	cd $$(dirname $<) ; unzip -q -o $(root_dir)/$<
	touch $@

$(lib_dir)/$(xsl_tng_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ --quiet $(xsl_tng_url)


$(build_dir)/Website/index.html: \
$(source_dir)/Website/index.html \
$(build_dir)/Website/css/style.css
	@ mkdir --parents $$(dirname $@)
	cp --archive $< $@

$(build_dir)/Website/css/style.css: \
$(source_dir)/Website/css/style.css \
$(build_dir)/Website/Documents/Release_Process/index.xhtml
	@ mkdir --parents $$(dirname $@)
	cp --archive $< $@

# this keeps running the copy
# I think it's this
# $(build_dir)/Website/alpha/Release_Process/index.xhtml
# not using --archive option to help
$(build_dir)/Website/alpha/index.html: \
$(source_dir)/Website/alpha/index.html \
$(build_dir)/Website/css/style.css \
$(build_dir)/Website/alpha/DevOps_Manual/xsl/index.xhtml \
$(build_dir)/Website/alpha/DevOps_Manual/xsltng/index.xhtml
	@ mkdir --parents $$(dirname $@)
	cp $< $@

$(build_dir)/Website/alpha/DevOps_Manual/xsl/index.xhtml: \
$(source_dir)/DevOps_Manual/DevOps_Manual.test.xml \
$(xsl1_markerfile)
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; \
	xsltproc --output $$(basename $@) \
	$(xsl1_xhtml5_stylesheet) \
	$(root_dir)/$<

# Saxon 12 does not like the xsl2 stylesheet.
# Does not seem to be a way to force XSLT 2.0 compatibility.
# Per https://www.saxonica.com/html/documentation12/conformance/xslt20.html
# Saxon 9.8 was first to allow break of xslt 2.0.
# Should be mostly compatible.
$(build_dir)/Website/alpha/DevOps_Manual/xsl2/index.xhtml: \
$(source_dir)/DevOps_Manual/DevOps_Manual.test.xml \
$(xsl_tng_cmd_docbook) \
$(xsl2_markerfile)
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; \
	$(root_dir)/$(xsl_tng_cmd_docbook) \
	-o:$$(basename $@) \
	-s:$(root_dir)/$< \
	-xsl:$(root_dir)/$(xsl2_stylesheet)

# can proc this 1.0 ( i think ) stylesheet
#$(build_dir)/test.xml: \
#$(source_dir)/DevOps_Manual/DevOps_Manual.test.xml
#	@ mkdir --parents $$(dirname $@)
#	cd $$(dirname $@) ; \
#	$(root_dir)/$(xsl_tng_cmd_docbook) \
#	-o:$$(basename $@) \
#	-s:$(root_dir)/$< \
#	-xsl:$(root_dir)/$(identity_stylesheet)

$(build_dir)/Website/alpha/DevOps_Manual/xsltng/index.xhtml: \
$(source_dir)/DevOps_Manual/DevOps_Manual.test.xml \
$(xsl_tng_cmd_docbook) \
$(build_dir)/Website/alpha/DevOps_Manual/xsltng/css/.done \
$(build_dir)/Website/alpha/DevOps_Manual/xsltng/js/.done
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; \
	$(root_dir)/$(xsl_tng_cmd_docbook) \
	-o:$$(basename $@) \
	-s:$(root_dir)/$< \
	-xsl:$(root_dir)/$(xsl_tng_stylesheet)

$(build_dir)/Website/alpha/DevOps_Manual/xsltng/css/.done: \
$(xsl_tng_cmd_docbook)
	mkdir --parents $$(dirname $@)
	cp --archive  --recursive \
	$(xsl_tng_resources)/css \
	$(build_dir)/Website/alpha/DevOps_Manual/xsltng/
	touch $@

$(build_dir)/Website/alpha/DevOps_Manual/xsltng/js/.done: \
$(xsl_tng_cmd_docbook)
	mkdir --parents $$(dirname $@)
	cp --archive  --recursive \
	$(xsl_tng_resources)/js \
	$(build_dir)/Website/alpha/DevOps_Manual/xsltng/
	touch $@

# need a 2.0 processor
#$(source_dir)/xsl/$(xsl_tng_name)/.done
#	$(xsl2_stylesheet) \


$(build_dir)/Release_Process/HTML5/index.xhtml: \
$(build_dir)/Release_Process/DocBook5/article.xml \
$(xsl_tng_cmd_docbook) \
$(build_dir)/Release_Process/HTML5/css/.done
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; \
	$(root_dir)/$(xsl_tng_cmd_docbook) \
	-o:$$(basename $@) \
	-s:$(root_dir)/$< \
	-xsl:$(root_dir)/$(xsl_tng_stylesheet)

$(build_dir)/Release_Process/HTML5/css/.done: \
$(build_dir)/$(xsl_tng_name)/resources/.done
	@ mkdir --parents $$(dirname $@)
	@ cp --archive --recursive \
	$(shell dirname $<)/* \
	$(shell dirname $(shell dirname $@))
	@ touch $@

$(build_dir)/Release_Process/DocBook5/article.xml: \
$(source_dir)/DocBook/Topics/Release_Process/article.xml \
$(source_dir)/DocBook/Topics/Release_Process/topic.xml \
$(assembly_jar)
	@ mkdir --parents $$(dirname $@)
	java -jar $(assembly_jar) $< $@

$(build_dir)/Website/Documents/Release_Process/index.xhtml: \
$(build_dir)/Release_Process/HTML5/index.xhtml
	@ mkdir --parents $$(dirname $@)
	cp --archive --recursive $(shell dirname $<)/* $(shell dirname $@)

.PHONEY: prepare.tool.xmlmind.assembly
prepare.tool.xmlmind.assembly: $(assembly_jar)

$(assembly_jar): \
lib/$(assembly_zip)
	cd $$(dirname $<) ; unzip -q -o $$(basename $<)
	touch $@

lib/$(assembly_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ --quiet $(assembly_url)

.PHONEY: saxon12
saxon12: \
$(lib_dir)/saxon12_5/.done \
$(lib_dir)/saxon12/.done

$(lib_dir)/$(saxon12_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ --quiet $(saxon12_url)

$(lib_dir)/$(saxon12_5_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ --quiet $(saxon12_5_url)

$(lib_dir)/saxon12/.done: \
$(lib_dir)/$(saxon12_zip)
	mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; unzip -q -o ../$$(basename $<)
	touch $@

$(lib_dir)/saxon12_5/.done: \
$(lib_dir)/$(saxon12_5_zip)
	mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; unzip -q -o ../$$(basename $<)
	touch $@
