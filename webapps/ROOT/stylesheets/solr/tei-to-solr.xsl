<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../kiln/stylesheets/solr/tei-to-solr.xsl" />

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 18, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> jvieira</xd:p>
      <xd:p>This stylesheet converts a TEI document into a Solr index document. It expects the parameter file-path,
      which is the path of the file being indexed.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:template match="/">
    <add>
      <xsl:apply-imports />
    </add>
  </xsl:template>
  
  <xsl:template match="tei:summary/tei:rs[@type='text_type']" mode="facet_ancient_document_type">
    <field name="ancient_document_type">
      <xsl:choose>
        <xsl:when test="text()!='-'">
          <xsl:value-of select="normalize-space(translate(translate(., '-', ''), '/', '／'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:msContents/tei:summary/tei:rs[@type='fiscal_property']" mode="facet_fiscal_property">
    <field name="fiscal_property">
      <xsl:choose>
        <xsl:when test="contains(lower-case(.), 'yes')"><xsl:text>Yes</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(.), 'no')"><xsl:text>No</xsl:text></xsl:when>
        <xsl:when test="contains(lower-case(.), 'uncertain')"><xsl:text>Uncertain</xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>No or uncertain</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:listChange/tei:change[1]" mode="facet_area">  
    <field name="area">
      <xsl:choose>
        <xsl:when test="lower-case(@who)=('ncerretani', 'cciccopiedi', 'ecinello', 'edelmercato', 'bferretti', 'tlazzari', 'emanarini', 'lmotta', 'fribani', 'cstedile', 'ltabarrini', 'gvignodelli')">1. North</xsl:when>
        <xsl:when test="lower-case(@who)=('langeli', 'scollavini', 'mcortese', 'agiacomelli', 'dinternullo', 'ptomei', 'mviti')">2. Centre</xsl:when>
        <xsl:when test="lower-case(@who)=('vdeangelis', 'vlore', 'pmassa', 'vriveramagos', 'atagliente', 'gzornetta')">3. South</xsl:when>
        <xsl:otherwise>4. Other</xsl:otherwise> <!-- lbelluscio, ecirelli, fdefalco, mdellipizzi, adimuro, aredeghieri, isommariva, mvallerani, other... -->
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:summary/tei:rs[@type='record_source']" mode="facet_record_source">
    <field name="record_source">
      <xsl:choose>
        <xsl:when test="text() or node()/text()">
          <xsl:value-of select="normalize-space(translate(., '/', '／'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:msContents/tei:summary/tei:rs[@type='document_tradition']" mode="facet_document_tradition">
    <field name="document_tradition">
      <xsl:choose>
        <xsl:when test="text() or node()/text()">
          <xsl:value-of select="normalize-space(translate(., '/', '／'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate/tei:note[@type='topical_date']" mode="facet_topical_date">
    <field name="topical_date">
      <xsl:choose>
        <xsl:when test="text() or node()/text()">
          <xsl:value-of select="normalize-space(translate(translate(., '/', '／'), '?', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate/tei:note[@type='redaction_date']" mode="facet_redaction_date">
    <field name="redaction_date">
      <xsl:choose>
        <xsl:when test="text() or node()/text()">
          <xsl:value-of select="normalize-space(translate(translate(., '/', '／'), '?', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate" mode="facet_document_date">
    <field name="document_date">
      <xsl:choose>
        <xsl:when test="@when and not(@notBefore) and not(@notAfter)"><xsl:value-of select="@when"/></xsl:when>
        <xsl:when test="@notBefore and @notAfter and not(@when)"><xsl:value-of select="concat(@notBefore, ' – ', @notAfter)"/></xsl:when>
        <xsl:when test="@notBefore and not(@notAfter) and not(@when)"><xsl:value-of select="concat(@notBefore, ' – ?')"/></xsl:when>
        <xsl:when test="@notAfter and not(@notBefore) and not(@when)"><xsl:value-of select="concat(@notAfter, '? – ', @notAfter)"/></xsl:when>
        <xsl:otherwise><xsl:text>?</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:persName[@ref!='']" mode="facet_people">
    <field name="people">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref][descendant::tei:persName!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/people.xml')//tei:person[descendant::tei:idno=$ref][1]/tei:persName[1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:placeName[@ref!='']" mode="facet_places">
    <field name="places">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/places.xml')//tei:place[descendant::tei:idno=$ref][descendant::tei:placeName[not(@type)]!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/places.xml')//tei:place[descendant::tei:idno=$ref][1]/tei:placeName[not(@type)][1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:orgName[@ref!='']" mode="facet_juridical_persons">
    <field name="juridical_persons">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/juridical_persons.xml')//tei:org[descendant::tei:idno=$ref][descendant::tei:orgName!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/juridical_persons.xml')//tei:org[descendant::tei:idno=$ref][1]/tei:orgName[1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:geogName[@ref!='']" mode="facet_estates">
    <field name="estates">
      <xsl:variable name="ref" select="translate(@ref,' #', '')"/>
      <xsl:choose>
        <xsl:when test="document('../../content/fiscus_framework/resources/estates.xml')//tei:place[descendant::tei:idno=$ref][descendant::tei:geogName!='']">
          <xsl:variable name="name" select="normalize-space(translate(translate(document('../../content/fiscus_framework/resources/estates.xml')//tei:place[descendant::tei:idno=$ref][1]/tei:geogName[1], '/', '／'), '?', ''))"/>
          <xsl:value-of select="upper-case(substring($name, 1, 1))"/>
          <xsl:value-of select="substring($name, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(@ref,' #', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:date" mode="facet_dates">
    <field name="dates">
      <xsl:choose>
        <xsl:when test="@when!=''"><xsl:value-of select="@when"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="translate(translate(., '/', '／'), '?', '')" /></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:persName/tei:name[@nymRef]" mode="facet_person_name">
    <field name="person_name">
      <xsl:value-of select="@nymRef"/>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:TEI" mode="facet_complete_edition">
    <field name="complete_edition"> 
      <xsl:apply-templates select="." />
    </field>
  </xsl:template>
  
  <xsl:template match="tei:rs[@key!='']" mode="facet_keywords_-_alphabetically">
    <xsl:variable name="keyvalue">
      <xsl:choose>
        <xsl:when test="starts-with(@key, ' ')"><xsl:value-of select="substring(normalize-space(@key), 2)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space(@key)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="tokenize($keyvalue, ' #')">
      <xsl:variable name="key" select="translate(., '#', '')"/>
      <xsl:variable name="thes" select="document('../../content/fiscus_framework/resources/thesaurus.xml')//tei:catDesc[lower-case(@n)=lower-case($key)]"/>
      <!-- All keys -->
      <field name="keywords_-_alphabetically">
            <xsl:variable name="thes_v">
              <xsl:choose>
                <xsl:when test="$thes">
                  <xsl:value-of select="lower-case(translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="lower-case(translate(translate(replace($key, '([a-z]{1})([A-Z]{1})', '$1_$2'), '_', ' '), '/', '／'))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
        <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
        <xsl:value-of select="substring($thes_v, 2)" />
      </field>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:rs[@key!='']" mode="facet_keywords">
    <xsl:variable name="keyvalue">
      <xsl:choose>
        <xsl:when test="starts-with(@key, ' ')"><xsl:value-of select="substring(normalize-space(@key), 2)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space(@key)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="tokenize($keyvalue, ' #')">
      <xsl:variable name="key" select="translate(., '#', '')"/>
      <xsl:variable name="thes" select="document('../../content/fiscus_framework/resources/thesaurus.xml')//tei:catDesc[lower-case(@n)=lower-case($key)]"/>
      
      <xsl:if test="$thes[ancestor::tei:category[5]][not(ancestor::tei:category[6])]">
        <field name="keywords_-_level_5">
          <xsl:number value="count($thes/ancestor::tei:category[5]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_4">
          <xsl:number value="count($thes/ancestor::tei:category[5]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[2]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_3">
          <xsl:number value="count($thes/ancestor::tei:category[5]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[3]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_2">
          <xsl:number value="count($thes/ancestor::tei:category[5]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[4]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_1">
          <xsl:number value="count($thes/ancestor::tei:category[5]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[5]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
      </xsl:if>
      
      
      <xsl:if test="$thes[ancestor::tei:category[4]][not(ancestor::tei:category[5])]">
        <field name="keywords_-_level_4">
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_3">
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[2]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_2">
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[3]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_1">
          <xsl:number value="count($thes/ancestor::tei:category[4]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[4]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
      </xsl:if>
      
      <xsl:if test="$thes[ancestor::tei:category[3]][not(ancestor::tei:category[4])]">
        <field name="keywords_-_level_3">
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_2">
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[2]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_1">
          <xsl:number value="count($thes/ancestor::tei:category[3]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[3]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
      </xsl:if>
      
      <xsl:if test="$thes[ancestor::tei:category[2]][not(ancestor::tei:category[3])]">
        <field name="keywords_-_level_2">
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>.</xsl:text>
          <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="01" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
        <field name="keywords_-_level_1">
          <xsl:number value="count($thes/ancestor::tei:category[2]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/ancestor::tei:category[2]/child::tei:catDesc/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
      </xsl:if>
      
      <xsl:if test="$thes[ancestor::tei:category[1]][not(ancestor::tei:category[2])]">
        <field name="keywords_-_level_1">
          <xsl:number value="count($thes/ancestor::tei:category[1]/preceding-sibling::tei:category) + 1" format="1" /><xsl:text>. </xsl:text>
          <xsl:variable name="thes_v" select="lower-case(translate(translate(replace($thes/@n, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/>
          <xsl:value-of select="upper-case(substring($thes_v, 1, 1))"/>
          <xsl:value-of select="substring($thes_v, 2)" />
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!-- This template is called by the Kiln tei-to-solr.xsl as part of
       the main doc for the indexed file. Put any code to generate
       additional Solr field data (such as new facets) here. -->
  
  <xsl:template name="extra_fields">
    <xsl:call-template name="field_ancient_document_type"/>
    <xsl:call-template name="field_fiscal_property"/>
    <xsl:call-template name="field_area"/>
    <xsl:call-template name="field_record_source"/>
    <xsl:call-template name="field_document_tradition" />
    <xsl:call-template name="field_topical_date"/>
    <xsl:call-template name="field_redaction_date"/>
    <xsl:call-template name="field_document_date"/>
    <xsl:call-template name="field_keywords"/>
    <xsl:call-template name="field_keywords_-_alphabetically"/>
    <xsl:call-template name="field_people"/>
    <xsl:call-template name="field_places"/>
    <xsl:call-template name="field_juridical_persons"/>
    <xsl:call-template name="field_estates"/>
    <xsl:call-template name="field_dates"/>
    <xsl:call-template name="field_person_name"/>
    <xsl:call-template name="field_complete_edition"/>
  </xsl:template>
  
  <xsl:template name="field_keywords">
    <xsl:apply-templates mode="facet_keywords" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  <xsl:template name="field_keywords_-_alphabetically">
    <xsl:apply-templates mode="facet_keywords_-_alphabetically" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  <xsl:template name="field_ancient_document_type">
    <xsl:apply-templates mode="facet_ancient_document_type" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='text_type']"/>
  </xsl:template>
  <xsl:template name="field_fiscal_property">
    <xsl:apply-templates mode="facet_fiscal_property" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='fiscal_property']" />
  </xsl:template>
  <xsl:template name="field_area">
    <xsl:apply-templates mode="facet_area" select="/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change[1]" />
  </xsl:template>
  <xsl:template name="field_record_source">
    <xsl:apply-templates mode="facet_record_source" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='record_source']"/>
  </xsl:template>
  <xsl:template name="field_document_tradition">
    <xsl:apply-templates mode="facet_document_tradition" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:summary/tei:rs[@type='document_tradition']" />
  </xsl:template>
  <xsl:template name="field_topical_date">
    <xsl:apply-templates mode="facet_topical_date" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/tei:note[@type='topical_date']"/>
  </xsl:template>
  <xsl:template name="field_redaction_date">
    <xsl:apply-templates mode="facet_redaction_date" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/tei:note[@type='redaction_date']"/>
  </xsl:template>
  <xsl:template name="field_document_date">
    <xsl:apply-templates mode="facet_document_date" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate"/>
  </xsl:template>
  <xsl:template name="field_people">
    <xsl:apply-templates mode="facet_people" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  <xsl:template name="field_places">
    <xsl:apply-templates mode="facet_places" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  <xsl:template name="field_juridical_persons">
    <xsl:apply-templates mode="facet_juridical_persons" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  <xsl:template name="field_estates">
    <xsl:apply-templates mode="facet_estates" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']" />
   </xsl:template>
  <xsl:template name="field_dates">
    <xsl:apply-templates mode="facet_dates" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  <xsl:template name="field_person_name">
    <xsl:apply-templates mode="facet_person_name" select="/tei:TEI/tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  <xsl:template name="field_complete_edition">
    <xsl:apply-templates mode="facet_complete_edition" select="/tei:TEI" />
  </xsl:template>

</xsl:stylesheet>
