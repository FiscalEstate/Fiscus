<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of keywords in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <xsl:variable name="root" select="." />
    <xsl:variable name="all_mentions">
      <xsl:for-each select="$root//tei:div[@type='edition']//tei:rs/@key"><xsl:value-of select="concat(' ', replace(normalize-space(.), '#', ''), ' ')"/></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="not_mentioned" select="$thesaurus//tei:catDesc[not(contains(lower-case($all_mentions), concat(' ', lower-case(normalize-space(@n)), ' ')))]"/>
    
    <xsl:variable name="key-values">
      <xsl:for-each select="//tei:rs[ancestor::tei:div/@type='edition'][@key!=''][@key!=' '][@key!='#']/@key|$not_mentioned/@n">
        <xsl:value-of select="lower-case(replace(replace(., '([a-z]{1})([A-Z]{1})', '$1_$2'), '#', ''))" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="keys" select="distinct-values(tokenize($key-values, '\s+'))" />
    
    <add>
      <xsl:for-each select="$keys">
        <xsl:variable name="key" select="."/>
        <xsl:variable name="thes" select="$thesaurus//tei:catDesc[lower-case(replace(@n, '([a-z]{1})([A-Z]{1})', '$1_$2'))=lower-case($key)]"/>
        <xsl:variable name="keyword" select="$root//tei:div[@type='edition']//tei:rs[@key!=''][@key!=' '][@key!='#']/@key[contains(concat(' ', replace(lower-case(replace(., '([a-z]{1})([A-Z]{1})', '$1_$2')), '#', ''), ' '), concat(' ', lower-case($key), ' '))]|$not_mentioned" />
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <xsl:if test="$thes">
          <field name="index_item_name">
            <xsl:variable name="thes_v" select="translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' ')"/>
            <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
            <xsl:value-of select="substring($thes_v, 2)" />
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="concat('https://ausohnum.huma-num.fr/concept/', $thes[1]/@xml:id)" />    
          </field> 
            <field name="index_thesaurus_hierarchy">
              <xsl:if test="$thes[ancestor::tei:category[5]][not(ancestor::tei:category[6])]">
                <xsl:number value="count($thes/ancestor::tei:category[5]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" />
              </xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[4]][not(ancestor::tei:category[5])]">
                <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" />
              </xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[3]][not(ancestor::tei:category[4])]">
                <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" />
              </xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[2]][not(ancestor::tei:category[3])]">
                <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
                <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" />
              </xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[1]][not(ancestor::tei:category[2])]">
                <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="1" />
              </xsl:if>
            </field>
            <field name="index_thesaurus_level">
              <xsl:if test="$thes[ancestor::tei:category[5]][not(ancestor::tei:category[6])]"><xsl:text>level5</xsl:text></xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[4]][not(ancestor::tei:category[5])]"><xsl:text>level4</xsl:text></xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[3]][not(ancestor::tei:category[4])]"><xsl:text>level3</xsl:text></xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[2]][not(ancestor::tei:category[3])]"><xsl:text>level2</xsl:text></xsl:if>
              <xsl:if test="$thes[ancestor::tei:category[1]][not(ancestor::tei:category[2])]"><xsl:text>level1</xsl:text></xsl:if>
            </field>
            <field name="index_thesaurus_descendants">
              <xsl:if test="$thes[following-sibling::tei:category]"><xsl:text>yes</xsl:text></xsl:if>
              <xsl:if test="$thes[not(following-sibling::tei:category)]"><xsl:text>no</xsl:text></xsl:if>
            </field>
          </xsl:if>
          <xsl:if test="$thes/@xml:id='c25661'"><!-- to prevent having this indexed for all instances -->
            <field name="index_total_items">
            <xsl:value-of select="string(count($thesaurus//tei:catDesc))"/>
          </field>
          </xsl:if>
          <xsl:apply-templates select="$keyword" />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>

  <xsl:template match="tei:rs/@key">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
