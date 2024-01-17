<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
  version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This XSLT generates map_data.xml export, containing 
    partly processed map data to be further processed by 
    epidoc-map-index-to-solr.xsl and results-to-html.xsl -->
  
  <xsl:import href="epidoc-index-utils.xsl" />
  
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <xsl:variable name="texts" select="collection(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/xml/epidoc/?select=*.xml;recurse=yes'))/tei:TEI/tei:text/tei:body/tei:div[@type='edition']//tei:placeName[@ref]"/>
  <xsl:variable name="keys">
    <xsl:for-each select="$texts">
      <!-- it includes also <placeName>s without @key: needed to count certain/uncertain occurrences --> 
      <xsl:variable name="key" select="normalize-space(lower-case(translate(translate(@key, '#', ''), ',', '')))"/>
      <p id="{substring-after(@ref, 'places/')}" doc="{ancestor::tei:TEI//tei:idno[@type='filename']}">
        <xsl:choose>
          <xsl:when test="contains($key, 'uncertain_tradition')">
            <xsl:attribute name="cert" select="'low'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="cert" select="'high'"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="matches($key, '.* (ports|bridges/pontoons|maritime_trade|fluvial_transport) .*')"><xsl:attribute name="ports" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (castle|fortress|tower|clusae/gates|walls|carbonaria|defensive_elements|right_to_fortify) .*')"><xsl:attribute name="fortifications" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (residential|palatium|laubia/topia) .*')"><xsl:attribute name="residences" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (mills|kilns|workshops|gynaecea|mints|overland_transport|markets|periodic_markets|decima|nona_et_decima|fodrum|albergaria/gifori|profits_of_justice|profits_of_mining/minting|tolls|teloneum|rights_of_use_on_woods/pastures/waters|coinage) .*')"><xsl:attribute name="revenues" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (villas|curtes|gai|massae|salae|demesnes|domuscultae|casali|mansi) .*')"><xsl:attribute name="estates" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (casae/cassinae_massaricie|casalini/fundamenta) .*')"><xsl:attribute name="tenures" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (petiae|landed_possessions) .*')"><xsl:attribute name="land" select="'yes'"/></xsl:if>
        <xsl:if test="matches($key, '.* (mines|quarries|forests|gualdi|cafagia|fisheries|saltworks|other_basins) .*')"><xsl:attribute name="fallow" select="'yes'"/></xsl:if>
        <xsl:if test="contains($key, 'fiscal_property')"><xsl:attribute name="fiscal" select="'yes'"/></xsl:if>
        <xsl:value-of select="$key"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
      </p>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="map_data_raw">
    <mapPlaces>
      <xsl:for-each select="$places/tei:place[matches(normalize-space(descendant::tei:geo[1]), '(\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1};\s+?)+\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}') or matches(normalize-space(descendant::tei:geo[1]), '\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
        <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
        <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
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
        
        <mapPlace>
          <name><xsl:value-of select="$name"/></name>
          <id><xsl:value-of select="$id"/></id>
          <type><xsl:value-of select="$type"/></type>
          <coord><xsl:value-of select="$coord"/></coord>
          <linkedKeys><xsl:copy-of select="$linked_keys"/></linkedKeys>            
        </mapPlace>
      </xsl:for-each>
    </mapPlaces>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:result-document href="{concat('file:',system-property('user.dir'), '/webapps/ROOT/content/map_data.xml')}">
      <xsl:copy-of select="$map_data_raw"/>
    </xsl:result-document>
  </xsl:template>
  
</xsl:stylesheet>
