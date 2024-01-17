<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Transform the XML returned from harvesting RDF into the Sesame
       server into HTML. -->
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
  <xsl:import href="../escape-xml.xsl" />
  
  <xsl:template match="error" mode="rdf">
    <td class="fail">
      <xsl:text>Failed: </xsl:text>
      <xsl:value-of select="." />
    </td>
  </xsl:template>

  <xsl:template match="file" mode="rdf">
    <tr>
      <td><xsl:value-of select="@path" /></td>
      <xsl:apply-templates mode="rdf" />
    </tr>
  </xsl:template>

  <xsl:template match="file/response" mode="rdf">
    <xsl:apply-templates mode="rdf" />
    <xsl:variable name="id" select="generate-id(.)" />
    <td>
      <span class="switch" id="{$id}-switch"
            onclick="toggle('{$id}', '[show]', '[hide]')">[show]</span>

      <pre id="{$id}" style="display: none">
        <xsl:apply-templates mode="escape-xml" select="." />
      </pre>
    </td>
  </xsl:template>

  <xsl:template match="success" mode="rdf">
    <td class="success">
      <xsl:text>Succeeded</xsl:text>
    </td>
  </xsl:template>

  <xsl:template match="xincludes" mode="rdf">
    <table class="pure-table pure-table-horizontal">
      <thead>
        <th scope="col">File</th>
        <th scope="col">Remove old data</th>
        <th scope="col">Add new data</th>
        <th scope="col">Full XML response</th>
      </thead>
      <tbody>
        <xsl:apply-templates mode="rdf" />
      </tbody>
    </table>
    
    <!-- This part of the XSLT generates map_data.xml export, containing 
    partly processed map data to be further processed by 
    epidoc-map-index-to-solr.xsl and results-to-html.xsl -->
    <xsl:variable name="texts" select="collection(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/xml/epidoc/?select=*.xml;recurse=yes'))/tei:TEI/tei:text/tei:body/tei:div[@type='edition']//tei:placeName[@ref]"/>
    <xsl:variable name="places" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/places.xml'))/tei:TEI/tei:text/tei:body/tei:listPlace[@type='places']/tei:listPlace"/>
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
    
    <xsl:result-document href="{concat('file:',system-property('user.dir'), '/webapps/ROOT/content/map_data.xml')}">
      <xsl:copy-of select="$map_data_raw"/>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
