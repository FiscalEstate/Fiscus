<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  
  <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->
  
  <xsl:output method="html"/>
  <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl" />
  
  <xsl:template match="tei:bibl">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="tei:listBibl[@type]">
    <div class="{@type}"><xsl:apply-templates/></div>
  </xsl:template>
  
  <xsl:template match="tei:anchor[@type='expand-collapse-button']">
    <button class="expander expand-about" onclick="$(this).prev().toggleClass('hidden'); $(this).text($(this).prev().hasClass('hidden') ? 'Expand' : 'Collapse');">Expand</button>
  </xsl:template>
  
  <xsl:template match="tei:addSpan[@xml:id='map']">
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
          <xsl:variable name="map_data" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/map_data.xml'))/mapData/text()"/>
          let mapData = [<xsl:value-of select="$map_data"/>];
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
  </xsl:template>
  
  <xsl:template match="tei:addSpan[@xml:id='relation_graph' or @xml:id='people_graph']"> 
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
            <xsl:if test="@xml:id='relation_graph'"><br/>- Se un gruppo di elementi (People, Juridical persons, Estates, Places) viene selezionato o deselezionato più volte consecutive il sistema si blocca e occorre ricaricare la pagina.</xsl:if>
          </p>
          <p><span class="autocomplete"><input type="text" id="inputSearch" placeholder="Search"/></span><button id="btnSearch" class="button">Show</button> <button id="reset" class="button">Reset</button> <button onclick="openFullscreen();" class="button">Fullscreen</button> <a class="button" href="#help">Help</a></p>
        </div>
        <div id="mygraph"></div>
        <div class="legend">
          <p>
            <xsl:choose>
              <xsl:when test="@xml:id='relation_graph'">
                <span class="people_label">People</span> <input type="checkbox" id="toggle_people" checked="true"/>
                <span class="jp_label">Juridical persons</span> <input type="checkbox" id="toggle_juridical_persons" checked="true"/>
                <span class="estates_label">Estates</span> <input type="checkbox" id="toggle_estates" checked="true"/>
                <span class="places_label">Places</span> <input type="checkbox" id="toggle_places" checked="true"/>
                <br/>
              </xsl:when>
              <xsl:when test="@xml:id='people_graph'">
                <span id="toggle_people"/><span id="toggle_juridical_persons"/><span id="toggle_estates"/><span id="toggle_places"/>
              </xsl:when>
            </xsl:choose>
            <span class="red_label">➔</span> Family relations <input type="checkbox" id="toggle_red" checked="true"/>
            <span class="green_label">➔</span> Interpersonal bonds <input type="checkbox" id="toggle_green" checked="true"/>
            <span class="blue_label">➔</span> Other interpersonal links <input type="checkbox" id="toggle_blue" checked="true"/>
            <xsl:choose>
              <xsl:when test="@xml:id='relation_graph'">
                <span class="orange_label">➔</span> Other links <input type="checkbox" id="toggle_orange" checked="true"/>
              </xsl:when>
              <xsl:when test="@xml:id='people_graph'">
                <span id="toggle_orange"/>
              </xsl:when>
            </xsl:choose>
            <span class="alleged_label">⤑</span> Alleged relations <input type="checkbox" id="toggle_alleged" checked="true"/>
            <span class="relations_label"> Relation types </span> <input type="checkbox" id="toggle_labels" checked="true"/>
          </p>
        </div>
        
        <script type="text/javascript">  
          <xsl:variable name="relation_graph_data" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/graph_data.xml'))/graphData"/>
          <xsl:variable name="people_graph_data" select="document(concat('file:',system-property('user.dir'), '/webapps/ROOT/content/exports/people_graph_data.xml'))/graphData"/>
          
          var graph_items = <xsl:choose>
            <xsl:when test="@xml:id='relation_graph'"><xsl:value-of select="$relation_graph_data/items/text()"/></xsl:when>
            <xsl:when test="@xml:id='people_graph'"><xsl:value-of select="$people_graph_data/items/text()"/></xsl:when>
          </xsl:choose>,
          graph_labels = <xsl:choose>
            <xsl:when test="@xml:id='relation_graph'"><xsl:value-of select="$relation_graph_data/labels/text()"/></xsl:when>
            <xsl:when test="@xml:id='people_graph'"><xsl:value-of select="$people_graph_data/labels/text()"/></xsl:when>
          </xsl:choose>,
          my_graph = "mygraph", box = "mygraph_box";
          <xsl:value-of select="fn:doc(concat('file:',system-property('user.dir'),'/webapps/ROOT//assets/scripts/networks.js'))"/>
        </script>
      </div>
  </xsl:template>
  
</xsl:stylesheet>