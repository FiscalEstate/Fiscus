<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of estates in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:geogName[ancestor::tei:div/@type='edition']" group-by="concat(., '-', @ref, '-', @key)">
        <xsl:variable name="est-id" select="translate(@ref, '#', '')"/>
        <xsl:variable name="estate-id" select="document(concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/estates.xml'))//tei:place[descendant::tei:idno=$est-id]/tei:geogName"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:value-of select="." />
          </field>
          <field name="index_base_form">
            <xsl:choose>
              <xsl:when test="$estate-id"><xsl:value-of select="$estate-id" /></xsl:when>
              <xsl:otherwise><xsl:value-of select="translate(@ref, '#', '')" /></xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_keys">
            <xsl:value-of select="translate(@key, '#', '')" />
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:geogName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>