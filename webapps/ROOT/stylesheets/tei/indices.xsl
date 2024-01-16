<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- XSLT to convert index metadata and index Solr results into HTML. This is the common functionality
    for both TEI and EpiDoc indices. It should be imported by the specific XSLT for the document type
    (eg, indices-epidoc.xsl). -->

  <xsl:import href="to-html.xsl" />

  <xsl:template match="index_metadata" mode="title">
    <xsl:value-of select="tei:div/tei:head" />
  </xsl:template>

  <xsl:template match="index_metadata" mode="head">
    <xsl:apply-templates select="tei:div/tei:head/node()" />
  </xsl:template> 
  
  <xsl:template match="response/result">
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

    <!-- GRAPH -->
    <xsl:if test="doc/str[@name='index_people_graph_labels'] or doc/str[@name='index_graph_labels']">
      <div><p>Please note that the graph may take some time to load.</p></div>
      <div class="row graph_box" id="mygraph_box">
        <div class="legend">
          <p id="help"><a href="#">[CLOSE]</a>
            <br/><strong>Ricerca tramite Search</strong>
            <br/>- Digitare il nome nel campo Search, selezionarlo fra i risultati che compaiono nel menu a tendina e cliccare su "Show".
            <br/>- Per effettuare una nuova ricerca che non tenga conto delle ricerche precedenti, occorre prima cliccare su "Reset".
            <br/>- Per visualizzare assieme più elementi, occorre ripetere la procedura senza cliccare su "Reset" fra le ricerche, assicurandosi che l’elemento cercato in precedenza sia rimasto selezionato, cioè bordato di arancione (cosa che avviene in automatico se non si clicca sul grafico; in caso contrario è comunque possibile riselezionarlo cliccandovi sopra).

            <br/><br/><strong>Ricerca tramite selezione sul grafico</strong>
            <br/>- Cliccare su uno o più elementi nel grafico (tenendo premuto Shift se gli elementi sono più d’uno) e cliccare su "Show".
            <br/>- È possibile combinare la ricerca tramite Search con quella tramite selezione sul grafico: selezionare prima gli elementi sul grafico (assicurandosi che siano bordati di arancione) ed effettuare poi la ricerca tramite Search, cliccando infine su "Show".
            <br/>- Una volta effettuata una ricerca tramite Search e/o tramite selezione sul grafico, è possibile aggiungere progressivamente alla visualizzazione gli elementi collegati ad uno o più degli elementi visualizzati cliccando con il tasto destro del mouse (o con l’equivalente combinazione su un trackpad) sull’elemento in questione.

            <br/><br/><strong>Tips</strong>
            <br/>- Se al primo utilizzo la ricerca non funziona, occorre ricaricare la pagina e riprovare.
            <br/>- Se cliccando su "Show" non zooma subito sugli elementi cercati, occorre cliccare una seconda volta su "Show".
            <br/>- Dopo aver deselezionato uno o più tipi di relazioni (Family relations, Interpersonal bonds...) per nasconderle nel grafico, occorre posizionarsi con il puntatore (o cliccare) su un punto qualsiasi del grafico affinché queste vengano effettivamente nascoste.
            <xsl:if test="doc/str[@name='index_graph_labels']"><br/>- Se un gruppo di elementi (People, Juridical persons, Estates, Places) viene selezionato o deselezionato più volte consecutive il sistema si blocca e occorre ricaricare la pagina.</xsl:if>
          </p>
          <p><span class="autocomplete"><input type="text" id="inputSearch" placeholder="Search"/></span><button id="btnSearch" class="button">Show</button> <button id="reset" class="button">Reset</button> <button onclick="openFullscreen();" class="button">Fullscreen</button> <a class="button" href="#help">Help</a></p>
        </div>
        <div id="mygraph"></div>
        <div class="legend">
          <p>
            <xsl:choose>
              <xsl:when test="doc/str[@name='index_graph_labels']">
                <span class="people_label">People</span> <input type="checkbox" id="toggle_people" checked="true"/>
                <span class="jp_label">Juridical persons</span> <input type="checkbox" id="toggle_juridical_persons" checked="true"/>
                <span class="estates_label">Estates</span> <input type="checkbox" id="toggle_estates" checked="true"/>
                <span class="places_label">Places</span> <input type="checkbox" id="toggle_places" checked="true"/>
                <br/>
              </xsl:when>
              <xsl:when test="doc/str[@name='index_people_graph_labels']">
                <span id="toggle_people"/><span id="toggle_juridical_persons"/><span id="toggle_estates"/><span id="toggle_places"/>
              </xsl:when>
            </xsl:choose>
            <span class="red_label">➔</span> Family relations <input type="checkbox" id="toggle_red" checked="true"/>
            <span class="green_label">➔</span> Interpersonal bonds <input type="checkbox" id="toggle_green" checked="true"/>
            <span class="blue_label">➔</span> Other interpersonal links <input type="checkbox" id="toggle_blue" checked="true"/>
            <xsl:choose>
              <xsl:when test="doc/str[@name='index_graph_labels']">
                <span class="orange_label">➔</span> Other links <input type="checkbox" id="toggle_orange" checked="true"/>
              </xsl:when>
              <xsl:when test="doc/str[@name='index_people_graph_labels']">
                <span id="toggle_orange"/>
              </xsl:when>
            </xsl:choose>
            <span class="alleged_label">⤑</span> Alleged relations <input type="checkbox" id="toggle_alleged" checked="true"/>
            <span class="relations_label"> Relation types </span> <input type="checkbox" id="toggle_labels" checked="true"/>
          </p>
        </div>
        <script type="text/javascript">
          var graph_items = <xsl:choose>
            <xsl:when test="doc/str[@name='index_graph_labels']"><xsl:value-of select="doc/str[@name='index_graph_items']"/></xsl:when>
            <xsl:when test="doc/str[@name='index_people_graph_labels']"><xsl:value-of select="doc/str[@name='index_people_graph_items']"/></xsl:when>
          </xsl:choose>,
          graph_labels = <xsl:choose>
            <xsl:when test="doc/str[@name='index_graph_labels']"><xsl:value-of select="doc/str[@name='index_graph_labels']"/></xsl:when>
            <xsl:when test="doc/str[@name='index_people_graph_labels']"><xsl:value-of select="doc/str[@name='index_people_graph_labels']"/></xsl:when>
          </xsl:choose>,
          my_graph = "mygraph", box = "mygraph_box";
          <xsl:value-of select="fn:doc(concat('file:',system-property('user.dir'),'/webapps/ROOT//assets/scripts/networks.js'))"/>
        </script>
      </div>
  </xsl:if>

    <!-- MAP -->
    <xsl:if test="doc/str[@name='index_map_data']">
          <div class="row map_box">
          <div id="mapid" class="map"></div>
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
          <script type="text/javascript">
            let mapData = [<xsl:value-of select="doc/str[@name='index_map_data']"/>];
            <xsl:value-of select="fn:doc(concat('file:',system-property('user.dir'),'/webapps/ROOT/assets/scripts/maps.js'))"/>
            let mymap = L.map('mapid', { center: [44, 10.335], zoom: 6, fullscreenControl: true, measureControl: true, layers: layers });
            L.control.layers(baseMaps, overlayMaps).addTo(mymap);
            L.control.scale().addTo(mymap);
            L.Control.geocoder().addTo(mymap);
            
            var url = String(window.location.href);
            if (!url.includes('select')) {
            toggle_purple_places.addTo(mymap);
            toggle_golden_places.addTo(mymap);
            toggle_polygons.addTo(mymap);
            toggle_lines.addTo(mymap);
            }
              
            <!-- to display only places linked to a specific juridical person, whose IDs are in the URL -->
            if (url.includes('select')) { 
                  toggle_select_linked_places.addTo(mymap); 
              }
              url.substring(url.indexOf("select#") +1, url.lastIndexOf("#")).split("#").forEach(el => displayById(el));
              
            <!-- to open popup of specific place, whose ID is at the end of the URL -->
            if (url.includes('#') &amp;&amp; !url.includes('select')) {
                openPopupById(url.substring(url.lastIndexOf("#") +1));
             }
            </script>
        </div>
        </xsl:if>

    <!-- items counter -->
    <xsl:if test="doc/str[@name='index_total_items']">
    <div>
      <p>Total items: <xsl:value-of select="doc/str[@name='index_total_items']" /></p>
      <xsl:if test="doc[str[@name='index_thesaurus_hierarchy']]">
        <button type="button" class="expander toggle_all" onclick="$('.level2, .level3, .level4, .level5').removeClass('hidden'); $('.plus:not(.minus)').addClass('hidden'); $('.minus').removeClass('hidden');">Expand all</button><xsl:text> </xsl:text>
        <button type="button" class="expander toggle_all" onclick="$('.level2, .level3, .level4, .level5').addClass('hidden'); $('.plus:not(.minus)').removeClass('hidden'); $('.minus').addClass('hidden');">Collapse all</button><xsl:text> </xsl:text>
      </xsl:if>
      <button type="button" class="expander toggle_all" onclick="$('.expanded').removeClass('hidden'); $('.expander:not(.plus):not(.toggle_all)').text($('.expander:not(.plus):not(.toggle_all)').next().hasClass('hidden') ? 'Show' : 'Hide');">Show all linked items</button><xsl:text> </xsl:text>
      <button type="button" class="expander toggle_all" onclick="$('.expanded').addClass('hidden'); $('.expander:not(.plus):not(.toggle_all)').text($('.expander:not(.plus):not(.toggle_all)').next().hasClass('hidden') ? 'Show' : 'Hide');">Hide all linked items</button>
      
      <xsl:if test="doc[str[@name='index_item_name']][not(str[@name='index_thesaurus_hierarchy'])]">
        <a class="expander" href="#main">Go to main list</a>
        <xsl:if test="doc[str[@name='index_item_name'][starts-with(., '#')]]">
          <a class="expander" href="#normalized">Go to normalized names list</a>
        </xsl:if>
        <a class="expander" href="#not-normalized">Go to not normalized names list</a>
      </xsl:if>
    </div>
    </xsl:if>

    <!-- LISTS -->
    <xsl:if test="doc[str[@name='index_item_name']][not(str[@name='index_thesaurus_hierarchy'])]">
      <xsl:if test="doc[str[@name='index_coordinates']]">
      <div>
        <p id="disclaimer">The places listed below are mere geographic references; all the types of transactions or legal actions linked to them are referred to the keywords enumerated at the beginning of each entry.</p>
      </div>
      </xsl:if>
      <div id="main">
        <xsl:apply-templates select="doc[str[@name='index_item_name'][not(starts-with(., '~'))][not(starts-with(., '#'))]]">
          <xsl:sort select="lower-case(replace(replace(., 'italicsstart', ''), 'italicsend', ''))"/>
        </xsl:apply-templates>
    </div>
    </xsl:if>
    <xsl:if test="doc[str[@name='index_item_name'][starts-with(., '#')]]">
      <h3 id="normalized" class="sublist_heading">Personal names normalized forms
        <xsl:text> </xsl:text><button type="button" class="expander" onclick="$(this).parent().next().toggleClass('hidden'); $(this).text($(this).parent().next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
      </h3>
      <div class="normalized hidden">
            <xsl:apply-templates select="doc[str[@name='index_item_name'][starts-with(., '#')]]">
              <xsl:sort select="lower-case(replace(replace(., 'italicsstart', ''), 'italicsend', ''))"/>
            </xsl:apply-templates>
        </div>
    </xsl:if>
    <xsl:if test="doc[str[@name='index_item_name'][starts-with(., '~')]]">
      <h3 id="not-normalized" class="sublist_heading">Items that have not been normalized
        <xsl:text> </xsl:text><button type="button" class="expander" onclick="$(this).parent().next().toggleClass('hidden'); $(this).text($(this).parent().next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
      </h3>
      <div class="not-normalized hidden">
            <xsl:apply-templates select="doc[str[@name='index_item_name'][starts-with(., '~')]]">
              <xsl:sort select="lower-case(replace(replace(., 'italicsstart', ''), 'italicsend', ''))"/>
            </xsl:apply-templates>
      </div>
    </xsl:if>
    
    <!-- THESAURUS HIERARCHICAL LIST  -->
    <xsl:if test="doc[str[@name='index_thesaurus_hierarchy']]">
      <div id="thesaurus_hierarchy">
        <xsl:apply-templates select="doc[str[@name='index_thesaurus_hierarchy']]">
          <xsl:sort select="lower-case(str[@name='index_thesaurus_hierarchy'])"/> <!-- or index_item_name -->
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- ITEMS IN THESAURUS HIERARCHICAL LIST  -->
  <xsl:template match="result/doc[str[@name='index_thesaurus_hierarchy']]">
    <xsl:variable name="hidden"><xsl:if test="str[@name='index_thesaurus_level']!='level1'"><xsl:text>hidden</xsl:text></xsl:if></xsl:variable>
    <div id="{translate(replace(str[@name='index_item_name'], ' / ', '/'), ' ', '_')}" class="keywords_list {str[@name='index_thesaurus_level']} {$hidden}">
      <xsl:choose>
        <xsl:when test="str[@name='index_thesaurus_level']='level1' and str[@name='index_thesaurus_descendants']='yes'">
          <button type="button" class="expander plus" onclick="$(this).parent().nextUntil('.level1', '.level2').removeClass('hidden'); $(this).toggleClass('hidden'); $(this).next().removeClass('hidden');">+</button><xsl:text> </xsl:text>
          <button type="button" class="expander plus minus hidden" onclick="$(this).parent().nextUntil('.level1', '.level2, .level3, .level4, .level5').addClass('hidden'); $(this).addClass('hidden'); $(this).prev().removeClass('hidden'); $(this).parent().nextUntil('.level1', '.level2, .level3, .level4, .level5').children('.minus').addClass('hidden'); $(this).parent().nextUntil('.level1', '.level2, .level3, .level4, .level5').children('.plus:not(.minus)').removeClass('hidden');">–</button><xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="str[@name='index_thesaurus_level']='level2' and str[@name='index_thesaurus_descendants']='yes'">
          <button type="button" class="expander plus" onclick="$(this).parent().nextUntil('.level2, level.1', '.level3').removeClass('hidden'); $(this).addClass('hidden'); $(this).next().removeClass('hidden');">+</button><xsl:text> </xsl:text>
          <button type="button" class="expander plus minus hidden" onclick="$(this).parent().nextUntil('.level2, .level1', '.level3, .level4, .level5').addClass('hidden'); $(this).addClass('hidden'); $(this).prev().removeClass('hidden'); $(this).parent().nextUntil('.level2, .level1', '.level3, .level4, .level5').children('.minus').addClass('hidden'); $(this).parent().nextUntil('.level2, .level1', '.level3, .level4, .level5').children('.plus:not(.minus)').removeClass('hidden');">–</button><xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="str[@name='index_thesaurus_level']='level3' and str[@name='index_thesaurus_descendants']='yes'">
          <button type="button" class="expander plus" onclick="$(this).parent().nextUntil('.level3, .level2, .level1', '.level4').removeClass('hidden'); $(this).addClass('hidden'); $(this).next().removeClass('hidden');">+</button><xsl:text> </xsl:text>
          <button type="button" class="expander plus minus hidden" onclick="$(this).parent().nextUntil('.level3, .level2, .level1', '.level4, .level5').addClass('hidden'); $(this).addClass('hidden'); $(this).prev().removeClass('hidden'); $(this).parent().nextUntil('.level3, .level2, .level1', '.level4, .level5').children('.minus').addClass('hidden'); $(this).parent().nextUntil('.level3, .level2, .level1', '.level4, .level5').children('.plus:not(.minus)').removeClass('hidden');">–</button><xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="str[@name='index_thesaurus_level']='level4' and str[@name='index_thesaurus_descendants']='yes'">
          <button type="button" class="expander plus" onclick="$(this).parent().nextUntil('.level4, .level3, .level2, .level1', '.level5').removeClass('hidden'); $(this).addClass('hidden'); $(this).next().removeClass('hidden');">+</button><xsl:text> </xsl:text>
          <button type="button" class="expander plus minus hidden" onclick="$(this).parent().nextUntil('.level4, .level3, .level2, .level1', '.level5').addClass('hidden'); $(this).addClass('hidden'); $(this).prev().removeClass('hidden');">–</button><xsl:text> </xsl:text>
        </xsl:when>
      </xsl:choose>
      <h3 class="index_item_name inline"><a target="_blank" href="{str[@name='index_external_resource']}"><xsl:value-of select="str[@name='index_item_name']" /></a></h3>
        <xsl:if test="arr[@name='index_instance_location']">
          <xsl:text> </xsl:text><button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
          <div class="expanded hidden linked_elements">
            <h4 class="inline"><xsl:text>Linked documents by date (</xsl:text><xsl:value-of select="count(arr[@name='index_instance_location']/str)"/> total occurrences<xsl:text>):</xsl:text></h4>
            <ul>
              <xsl:apply-templates select="arr[@name='index_instance_location']/str">
                <xsl:sort><xsl:value-of select="substring-before(substring-after(substring-after(., '#doc'), '#'), '#')"/></xsl:sort>
              </xsl:apply-templates>
            </ul>
      </div>
        </xsl:if>
        
    </div>
  </xsl:template>

  <!-- ITEMS IN LISTS -->
  <!-- items in lists structure -->
  <xsl:template match="result/doc[str[@name='index_item_name']][not(str[@name='index_thesaurus_hierarchy'])]">
    <div id="{substring-after(str[@name='index_item_number'], '/')}" class="index_item">
      <div>
      <xsl:apply-templates select="str[@name='index_item_name']" />
      <xsl:apply-templates select="str[@name='index_other_names']" />
      <xsl:apply-templates select="str[@name='index_item_number']" />
      <xsl:apply-templates select="str[@name='index_coordinates']" />
      <xsl:apply-templates select="str[@name='index_notes']" />
      <xsl:apply-templates select="str[@name='index_external_resource']" />
      <xsl:apply-templates select="str[@name='index_linked_keywords']" />
      </div>
      <xsl:apply-templates select="str[@name='index_linked_estates']" />
      <xsl:apply-templates select="str[@name='index_linked_juridical_persons']" />
      <xsl:apply-templates select="str[@name='index_linked_people']" />
      <xsl:apply-templates select="str[@name='index_linked_places']" />
      <xsl:apply-templates select="arr[@name='index_instance_location']" />
    </div>
  </xsl:template>

  <!-- item name -->
  <xsl:template match="str[@name='index_item_name']">
    <h3 class="index_item_name">
      <xsl:analyze-string select="replace(replace(normalize-space(.), '~ ', ''), '# ', '')" regex="italicsstart(.*?)italicsend">
        <xsl:matching-substring><i><xsl:value-of select="regex-group(1)"/></i></xsl:matching-substring>
      <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
    </xsl:analyze-string>
    </h3>
  </xsl:template>

  <!-- item other names -->
  <xsl:template match="str[@name='index_other_names']">
    <p><strong>Also known as: </strong>
      <xsl:analyze-string select="normalize-space(.)" regex="italicsstart(.*?)italicsend">
        <xsl:matching-substring><i><xsl:value-of select="regex-group(1)"/></i></xsl:matching-substring>
        <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
      </xsl:analyze-string>
    </p>
  </xsl:template>

  <!-- item number -->
  <xsl:template match="str[@name='index_item_number']">
    <p><strong>Item number: </strong><xsl:value-of select="."/></p>
  </xsl:template>

  <!-- item coordinates -->
  <xsl:template match="str[@name='index_coordinates']">
    <p><strong>Coordinates (Lat, Long): </strong>
      <a target="_blank" href="{concat('map.html#',substring-after(parent::doc/str[@name='index_item_number'], 'places/'))}" class="open_link"><xsl:text>See on map</xsl:text></a>
      <xsl:text> </xsl:text><xsl:value-of select="."/></p>
  </xsl:template>

  <!-- item notes, handling also included URIs -->
  <xsl:template match="str[@name='index_notes']">
    <p><strong>Commentary/Bibliography: </strong>
      <xsl:analyze-string select="normalize-space(.)" regex="italicsstart(.*?)italicsend">
        <xsl:matching-substring><i>
          <xsl:analyze-string select="regex-group(1)" regex="(http:|https:)(\S+?)(\.|\)|\]|;|,|\?|!|:)?(\s|$)">
            <xsl:matching-substring>
              <a target="_blank" href="{concat(regex-group(1),regex-group(2))}"><xsl:value-of select="concat(regex-group(1),regex-group(2))"/></a>
              <xsl:value-of select="concat(regex-group(3),regex-group(4))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
          </xsl:analyze-string>
        </i></xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:analyze-string select="." regex="(http:|https:)(\S+?)(\.|\)|\]|;|,|\?|!|:)?(\s|$)">
            <xsl:matching-substring>
              <a target="_blank" href="{concat(regex-group(1),regex-group(2))}"><xsl:value-of select="concat(regex-group(1),regex-group(2))"/></a>
              <xsl:value-of select="concat(regex-group(3),regex-group(4))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </p>
  </xsl:template>

  <!-- item links to external resources -->
  <xsl:template match="str[@name='index_external_resource']">
    <p><strong>Item number: </strong><a target="_blank" href="{.}"><xsl:value-of select="substring-after(., 'concept/')"/></a></p>
  </xsl:template>

  <!-- item linked keywords -->
  <xsl:template match="str[@name='index_linked_keywords']">
    <p><strong>Linked keywords: </strong><xsl:value-of select="."/></p>
  </xsl:template>

  <!-- item list of linked estates -->
  <xsl:template match="str[@name='index_linked_estates']">
    <xsl:variable name="item" select="tokenize(., '£')"/>
    <div class="linked_elements">
    <h4 class="inline"><xsl:text>Linked estates:</xsl:text></h4>
    <xsl:text> </xsl:text>
      <button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
    <ul class="expanded hidden">
      <xsl:for-each select="$item">
        <xsl:sort select="substring-after(replace(replace(., 'italicsstart', ''), 'italicsend', ''), '#')"/>
        <li>
          <a target="_blank" href="{concat('estates.html#', substring-before(., '#'))}">
            <xsl:analyze-string select="substring-before(substring-after(normalize-space(.), '#'), '@')" regex="italicsstart(.*?)italicsend">
              <xsl:matching-substring><i><xsl:value-of select="regex-group(1)"/></i></xsl:matching-substring>
              <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
            </xsl:analyze-string>
          <span class="link_type"><xsl:value-of select="substring-after(., '@')"/></span>
          </a>
        </li>
      </xsl:for-each>
    </ul>
    </div>
  </xsl:template>

  <!-- item list of linked juridical persons -->
  <xsl:template match="str[@name='index_linked_juridical_persons']">
    <xsl:variable name="item" select="tokenize(., '£')"/>
    <div class="linked_elements">
      <h4 class="inline"><xsl:text>Linked juridical persons:</xsl:text></h4>
    <xsl:text> </xsl:text>
      <button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
    <ul class="expanded hidden">
      <xsl:for-each select="$item">
        <xsl:sort select="substring-after(replace(replace(., 'italicsstart', ''), 'italicsend', ''), '#')"/>
        <li>
          <a target="_blank" href="{concat('juridical_persons.html#', substring-before(., '#'))}">
            <xsl:analyze-string select="substring-before(substring-after(normalize-space(.), '#'), '@')" regex="italicsstart(.*?)italicsend">
              <xsl:matching-substring><i><xsl:value-of select="regex-group(1)"/></i></xsl:matching-substring>
              <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
            </xsl:analyze-string>
            <span class="link_type"><xsl:value-of select="substring-after(., '@')"/></span>
          </a>
        </li>
      </xsl:for-each>
    </ul>
    </div>
  </xsl:template>

  <!-- item list of linked people -->
  <xsl:template match="str[@name='index_linked_people']">
    <xsl:variable name="item" select="tokenize(., '£')"/>
    <div class="linked_elements">
      <h4 class="inline"><xsl:text>Linked people:</xsl:text></h4>
    <xsl:text> </xsl:text>
      <button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
    <ul class="expanded hidden">
      <xsl:for-each select="$item">
        <xsl:sort select="substring-after(replace(replace(., 'italicsstart', ''), 'italicsend', ''), '#')"/>
        <li>
          <a target="_blank" href="{concat('people.html#', substring-before(., '#'))}">
            <xsl:analyze-string select="substring-before(substring-after(normalize-space(.), '#'), '@')" regex="italicsstart(.*?)italicsend">
              <xsl:matching-substring><i><xsl:value-of select="regex-group(1)"/></i></xsl:matching-substring>
              <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
            </xsl:analyze-string>
            <span class="link_type"><xsl:value-of select="substring-after(., '@')"/></span>
          </a>
        </li>
      </xsl:for-each>
    </ul>
    </div>
  </xsl:template>

  <!-- item list of linked places -->
  <xsl:template match="str[@name='index_linked_places']">
    <xsl:variable name="item" select="tokenize(substring-after(., '~'), '£')"/>
    <div class="linked_elements">
      <h4 class="inline"><xsl:text>Linked places: </xsl:text></h4>
      <xsl:if test="contains(., '€coord')">
      <a target="_blank" href="{concat('map.html#', substring-before(substring-after(., 'map.html#'), '~'))}" class="open_link">See on map</a>
      </xsl:if>
      <xsl:text> </xsl:text>
      <button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
    <ul class="expanded hidden">
      <xsl:for-each select="$item">
        <xsl:sort select="substring-after(replace(replace(., 'italicsstart', ''), 'italicsend', ''), '#')"/>
        <li>
          <a target="_blank" href="{concat('places.html#', substring-before(., '#'))}">
            <xsl:analyze-string select="substring-before(substring-after(normalize-space(.), '#'), '@')" regex="italicsstart(.*?)italicsend">
              <xsl:matching-substring><i><xsl:value-of select="regex-group(1)"/></i></xsl:matching-substring>
              <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
            </xsl:analyze-string>
            <span class="link_type"><xsl:value-of select="substring-before(substring-after(., '@'), '€')"/></span>
          </a>
        </li>
      </xsl:for-each>
    </ul>
    </div>
  </xsl:template>

  <!-- item list of linked documents -->
  <xsl:template match="arr[@name='index_instance_location']">
    <div class="linked_elements">
      <h4 class="inline"><xsl:text>Linked documents by date (</xsl:text><xsl:value-of select="count(str)"/><xsl:text> total occurrences):</xsl:text></h4>
    <xsl:text> </xsl:text>
      <button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
    <ul class="expanded hidden">
        <xsl:apply-templates select="str">
          <xsl:sort><xsl:value-of select="substring-before(substring-after(substring-after(., '#doc'), '#'), '#')"/></xsl:sort>
        </xsl:apply-templates>
    </ul>
    </div>
  </xsl:template>
  <!-- item single linked documents; template called from indices-epidoc.xsl -->
  <xsl:template match="arr[@name='index_instance_location']/str">
    <xsl:call-template name="render-instance-location" />
  </xsl:template>

</xsl:stylesheet>
