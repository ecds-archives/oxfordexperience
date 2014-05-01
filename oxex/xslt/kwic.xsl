<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:output method="xml"/>


  <xsl:param name="mode">kwic</xsl:param>
  <xsl:param name="url_suffix"/> 
  <xsl:param name="url"/>  	<!-- needed in common.xsl; not used here -->
  <xsl:param name="id"/>	

  <xsl:include href="common.xsl"/>
  <xsl:include href="kwic-words.xsl"/>


  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

<xsl:template match="item">
    <h2>Keyword in Context</h2>
    
    <div class="kwic">
      <p>
        <a>
          <xsl:attribute name="href">document.php?id=<xsl:value-of select="//@xml:id"/>&amp;<xsl:value-of select="$url_suffix"/></xsl:attribute>
          <xsl:value-of select="tei:title"/>, 
        </a><xsl:apply-templates select="tei:name//tei:reg"/>, 
    <xsl:apply-templates select="tei:date"/>
      </p>
    </div>
   
    <xsl:apply-templates select="//context"/>

  </xsl:template>

<xsl:template match="name">
    <xsl:choose>
      <xsl:when test="position() = 1"/>
      <xsl:when test="position() = last()">
        <xsl:text> and </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text> </xsl:text>
      </xsl:otherwise>
  </xsl:choose>
    <xsl:apply-templates />
</xsl:template>



  <!-- use kwic mode to show context # of words around match terms -->
<!--  <xsl:template match="//p|//head|//note|//item"> -->
    <!-- FIXME: adding l shows only keyword, and not context -->
    <!-- <p><xsl:apply-templates select="." mode="kwic"/></p>
    <hr class="kwic"/>
  </xsl:template> -->

  <!-- poetry lines are short enough; shouldn't need parsing out words -->
  <xsl:template match="tei:l">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>


</xsl:stylesheet>
