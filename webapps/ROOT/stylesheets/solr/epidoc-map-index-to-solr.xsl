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
    <xsl:for-each select="$texts//tei:placeName[@key!=''][@ref]">
      <p id="{substring-after(@ref, 'places/')}"><xsl:value-of select="translate(@key, '#', '')"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></p>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="uncertain_places">
    <xsl:for-each select="$texts">
      <xsl:for-each select="//tei:placeName[matches(lower-case(@key), '.*(uncertain_tradition).*')][@ref]">
        <xsl:text> </xsl:text><xsl:value-of select="substring-after(@ref, 'places/')"/><xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="certain_places">
    <xsl:for-each select="$texts">
      <xsl:for-each select="//tei:placeName[not(matches(lower-case(@key), '.*(uncertain_tradition).*'))][@ref]">
        <xsl:text> </xsl:text><xsl:value-of select="substring-after(@ref, 'places/')"/><xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- generate lists of places by type -->
  <xsl:variable name="map_polygons">
    <xsl:text>{</xsl:text>
    <xsl:for-each select="$places/tei:place[matches(normalize-space(descendant::tei:geo[not(@style='line')]), '(\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1};\s+?)+\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
      <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
      <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
      <xsl:variable name="years" select="'0500/1500'"/>
      <xsl:variable name="mentioning_documents">
        <xsl:for-each select="$texts">
          <xsl:for-each select=".[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
      <xsl:text>"</xsl:text><xsl:value-of select="$years"/><xsl:text>|</xsl:text><xsl:value-of select="$name"/>
      <xsl:text>#</xsl:text><xsl:value-of select="$number_of_mentioning_documents"/>
      <xsl:text>#</xsl:text><xsl:value-of select="$id"/><xsl:text>": "</xsl:text>
      <xsl:value-of select="replace(replace(normalize-space(tei:geogName/tei:geo[not(@style='line')]), ', ', ';'), '; ', ';')"/>
      <xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="map_lines">
    <xsl:text>{</xsl:text>
    <xsl:for-each select="$places/tei:place[matches(normalize-space(descendant::tei:geo[@style='line']), '(\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1};\s+?)+\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
      <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
      <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
      <xsl:variable name="years" select="'0500/1500'"/>
      <xsl:variable name="mentioning_documents">
        <xsl:for-each select="$texts">
          <xsl:for-each select=".[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
      <xsl:text>"</xsl:text><xsl:value-of select="$years"/><xsl:text>|</xsl:text><xsl:value-of select="$name"/>
      <xsl:text>#</xsl:text><xsl:value-of select="$number_of_mentioning_documents"/>
      <xsl:text>#</xsl:text><xsl:value-of select="$id"/><xsl:text>": "</xsl:text>
      <xsl:value-of select="replace(replace(normalize-space(tei:geogName/tei:geo[@style='line']), ', ', ';'), '; ', ';')"/>
      <xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="map_points">
    <xsl:text>{</xsl:text>
    <xsl:for-each select="$places/tei:place[matches(normalize-space(descendant::tei:geo), '\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
      <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
      <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
      <xsl:variable name="linked_keys"><xsl:for-each select="$keys/p[@id=$id]"><xsl:value-of select="lower-case(.)"/><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
      <xsl:variable name="all_keys" select="concat(' ', normalize-space($linked_keys))"/>
      <xsl:variable name="years" select="'0500/1500'"/>
      <xsl:variable name="mentioning_documents">
        <xsl:for-each select="$texts">
          <xsl:for-each select=".[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
      <xsl:text>"</xsl:text><xsl:value-of select="$years"/><xsl:text>|</xsl:text><xsl:value-of select="$name"/>
      <xsl:text>#</xsl:text><xsl:value-of select="$number_of_mentioning_documents"/>
      <xsl:if test="not(matches($all_keys, '.*(fiscal_property).*'))"><xsl:text>#a@</xsl:text></xsl:if> <!-- fiscal -->
      <xsl:if test="matches($all_keys, '.*(fiscal_property).*')"><xsl:text>#b@</xsl:text></xsl:if> <!-- not fiscal -->
      <xsl:if test="matches($all_keys, '.* (ports|bridges/pontoons|maritime_trade|fluvial_transport) .*')"><xsl:text>c@</xsl:text></xsl:if> <!-- ports -->
      <xsl:if test="matches($all_keys, '.* (castle|fortress|tower|clusae/gates|walls|carbonaria|defensive_elements|right_to_fortify) .*')"><xsl:text>d@</xsl:text></xsl:if> <!-- fortifications -->
      <xsl:if test="matches($all_keys, '.* (residential|palatium|laubia/topia) .*')"><xsl:text>e@</xsl:text></xsl:if> <!-- residences -->
      <xsl:if test="matches($all_keys, '.* (mills|kilns|workshops|gynaecea|mints|overland_transport|markets|periodic_markets|decima|nona_et_decima|fodrum|albergaria/gifori|profits_of_justice|profits_of_mining/minting|tolls|teloneum|rights_of_use_on_woods/pastures/waters|coinage) .*')"><xsl:text>f@</xsl:text></xsl:if> <!-- revenues -->
      <xsl:if test="matches($all_keys, '.* (villas|curtes|gai|massae|salae|demesnes|domuscultae|casali|mansi) .*')"><xsl:text>g@</xsl:text></xsl:if> <!-- estates -->
      <xsl:if test="matches($all_keys, '.* (casae/cassinae_massaricie|casalini/fundamenta) .*')"><xsl:text>h@</xsl:text></xsl:if> <!-- tenures -->
      <xsl:if test="matches($all_keys, '.* (petiae|landed_possessions) .*')"><xsl:text>i@</xsl:text></xsl:if> <!-- land -->
      <xsl:if test="matches($all_keys, '.* (mines|quarries|forests|gualdi|cafagia|fisheries|saltworks|other_basins) .*')"><xsl:text>j@</xsl:text></xsl:if> <!-- fallow -->
      <xsl:if test="contains($uncertain_places, concat(' ',$id,' ')) and not(contains($certain_places, concat(' ',$id,' ')))"><xsl:text>k@</xsl:text></xsl:if> <!-- all occurrences from uncertain tradition -->
      <!--<xsl:if test="matches($all_keys, '.*(uncertain_tradition).*')"><xsl:text>k@</xsl:text></xsl:if> <!-\- at least one occurrence from uncertain tradition -\->-->
      <xsl:value-of select="$id"/><xsl:text>": "</xsl:text><xsl:choose>
        <xsl:when test="contains(normalize-space(tei:geogName/tei:geo), ';')"><xsl:value-of select="substring-before(normalize-space(tei:geogName/tei:geo), ';')"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="normalize-space(tei:geogName/tei:geo)"/></xsl:otherwise>
      </xsl:choose><xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
  </xsl:variable>
  
  <xsl:variable name="map_labels">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="$places/tei:place[matches(normalize-space(descendant::tei:geo), '^\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}$') or matches(descendant::tei:geo, '(\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1};\s+?)+\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:placeName[1], ',', '; '))"/><xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
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
          <field name="index_map_polygons"><xsl:value-of select="normalize-space($map_polygons)"/></field>
          <field name="index_map_lines"><xsl:value-of select="normalize-space($map_lines)"/></field>
          <field name="index_map_points"><xsl:value-of select="normalize-space($map_points)"/></field>
          <field name="index_map_labels"><xsl:value-of select="normalize-space($map_labels)"/></field>
          <xsl:apply-templates select="current()" />
        </doc>
      </xsl:for-each>
    </add>
  </xsl:template>
  
</xsl:stylesheet>
