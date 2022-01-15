<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="base-uri" />

  <!-- Variables and templates used in epidoc-xxx-index-to-solr.xsl files -->
  <xsl:variable name="places" select="document('../../content/fiscus_framework/resources/places.xml')/tei:TEI/tei:text/tei:body/tei:listPlace[@type='places']/tei:listPlace"/>
  <xsl:variable name="juridical_persons" select="document('../../content/fiscus_framework/resources/juridical_persons.xml')/tei:TEI/tei:text/tei:body/tei:listOrg[@type='juridical_persons']/tei:listOrg"/>
  <xsl:variable name="estates" select="document('../../content/fiscus_framework/resources/estates.xml')/tei:TEI/tei:text/tei:body/tei:listPlace[@type='estates']/tei:listPlace"/>
  <xsl:variable name="people" select="document('../../content/fiscus_framework/resources/people.xml')/tei:TEI/tei:text/tei:body/tei:listPerson[@type='people']/tei:listPerson"/>
  <xsl:variable name="thesaurus" select="document('../../content/fiscus_framework/resources/thesaurus.xml')/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:classDecl/tei:taxonomy"/>
  <xsl:variable name="link_subtypes" select="document('../../content/fiscus_framework/resources/link_subtypes.xml')/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:classDecl/tei:taxonomy"/>
  <xsl:variable name="all_items" select="$places|$juridical_persons|$estates|$people"/>
  
  <xsl:template match="//tei:foreign|//tei:title" mode="italics">
    <xsl:text>italicsstart</xsl:text><xsl:apply-templates select="."/><xsl:text>italicsend</xsl:text>
  </xsl:template>
  
  <xsl:template name="field_file_path">
    <!-- The file_path field for user indices should be the same for
         all indices defined in the same index file, as they are all
         indexed together and so existing entries need to be deleted
         together. -->
    <field name="file_path">
      <xsl:text>indices/</xsl:text>
      <xsl:value-of select="$subdirectory" />
    </field>
  </xsl:template>

  <xsl:template name="field_index_instance_location">
    <field name="index_instance_location">
      <!-- This field contains a combination of the following:
             * The content/xml subdirectory containing the indexed field, to be used in generating the map:match 
             id used in generating the URL of the document containing this instance, via kiln:url-for-match. 
             (This is the $subdirectory parameter.)
             * The path to the file (minus extension) this instance belongs to, relative to the content subdirectory 
             (ie, the value in the preceding item), to be passed to the kiln:url-for-match call to generate the URL 
             of the document containing this instance.
             * The document date.
             * The @key values associated to the index entry in such document.
           Each part is separated by "#" for parsing in the query
           results.
      -->
      <xsl:variable name="filepath" select="substring-before(ancestor::file[1]/@path, '.xml')" />
      <xsl:value-of select="$subdirectory" />
      <xsl:text>#</xsl:text>
      <xsl:value-of select="$filepath" />
      <xsl:text>#</xsl:text>
      <xsl:choose>
        <xsl:when test="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[@when!=''][@when!='0001']"><xsl:value-of select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@when" /></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore" />
          <xsl:text>–</xsl:text>
          <xsl:value-of select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notAfter" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>#</xsl:text>
      <xsl:choose>
        <xsl:when test="@key!='' and not(self::tei:rs)">
          <xsl:variable name="allkeys" select="distinct-values(tokenize(lower-case(translate(replace(translate(@key, '_', ' '), ' #', '; '), '#', '')), '; '))"/>
            <xsl:for-each select="$allkeys"><xsl:sort/><xsl:value-of select="."/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </field>
  </xsl:template>

</xsl:stylesheet>
