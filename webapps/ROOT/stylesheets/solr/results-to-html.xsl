<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:h="http://apache.org/cocoon/request/2.0"
                xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:tei="http://www.tei-c.org/ns/1.0">

  <!-- XSLT for displaying Solr results. -->
  
  <xsl:param name="root" select="/" />

  <xsl:include href="results-pagination.xsl" />

  <!-- Split the list of Solr facet fields that need to be looked up
       in RDF for its labels into a sequence for easier querying. -->
  <xsl:variable name="rdf-facet-lookup-fields-sequence"
                select="tokenize($rdf-facet-lookup-fields, ',')" />

  <!-- Display an unselected facet. -->
  <xsl:template match="int" mode="search-results">
    <xsl:variable name="name" select="../@name" />
    <xsl:variable name="value" select="@name" />
    <!-- List a facet only if it is not selected. -->
    <xsl:if test="not($request/h:parameter[@name=$name]/h:value = $value)">
      <li>
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="$query-string-at-start" />
            <xsl:text>&amp;</xsl:text>
            <xsl:value-of select="$name" />
            <xsl:text>=</xsl:text>
            <xsl:value-of select="kiln:escape-for-query-string($value)" />
          </xsl:attribute>
          <xsl:call-template name="display-facet-value">
            <xsl:with-param name="facet-field" select="$name" />
            <xsl:with-param name="facet-value" select="$value" />
          </xsl:call-template>
        </a>
        <xsl:call-template name="display-facet-count" />
      </li>
    </xsl:if>
  </xsl:template>

  <!-- Display unselected facets. -->
  <xsl:template match="lst[@name='facet_fields']" mode="search-results">
    <xsl:if test="lst/int">
      <h3>Facets</h3>
      <div class="section-container accordion"
           data-section="accordion">
        <xsl:apply-templates mode="search-results" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lst[@name='facet_fields']/lst"
                mode="search-results">
    <xsl:variable name="toggle_facet_items"><xsl:text>toggle_visibility('</xsl:text><xsl:value-of select="@name"/><xsl:text>');</xsl:text></xsl:variable>
    <section>
      <p class="title" data-section-title="">
        <a href="#">
          <xsl:attribute name="onclick"><xsl:value-of select="$toggle_facet_items"/></xsl:attribute>
          <xsl:apply-templates mode="search-results" select="@name" />
        </a>
      </p>
      <div class="content" data-section-content="">
        <xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
        <xsl:attribute name="style"><xsl:text>display:none;</xsl:text></xsl:attribute>
        <ul class="no-bullet">
          <xsl:apply-templates mode="search-results" />
        </ul>
      </div>
    </section>
  </xsl:template>

  <!-- Display a facet's name. -->
  <xsl:template match="lst[@name='facet_fields']/lst/@name"
                mode="search-results">
    <i18n:text key="facet-{.}">
      <xsl:for-each select="tokenize(., '_')">
        <xsl:value-of select="upper-case(substring(., 1, 1))" />
        <xsl:value-of select="substring(., 2)" />
        <xsl:if test="not(position() = last())">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </i18n:text>
  </xsl:template>

  <!-- Display an individual search result. -->
  <xsl:template match="result/doc" mode="search-results">
    <xsl:variable name="document-type" select="str[@name='document_type']" />
    <xsl:variable name="short-filepath"
                  select="substring-after(str[@name='file_path'], '/')" />
    <xsl:variable name="result-url">
      <xsl:choose>
        <xsl:when test="$document-type = 'tei'">
          <xsl:value-of select="kiln:url-for-match('local-tei-display-html', ($language, $short-filepath), 0)" />
        </xsl:when>
        <xsl:when test="$document-type = 'epidoc'">
          <xsl:value-of select="kiln:url-for-match('local-epidoc-display-html', ($language, $short-filepath), 0)" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    
    <tr style="height:3em">
      <td><a href="{$result-url}"><xsl:value-of select="substring-after(replace(str[@name='document_id'], ' ', ''), 'doc')" /></a></td>
      <td><xsl:value-of select="arr[@name='document_title']/str[1]" /></td>
      <td><xsl:value-of select="str[@name='document_date']"/>
      </td>
    </tr>
  </xsl:template>

  <!-- Display search results. -->
  <xsl:template match="response/result" mode="search-results">
    <xsl:variable name="results" select="."/>
    <!-- scrolling down button -->
    <button type="button" onclick="topFunction()" id="scroll" title="Go to top">⬆  </button>
    <script type="text/javascript">
      mybutton = document.getElementById("scroll");
      window.onscroll = function() {scrollFunction()};
      function scrollFunction() {
      if (document.body.scrollTop > 400 || document.documentElement.scrollTop > 400) { mybutton.style.display = "block"; }
      else { mybutton.style.display = "none"; }
      }
      function topFunction() {
      document.body.scrollTop = 0;
      document.documentElement.scrollTop = 0;
      }
    </script>
    <xsl:choose>
      <xsl:when test="number(@numFound) = 0">
        <h3>No results found</h3>
      </xsl:when>
      <xsl:when test="doc">
        <h3>Results</h3>
        
        <button class="expander expand-map-in-search" onclick="$(this).next().toggleClass('not-visible'); $(this).text($(this).next().hasClass('not-visible') ? 'Show results on map' : 'Hide map');">Show results on map</button>
        <div class="row map_box search_page not-visible">
          <div id="mapidsearch" class="map"></div>
          <div class="legend">
            <p>
              <img src="../../../assets/images/golden.png" alt="golden circle" class="mapicon"/>Places linked to fiscal properties
              <img src="../../../assets/images/purple.png" alt="purple circle" class="mapicon"/>Places not linked to fiscal properties
              <img src="../../../assets/images/polygon.png" alt="green polygon" class="mapicon"/>Places not precisely located or wider areas
              <img src="../../../assets/images/line.png" alt="blue line" class="mapicon"/> Rivers
              <img src="../../../assets/images/black.png" alt="black" class="mapicon" style="margin-right:0"/> <img src="../../../assets/images/uncertain.png" alt="uncertain" class="mapicon" style="margin-left:2px"/>From uncertain tradition <br/>
              <img src="../../../assets/images/anchor.png" alt="anchor" class="mapicon"/>Ports, fords
              <img src="../../../assets/images/tower.png" alt="tower" class="mapicon"/>Fortifications
              <img src="../../../assets/images/sella.png" alt="sella" class="mapicon"/>Residences
              <img src="../../../assets/images/coin.png" alt="coin" class="mapicon"/>Markets, crafts, revenues
              <img src="../../../assets/images/star.png" alt="star" class="mapicon"/>Estates, estate units
              <img src="../../../assets/images/square.png" alt="square" class="mapicon"/>Tenures
              <img src="../../../assets/images/triangle.png" alt="triangle" class="mapicon"/>Land plots, rural buildings
              <img src="../../../assets/images/tree.png" alt="tree" class="mapicon"/>Fallow land
            </p>
          </div>
        
          <xsl:variable name="map_data_raw" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/map_raw_data.xml'))/mapPlaces/mapPlace"/>
          
          <xsl:variable name="map_data">
          <xsl:for-each select="$map_data_raw">
            <xsl:variable name="item" select="."/>
            <xsl:variable name="linked_keys" select="linkedKeys/p[@doc=$results/doc/str[@name='document_id']]"/>
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
            
            <xsl:if test="number($number_of_mentioning_documents) gt 0">
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
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
          
        <script type="text/javascript">
          let mapData = [<xsl:value-of select="$map_data"/>];
          <xsl:value-of select="fn:doc(concat('file:',system-property('user.dir'),'/webapps/ROOT/assets/scripts/maps.js'))"/>
          let searchmap = L.map('mapidsearch', { center: [42, 12], zoom: 5.5, fullscreenControl: true, measureControl: true, layers: layers });
          L.control.layers(baseMaps, overlayMaps).addTo(searchmap);
          L.control.scale().addTo(searchmap);
          L.Control.geocoder().addTo(searchmap);
          toggle_purple_places.addTo(searchmap);
          toggle_golden_places.addTo(searchmap);
          toggle_polygons.addTo(searchmap);
          toggle_lines.addTo(searchmap);
        </script>
        </div>
        
        <table class="tablesorter" style="width:100%">
          <thead>
            <tr style="height:3em">
              <th>ID</th>
              <th>Title</th>
              <th style="width:13em">Date</th>
            </tr>
          </thead>
          <tbody>
          <xsl:apply-templates mode="search-results" select="doc">
            <xsl:sort>
              <xsl:variable name="id" select="substring-after(replace(str[@name='document_id'], ' ', ''), 'doc')"/>
              <xsl:variable name="sorted-id">
                <xsl:choose>
                  <xsl:when test="string-length($id) = 1"><xsl:value-of select="concat('000',$id)"/></xsl:when>
                  <xsl:when test="string-length($id) = 2"><xsl:value-of select="concat('00',$id)"/></xsl:when>
                  <xsl:when test="string-length($id) = 3"><xsl:value-of select="concat('0',$id)"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="$id"/></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="sort-date">
                <xsl:choose>
                  <xsl:when test="contains(str[@name='document_date'], ' –')"><xsl:value-of select="substring-before(str[@name='document_date'], ' –')" /></xsl:when>
                  <xsl:otherwise><xsl:value-of select="str[@name='document_date']" /></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="sorted-date">
                <xsl:choose>
                  <xsl:when test="not(contains($sort-date, '-'))"><xsl:value-of select="concat($sort-date, '-01-01')"/></xsl:when>
                  <xsl:when test="contains($sort-date, '-') and not(contains(substring-after($sort-date, '-'), '-'))"><xsl:value-of select="concat($sort-date, '-01')"/></xsl:when>
                  <xsl:when test="contains($sort-date, '-') and contains(substring-after($sort-date, '-'), '-')"><xsl:value-of select="$sort-date"/></xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:value-of select="$sorted-date"/>
            </xsl:sort>
          </xsl:apply-templates>
          </tbody>
        </table>

        <xsl:call-template name="add-results-pagination" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Display selected facets. -->
  <xsl:template match="*[@name='fq']" mode="search-results">
    <h3>Current filters</h3>

    <ul>
      <xsl:choose>
        <xsl:when test="local-name(.) = 'str'">
          <xsl:apply-templates mode="display-selected-facet" select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="str">
            <xsl:apply-templates mode="display-selected-facet" select="." />
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </ul>
  </xsl:template>

  <!-- Display selected facet. -->
  <xsl:template match="str" mode="display-selected-facet">
    <!-- ORed facets have names and values that are different from
         ANDed facets and must be handled differently. ORed facets
         have the exclusion tag at the beginning of the name, and may
         have multiple values within parentheses separated by " OR
         ". -->
    <xsl:choose>
      <xsl:when test="starts-with(., '{!tag')">
        <xsl:call-template name="display-selected-or-facet" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="display-selected-and-facet" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()" mode="search-results" />

  <xsl:template name="display-facet-count">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template name="display-facet-value">
    <xsl:param name="facet-field" />
    <xsl:param name="facet-value" />
    <xsl:choose>
      <xsl:when test="$facet-field = $rdf-facet-lookup-fields-sequence">
        <xsl:variable name="rdf-uri" select="concat($base-uri, $facet-value)" />
        <!-- QAZ: Uses only the first rdf:Description matching
             the $rdf-uri, due to the Sesame version not
             including the fix for
             https://github.com/eclipse/rdf4j/issues/742 (if an
             inferencing repository is used). -->
        <xsl:variable name="rdf-name" select="$root/aggregation/facet_names/rdf:RDF/rdf:Description[@rdf:about=$rdf-uri][1]/*[@xml:lang=$language][1]" />
        <xsl:choose>
          <xsl:when test="normalize-space($rdf-name)">
            <xsl:value-of select="$rdf-name" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$facet-value" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$facet-value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Display a selected facet. -->
  <xsl:template name="display-selected-facet">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:variable name="name-value-pair">
      <!-- Match the fq parameter as it appears in the query
           string. -->
      <xsl:value-of select="$name" />
      <xsl:text>=</xsl:text>
      <xsl:value-of select="kiln:escape-for-query-string($value)" />
    </xsl:variable>
    <li>
      <xsl:call-template name="display-facet-value">
        <xsl:with-param name="facet-field" select="$name" />
        <xsl:with-param name="facet-value" select="$value" />
      </xsl:call-template>
      <xsl:text> (</xsl:text>
      <!-- Create a link to unapply the facet. -->
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="kiln:string-replace($query-string-at-start,
                                $name-value-pair, '')" />
        </xsl:attribute>
        <xsl:text>x</xsl:text>
      </a>
      <xsl:text>)</xsl:text>
    </li>
  </xsl:template>

  <!-- Display a selected AND facet. -->
  <xsl:template name="display-selected-and-facet">
    <xsl:variable name="name" select="substring-before(., ':')" />
    <xsl:variable name="value"
                  select="replace(., '^[^:]+:&quot;(.*)&quot;$', '$1')" />
    <xsl:call-template name="display-selected-facet">
      <xsl:with-param name="name" select="$name" />
      <xsl:with-param name="value" select="$value" />
    </xsl:call-template>
  </xsl:template>

  <!-- Display a selected OR facet. -->
  <xsl:template name="display-selected-or-facet">
    <xsl:variable name="name"
                  select="substring-before(substring-after(., '}'), ':')" />
    <xsl:variable name="value" select="substring-before(substring-after(., ':('), ')')" />
    <xsl:for-each select="tokenize($value, ' OR ')">
      <xsl:call-template name="display-selected-facet">
        <xsl:with-param name="name" select="$name" />
        <!-- The facet value has surrounding quotes. -->
        <xsl:with-param name="value" select="substring(., 2, string-length(.)-2)" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="kiln:string-replace" as="xs:string">
    <!-- Replaces the first occurrence of $replaced in $input with
         $replacement. -->
    <xsl:param name="input" as="xs:string" />
    <xsl:param name="replaced" as="xs:string" />
    <xsl:param name="replacement" as="xs:string" />
    <xsl:sequence select="concat(substring-before($input, $replaced),
                          $replacement, substring-after($input, $replaced))" />
  </xsl:function>

</xsl:stylesheet>
