<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
  version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of map data in those
       documents. -->
  
  <xsl:import href="epidoc-index-utils.xsl" />
  
  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" /> 
 
  <xsl:variable name="map_data_raw" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/map_data.xml'))"/>
  
  <xsl:variable name="map_data">
    <xsl:for-each select="$map_data_raw/mapPlaces/mapPlace">
      <xsl:variable name="item" select="."/>
      <xsl:variable name="linked_keys" select="linkedKeys/p"/>
      <xsl:variable name="number_of_mentioning_documents">
        <xsl:value-of select="count(distinct-values($linked_keys/@doc))"/>
      </xsl:variable>
      <xsl:variable name="certainty">
        <xsl:choose>
          <xsl:when test="count($linked_keys[@cert='low']) gt 0 and count($linked_keys[@cert='high']) = 0">
            <xsl:text>low</xsl:text> <!-- all occurrences are uncertain: this is the value used to mark a map entry as 'From uncertain tradition' -->
          </xsl:when>
          <xsl:when test="count($linked_keys[@cert='low']) gt 0 and count($linked_keys[@cert='high']) gt 0">
            <xsl:text>medium</xsl:text> <!-- there are at least one certain and one uncertain occurrence: this should be used instead if it is enough to have one uncertain occurrence to mark a map entry as 'From uncertain tradition' -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>high</xsl:text> <!-- all occurrences are certain -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="symbols">
        <xsl:if test="$linked_keys[@ports]">"ports", </xsl:if>
        <xsl:if test="$linked_keys[@fortifications]">"fortifications", </xsl:if>
        <xsl:if test="$linked_keys[@residences]">"residences", </xsl:if>
        <xsl:if test="$linked_keys[@revenues]">"revenues", </xsl:if>
        <xsl:if test="$linked_keys[@estates]">"estates", </xsl:if>
        <xsl:if test="$linked_keys[@tenures]">"tenures", </xsl:if>
        <xsl:if test="$linked_keys[@land]">"land", </xsl:if>
        <xsl:if test="$linked_keys[@fallow]">"fallow", </xsl:if>
        <xsl:if test="$linked_keys[@fiscal]">"fiscal"</xsl:if>
        <xsl:if test="not($linked_keys[@fiscal])">"not fiscal"</xsl:if>
      </xsl:variable>
      
        {"type": "Feature",
        "properties": {
        "name": "<xsl:value-of select="$item/name"/>",
        "id": "<xsl:value-of select="$item/id"/>",
        "mentioningDocsCount": "<xsl:value-of select="$number_of_mentioning_documents"/>",
        "certainty": "<xsl:value-of select="$certainty"/>",
        "symbols": [<xsl:value-of select="$symbols"/>]
        },
        "geometry": {
        "type": "<xsl:value-of select="$item/type"/>",
        "coordinates": <xsl:value-of select="$item/coord"/>
        }
        }
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:variable name="root" select="." />
    <add>
      <xsl:for-each select="$places[1]/tei:place[1]/tei:idno"><!-- to prevent having this indexed for all instances -->
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" /><xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" /><xsl:text>_index</xsl:text>
          </field>
          <field name="index_map_data"><xsl:value-of select="normalize-space($map_data)"/></field>
          <xsl:apply-templates select="current()" />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>
  
</xsl:stylesheet>
