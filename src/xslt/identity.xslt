<?xml version='1.0'?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version='1.0'
>

  <!-- identity transform -->

  <xsl:output
      method="xml"
      version="1.0"
      encoding="UTF-8"
      indent="yes"
      omit-xml-declaration="no"
  />

  <xsl:template match="/ | @* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node() " />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
