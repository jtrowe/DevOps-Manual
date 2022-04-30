
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

.DELETE_ON_ERROR:


source_dir=src
build_dir=build

epub_stylesheet=/usr/share/xml/docbook/stylesheet/docbook-xsl/epub3/chunk.xsl
identity_stylesheet=src/xslt/identity.xslt
deploy_dir=DOC


build : \
$(build_dir)/DevOps-Manual/epub3/DevOps-Manual.epub \
$(build_dir)/QuickReference.html \
$(build_dir)/QuickReference-Hugo.html \
$(build_dir)/QuickReference-Hugo.md


deploy : \
$(deploy_dir)/QuickReference.html \
$(deploy_dir)/QuickReference-Hugo.html


.PHONEY : clean
clean :
	rm -rf $(build_dir)/*


$(build_dir)/DevOps-Manual/epub3/DevOps-Manual.epub : \
$(build_dir)/DevOps-Manual/epub3/mimetype
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; zip -X0 $$(basename $@) mimetype
	cd $$(dirname $@) ; zip -r -X9 $$(basename $@) META-INF OEBPS


$(build_dir)/DevOps-Manual/epub3/mimetype : \
$(build_dir)/DevOps-Manual/DocBook5/DevOps-Manual.xml
	@ mkdir --parents $$(dirname $@)
	cd $$(dirname $@) ; xsltproc $(epub_stylesheet) ../DocBook5/$$(basename $<)


$(build_dir)/DevOps-Manual/DocBook5/DevOps-Manual.xml : \
$(source_dir)/DevOps-Manual/DevOps-Manual.xml
	@ mkdir --parents $$(dirname $@)
	xsltproc --output $@ --xinclude $(identity_stylesheet) $<


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
	tpage --define data_file="$(build_dir)/YAML/QuickReference.yml" --eval_perl $< > $@


$(build_dir)/QuickReference-Hugo.md : \
$(source_dir)/QuickReference/index.tt \
$(build_dir)/YAML/QuickReference.yml
	@ mkdir --parents $$(dirname $@)
	tpage --define data_file="$(build_dir)/YAML/QuickReference.yml" --define format=markdown --eval_perl $< > $@


$(build_dir)/YAML/QuickReference.yml : \
$(source_dir)/QuickReference/data.pl \
$(source_dir)/QuickReference/data.yml
	@ mkdir --parents $$(dirname $@)
	perl $^ > $@


