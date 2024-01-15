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
  
  <!-- MAP VARIABLES - START -->
  <xsl:variable name="texts" select="collection(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/xml/epidoc/?select=*.xml;recurse=yes'))/tei:TEI/tei:text/tei:body/tei:div[@type='edition']"/>
  <xsl:variable name="keys">
    <xsl:for-each select="$texts//tei:placeName[@ref]">
      <!-- it includes also <placeName>s without @key: needed to count certain/uncertain occurrences --> 
      <p id="{substring-after(@ref, 'places/')}">
        <xsl:choose>
          <xsl:when test="contains(lower-case(@key), 'uncertain_tradition')">
            <xsl:attribute name="cert" select="'low'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="cert" select="'high'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="translate(@key, '#', '')"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
      </p>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- generate map data -->
  <xsl:variable name="map_data">
    <xsl:for-each select="$places/tei:place[matches(normalize-space(descendant::tei:geo[1]), '(\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1};\s+?)+\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}') or matches(normalize-space(descendant::tei:geo[1]), '\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
      <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
      <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
      <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($texts[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]])"/></xsl:variable>
      <xsl:variable name="type">
        <xsl:choose>
          <xsl:when test="tei:geogName/tei:geo[1][@style='line']">LineString</xsl:when>
          <xsl:when test="tei:geogName/tei:geo[1][not(@style='line')] and contains(descendant::tei:geo[1], ';')">Polygon</xsl:when>
          <xsl:otherwise>Point</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="coord">
        <xsl:choose>
          <xsl:when test="$type = 'Point'">
            [<xsl:value-of select="normalize-space(concat(substring-after(tei:geogName/tei:geo[1], ','), ', ', substring-before(tei:geogName/tei:geo[1], ',')))"/>]
          </xsl:when>
          <xsl:when test="$type = 'Polygon'">
            <xsl:variable name="coord_pairs" select="tokenize(normalize-space(tei:geogName/tei:geo[1]), ';' )"/>
            [[<xsl:for-each select="$coord_pairs">
              [<xsl:value-of select="normalize-space(concat(substring-after(., ','), ', ', substring-before(., ',')))"/>]<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
            </xsl:for-each>]]
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="coord_pairs" select="tokenize(normalize-space(tei:geogName/tei:geo[1]), ';' )"/>
            [<xsl:for-each select="$coord_pairs">
              [<xsl:value-of select="normalize-space(concat(substring-after(., ','), ', ', substring-before(., ',')))"/>]<xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
            </xsl:for-each>]
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="linked_keys" select="$keys/p[@id=$id]"/>
      <xsl:variable name="linked_keys_string">
        <xsl:for-each select="$linked_keys[normalize-space(text())!='']">
          <xsl:value-of select="lower-case(.)"/><xsl:text> </xsl:text>
        </xsl:for-each>
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
      <xsl:variable name="all_keys" select="concat(' ', normalize-space($linked_keys_string))"/>
      <xsl:variable name="is-fiscal">
        <xsl:choose>
          <xsl:when test="matches($all_keys, '.*(fiscal_property).*')">
            <xsl:text>yes</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>no</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="symbols_raw">
        <xsl:if test="matches($all_keys, '.* (ports|bridges/pontoons|maritime_trade|fluvial_transport) .*')">, "ports"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (castle|fortress|tower|clusae/gates|walls|carbonaria|defensive_elements|right_to_fortify) .*')">, "fortifications"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (residential|palatium|laubia/topia) .*')">, "residences"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (mills|kilns|workshops|gynaecea|mints|overland_transport|markets|periodic_markets|decima|nona_et_decima|fodrum|albergaria/gifori|profits_of_justice|profits_of_mining/minting|tolls|teloneum|rights_of_use_on_woods/pastures/waters|coinage) .*')">, "revenues"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (villas|curtes|gai|massae|salae|demesnes|domuscultae|casali|mansi) .*')">, "estates"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (casae/cassinae_massaricie|casalini/fundamenta) .*')">, "tenures"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (petiae|landed_possessions) .*')">, "land"</xsl:if>
        <xsl:if test="matches($all_keys, '.* (mines|quarries|forests|gualdi|cafagia|fisheries|saltworks|other_basins) .*')">, "fallow"</xsl:if>
      </xsl:variable>
      <xsl:variable name="symbols">
        <xsl:choose>
          <xsl:when test="starts-with(normalize-space($symbols_raw), ', ')"><xsl:value-of select="substring-after(normalize-space($symbols_raw), ', ')"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="normalize-space($symbols_raw)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <!--<xsl:if test="number($number_of_mentioning_documents) gt 0">-->
        {"type": "Feature",
        "properties": {
        "name": "<xsl:value-of select="$name"/>",
        "mentioningDocsCount": "<xsl:value-of select="$number_of_mentioning_documents"/>",
        "id": "<xsl:value-of select="$id"/>",
        "certainty": "<xsl:value-of select="$certainty"/>",
        "isFiscal": "<xsl:value-of select="$is-fiscal"/>",
        "symbols": [<xsl:value-of select="$symbols"/>]
        },
        "geometry": {
        "type": "<xsl:value-of select="$type"/>",
        "coordinates": <xsl:value-of select="$coord"/>
        }
        }
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      <!--</xsl:if>-->
    </xsl:for-each>
  </xsl:variable>
  <!-- MAP VARIABLES - END -->
  
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
