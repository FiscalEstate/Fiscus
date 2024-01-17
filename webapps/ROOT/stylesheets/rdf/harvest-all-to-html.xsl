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
    
    <!-- This part of the XSLT generates some data export files stored in content/exports -->
    <xsl:variable name="texts" select="collection(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/xml/epidoc/?select=*.xml;recurse=yes'))/tei:TEI/tei:text/tei:body/tei:div[@type='edition']//tei:placeName[@ref]"/>
    <xsl:variable name="places" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/places.xml'))/tei:TEI/tei:text/tei:body/tei:listPlace[@type='places']/tei:listPlace"/>
    <xsl:variable name="juridical_persons" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/juridical_persons.xml'))/tei:TEI/tei:text/tei:body/tei:listOrg[@type='juridical_persons']/tei:listOrg"/>
    <xsl:variable name="estates" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/estates.xml'))/tei:TEI/tei:text/tei:body/tei:listPlace[@type='estates']/tei:listPlace"/>
    <xsl:variable name="people" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/people.xml'))/tei:TEI/tei:text/tei:body/tei:listPerson[@type='people']/tei:listPerson"/>
    <xsl:variable name="thesaurus" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/fiscus_framework/resources/thesaurus.xml'))/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:classDecl/tei:taxonomy"/>
    <xsl:variable name="all_items" select="$places|$juridical_persons|$estates|$people"/>
    
    <!-- This part of the XSLT generates map_raw_data.xml export, containing 
    partly processed map data to be further processed 1) in results-to-html.xsl 
    and 2) below in this file to be displayed in map.xml -->
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
    
    <xsl:result-document href="{concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/map_raw_data.xml')}">
      <xsl:copy-of select="$map_data_raw"/>
    </xsl:result-document>
    
    <!-- This part of the XSLT generates map_data.xml export, containing 
    processed data to be displayed in map.xml. 
    It takes $map_data_raw from above in the file as input data. -->
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
    
    <xsl:result-document href="{concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/map_data.xml')}">
      <mapData>
        <xsl:copy-of select="$map_data"/>
      </mapData>
    </xsl:result-document>
    
    <!-- This part of the XSLT generates graph_data.xml export, containing 
    processed data to be displayed in relation_graph.xml -->
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
    
    <xsl:result-document href="{concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/graph_data.xml')}">
      <graphData>
        <items><xsl:copy-of select="$graph_items"/></items>
        <labels><xsl:copy-of select="$graph_labels"/></labels>
      </graphData>
    </xsl:result-document>
    
    <!-- This part of the XSLT generates people_graph_data.xml export, containing 
    processed data to be displayed in people_graph.xml -->
    <xsl:variable name="people_graph_items">
      <xsl:text>{nodes:[</xsl:text>
      <xsl:for-each select="$people/tei:person[not(child::tei:persName='XXX')][child::tei:idno!=''][child::tei:persName!='']">
        <xsl:text>{data: {id: "</xsl:text><xsl:value-of select="tei:idno[1]"/><xsl:text>", name: "</xsl:text>        
        <xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>", type: "people_only"}</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>], edges:[</xsl:text>
      <xsl:for-each select="$people/tei:person/tei:link[tokenize(concat(replace(@corresp, '#', ''), ' '), ' ')=$people/tei:person/tei:idno][@type='people'][not(starts-with(@corresp, ' '))][not(ends-with(@corresp, ' '))]">
        <xsl:variable name="id" select="parent::tei:*/tei:idno[1]"/>
        <xsl:variable name="relation_type"><xsl:choose>
          <xsl:when test="@subtype='' or @subtype='link'"><xsl:text> </xsl:text></xsl:when>
          <xsl:otherwise><xsl:value-of select="lower-case(translate(translate(replace(@subtype, '([a-z]{1})([A-Z]{1})', '$1_$2'), '/', '／'), '_', ' '))"/></xsl:otherwise>
        </xsl:choose></xsl:variable>
        <xsl:variable name="cert" select="@cert"/>
        <xsl:variable name="color">
          <xsl:choose>
            <xsl:when test="$thesaurus//tei:catDesc[@n=$relation_type][@key='family']">
              <xsl:text>red</xsl:text>
            </xsl:when>
            <xsl:when test="$thesaurus//tei:catDesc[@n=$relation_type][@key='personal']">
              <xsl:text>green</xsl:text>
            </xsl:when>
            <xsl:otherwise><xsl:text>blue</xsl:text></xsl:otherwise>
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
            <xsl:for-each select="tokenize(@corresp, ' ')[replace(., '#', '')=$people/tei:person/tei:idno]">
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
    
    <xsl:variable name="people_graph_labels">
      <xsl:text>[</xsl:text>
      <xsl:for-each select="$people/tei:person[not(child::tei:persName='XXX')][child::tei:persName!=''][child::tei:idno!='']">
        <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    
    <xsl:result-document href="{concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/people_graph_data.xml')}">
      <graphData>
        <items><xsl:copy-of select="$people_graph_items"/></items>
        <labels><xsl:copy-of select="$people_graph_labels"/></labels>
      </graphData>
    </xsl:result-document>
  </xsl:template>
</xsl:stylesheet>
