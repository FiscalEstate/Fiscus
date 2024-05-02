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
    
    <!-- items counter -->
    <xsl:if test="doc/str[@name='index_total_items']">
    <div>  
      <p>Total items: <xsl:value-of select="doc/str[@name='index_total_items']" /></p>
    </div>
    </xsl:if>

    <!-- LISTS -->
    <xsl:if test="doc[str[@name='index_item_name']][not(str[@name='index_thesaurus_hierarchy'])]">
      <!-- intro texts -->
      <div id="intro-text">
        <xsl:choose>
          <xsl:when test="doc[str[@name='index_item_number' and starts-with(., 'places')]]">
          <p>The places listed below are mere geographic references, which have been employed in order to locate on the map the second-level records and the keywords. All the types of transactions or legal actions linked to them are referred to the keywords enumerated at the beginning of each entry. One will find two different lists in this section: 1) the list containing all the places which correspond to an individual item (expressed as places/<i>number</i>); this item has been marked up in at least one document; 2) the list of all the places whose names have not been standardised, and which do not correspond to an individual item. Please note that it may be necessary to zoom in on the map in order to see more clearly the place that one intends to visualise. Please click on ‘Show all Linked Items’ in order to display all the links between the items of this section and the second-level records that have been created. Please note that by clicking on the ‘See on Map’ button you will display all the places linked to the item you have selected.</p>
        </xsl:when>
          <xsl:when test="doc[str[@name='index_item_number' and starts-with(., 'juridical_persons')]]">
            <p>This section includes religious and ecclesiastical institutions, as well as political collective bodies (urban communes in particular). One will find two different lists in this section: 1) the list containing all the juridical persons which correspond to an individual item (expressed as juridical_persons/<i>number</i>); this item has been marked up in at least one document; 2) the list of all the juridical persons whose names have not been standardised, and which do not correspond to an individual item. Please click on ‘Show all Linked Items’ in order to display all the links between the items of this section and the second-level records that have been created. Please note that by clicking on the ‘See on Map’ button you will display all the places linked to the item you have selected.</p>
          </xsl:when>
          <xsl:when test="doc[str[@name='index_item_number' and starts-with(., 'estates')]]">
            <p>This section lists the landed estates and the jurisdictional ambits within which fiscal lands and/or the exertion of public rights are recorded. One will find two different lists in this section: 1) the list containing all the estates which correspond to an individual item (expressed as estates/<i>number</i>); this item has been marked up in at least one document; 2) the list of all the estates whose names have not been standardised, and which do not correspond to an individual item. Please click on ‘Show all Linked Items’ in order to display all the links between the items of this section and the second-level records that have been created. Please note that by clicking on the ‘See on Map’ button you will display all the places linked to the item you have selected.</p>
          </xsl:when>
          <xsl:when test="doc[str[@name='index_item_number' and starts-with(., 'people')]]">
            <p>People’s names have been standardised according to the critical edition of the so-called <i>Liber vitae</i> from the abbey of S. Salvatore/S. Giulia di Brescia (Brescia, Biblioteca Civica Queriniana, G. VI. 7), which was redacted after the middle of the ninth century and updated until the fourteenth century with a high number of names (including lists of oblates and obituaries). The years following each person’s name can indicate birth-death dates, period(s) in office, or attestation(s). One will find three different lists in this section: 1) the list containing all the names which have been standardised, and which correspond to an individual item (expressed as people/<i>number</i>); this item has been marked up in at least one document; 2) the list of all the names that have been standardised, but do not correspond to an individual item; 3) the list of the names that have not been standardised, and do not correspond to an individual item. Please click on ‘Show all Linked Items’ in order to display all the links between the items of this section and the second-level records that have been created. Please note that by clicking on the ‘See on Map’ button you will display all the places linked to the item you have selected.</p>
          </xsl:when>
      </xsl:choose>
      </div>
      
      <!-- buttons -->
      <div id="buttons">
          <button type="button" class="expander toggle_all" onclick="$('.expanded').removeClass('hidden'); $('.expander:not(.plus):not(.toggle_all)').text($('.expander:not(.plus):not(.toggle_all)').next().hasClass('hidden') ? 'Show' : 'Hide');">Show all linked items</button><xsl:text> </xsl:text>
          <button type="button" class="expander toggle_all" onclick="$('.expanded').addClass('hidden'); $('.expander:not(.plus):not(.toggle_all)').text($('.expander:not(.plus):not(.toggle_all)').next().hasClass('hidden') ? 'Show' : 'Hide');">Hide all linked items</button>
        <a class="go-to-list" href="#main">Go to main list</a>
        <xsl:if test="doc[str[@name='index_item_name'][starts-with(., '#')]]">
          <a class="go-to-list" href="#normalized">Go to the list of standardised names</a>
        </xsl:if>
        <a class="go-to-list" href="#not-normalized">Go to the list of unstandardised names</a>
      </div>
      
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
        <!-- intro - keywords --> 
      <div id="intro-text">
          <p>The semantic markup makes it possible to frame the data that can be extracted from a primary source by resorting to a controlled vocabulary, in which specific words, expressions and concepts are lemmatised and placed in a hierarchical relationship.</p>
          <p>We abide by the definition of controlled vocabulary as it has been formulated in the ERC project <i>Patrimonium. Geography and Economy of the Imperial Properties in the Roman World</i> (<a href="https://patrimonium.huma-num.fr/" target="_blank">https://patrimonium.huma-num.fr/</a>), available in the thesaurus manager of AusoHNum (<a href="https://ausohnum.huma-num.fr/" target="_blank">https://ausohnum.huma-num.fr/</a>). Its framework, based on the division into eight main sections, was left unchanged. However, some changes were needed because of the chronological shift that <i>FISCUS</i> required.</p>
          <p>The changes were mainly directed towards the core of the project – that is, the keywords grouped in the subsection ‘Fiscal Property’, placed in turn under the category ‘Economy’. Whenever a place has been marked at least once as a ‘Fiscal Property’, the point on the Map is displayed as a golden one (it is violet, instead, when the keyword ‘Fiscal Property’ has not been selected). The category ‘Textual Occurrence’ is intended to specify whether one fiscal estate appears as a marginal element in the document – e.g. when it is mentioned in the list of land borders or as a topical date – or whether it constitutes the main object of a legal transaction. The category ‘Function’ refers to the management forms of the fiscal estates, and to the uses that owners and beneficiaries could make of them. The categories ‘Inflow’ and ‘Outflow’ describe synthetically the dynamics of the fiscal redistribution circuit (on which. cf. Bougard, F., and V. Loré, eds, <i>Biens publics, biens du roi. Les bases économiques des pouvoirs royaux dans le haut Moyen Âge / Beni pubblici, beni del re. Le basi economiche dei poteri regi nell’alto Medioevo</i>. Turnhout: Brepols, 2019).</p>
      </div>
      
      <!-- buttons -->
      <div id="buttons">
        <button type="button" class="expander toggle_all" onclick="$('.level2, .level3, .level4, .level5').removeClass('hidden'); $('.plus:not(.minus)').addClass('hidden'); $('.minus').removeClass('hidden');">Expand all</button><xsl:text> </xsl:text>
      <button type="button" class="expander toggle_all" onclick="$('.level2, .level3, .level4, .level5').addClass('hidden'); $('.plus:not(.minus)').removeClass('hidden'); $('.minus').addClass('hidden');">Collapse all</button><xsl:text> </xsl:text>
      </div>
      
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
      <h3 class="index_item_name inline">
        <!--<a target="_blank" href="{str[@name='index_external_resource']}">-->
          <xsl:value-of select="str[@name='index_item_name']" />
        <!--</a>-->
      </h3>
        <!--<xsl:if test="arr[@name='index_instance_location']">
          <xsl:text> </xsl:text><button type="button" class="expander" onclick="$(this).next().toggleClass('hidden'); $(this).text($(this).next().hasClass('hidden') ? 'Show' : 'Hide');">Show</button>
          <div class="expanded hidden linked_elements">
            <h4 class="inline"><xsl:text>Linked documents by date (total occurrences: </xsl:text><xsl:value-of select="count(arr[@name='index_instance_location']/str)"/><xsl:text>)</xsl:text></h4>
            <ul>
              <xsl:apply-templates select="arr[@name='index_instance_location']/str">
                <xsl:sort><xsl:value-of select="substring-before(substring-after(substring-after(., '#doc'), '#'), '#')"/></xsl:sort>
              </xsl:apply-templates>
            </ul>
      </div>
        </xsl:if>-->
        
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
      <a target="_blank" href="{concat('resources/map.html#',substring-after(parent::doc/str[@name='index_item_number'], 'places/'))}" class="open_link"><xsl:text>See on map</xsl:text></a>
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
    <h4 class="inline"><xsl:text>Linked estates</xsl:text></h4>
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
      <h4 class="inline"><xsl:text>Linked juridical persons</xsl:text></h4>
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
      <h4 class="inline"><xsl:text>Linked people</xsl:text></h4>
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
      <h4 class="inline"><xsl:text>Linked places</xsl:text></h4>
      <xsl:if test="contains(., '€coord')">
        <a target="_blank" href="{concat('resources/map.html#', substring-before(substring-after(., 'map.html#'), '~'))}" class="open_link">See on map</a>
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
      <h4 class="inline"><xsl:text>Linked documents by date (total occurrences: </xsl:text><xsl:value-of select="count(str)"/><xsl:text>)</xsl:text></h4>
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
