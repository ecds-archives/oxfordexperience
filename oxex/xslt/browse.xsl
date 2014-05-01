<?xml version="1.0" encoding="ISO-8859-1"?> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/TR/REC-html40" version="1.0"
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	exclude-result-prefixes="exist" 
	xmlns:xq="http://metalab.unc.edu/xq/"
	xmlns:tei="http://www.tei-c.org/ns/1.0">


<xsl:output method="html"/>
<xsl:template match="/">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="result">
  <xsl:element name="ul">
    <xsl:attribute name="class">contents</xsl:attribute>
<xsl:for-each select=".">
  <xsl:element name="li">
    <xsl:element name="a">
      <xsl:attribute name="href">document.php?id=<xsl:apply-templates select="@xml:id"/></xsl:attribute>
      <xsl:apply-templates select="tei:title"/>
    </xsl:element><!-- a -->
    <xsl:text>, </xsl:text><xsl:value-of select="tei:sic"/>
  </xsl:element> <!-- li -->
</xsl:for-each>
  </xsl:element> <!-- ul -->
</xsl:template> <!--result -->
</xsl:stylesheet>

