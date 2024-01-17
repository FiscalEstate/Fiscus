<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
  version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of symbols in those
       documents. -->
  
  <xsl:import href="epidoc-index-utils.xsl" />
  
  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <!-- GRAPH VARIABLES - START -->
  <!--<xsl:variable name="places" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/places.xml'))/tei:TEI/tei:text/tei:body/tei:listPlace[@type='places']/tei:listPlace"/>
  <xsl:variable name="juridical_persons" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/juridical_persons.xml'))/tei:TEI/tei:text/tei:body/tei:listOrg[@type='juridical_persons']/tei:listOrg"/>
  <xsl:variable name="estates" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/estates.xml'))/tei:TEI/tei:text/tei:body/tei:listPlace[@type='estates']/tei:listPlace"/>
  <xsl:variable name="people" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/people.xml'))/tei:TEI/tei:text/tei:body/tei:listPerson[@type='people']/tei:listPerson"/>
  <xsl:variable name="thesaurus" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/thesaurus.xml'))/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:classDecl/tei:taxonomy"/>
  <xsl:variable name="all_items" select="$places|$juridical_persons|$estates|$people"/>-->
  
  <!-- generate lists of items, their relations and their labels -->  
  <xsl:variable name="graph_items">
    <xsl:text>{nodes:[</xsl:text>
    <xsl:for-each select="$all_items/tei:*[not(child::tei:*[1]='XXX')][child::tei:*[1]!=''][child::tei:idno!='']">
      <xsl:text>{data: {id: "</xsl:text><xsl:value-of select="tei:idno[1]"/><xsl:text>", name: "</xsl:text>        
      <xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>"</xsl:text>
      <xsl:text>, type: "</xsl:text><xsl:choose>
        <xsl:when test="ancestor::tei:listPerson">people</xsl:when>
        <xsl:when test="ancestor::tei:listOrg">juridical_persons</xsl:when>
        <xsl:when test="ancestor::tei:listPlace[@type='estates']">estates</xsl:when>
        <xsl:when test="ancestor::tei:listPlace[@type='places']">places</xsl:when>
      </xsl:choose><xsl:text>"}</xsl:text>
      <xsl:text>}</xsl:text>
      <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>], edges:[</xsl:text>
    <xsl:for-each select="$all_items/tei:*/tei:link[tokenize(concat(replace(@corresp, '#', ''), ' '), ' ')=$all_items/tei:*/tei:idno][not(starts-with(@corresp, ' '))][not(ends-with(@corresp, ' '))]">
      <xsl:variable name="id" select="parent::tei:*/tei:idno[1]"/>
      <xsl:variable name="relation_type"><xsl:choose>
        <xsl:when test="@subtype='' or @subtype='link'"><xsl:text> </xsl:text></xsl:when>
        <xsl:otherwise><xsl:value-of select="lower-case(translate(translate(replace(@subtype, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/></xsl:otherwise>
      </xsl:choose></xsl:variable>
      <xsl:variable name="cert" select="@cert"/>
      <xsl:variable name="color">
        <xsl:choose>
          <xsl:when test="parent::tei:person and @type='people'">
            <xsl:choose>
              <xsl:when test="$thesaurus//tei:catDesc[@n=$relation_type][@key='family']">
                <xsl:text>red</xsl:text>
              </xsl:when>
              <xsl:otherwise><xsl:text>green</xsl:text></xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="parent::tei:person or @type='people'">
            <xsl:text>blue</xsl:text>
          </xsl:when>
          <xsl:otherwise><xsl:text>orange</xsl:text></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="not(contains(@corresp, ' '))">
          <xsl:text>{data: {id: "</xsl:text><xsl:value-of select="concat($id, ' + ', replace(@corresp, '#', ''))"/><xsl:text>", name: "</xsl:text><xsl:value-of select="$relation_type"/><xsl:text>", source: "</xsl:text><xsl:value-of select="$id"/>
          <xsl:text>", target: "</xsl:text><xsl:value-of select="replace(@corresp, '#', '')"/><xsl:text>"</xsl:text> 
          <xsl:text>, type: "</xsl:text><xsl:value-of select="$color"/><xsl:text>"</xsl:text>
          <xsl:if test="$relation_type!=' '"><xsl:text>, subtype: "arrow"</xsl:text></xsl:if>
          <xsl:if test="$cert='low'"><xsl:text>, cert: "low"</xsl:text></xsl:if>
          <xsl:text>}}</xsl:text>
        </xsl:when>
        <xsl:when test="contains(@corresp, ' ')">
          <xsl:for-each select="tokenize(@corresp, ' ')[replace(., '#', '')=$all_items/tei:*/tei:idno]">
            <xsl:variable name="single_item" select="replace(., '#', '')"/>
            <xsl:text>{data: {id: "</xsl:text><xsl:value-of select="concat($id, ' + ', $single_item)"/><xsl:text>", name: "</xsl:text><xsl:value-of select="$relation_type"/><xsl:text>", source: "</xsl:text><xsl:value-of select="$id"/>
            <xsl:text>", target: "</xsl:text><xsl:value-of select="$single_item"/><xsl:text>"</xsl:text> 
            <xsl:text>, type: "</xsl:text><xsl:value-of select="$color"/><xsl:text>"</xsl:text>
            <xsl:if test="$relation_type!=' '"><xsl:text>, subtype: "arrow"</xsl:text></xsl:if>
            <xsl:if test="$cert='low'"><xsl:text>, cert: "low"</xsl:text></xsl:if>
            <xsl:text>}}</xsl:text>
            <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>]}</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="graph_labels">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="$all_items/tei:*[not(child::tei:*[1]='XXX')][child::tei:*[1]!=''][child::tei:idno!='']">
      <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>"</xsl:text>
      <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:variable>
  <!-- GRAPH VARIABLES - END -->
  
  <xsl:template match="/">
    <add>
      <xsl:for-each select="$juridical_persons[1]/tei:org[1]/tei:idno"><!-- to prevent having this indexed for all instances -->
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" /><xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" /><xsl:text>_index</xsl:text>
          </field>
          <field name="index_graph_items"><xsl:value-of select="$graph_items"/></field>
          <field name="index_graph_labels"><xsl:value-of select="$graph_labels"/></field>
          <xsl:apply-templates select="current()" />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>
  
</xsl:stylesheet>
