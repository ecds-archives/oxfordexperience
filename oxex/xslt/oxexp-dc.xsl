<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:dcterms="http://purl.org/dc/terms"
                version="1.0"
		xmlns:tei="http://www.tei-c.org/ns/1.0">
  <!-- This stylesheet creates Dublin core metadata for each document -->
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:param name="qualified">true</xsl:param>
  <xsl:variable name="baseurl">http://beck.library.emory.edu/</xsl:variable>
  <xsl:variable name="siteurl">oxfordexperience</xsl:variable>

  <xsl:template match="/">
    <dc>
      <xsl:apply-templates select="//tei:TEI"/> <!-- get everything below this -->
      <dc:type>Text</dc:type>
    <dc:format>text/xml</dc:format>
    </dc>
  </xsl:template>

  
  
  <xsl:template match="tei:extent"/>
  
  <xsl:template match="tei:fileDesc">
    <xsl:element name="dc:title">
      <xsl:apply-templates select="tei:titleStmt/tei:title"/>
    </xsl:element>
    <xsl:element name="dc:creator">
      <xsl:value-of select="tei:titleStmt//tei:name//tei:reg"/>
    </xsl:element>
        <xsl:element name="dc:contributor">
      <xsl:text>Lewis H. Beck Center</xsl:text>
    </xsl:element>
    <xsl:element name="dc:publisher">
      <xsl:apply-templates select="tei:publicationStmt/tei:publisher"/>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="$qualified = 'true'">
	<xsl:element name="dcterms:issued">
	  <xsl:apply-templates select="tei:publicationStmt/tei:date"/>
	</xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="dc:date">
	  <xsl:apply-templates select="tei:publicationStmt/tei:date"/>
      </xsl:element>
    </xsl:otherwise>
    </xsl:choose>
    <xsl:element name="dc:rights">
      <xsl:apply-templates select="tei:publicationStmt/tei:availability/tei:p"/>
    </xsl:element>
    
    <xsl:choose>
      <xsl:when test="$qualified = 'true'">
	<xsl:element name="dcterms:isPartOf">
	  <xsl:apply-templates select="tei:seriesStmt/tei:title"/>
	</xsl:element>
	<xsl:element name="dcterms:isPartOf">
	  <xsl:value-of select="$baseurl"/><xsl:value-of
	  select="$siteurl"/>      
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="dc:relation">
	  <xsl:apply-templates select="tei:seriesStmt/tei:title"/>
	</xsl:element>
	<xsl:element name="dc:relation">
	  <xsl:value-of select="$baseurl"/><xsl:value-of
	    select="$siteurl"/>      
	</xsl:element>
      </xsl:otherwise>	
    </xsl:choose>

    <xsl:element name="dc:source">
      <!-- only one element here. -->
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl"/>
      <!-- in case source is in plain text, without tags -->
      <!--  <xsl:apply-templates select="text()"/> -->
    </xsl:element>
    
    <xsl:element name="dc:identifier">
      <xsl:value-of select="tei:publicationStmt/tei:idno[@type='ark']"/>      
    </xsl:element>

  </xsl:template>
  
  <xsl:template match="tei:publicationStmt"> 
    <xsl:if test="$qualified = 'true'">
    <!-- electronic publication date: Per advice of LA -->
    <xsl:element name="dcterms:created">
      <xsl:value-of select="tei:date"/>
    </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:profileDesc">
    <xsl:for-each select="tei:textClass//tei:item">
    <xsl:element name="dc:subject">
      <xsl:value-of select="."/>
    </xsl:element>
    </xsl:for-each>
  </xsl:template>

<!-- normalize space in titles -->
  <xsl:template match="tei:titleStmt/tei:title">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

<!-- add a space after titles in the head -->
  <xsl:template match="tei:titleStmt/tei:title">
    <xsl:apply-templates/><xsl:text> </xsl:text>
  </xsl:template>

<!-- handle <lb/> in head -->
   <xsl:template match="tei:lb">
      <xsl:apply-templates/><xsl:text> </xsl:text>
   </xsl:template>


  <!-- ignore these: encoding-specific information -->
  <xsl:template match="tei:encodingDesc"/>
  <xsl:template match="tei:encodingDesc/tei:projectDesc"/>
  <xsl:template match="tei:encodingDesc/tei:tagsDecl"/>
  <xsl:template match="tei:encodingDesc/tei:refsDecl"/>
  <xsl:template match="tei:encodingDesc/tei:editorialDecl"/>
  <xsl:template match="tei:profileDesc/tei:creation"/>
  <xsl:template match="tei:revisionDesc"/>
  <xsl:template match="tei:text"/>

  <!-- normalize space for all text nodes -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>
