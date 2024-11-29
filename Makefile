
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

.DELETE_ON_ERROR:


source_dir=src
build_dir=build
root_dir:=$(shell pwd)

db_xsl1_ver=snapshot
db_xsl1_name=docbook-xsl-$(db_xsl1_ver)
db_xsl1_zip=$(db_xsl1_name).zip
db_xsl1_url=https://github.com/docbook/xslt10-stylesheets/releases/download/snapshot%2F2020-06-03/$(db_xsl1_zip)
db_xsl1_stylesheet:=$(root_dir)/$(source_dir)/xsl/$(db_xsl1_name)/xhtml5/docbook.xsl

db_xsl2_ver=2.6.0
db_xsl2_name=docbook-xslt2-$(db_xsl2_ver)
db_xsl2_zip=$(db_xsl2_name).zip
db_xsl2_url=https://github.com/docbook/xslt20-stylesheets/releases/download/$(db_xsl2_ver)/$(db_xsl2_zip)
db_xsl2_stylesheet:=$(root_dir)/$(source_dir)/xsl/$(db_xsl2_name)/xslt/base/html/html.xsl

db_xsl_tng_ver=2.5.0
db_xsl_tng_name=docbook-xslTNG-$(db_xsl_tng_ver)
db_xsl_tng_zip=$(db_xsl_tng_name).zip
db_xsl_tng_url=https://github.com/docbook/xslTNG/releases/download/$(db_xsl_tng_ver)/$(db_xsl_tng_zip)
db_xsl_tng_stylesheet:=$(root_dir)/$(source_dir)/xsl/$(db_xsl_tng_name)/xslt/docbook.xsl

epub_stylesheet=/usr/share/xml/docbook/stylesheet/docbook-xsl/epub3/chunk.xsl
xhtml5_stylesheet=/usr/share/xml/docbook/stylesheet/docbook-xsl/xhtml5/chunk.xsl
identity_stylesheet=src/xslt/identity.xslt
deploy_dir=DOC
assembly_jar=/home/jrowe/projects/SuperDoc/lib/assembly-1_1_0/lib/assembly.jar


build : \
$(build_dir)/DevOps-Manual/epub3/DevOps-Manual.epub \
$(build_dir)/DevOps-Manual/xhtml5/DevOps-Manual.xhtml \
$(build_dir)/DevOps-Manual/xhtml5-assembly/DevOps-Manual.xhtml \
$(build_dir)/QuickReference.html \
$(build_dir)/QuickReference-Hugo.html \
$(build_dir)/QuickReference-Hugo.md


deploy : \
$(deploy_dir)/QuickReference.html \
$(deploy_dir)/QuickReference-Hugo.md


.PHONEY : clean
clean :
	rm -rf $(build_dir)/*


#
# epub format
#

$(build_dir)/DevOps-Manual/epub3/DevOps-Manual.epub : \
$(build_dir)/DevOps-Manual/epub3/mimetype
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; zip -X0 $$(basename $@) mimetype
	cd $$(dirname $@) ; zip -r -X9 $$(basename $@) META-INF OEBPS


$(build_dir)/DevOps-Manual/epub3/mimetype : \
$(build_dir)/DevOps-Manual/DocBook5/DevOps-Manual.xml
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc $(epub_stylesheet) ../DocBook5/$$(basename $<)


#
# xhtml5 format
#


$(build_dir)/DevOps-Manual/xhtml5/DevOps-Manual.xhtml : \
$(build_dir)/DevOps-Manual/DocBook5/DevOps-Manual.xml
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc $(xhtml5_stylesheet) ../DocBook5/$$(basename $<)


#
# DocBook5 intermediate output
#


$(build_dir)/DevOps-Manual/DocBook5/DevOps-Manual.xml : \
$(source_dir)/DevOps-Manual/DevOps-Manual.xml \
$(source_dir)/DevOps-Manual/Topics/SSH/verify_key_passphrase.xml \
$(source_dir)/Biblioentries/S/SO_4411457.xml
	@ mkdir --parents $$(dirname $@)
	xsltproc --output $@ --xinclude $(identity_stylesheet) $<


#
# DevOps assembly
#

$(build_dir)/DevOps-Manual/xhtml5-assembly/DevOps-Manual.xhtml : \
$(build_dir)/DevOps-Manual/DocBook5/realized.xml
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc $(xhtml5_stylesheet) ../DocBook5/$$(basename $<)


$(build_dir)/DevOps-Manual/DocBook5/realized.xml : \
$(source_dir)/DevOps-Manual/assembly.xml \
$(source_dir)/DevOps-Manual/Topics/SSH/add_passphrase_to_key.xml \
$(source_dir)/DevOps-Manual/Topics/SSH/verify_key_passphrase.xml \
$(source_dir)/Biblioentries/M/MAN_ssh-keygen.xml \
$(source_dir)/Biblioentries/S/SO_4411457.xml
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

$(build_dir)/QuickReference.html : $(build_dir)/QuickReference.adoc
	@ mkdir --parents $$(dirname $@)
	asciidoc --backend html --doctype article --out-file $@ $<


$(build_dir)/QuickReference-Hugo.html : $(build_dir)/QuickReference.adoc
	@ mkdir --parents $$(dirname $@)
	cp src/css/hugo-loveit.css $$(dirname $@)/style.min.css
	asciidoc -a linkcss -a stylesdir=css -a stylesheet=style.min.css --backend html --doctype article --out-file $@ $<


$(build_dir)/QuickReference.adoc : \
$(source_dir)/QuickReference/index.tt \
$(build_dir)/YAML/QuickReference.yml
	@ mkdir --parents $$(dirname $@)
	carton exec -- tpage --define data_file="$(build_dir)/YAML/QuickReference.yml" --eval_perl $< > $@


$(build_dir)/QuickReference-Hugo.md : \
$(source_dir)/QuickReference/index.tt \
$(build_dir)/YAML/QuickReference.yml
	@ mkdir --parents $$(dirname $@)
	carton exec -- tpage --define data_file="$(build_dir)/YAML/QuickReference.yml" --define format=markdown --eval_perl $< > $@


$(build_dir)/YAML/QuickReference.yml : \
$(source_dir)/QuickReference/data.pl \
$(source_dir)/QuickReference/data.yml
	@ mkdir --parents $$(dirname $@)
	carton exec -- perl $^ > $@


.PHONEY: docbook-xsl1
docbook-xsl1: $(source_dir)/xsl/$(db_xsl1_name)/.done

$(source_dir)/xsl/$(db_xsl1_name)/.done : \
$(source_dir)/xsl/$(db_xsl1_zip)
	cd $$(dirname $<) ; unzip -o $$(basename $<)
	touch $@

$(source_dir)/xsl/$(db_xsl1_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ $(db_xsl1_url)

.PHONEY: docbook-xsl2
docbook-xsl2: $(source_dir)/xsl/$(db_xsl2_name)/.done

$(source_dir)/xsl/$(db_xsl2_name)/.done : \
$(source_dir)/xsl/$(db_xsl2_zip)
	cd $$(dirname $<) ; unzip -o $$(basename $<)
	touch $@

$(source_dir)/xsl/$(db_xsl2_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ $(db_xsl2_url)

.PHONEY: docbook-xsl-tng
docbook-xsl-tng: $(source_dir)/xsl/$(db_xsl_tng_name)/.done

$(source_dir)/xsl/$(db_xsl_tng_name)/.done: \
$(source_dir)/xsl/$(db_xsl_tng_zip)
	cd $$(dirname $<) ; unzip -o $$(basename $<)
	touch $@

$(source_dir)/xsl/$(db_xsl_tng_zip):
	@ mkdir --parents $$(dirname $@)
	wget --output-document $@ $(db_xsl_tng_url)


.PHONEY: build.html5
build.html5: \
$(build_dir)/Website/index.html \
$(build_dir)/Website/Test/DevOps-Manual/index.xhtml

$(build_dir)/Website/Test/DevOps-Manual/index.xhtml: \
$(source_dir)/DevOps-Manual/DevOps-Manual.test.xml \
$(source_dir)/xsl/$(db_xsl1_name)/.done
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; \
	xsltproc --output $$(basename $@) \
	$(db_xsl1_stylesheet) \
	../../../../$<

# need a 2.0 and 3.0 xslt processor
#$(source_dir)/xsl/$(db_xsl2_name)/.done \
#$(source_dir)/xsl/$(db_xsl_tng_name)/.done
#	$(db_xsl2_stylesheet) \
#	$(db_xsl_tng_stylesheet) \


$(build_dir)/Website/index.html: \
$(source_dir)/Website/index.html
	@ mkdir --parents $$(dirname $@)
	cp --archive $< $@


