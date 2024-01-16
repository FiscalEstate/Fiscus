<script type="text/javascript">
/*Maps layers*/
            var dare = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
            minZoom: 4,
            maxZoom: 11,
            attribution: 'Map data &lt;a href="https://imperium.ahlfeldt.se/"&gt;Digital Atlas of the Roman Empire&lt;/a&gt; CC BY 4.0'
            });
            var terrain = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles and source Esri',
            maxZoom: 13
            });
            var watercolor = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.{ext}', {
            attribution: 'Map tiles &lt;a href="http://stamen.com"&gt;Stamen Design&lt;/a&gt;, &lt;a href="http://creativecommons.org/licenses/by/3.0"&gt;CC BY 3.0&lt;/a&gt;, Map data &lt;a href="https://www.openstreetmap.org/copyright"&gt;OpenStreetMap&lt;/a&gt;',
            subdomains: 'abcd',
            minZoom: 1,
            maxZoom: 16,
            ext: 'jpg'
            });
            var osm = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: 'Map data &lt;a href="https://www.openstreetmap.org/copyright"&gt;OpenStreetMap&lt;/a&gt;'
            });
            
            var baseMaps = {"DARE": dare, "Terrain": terrain, "Open Street Map": osm}; //, "Watercolor": watercolor
            var layers = [osm, terrain]; //, watercolor             

            let LeafIcon = L.Icon.extend({ options: {iconSize: [14, 14]} });
            let purpleIcon = new LeafIcon({iconUrl: '../../assets/images/purple.png'});
            let goldenIcon = new LeafIcon({iconUrl: '../../assets/images/golden.png'});
            let purpleUncertainIcon = new LeafIcon({iconUrl: '../../assets/images/purple_uncertain.png'});
            let goldenUncertainIcon = new LeafIcon({iconUrl: '../../assets/images/golden_uncertain.png'});
            
            function addPopup(feature, layer) {
                    let symbols = '';
                    if (feature.properties.symbols.includes('ports')) {
                    symbols += '&lt;img src="../../../assets/images/anchor.png" alt="anchor" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('fortifications')) {
                    symbols += '&lt;img src="../../../assets/images/tower.png" alt="tower" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('residences')) {
                    symbols += '&lt;img src="../../../assets/images/sella.png" alt="sella" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('revenues')) {
                    symbols += '&lt;img src="../../../assets/images/coin.png" alt="coin" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('estates')) {
                    symbols += '&lt;img src="../../../assets/images/star.png" alt="star" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('tenures')) {
                    symbols += '&lt;img src="../../../assets/images/square.png" alt="square" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('land')) {
                    symbols += '&lt;img src="../../../assets/images/triangle.png" alt="triangle" class="mapicon"/&gt;';
                    }
                    if (feature.properties.symbols.includes('fallow')) {
                    symbols += '&lt;img src="../../../assets/images/tree.png" alt="tree" class="mapicon"/&gt;';
                    }
                    if (feature.properties.certainty === 'low') {
                    symbols += '&lt;img src="../../../assets/images/uncertain.png" alt="uncertain" class="mapicon"/&gt;';
                    }
                    let popupContents = '&lt;a target="_blank" href="/en/places.html#' + feature.properties.id + '"&gt;' + feature.properties.name + '&lt;/a&gt; ' + symbols + ' &lt;span class="block"&gt;Linked documents: ' + feature.properties.mentioningDocsCount + '&lt;/span&gt;'
                    
                    layer.bindPopup(popupContents);
                    
            }
            
            function styleMarker(feature, latlng) {
                if (feature.geometry.type === 'Point') {
                   if (feature.properties.symbols.includes('fiscal') &amp;&amp; feature.properties.certainty !== 'low') {
                   return L.marker(latlng, {icon: goldenIcon});
                   } else if (feature.properties.symbols.includes('fiscal') &amp;&amp; feature.properties.certainty === 'low') {
                   return L.marker(latlng, {icon: goldenUncertainIcon});
                   } else if (!(feature.properties.symbols.includes('fiscal')) &amp;&amp; feature.properties.certainty !== 'low') {
                   return L.marker(latlng, {icon: purpleIcon});
                   } else if (!(feature.properties.symbols.includes('fiscal')) &amp;&amp; feature.properties.certainty === 'low') {
                   return L.marker(latlng, {icon: purpleUncertainIcon});
                   }
                }
            }
            
            function furtherStyling(feature) {
                if (feature.geometry.type === 'Polygon') {
                    return {color: "green", id:feature.properties.id};
                } else {
                    return {id:feature.properties.id};
                }
            }
            
            function addLayer(featuresArray) {
              return L.geoJSON(featuresArray, {onEachFeature: addPopup, pointToLayer: styleMarker, style: furtherStyling});
            }
            
            
            // mapData is defined in results-to-html.xsl and indices.xsl
            let points = mapData.filter(i => i.geometry.type === 'Point');
            let polygons = mapData.filter(i => i.geometry.type === 'Polygon');
            let lines = mapData.filter(i => i.geometry.type === 'LineString');
            let purple_places = points.filter(i => i.properties.symbols.includes('fiscal'));
            let golden_places = points.filter(i => !(i.properties.symbols.includes('fiscal')));
            let ports_places = points.filter(i => i.properties.symbols.includes('ports'));
            let fortifications_places = points.filter(i => i.properties.symbols.includes('fortifications'));
            let residences_places = points.filter(i => i.properties.symbols.includes('residences'));
            let revenues_places = points.filter(i => i.properties.symbols.includes('revenues'));
            let estates_places = points.filter(i => i.properties.symbols.includes('estates'));
            let tenures_places = points.filter(i => i.properties.symbols.includes('tenures'));
            let land_places = points.filter(i => i.properties.symbols.includes('land'));
            let fallow_places = points.filter(i => i.properties.symbols.includes('fallow'));
            let uncertain_places = points.filter(i => i.properties.certainty === 'low');
            let select_linked_places = [];
            
            var toggle_ports_places = addLayer(ports_places);
            var toggle_fortifications_places = addLayer(fortifications_places);
            var toggle_residences_places = addLayer(residences_places);
            var toggle_revenues_places = addLayer(revenues_places);
            var toggle_estates_places = addLayer(estates_places);
            var toggle_tenures_places = addLayer(tenures_places);
            var toggle_land_places = addLayer(land_places);
            var toggle_fallow_places = addLayer(fallow_places);
            var toggle_uncertain_places = addLayer(uncertain_places);
            var toggle_purple_places = addLayer(purple_places); 
            var toggle_golden_places = addLayer(golden_places);
            var toggle_polygons = addLayer(polygons);
            var toggle_lines = addLayer(lines);
            var toggle_select_linked_places = addLayer(select_linked_places);
            
            var overlayMaps = {
            "All places linked to fiscal properties": toggle_golden_places,
            "All places not linked to fiscal properties": toggle_purple_places,
            "Places not precisely located or wider areas": toggle_polygons,
            "Rivers": toggle_lines,
            "From uncertain tradition": toggle_uncertain_places,
            "Ports and fords": toggle_ports_places,
            "Fortifications": toggle_fortifications_places,
            "Residences": toggle_residences_places,
            "Markets, crafts and revenues": toggle_revenues_places,
            "Estates and estate units": toggle_estates_places,
            "Tenures": toggle_tenures_places,
            "Land plots and rural buildings": toggle_land_places,
            "Fallow land": toggle_fallow_places
            };
            
            function openPopupById(id){ 
                toggle_purple_places.eachLayer(function(feature){
                  if (feature.feature.properties.id === id){
                      feature.openPopup();
                  }
              });
              toggle_golden_places.eachLayer(function(feature){
                  if (feature.feature.properties.id === id){
                      feature.openPopup();
                  }
              });
            }
    
            function displayById(id){ 
                toggle_purple_places.eachLayer(function(feature){
                      if (feature.feature.properties.id === id){
                            toggle_select_linked_places.addLayer(feature); 
                      }
                  });
                  toggle_golden_places.eachLayer(function(feature){
                      if (feature.feature.properties.id === id){
                            toggle_select_linked_places.addLayer(feature); 
                      }
                  });
            }
</script>