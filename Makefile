
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

.DELETE_ON_ERROR:


source_dir=src
build_dir=build

epub_stylesheet=/usr/share/xml/docbook/stylesheet/docbook-xsl/epub3/chunk.xsl
identity_stylesheet=src/xslt/identity.xslt


build : \
$(build_dir)/DevOps-Manual/epub3/DevOps-Manual.epub \
$(build_dir)/QuickReference.html


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
# QuickReference
#

$(build_dir)/QuickReference.html : $(build_dir)/QuickReference.adoc
	@ mkdir --parents $$(dirname $@)
	asciidoc --backend html --doctype article --out-file $@ $<


$(build_dir)/QuickReference.adoc : \
$(source_dir)/QuickReference/index.tt \
$(build_dir)/YAML/QuickReference.yml
	@ mkdir --parents $$(dirname $@)
	tpage --define data_file="$(build_dir)/YAML/QuickReference.yml" --eval_perl $< > $@


$(build_dir)/YAML/QuickReference.yml : \
$(source_dir)/QuickReference/data.pl
	@ mkdir --parents $$(dirname $@)
	perl $< > $@


