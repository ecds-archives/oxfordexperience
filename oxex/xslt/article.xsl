<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/TR/REC-html40" 
	xmlns:xql="http://metalab.unc.edu/xql/"
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	exclude-result-prefixes="exist" version="1.0"
	xmlns:tei="http://www.tei-c.org/ns/1.0">


<xsl:param name="kwic"/> <!-- value is true if comes from search -->
<xsl:param name="view"/> <!-- value is xml if view source is chosen, intro if c intro essay is chosen -->
<xsl:param name="id"/>
<xsl:param name="defaultindent">5</xsl:param>

<!-- code adapted from ewwrp -->
<xsl:variable name="imgserver">http://bohr.library.emory.edu/beck/oxfordexperience/images/</xsl:variable>

<xsl:variable name="figure-prefix">
    <xsl:value-of select="$imgserver"/>
</xsl:variable>
<xsl:variable name="thumbs-prefix"><xsl:value-of select="$figure-prefix"/>thumbs/</xsl:variable>
<xsl:variable name="figure-suffix">.jpg</xsl:variable>


<!-- note: Change for P5: to make the stylesheets work properly, if they use the tei namespace, they must declare it! -->
<!-- <xsl:include href="teihtml-tables.xsl"/>
<xsl:include href="table.xsl"/> -->
 <xsl:include href="footnotes.xsl"/>
<xsl:output method="html"/>  


<xsl:template match="/">
  <!-- recall the article list -->
  <xsl:call-template name="return" />
  <xsl:call-template name="xmlview"/>
 <xsl:apply-templates/>
<!-- display footnotes at end -->
    <xsl:call-template name="endnotes"/> 
  <!-- recall the article list -->
  <xsl:call-template name="return" />
<!-- links to next & previous titles (if present) -->
  <xsl:call-template name="next-prev" />
</xsl:template>



<!--
<xsl:template match="/">
<xsl:choose>
<xsl:when test="$view='xml'">

</xsl:when>
<xsl:otherwise> -->
  <!-- offer xml view -->
<!--  <xsl:element name="a">
    <xsl:attribute name="href">document.php?view=xml&amp;id=<xsl:value-of select="$id"/></xsl:attribute>
    <xsl:attribute name="class">xmlview</xsl:attribute>
    View xml code for document</xsl:element>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
-->

<!-- Don't print the header -->
  <xsl:template match="tei:teiHeader"/>

<xsl:template match="tei:front[tei:div/@type='critical_introduction']">
  <xsl:choose>
<!-- link to the essay - default -->
    <xsl:when test="$view = ''">
      <xsl:element name="a">
	<xsl:attribute name="href">document.php?id=<xsl:value-of select="$id"/>&amp;view=intro</xsl:attribute>View the introduction</xsl:element>
	<xsl:element name="br"/>
	</xsl:when>
 <!-- show intro essay, link back to letter view -->
   <xsl:when test="$view = 'intro'">  
      <xsl:element name="a">
	<xsl:attribute name="href">document.php?id=<xsl:value-of select="$id"/></xsl:attribute>View document only</xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">intro</xsl:attribute>
  <xsl:apply-templates select="tei:div"/>
      </xsl:element>
    </xsl:when>
  </xsl:choose> 
</xsl:template>



<!-- print out the content-->
<xsl:template match="tei:body/tei:div">
<!-- get everything under this node -->
  <xsl:apply-templates/> 
</xsl:template>

  <!-- figure code for yjallen, using P5 @facs in pb -->
  <!-- if it is inside a paragraph, or in the back, add breaks around the page break -->
  <!-- only offer the view if there is @facs -->
  
  <xsl:template match="//tei:pb|//tei:milestone">
    <xsl:if test="ancestor::tei:p | ancestor::tei:back"><br/></xsl:if>
  <xsl:if test="@*[name() = 'facs']">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="concat($figure-prefix, @facs)"/></xsl:attribute>
      <xsl:attribute name="target">_blank</xsl:attribute>
      View image of page
    </xsl:element>
    <xsl:if test="position()=1">
      <xsl:element name="br"/>
    </xsl:if>
  </xsl:if>
    <xsl:if test="following-sibling::tei:opener"><br/></xsl:if>
    <xsl:if test="ancestor::tei:p | ancestor::tei:back"><br/></xsl:if>
  </xsl:template>


<!-- display the title -->
<xsl:template match="tei:div/tei:head">
  <xsl:element name="h2">
    <xsl:attribute name="class">title</xsl:attribute>
   <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="tei:byline">
  <xsl:element name="i">
    <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:docDate">
<xsl:element name="p">
  <xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:bibl">
<xsl:element name="p">
  <xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:front/tei:div/tei:docAuthor">
  <xsl:element name="h3">
    <xsl:attribute name="class">author</xsl:attribute>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>
<!--
<xsl:template match="div3">
"u  <xsl:if test="@type='About'">
    <xsl:element name="i">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:if>
  <xsl:if test="@type='Section'">
    <xsl:apply-templates />
  </xsl:if>
  <xsl:if test="@type='Sidebar'">
  <xsl:element name="span">
      <xsl:attribute name="class">sidebar</xsl:attribute>
  <xsl:apply-templates />
  </xsl:element>
  </xsl:if>
  <xsl:if test="@type='sidebar'">
  <xsl:element name="span">
      <xsl:attribute name="class">sidebar</xsl:attribute>
  <xsl:apply-templates />
  </xsl:element>
  </xsl:if> 

</xsl:template> -->


<xsl:template match="tei:div3/tei:head">
    <xsl:element name="h2">
    Sidebar: <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>


<xsl:template match="tei:p/tei:title">
  <xsl:element name="i">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>  

<xsl:template match="tei:bibl/tei:title[@level='m']">
  <xsl:element name="i">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>  

<xsl:template match="tei:p" priority="1">
  <xsl:element name="p">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:q" priority="1">
  <xsl:element name="blockquote">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:list">
  <xsl:element name="ul">
   <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:item" priority="1">
  <xsl:element name="li">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>  </xsl:element>
</xsl:template>


<xsl:template match="tei:speaker">
<xsl:element name="br"/>
<xsl:element name="span">
<xsl:attribute name="class">speaker</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:sp/tei:p">
<xsl:element name="span">
<xsl:attribute name="class">speech</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
<xsl:element name="br"/>
</xsl:template>

<xsl:template match="tei:lg/tei:head">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>
<xsl:element name="br"/>
</xsl:template>

<!-- for letters in Oxford Experience -->
<xsl:template match="tei:dateline/tei:name[@type='place']">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>
<xsl:element name="br"/>
</xsl:template>

<xsl:template match="tei:dateline/tei:date">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>
<xsl:element name="br"/>
</xsl:template>

<xsl:template match="tei:closer/tei:salute">
<xsl:choose>
<xsl:when test="./@rend">
    <xsl:call-template name="rend"/>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates /> 
</xsl:otherwise>
</xsl:choose>
<xsl:element name="br"/>
</xsl:template>


<!-- convert rend tags to their html equivalents 
     so far, converts: center, italic, smallcaps, bold, underline   -->
<xsl:template name="rend">
  <xsl:choose>
    <xsl:when test="@rend='center'">
      <xsl:element name="center">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='italic'">
      <xsl:element name="i">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='bold'">
      <xsl:element name="b">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='smallcaps'">
      <xsl:element name="span">
        <xsl:attribute name="class">smallcaps</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='underline'">
      <xsl:element name="u">
        <xsl:apply-templates/>
      </xsl:element><xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@rend='right'">
         <xsl:element name="span"><xsl:attribute name="class">right</xsl:attribute>
        <xsl:apply-templates/>
         </xsl:element>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="//*[@rend]" priority="-1">
  <xsl:choose>
    <xsl:when test="@rend='center'">
      <xsl:element name="center">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='italic'">
      <xsl:element name="i">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='bold'">
      <xsl:element name="b">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='smallcaps'">
      <xsl:element name="span">
        <xsl:attribute name="class">smallcaps</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='underline'">
      <xsl:element name="u">
        <xsl:apply-templates/>
      </xsl:element><xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@rend='right'">
         <xsl:element name="span"><xsl:attribute name="class">right</xsl:attribute>
        <xsl:apply-templates/>
         </xsl:element>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:lb">
  <xsl:element name="br" />
</xsl:template>

<xsl:template match="tei:pb">
  <hr class="pb"/>
  <xsl:if test="pb/@n">
    <p class="pagebreak">
      <xsl:text>Page </xsl:text><xsl:value-of select="@n"/></p>
</xsl:if>
</xsl:template>

<!-- sic : only show 'sic' as an editorial comment with corr not with reg-->
<xsl:template match="tei:choice">
  <xsl:choose>
    <xsl:when test="child::tei:sic">
      <xsl:choose>
	<xsl:when test="child::tei:reg">
	  <xsl:apply-templates select="tei:sic"/> <!-- only print the sic -->
	</xsl:when>
	<xsl:when test="child::tei:corr">
      <xsl:apply-templates select="tei:sic"/> <!-- print [sic] after -->
	<xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
	[sic]
  </xsl:element>
  <xsl:element name="span">  <!-- print the correction in [ ] -->
	  <xsl:attribute name="class">edcorr</xsl:attribute>
	  <xsl:text> [</xsl:text>
	  <xsl:apply-templates select="tei:corr"/>
	  <xsl:text>] </xsl:text>
	</xsl:element>
    </xsl:when>
      </xsl:choose> <!-- end the sic case -->
    </xsl:when>
    <xsl:when test="child::tei:orig">
      <xsl:apply-templates select="tei:orig"/>
      <xsl:if test="child::tei:reg">
        <xsl:element name="span">
	  <xsl:attribute name="class">edcorr</xsl:attribute>
	  <xsl:text> [</xsl:text>
	  <xsl:apply-templates select="tei:reg"/>
	  <xsl:text>] </xsl:text>
	</xsl:element>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:template>



<!-- sic not inside choice element -->
<xsl:template match="tei:sic[not(ancestor::tei:choice)]">
  <xsl:apply-templates select="text()"/>
  <!-- show the text between the sic tags -->
  <xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
	[sic]
  </xsl:element>
</xsl:template>

<!-- when not inside choice element -->
<!-- put the correction in brackets and add style for coloring -->
<xsl:template match="tei:corr[not(ancestor::tei:choice)] | tei:reg[not(ancestor::tei:choice)]">
  <xsl:element name="span">
    <xsl:attribute name="class">edcorr</xsl:attribute>
  <xsl:text> [</xsl:text>
  <xsl:apply-templates select="text()"/>
  <xsl:text>] </xsl:text>
  </xsl:element>
</xsl:template>

<!-- gap : show 'gap' as an editorial comment, pick up @extent, @unit, @reason -->
<xsl:template match="tei:gap">
  <xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
       <xsl:text>[gap </xsl:text><xsl:value-of select="@extent"/><xsl:text> </xsl:text><xsl:value-of select="@unit"/><xsl:text> </xsl:text><xsl:value-of select="@reason"/><xsl:text>]</xsl:text>
  </xsl:element>
</xsl:template>

<!-- add and del colored and commented -->
  <xsl:template match="tei:add">
    <xsl:element name="span">
      <xsl:attribute name="class">add</xsl:attribute>
      <xsl:apply-templates select="text()"/>
    </xsl:element>
    <xsl:element name="span">
      <xsl:attribute name="class">editorial</xsl:attribute>
      [added]
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:del">
    <xsl:element name="span">
      <xsl:attribute name="class">del</xsl:attribute>
      <xsl:apply-templates select="text()"/>
    </xsl:element>
    <xsl:element name="span">
      <xsl:attribute name="class">editorial</xsl:attribute>
      [deleted]
    </xsl:element>
  </xsl:template>
<!--  unclear as an editorial comment -->
  <xsl:template match="tei:unclear">
    <xsl:apply-templates select="text()"/>
    <!-- show the text between the unclear tags -->
    <xsl:element name="span">
      <xsl:attribute name="class">editorial</xsl:attribute>
      [unclear]
    </xsl:element>
  </xsl:template>


<!-- line group -->
<xsl:template match="tei:lg">
  <xsl:element name="p">
     <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<!-- line  -->
<!--   Indentation should be specified in format rend="indent#", where # is
       number of spaces to indent.  --> 
<xsl:template match="tei:l">
  <!-- retrieve any specified indentation -->
  <xsl:if test="@rend">
  <xsl:variable name="rend">
    <xsl:value-of select="./@rend"/>
  </xsl:variable>
  <xsl:variable name="indent">
     <xsl:choose>
       <xsl:when test="$rend='indent'">		
	<!-- if no number is specified, use a default setting -->
         <xsl:value-of select="$defaultindent"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="substring-after($rend, 'indent')"/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
   <xsl:call-template name="indent">
     <xsl:with-param name="num" select="$indent"/>
   </xsl:call-template>
 </xsl:if>

  <xsl:apply-templates/>
  <xsl:element name="br"/>
</xsl:template>

<!-- generate next & previous links (if present) -->
<!-- note: all div2s, with id, head, and bibl are retrieved in a <siblings> node -->
<xsl:template name="next-prev">

<xsl:element name="table">
  <xsl:attribute name="width">100%</xsl:attribute>
<!-- this is not implemented for oxex -->
<!-- display articles relative to position of current article -->
<xsl:element name="tr">
<xsl:if test="//prev/@id">
<xsl:element name="th">
    <xsl:text>Previous: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">article.php?id=<xsl:value-of
		select="//prev/@id"/></xsl:attribute>
   <xsl:apply-templates select="//prev/head"/>
 </xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates select="//prev/@type"></xsl:apply-templates></xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates
select="//prev/docDate"/></xsl:element>
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  prev row --> 

<xsl:element name="tr">
<xsl:if test="//next/@id">
<xsl:element name="th">
    <xsl:text>Next: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">article.php?id=<xsl:value-of
		select="//next/@id"/></xsl:attribute>
   <xsl:apply-templates select="//next/head"/>
 </xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates select="//next/@type"></xsl:apply-templates></xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates
select="//next/docDate"/></xsl:element>
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  next row --> 


</xsl:element> <!-- table -->
</xsl:template>



<xsl:template name="return">
      <xsl:element name="p">
	Go to <xsl:element name="a">
	  <xsl:attribute
	      name="href">index.php</xsl:attribute>
<xsl:attribute name="rel">Contents</xsl:attribute>Document List 
</xsl:element> <!-- a --> 
</xsl:element> <!-- p -->

</xsl:template>

<!-- mark exist matches for highlighting -->
  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>

<!-- simple table test by Alice Hickcox, March 8, 2006 -->
<!-- this works -->
<!--    <xsl:param name="tableAlign">left</xsl:param> -->
   <xsl:param name="tableAlign">center</xsl:param>
   <xsl:param name="cellAlign">left</xsl:param>

<xsl:template match="tei:table">
<table>
<xsl:for-each select="@*">
<xsl:copy-of select="."/>
</xsl:for-each>
<xsl:apply-templates/></table>
</xsl:template>

<xsl:template match="tei:table/tei:head">
<h3><xsl:apply-templates/>
</h3>
</xsl:template>

<xsl:template match="tei:row">
<tr><xsl:apply-templates/>
</tr>
</xsl:template>

<xsl:template match="tei:cell">
<td valign="top">
<xsl:apply-templates/>
</td>
</xsl:template>

<!-- figure code from ewwrp -->
<xsl:template match="tei:figure">
  <xsl:element name="div">	<!-- wrap image in a div so it can be centered -->
    <xsl:attribute name="class">figure</xsl:attribute>
    <xsl:element name="img">
      <xsl:apply-templates select="@rend"/>
      <xsl:attribute name="src"><xsl:value-of select="concat($figure-prefix, @entity, $figure-suffix)"/></xsl:attribute>
      <xsl:attribute name="alt"><xsl:value-of select="normalize-space(figDesc)"/></xsl:attribute>
    </xsl:element>  <!-- img -->
  </xsl:element> <!-- div -->
</xsl:template>

<xsl:template match="tei:figure/@rend">
  <xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

  <!-- recursive template to indent by inserting non-breaking spaces -->
  <xsl:template name="indent">
    <xsl:param name="num">0</xsl:param>
    <xsl:variable name="space">&#160;</xsl:variable>
    
    <xsl:value-of select="$space"/>
    
    <xsl:if test="$num > 1">
      <xsl:call-template name="indent">
        <xsl:with-param name="num" select="$num - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- offer view of xml -->
  <xsl:template name="xmlview">
    <xsl:element name="a">
      <xsl:attribute name="href">document.php?id=<xsl:value-of select="$id"/>&amp;view=xml</xsl:attribute>View the TEI xml code for this page</xsl:element>
	<xsl:element name="br"/>
  </xsl:template>
</xsl:stylesheet>

