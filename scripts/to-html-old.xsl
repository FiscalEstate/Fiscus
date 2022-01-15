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
  
  <!-- recurring paths & lists -->
  <xsl:variable name="resources"><xsl:value-of select="concat('file:',system-property('user.dir'),'/webapps/ROOT/content/fiscus_framework/resources/')"/></xsl:variable>
  <xsl:variable name="epidoc"><xsl:value-of select="concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/epidoc/')"/></xsl:variable>
  <xsl:variable name="places" select="document(concat($resources, 'places.xml'))//tei:listPlace[not(ancestor::tei:listPlace)]"/>
  <xsl:variable name="juridical_persons" select="document(concat($resources, 'juridical_persons.xml'))//tei:listOrg[not(ancestor::tei:listOrg)]"/>
  <xsl:variable name="estates" select="document(concat($resources, 'estates.xml'))//tei:listPlace[not(ancestor::tei:listPlace)]"/>
  <xsl:variable name="people" select="document(concat($resources, 'people.xml'))//tei:listPerson[not(ancestor::tei:listPerson)]"/>
  <xsl:variable name="thesaurus" select="document(concat($resources, 'thesaurus.xml'))//tei:taxonomy"/>
  <xsl:variable name="all_items" select="document(concat($resources, 'places.xml'))//tei:listPlace[not(ancestor::tei:listPlace)]|document(concat($resources, 'juridical_persons.xml'))//tei:listOrg[not(ancestor::tei:listOrg)]| document(concat($resources, 'estates.xml'))//tei:listPlace[not(ancestor::tei:listPlace)]|document(concat($resources, 'people.xml'))//tei:listPerson[not(ancestor::tei:listPerson)]"/>
  
  <!-- import @key values from markup in documents -->
  <xsl:variable name="texts" select="collection(concat($epidoc, '?select=*.xml;recurse=yes'))//tei:div[@type='edition']"/>
  
  <xsl:variable name="keys">
    <xsl:for-each select="$texts">
        <xsl:for-each select=".//tei:placeName[@key!=''][@ref]">
          <p class="place_keys"><xsl:attribute name="id"><xsl:value-of select="substring-after(@ref, 'places/')"/></xsl:attribute><xsl:value-of select="translate(@key, '#', '')"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></p>
        </xsl:for-each>
        <xsl:for-each select=".//tei:geogName[@key!=''][@ref]">
          <p class="estate_keys"><xsl:attribute name="id"><xsl:value-of select="substring-after(@ref, 'estates/')"/></xsl:attribute><xsl:value-of select="translate(@key, '#', '')"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></p>
        </xsl:for-each>
        <xsl:for-each select=".//tei:persName[@key!=''][@ref]">
          <p class="person_keys"><xsl:attribute name="id"><xsl:value-of select="substring-after(@ref, 'people/')"/></xsl:attribute><xsl:value-of select="translate(@key, '#', '')"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></p>
        </xsl:for-each>
        <xsl:for-each select=".//tei:orgName[@key!=''][@ref]">
          <p class="jp_keys"><xsl:attribute name="id"><xsl:value-of select="substring-after(@ref, 'juridical_persons/')"/></xsl:attribute><xsl:value-of select="translate(@key, '#', '')"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></p>
        </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- identifying places from uncertain tradition -->
  <xsl:variable name="uncertain_places">
    <xsl:for-each select="$texts">
      <xsl:for-each select=".//tei:placeName[matches(lower-case(@key), '.*(uncertain_tradition).*')][@ref]">
        <xsl:text> </xsl:text><xsl:value-of select="substring-after(@ref, 'places/')"/><xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="certain_places">
    <xsl:for-each select="$texts">
      <xsl:for-each select=".//tei:placeName[not(matches(lower-case(@key), '.*(uncertain_tradition).*'))][@ref]">
        <xsl:text> </xsl:text><xsl:value-of select="substring-after(@ref, 'places/')"/><xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- import lists -->
  <xsl:template match="//tei:p[@n='import']">
    <div class="imported_list">
      <button onclick="topFunction()" id="scroll" title="Go to top">⬆  </button> 
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
      <xsl:if test="ancestor::tei:TEI[@xml:id='places']"><xsl:apply-templates select="$places"/></xsl:if>
      <xsl:if test="ancestor::tei:TEI[@xml:id='juridical_persons']"><xsl:apply-templates select="$juridical_persons"/></xsl:if>
      <xsl:if test="ancestor::tei:TEI[@xml:id='estates']"><xsl:apply-templates select="$estates"/></xsl:if>
      <xsl:if test="ancestor::tei:TEI[@xml:id='people']"><xsl:apply-templates select="$people"/></xsl:if>
    </div>
  </xsl:template>
  
  <!-- order lists items -->
  <xsl:template match="//tei:listPlace[@type='places']">
    <div>
      <p><xsl:text>Total items: </xsl:text> <xsl:value-of select="count($places//tei:place[not(descendant::tei:placeName='XXX')])"/></p>
    </div>
    <xsl:apply-templates select="//tei:place[not(descendant::tei:placeName='XXX')]"><xsl:sort select="./tei:placeName[1]"/></xsl:apply-templates>
  </xsl:template>
  <xsl:template match="//tei:listPlace[@type='estates']">
    <div>
      <p><xsl:text>Total items: </xsl:text> <xsl:value-of select="count($estates//tei:place[not(descendant::tei:geogName='XXX')])"/></p>
    </div>
    <xsl:apply-templates select="//tei:place[not(descendant::tei:geogName='XXX')]"><xsl:sort select="./tei:geogName[1]"/></xsl:apply-templates>
  </xsl:template>
  <xsl:template match="//tei:listOrg">
    <div>
      <p><xsl:text>Total items: </xsl:text> <xsl:value-of select="count($juridical_persons//tei:org[not(descendant::tei:orgName='XXX')])"/></p>
    </div>
    <xsl:apply-templates select="//tei:org[not(descendant::tei:orgName='XXX')]"><xsl:sort select="./tei:orgName[1]"/></xsl:apply-templates>
  </xsl:template>
  <xsl:template match="//tei:listPerson">
    <div>
      <p><xsl:text>Total items: </xsl:text> <xsl:value-of select="count($people//tei:person[not(descendant::tei:persName='XXX')])"/></p>
    </div>
    <xsl:apply-templates select="//tei:person[not(descendant::tei:persName='XXX')]"><xsl:sort select="./tei:persName[1]"/></xsl:apply-templates>
  </xsl:template>
  
  <!-- display thesaurus -->
  <xsl:template match="//tei:taxonomy//tei:catDesc">
    <div class="list_item">
      <p><xsl:value-of select="."/></p>
    </div>
  </xsl:template>
  
  <!-- italics for titles and foreign terms -->
  <xsl:template match="tei:foreign[ancestor::tei:listOrg|ancestor::tei:listPerson|ancestor::tei:listPlace]|tei:title[ancestor::tei:listOrg|ancestor::tei:listPerson|ancestor::tei:listPlace]"><i><xsl:apply-templates/></i></xsl:template>
  
  <!-- display juridical persons, people, places, estates  -->
  <xsl:template match="//tei:listOrg//tei:org[not(descendant::tei:orgName='XXX')]|//tei:listPerson//tei:person[not(descendant::tei:persName='XXX')]|//tei:listPlace//tei:place[not(descendant::tei:placeName='XXX')]">
    <!-- variables -->
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="ancestor::tei:listOrg"><xsl:value-of select="substring-after(translate(tei:idno, '#', ''), 'juridical_persons/')"/></xsl:when>
        <xsl:when test="ancestor::tei:listPerson"><xsl:value-of select="substring-after(translate(tei:idno, '#', ''), 'people/')"/></xsl:when>
        <xsl:when test="ancestor::tei:listPlace[descendant::tei:geo]"><xsl:value-of select="substring-after(translate(tei:idno, '#', ''), 'places/')"/></xsl:when>
        <xsl:when test="ancestor::tei:listPlace[not(descendant::tei:geo)]"><xsl:value-of select="substring-after(translate(tei:idno, '#', ''), 'estates/')"/></xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
    <xsl:variable name="links" select="tei:link"/>
    <xsl:variable name="linked_keys_jp"><xsl:for-each select="$keys//p[@class='jp_keys'][@id=$id]">
      <xsl:value-of select="lower-case(.)"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="all_linked_keys_jp" select="distinct-values(tokenize(lower-case($linked_keys_jp), '\s+?'))"/>
    <xsl:variable name="all_keys_jp"><xsl:for-each select="$all_linked_keys_jp"><xsl:sort/><xsl:value-of select="replace(., '_', ' ')"/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="linked_keys_person"><xsl:for-each select="$keys//p[@class='person_keys'][@id=$id]">
      <xsl:value-of select="lower-case(.)"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="all_linked_keys_person" select="distinct-values(tokenize(lower-case($linked_keys_person), '\s+?'))"/>
    <xsl:variable name="all_keys_person"><xsl:for-each select="$all_linked_keys_person"><xsl:sort/><xsl:value-of select="replace(., '_', ' ')"/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="linked_keys_place"><xsl:for-each select="$keys//p[@class='place_keys'][@id=$id]">
      <xsl:value-of select="lower-case(.)"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="all_linked_keys_place" select="distinct-values(tokenize(lower-case($linked_keys_place), '\s+?'))"/>
    <xsl:variable name="all_keys_place"><xsl:for-each select="$all_linked_keys_place"><xsl:sort/><xsl:value-of select="replace(., '_', ' ')"/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="linked_keys_estate"><xsl:for-each select="$keys//p[@class='estate_keys'][@id=$id]">
      <xsl:value-of select="lower-case(.)"/><xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="all_linked_keys_estate" select="distinct-values(tokenize(lower-case($linked_keys_estate), '\s+?'))"/>
    <xsl:variable name="all_keys_estate"><xsl:for-each select="$all_linked_keys_estate"><xsl:sort/><xsl:value-of select="replace(., '_', ' ')"/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each></xsl:variable>
    <xsl:variable name="linked_people">
      <xsl:for-each select="tei:link[@type='people']/@corresp"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/>
        <xsl:value-of select="$people//tei:person[descendant::tei:idno=$link][1]//tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linking_people">
      <xsl:for-each select="$people//tei:person//tei:link/@corresp"><xsl:variable name="link" select="."/>
        <xsl:if test="contains(concat($link, ' '), concat($idno, ' '))"><xsl:value-of select="$link/ancestor::tei:person/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linked_places">
      <xsl:for-each select="tei:link[@type='places']/@corresp"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/>
        <xsl:value-of select="$places//tei:place[descendant::tei:idno=$link][1]//tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linking_places">
      <xsl:for-each select="$places//tei:place//tei:link/@corresp"><xsl:variable name="link" select="."/>
        <xsl:if test="contains(concat($link, ' '), concat($idno, ' '))"><xsl:value-of select="$link/ancestor::tei:place/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linked_jp">
      <xsl:for-each select="tei:link[@type='juridical_persons']/@corresp"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/><xsl:value-of select="$juridical_persons//tei:org[descendant::tei:idno=$link][1]//tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linking_jp">
      <xsl:for-each select="$juridical_persons//tei:org//tei:link/@corresp"><xsl:variable name="link" select="."/>
        <xsl:if test="contains(concat($link, ' '), concat($idno, ' '))"><xsl:value-of select="$link/ancestor::tei:org/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linked_estates">
      <xsl:for-each select="tei:link[@type='estates']/@corresp"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/>
          <xsl:value-of select="$estates//tei:place[descendant::tei:idno=$link][1]//tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="linking_estates">
      <xsl:for-each select="$estates//tei:place//tei:link/@corresp"><xsl:variable name="link" select="."/>
        <xsl:if test="contains(concat($link, ' '), concat($idno, ' '))"><xsl:value-of select="$link/ancestor::tei:place/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
    </xsl:variable>
    
    <!--<xsl:variable name="i_linked_estates"><!-\- estates linked to linking jp -\->
      <xsl:for-each select="$linking_jp"><xsl:variable name="links0" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$links0"><xsl:variable name="links1" select="."/><xsl:variable name="links2" select="$juridical_persons//tei:org[descendant::tei:idno=translate(translate($links1, '#', ''), ' ', '')]//tei:link[@type='estates']/@corresp"/>
          <xsl:for-each select="$links2"><xsl:variable name="links3" select="distinct-values(tokenize(., '\s+'))"/>
            <xsl:for-each select="$links3"><xsl:variable name="links4" select="translate(., '#', '')"/>
              <xsl:value-of select="$estates//tei:place[descendant::tei:idno=translate($links4, ' ', '')]//tei:idno"/><xsl:text> </xsl:text>
            </xsl:for-each></xsl:for-each></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="i_linked_estates1"><!-\- estates linked to linked jp -\->
      <xsl:for-each select="tei:link[@type='juridical_persons']/@corresp"><xsl:variable name="link1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$link1"><xsl:variable name="link2" select="translate(., '#', '')"/>
          <xsl:variable name="link3" select="$juridical_persons//tei:org[descendant::tei:idno=$link2]//tei:link[@type='estates']/@corresp"/>
          <xsl:for-each select="$link3"><xsl:variable name="link4" select="distinct-values(tokenize(., '\s+'))"/>
            <xsl:for-each select="$link4"><xsl:value-of select="translate(., '#', '')"/><xsl:text> </xsl:text>
            </xsl:for-each></xsl:for-each></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="i_linked_jp"><!-\- jp linked to linking estates -\->
      <xsl:for-each select="$linking_estates"><xsl:variable name="links0" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$links0"><xsl:variable name="links1" select="."/><xsl:variable name="links2" select="$estates//tei:place[descendant::tei:idno=translate(translate($links1, '#', ''), ' ', '')]//tei:link[@type='juridical_persons']/@corresp"/>
          <xsl:for-each select="$links2"><xsl:variable name="links3" select="distinct-values(tokenize(., '\s+'))"/>
            <xsl:for-each select="$links3"><xsl:variable name="links4" select="translate(., '#', '')"/>
              <xsl:value-of select="$juridical_persons//tei:org[descendant::tei:idno=translate($links4, ' ', '')]//tei:idno"/><xsl:text> </xsl:text>
            </xsl:for-each></xsl:for-each></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="i_linked_jp1"><!-\- jp linked to linked estates -\->
      <xsl:for-each select="tei:link[@type='estates']/@corresp"><xsl:variable name="link1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$link1"><xsl:variable name="link2" select="translate(., '#', '')"/>
          <xsl:variable name="link3" select="$estates//tei:place[descendant::tei:idno=$link2]//tei:link[@type='juridical_persons']/@corresp"/>
          <xsl:for-each select="$link3"><xsl:variable name="link4" select="distinct-values(tokenize(., '\s+'))"/>
            <xsl:for-each select="$link4"><xsl:value-of select="translate(., '#', '')"/><xsl:text> </xsl:text>
            </xsl:for-each></xsl:for-each></xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="i_linking_estates"><!-\- estates linking to linking jp -\->
      <xsl:for-each select="$estates//tei:place//tei:link[@type='juridical_persons']/@corresp">
        <xsl:variable name="link1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$link1"><xsl:variable name="link" select="translate(., '#', '')"/>
          <xsl:if test="contains(concat($linking_jp, ' '), concat($link, ' '))">
            <xsl:value-of select="$estates//tei:place[contains(string-join(descendant::tei:link[@type='juridical_persons']/@corresp, ' '), concat($link, ' '))]//tei:idno"/><xsl:text> </xsl:text></xsl:if>
      </xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="i_linking_jp"><!-\- jp linking to linking estates -\->
      <xsl:for-each select="$juridical_persons//tei:org//tei:link[@type='estates']/@corresp">
        <xsl:variable name="link1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$link1"><xsl:variable name="link" select="translate(., '#', '')"/>
          <xsl:if test="contains(concat($linking_estates, ' '), concat($link, ' '))">
            <xsl:value-of select="$juridical_persons//tei:org[contains(string-join(descendant::tei:link[@type='estates']/@corresp, ' '), concat($link, ' '))]//tei:idno"/><xsl:text> </xsl:text></xsl:if>
        </xsl:for-each></xsl:for-each>
     </xsl:variable>
    <xsl:variable name="i_linking_estates1"><!-\- estates linking to linked jp -\->
      <xsl:for-each select="$estates//tei:place//tei:link[@type='juridical_persons']/@corresp">
        <xsl:variable name="link1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$link1"><xsl:variable name="link" select="translate(., '#', '')"/>
          <xsl:if test="contains(concat($linked_jp, ' '), concat($link, ' '))">
            <xsl:value-of select="$estates//tei:place[contains(string-join(descendant::tei:link[@type='juridical_persons']/@corresp, ' '), concat($link, ' '))]//tei:idno"/><xsl:text> </xsl:text></xsl:if>
      </xsl:for-each></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="i_linking_jp1"><!-\- jp linking to linked estates -\->
    <xsl:for-each select="$juridical_persons//tei:org//tei:link[@type='estates']/@corresp">
        <xsl:variable name="link1" select="distinct-values(tokenize(., '\s+'))"/>
        <xsl:for-each select="$link1"><xsl:variable name="link" select="translate(., '#', '')"/>
          <xsl:if test="contains(concat($linked_estates, ' '), concat($link, ' '))">
            <xsl:value-of select="$juridical_persons//tei:org[contains(string-join(descendant::tei:link[@type='estates']/@corresp, ' '), concat($link, ' '))]//tei:idno"/><xsl:text> </xsl:text></xsl:if>
        </xsl:for-each></xsl:for-each>
    </xsl:variable>-->
    
    <xsl:variable name="links_est"><xsl:for-each select="$linked_estates|$linking_estates"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable> <!-- |$i_linked_estates1|$i_linked_estates|$i_linking_estates1|$i_linking_estates -->
    <xsl:variable name="linkedest" select="distinct-values(tokenize(normalize-space($links_est), '\s+'))" />
    <xsl:variable name="links_jp"><xsl:for-each select="$linked_jp|$linking_jp"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable> <!-- |$i_linked_jp1|$i_linked_jp|$i_linking_jp1|$i_linking_jp -->
    <xsl:variable name="linkedjp" select="distinct-values(tokenize(normalize-space($links_jp), '\s+'))" />
    <xsl:variable name="links_people"><xsl:for-each select="$linked_people|$linking_people"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
    <xsl:variable name="linkedpeople" select="distinct-values(tokenize(normalize-space($links_people), '\s+'))" />
    <xsl:variable name="links_places"><xsl:for-each select="$linked_places|$linking_places"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
    <xsl:variable name="linkedplaces" select="distinct-values(tokenize(normalize-space($links_places), '\s+'))" />
    
    <xsl:variable name="mentioning_documents">
          <xsl:for-each select="$texts">
              <xsl:for-each select=".[descendant::tei:*[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
    
    <!-- variables for map for each juridical person having linked places -->
    <xsl:variable name="map_polygons">
      <xsl:text>{</xsl:text>
      <xsl:for-each select="$linkedplaces">
        <xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
        <xsl:for-each select="$places//tei:place[descendant::tei:idno=$key][1][matches(descendant::tei:geo[not(@style='line')], '[\d+\.{0,1}\d+?,\s+?\d+\.{0,1}\d+;]+\s+\d+\.{0,1}\d+?,\s+\d+\.{0,1}\d+')]">
          <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
          <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
          <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
          <xsl:variable name="mentioning_documents">
            <xsl:for-each select="$texts">
              <xsl:for-each select=".[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
          <xsl:text>"</xsl:text><xsl:value-of select="$name"/>
          <xsl:text>#</xsl:text><xsl:value-of select="$number_of_mentioning_documents"/>
          <xsl:text>#</xsl:text><xsl:value-of select="$id"/><xsl:text>": "</xsl:text>
          <xsl:value-of select="replace(replace(normalize-space(tei:geogName/tei:geo[not(@style='line')]), ', ', ';'), '; ', ';')"/>
          <xsl:text>", </xsl:text>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:text>!}</xsl:text>
    </xsl:variable>
    <xsl:variable name="map_lines">
      <xsl:text>{</xsl:text>
      <xsl:for-each select="$linkedplaces">
        <xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
        <xsl:for-each select="$places//tei:place[descendant::tei:idno=$key][1][matches(descendant::tei:geo[@style='line'], '[\d+\.{0,1}\d+?,\s+?\d+\.{0,1}\d+;]+\s+\d+\.{0,1}\d+?,\s+\d+\.{0,1}\d+')]">
          <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
          <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
          <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
          <xsl:variable name="mentioning_documents">
            <xsl:for-each select="$texts">
              <xsl:for-each select=".[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
          <xsl:text>"</xsl:text><xsl:value-of select="$name"/>
          <xsl:text>#</xsl:text><xsl:value-of select="$number_of_mentioning_documents"/>
          <xsl:text>#</xsl:text><xsl:value-of select="$id"/><xsl:text>": "</xsl:text>
          <xsl:value-of select="replace(replace(normalize-space(tei:geogName/tei:geo[@style='line']), ', ', ';'), '; ', ';')"/>
          <xsl:text>", </xsl:text>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:text>!}</xsl:text>
    </xsl:variable>
    <xsl:variable name="map_points">
      <xsl:text>{</xsl:text> 
      <xsl:for-each select="$linkedplaces">
        <xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
        <xsl:for-each select="$places//tei:place[descendant::tei:idno=$key][1][matches(descendant::tei:geo, '\d+[\.]{0,1}\d+?,\s+?\d+[\.]{0,1}\d+')]">
          <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
          <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
          <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
          <xsl:variable name="linked_keys"><xsl:for-each select="$keys//p[@class='place_keys'][@id=$id]"><xsl:value-of select="lower-case(.)"/><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
          <xsl:variable name="all_keys" select="concat(' ', normalize-space($linked_keys))"/>
          <xsl:variable name="mentioning_documents">
            <xsl:for-each select="$texts">
              <xsl:for-each select=".[descendant::tei:placeName[contains(concat(@ref, ' '), concat($idno, ' '))]]"><p/></xsl:for-each>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="number_of_mentioning_documents"><xsl:value-of select="count($mentioning_documents/p)"/></xsl:variable>
          <xsl:text>"</xsl:text><xsl:value-of select="$name"/>
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
            <xsl:when test="contains(normalize-space(tei:geogName/tei:geo), ';')"><xsl:value-of select="substring-before(tei:geogName/tei:geo, ';')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="normalize-space(tei:geogName/tei:geo)"/></xsl:otherwise>
          </xsl:choose><xsl:text>"</xsl:text>
        </xsl:for-each><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:variable>
    <xsl:variable name="this_id" select="translate(tei:idno, '#', '')"/>
    <!-- display -->
    <div class="list_item"><xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
      <xsl:if test="tei:orgName|tei:persName|tei:placeName"><h2 class="item_name"><xsl:apply-templates select="tei:orgName[1]|tei:persName[1]|tei:placeName[1]"/></h2></xsl:if>
      <xsl:if test="tei:geogName[not(descendant::tei:geo)]"><h2 class="item_name"><xsl:apply-templates select="tei:geogName[not(descendant::tei:geo)][1]"/></h2></xsl:if>
      
      <p><xsl:if test="tei:orgName[@type='other']//text()|tei:persName[@type='other']//text()|tei:placeName[@type='other']//text()|tei:geogName[@type='other']//text()"><strong><xsl:text>Also known as: </xsl:text></strong><xsl:apply-templates select="tei:orgName[@type='other']|tei:persName[@type='other']|tei:placeName[@type='other']|tei:geogName[@type='other']"/><br/></xsl:if>
        
        <xsl:if test="tei:geogName/tei:geo/text()"><strong><xsl:text>Coordinates (Lat, Long): </xsl:text></strong>
          <xsl:value-of select="tei:geogName/tei:geo"/> <a href="#" onclick="openPopupById($(this)[0].id);"><xsl:attribute name="id"><xsl:value-of select="substring-after(tei:idno, 'places/')"/></xsl:attribute><xsl:text> [See on map]</xsl:text></a><br/></xsl:if>
        <xsl:if test="tei:idno"><strong><xsl:text>Item number: </xsl:text></strong><xsl:value-of select="$this_id"/><br/></xsl:if>
        <xsl:if test="tei:note//text()"><strong><xsl:text>Commentary/Bibliography: </xsl:text></strong><xsl:for-each select="tei:note[node()]"><xsl:apply-templates select="."/><br/></xsl:for-each></xsl:if>
        <xsl:if test="//tei:org and matches($all_keys_jp, '.*[a-zA-Z].*')"><strong><xsl:text>Linked keywords: </xsl:text></strong> 
          <xsl:value-of select="replace(replace($all_keys_jp, ',$', ''), '^, ', '')"/><br/></xsl:if>
        <xsl:if test="//tei:person and matches($all_keys_person, '.*[a-zA-Z].*')"><strong><xsl:text>Linked keywords: </xsl:text></strong> 
          <xsl:value-of select="replace(replace($all_keys_person, ',$', ''), '^, ', '')"/><br/></xsl:if>
        <xsl:if test="tei:geogName[descendant::tei:geo] and matches($all_keys_place, '.*[a-zA-Z].*')"><strong><xsl:text>Linked keywords: </xsl:text></strong> 
          <xsl:value-of select="replace(replace($all_keys_place, ',$', ''), '^, ', '')"/><br/></xsl:if>
        <xsl:if test="tei:geogName[not(descendant::tei:geo)] and matches($all_keys_estate, '.*[a-zA-Z].*')"><strong><xsl:text>Linked keywords: </xsl:text></strong> 
          <xsl:value-of select="replace(replace($all_keys_estate, ',$', ''), '^, ', '')"/><br/></xsl:if>
        <xsl:if test="$number_of_mentioning_documents!=0"><strong><xsl:text>Linked documents (</xsl:text><xsl:value-of select="$number_of_mentioning_documents"/><xsl:text>): </xsl:text></strong>
            <a><xsl:attribute name="href"><xsl:choose>
            <xsl:when test="ancestor::tei:listOrg"><xsl:value-of select="concat('../indices/epidoc/juridical_persons.html#', $id)"/></xsl:when>
            <xsl:when test="ancestor::tei:listPerson"><xsl:value-of select="concat('../indices/epidoc/people.html#', $id)"/></xsl:when>
            <xsl:when test="ancestor::tei:listPlace[descendant::tei:geo]"><xsl:value-of select="concat('../indices/epidoc/places.html#', $id)"/></xsl:when>
            <xsl:when test="ancestor::tei:listPlace[not(descendant::tei:geo)]"><xsl:value-of select="concat('../indices/epidoc/estates.html#', $id)"/></xsl:when>
          </xsl:choose></xsl:attribute><xsl:text>➚</xsl:text></a>
          <br/></xsl:if>
      </p>
      <!-- display linked items -->
      <xsl:if test="$linkedjp!=''"><strong><xsl:text>Linked juridical persons: </xsl:text></strong>
        <ul><xsl:for-each select="$linkedjp"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
          <li class="linked_item"><a><xsl:attribute name="href"><xsl:value-of select="concat('./juridical_persons.html#', substring-after($key, 'juridical_persons/'))"/></xsl:attribute><xsl:apply-templates select="$juridical_persons//tei:org[descendant::tei:idno=$key][1]/tei:orgName[1]"/></a>
            <xsl:variable name="subtype">
              <xsl:choose>
                <xsl:when test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                  <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:when>
                <xsl:when test="$all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@subtype!='']">
                  <xsl:variable name="reverse" select="$all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))]/@subtype"/>
                  <xsl:choose>
                    <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                    <xsl:when test="$reverse='isAdjacentTo'"><xsl:text>isAdjacentTo</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isInVicinityOf'"><xsl:text>hasInItsVicinity</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasInItsVicinity'"><xsl:text>isInVicinityOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isMadeOf'"><xsl:text>isPartOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isPartOf'"><xsl:text>isMadeOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isWithin'"><xsl:text>hasWithin</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasWithin'"><xsl:text>isWithin</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>reverse link of: </xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$subtype"><xsl:text> (</xsl:text><xsl:value-of select="$subtype"/><xsl:text>)</xsl:text></xsl:if>
            <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
          </li></xsl:for-each></ul><br/></xsl:if>
      
      <xsl:if test="$linkedest!=''"><strong><xsl:text>Linked estates: </xsl:text></strong>
        <ul><xsl:for-each select="$linkedest"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
          <li class="linked_item"><a><xsl:attribute name="href"><xsl:value-of select="concat('./estates.html#', substring-after($key, 'estates/'))"/></xsl:attribute><xsl:apply-templates select="$estates//tei:place[descendant::tei:idno=$key][1]/tei:geogName[1]"/></a>
            <xsl:variable name="subtype">
              <xsl:choose>
                <xsl:when test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                  <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:when>
                <xsl:when test="$all_items//tei:*[descendant::tei:idno=$key]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@subtype!='']">
                  <xsl:variable name="reverse" select="$all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))]/@subtype"/>
                  <xsl:choose>
                    <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                    <xsl:when test="$reverse='isAdjacentTo'"><xsl:text>isAdjacentTo</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isInVicinityOf'"><xsl:text>hasInItsVicinity</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasInItsVicinity'"><xsl:text>isInVicinityOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isMadeOf'"><xsl:text>isPartOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isPartOf'"><xsl:text>isMadeOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isWithin'"><xsl:text>hasWithin</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasWithin'"><xsl:text>isWithin</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>reverse link of: </xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$subtype"><xsl:text> (</xsl:text><xsl:value-of select="$subtype"/><xsl:text>)</xsl:text></xsl:if>
            <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
          </li></xsl:for-each></ul><br/></xsl:if>
      
      <xsl:if test="$linkedplaces!=''"><strong><xsl:text>Linked places: </xsl:text></strong>
        <ul><xsl:for-each select="$linkedplaces"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
          <li class="linked_item"><a><xsl:attribute name="href"><xsl:value-of select="concat('./places.html#', substring-after($key, 'places/'))"/></xsl:attribute><xsl:apply-templates select="$places//tei:place[descendant::tei:idno=$key][1]/tei:placeName[1]"/></a>
            <xsl:variable name="subtype">
              <xsl:choose>
                <xsl:when test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                  <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:when>
                <xsl:when test="$all_items//tei:*[descendant::tei:idno=$key]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@subtype!='']">
                  <xsl:variable name="reverse" select="$all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))]/@subtype"/>
                  <xsl:choose>
                    <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                    <xsl:when test="$reverse='isAdjacentTo'"><xsl:text>isAdjacentTo</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isInVicinityOf'"><xsl:text>hasInItsVicinity</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasInItsVicinity'"><xsl:text>isInVicinityOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isMadeOf'"><xsl:text>isPartOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isPartOf'"><xsl:text>isMadeOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isWithin'"><xsl:text>hasWithin</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasWithin'"><xsl:text>isWithin</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>reverse link of: </xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$subtype"><xsl:text> (</xsl:text><xsl:value-of select="$subtype"/><xsl:text>)</xsl:text></xsl:if>
            <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
          </li></xsl:for-each></ul><br/></xsl:if>
      
      <xsl:if test="$linkedpeople!=''"><strong><xsl:text>Linked people: </xsl:text></strong>
        <ul><xsl:for-each select="$linkedpeople"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
          <li class="linked_item"><a><xsl:attribute name="href"><xsl:value-of select="concat('./people.html#', substring-after($key, 'people/'))"/></xsl:attribute><xsl:apply-templates select="$people//tei:person[descendant::tei:idno=$key][1]/tei:persName[1]"/></a>
            <xsl:variable name="subtype">
              <xsl:choose>
                <xsl:when test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                  <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:when>
                <xsl:when test="$all_items//tei:*[descendant::tei:idno=$key]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@subtype!='']">
                  <xsl:variable name="reverse" select="$all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))]/@subtype"/>
                  <xsl:choose>
                    <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                    <xsl:when test="$reverse='isAdjacentTo'"><xsl:text>isAdjacentTo</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isInVicinityOf'"><xsl:text>hasInItsVicinity</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasInItsVicinity'"><xsl:text>isInVicinityOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isMadeOf'"><xsl:text>isPartOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isPartOf'"><xsl:text>isMadeOf</xsl:text></xsl:when>
                    <xsl:when test="$reverse='isWithin'"><xsl:text>hasWithin</xsl:text></xsl:when>
                    <xsl:when test="$reverse='hasWithin'"><xsl:text>isWithin</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>reverse link of: </xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$subtype"><xsl:text> (</xsl:text><xsl:value-of select="$subtype"/><xsl:text>)</xsl:text></xsl:if>
            <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items//tei:*[descendant::tei:idno=$key][1]//tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($this_id, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
          </li></xsl:for-each></ul><br/></xsl:if>
        
        <!-- map for each juridical person -->
      <xsl:if test="ancestor::tei:listOrg and $linkedplaces!=''">
        <div class="row map_box">
          <div class="map_jp"><xsl:attribute name="id"><xsl:value-of select="concat('map', $id)"/></xsl:attribute></div>
          <div class="legend" id="map_legend">
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
            var polygons = <xsl:value-of select="replace(replace($map_polygons, ', !', ''), '!', '')"/>;
            var lines = <xsl:value-of select="replace(replace($map_lines, ', !', ''), '!', '')"/>;
            var points = <xsl:value-of select="replace($map_points, ', ,', ',')"/>;
            </script>
          <script type="text/javascript" src="../../assets/scripts/maps.js"></script>
          <script type="text/javascript">
            var <xsl:value-of select="concat('map', $id)"/> = L.map('<xsl:value-of select="concat('map', $id)"/>', 
            { center: [44, 10.335], zoom: 6, fullscreenControl: true, layers: layers });
            L.control.layers(baseMaps, overlayMaps).addTo(<xsl:value-of select="concat('map', $id)"/>);
            L.control.scale().addTo(<xsl:value-of select="concat('map', $id)"/>);
            L.Control.geocoder().addTo(<xsl:value-of select="concat('map', $id)"/>);
            toggle_purple_places.addTo(<xsl:value-of select="concat('map', $id)"/>);
            toggle_golden_places.addTo(<xsl:value-of select="concat('map', $id)"/>);
            toggle_polygons.addTo(<xsl:value-of select="concat('map', $id)"/>);
            toggle_lines.addTo(<xsl:value-of select="concat('map', $id)"/>);
          </script>
        </div>
      </xsl:if>
    </div>
  </xsl:template>
  
  <!-- PEOPLE GRAPH -->
  <xsl:template match="//tei:addSpan[@xml:id='people_graph']">
    <xsl:variable name="graph_items">
      <xsl:text>{nodes:[</xsl:text>
      <xsl:for-each select="$people//tei:person[not(descendant::tei:persName='XXX')][descendant::tei:idno!=''][descendant::tei:persName!='']">
        <xsl:text>{data: {id: "</xsl:text><xsl:value-of select="tei:idno[1]"/><xsl:text>", name: "</xsl:text>        
        <xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>", type: "people_only"}</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>], edges:[</xsl:text>
      <xsl:for-each select="$people//tei:link[tokenize(concat(replace(@corresp, '#', ''), ' '), ' ')=$people//tei:idno][@type='people'][not(starts-with(@corresp, ' '))][not(ends-with(@corresp, ' '))]">
        <xsl:variable name="id" select="parent::tei:*/tei:idno[1]"/>
        <xsl:variable name="relation_type"><xsl:choose>
          <xsl:when test="@subtype='' or @subtype='link'"><xsl:text> </xsl:text></xsl:when>
          <xsl:otherwise><xsl:value-of select="@subtype"/></xsl:otherwise>
        </xsl:choose></xsl:variable>
        <xsl:variable name="cert" select="@cert"/>
        <xsl:variable name="color">
          <xsl:choose>
            <xsl:when test="$thesaurus//tei:catDesc[@n=$relation_type][@key='family']"><xsl:text>red</xsl:text></xsl:when>
            <xsl:when test="$thesaurus//tei:catDesc[@n=$relation_type][@key='personal']"><xsl:text>green</xsl:text></xsl:when>
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
            <xsl:for-each select="tokenize(@corresp, ' ')[replace(., '#', '')=$people//tei:idno]">
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
      <xsl:for-each select="$people//tei:person[not(descendant::tei:persName='XXX')][descendant::tei:persName!=''][descendant::tei:idno!='']">
        <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    
    <div class="row network_box" id="mynetwork_box">
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
        </p>
        <p><span class="autocomplete"><input type="text" id="inputSearch" placeholder="Search"/></span><button id="btnSearch" class="button">Show</button> <button id="reset" class="button">Reset</button> <button onclick="openFullscreen();" class="button">Fullscreen</button> <a class="button" href="#help">Help</a></p>
      </div>
      <div id="mynetwork"></div>
      <div class="legend">
        <p>
          <span id="toggle_people"/><span id="toggle_juridical_persons"/><span id="toggle_estates"/><span id="toggle_places"/>
          <span class="red_label">➔</span> Family relations <input type="checkbox" id="toggle_red" checked="true"/> 
          <span class="green_label">➔</span> Interpersonal bonds <input type="checkbox" id="toggle_green" checked="true"/>
          <span id="toggle_orange"/>
          <span class="blue_label">➔</span> Other interpersonal links <input type="checkbox" id="toggle_blue" checked="true"/>
          <span class="alleged_label">⤑</span> Alleged relations <input type="checkbox" id="toggle_alleged" checked="true"/>
          <span class="relations_label"> Relation types </span> <input type="checkbox" id="toggle_labels" checked="true"/>
        </p>
      </div>
      
      <script type="text/javascript">
          var graph_items = <xsl:value-of select="$graph_items"/>, graph_labels = <xsl:value-of select="$graph_labels"/>, my_graph = "mynetwork", box = "mynetwork_box";
        </script>
        <script type="text/javascript" src="../../assets/scripts/networks.js"></script>
     </div>
  </xsl:template>
  
  <!-- COMPLETE GRAPH -->
  <xsl:template match="//tei:addSpan[@xml:id='relation_graph']">
    <xsl:variable name="graph_items">
      <xsl:text>{nodes:[</xsl:text>
      <xsl:for-each select="$people//tei:person[not(descendant::tei:persName='XXX')][descendant::tei:persName!=''][descendant::tei:idno!='']|$juridical_persons//tei:org[not(descendant::tei:orgName='XXX')][descendant::tei:orgName!=''][descendant::tei:idno!='']|$estates//tei:place[not(descendant::tei:geogName='XXX')][descendant::tei:geogName!=''][descendant::tei:idno!='']|$places//tei:place[not(descendant::tei:placeName='XXX')][descendant::tei:placeName!=''][descendant::tei:idno!='']">
        <xsl:text>{data: {id: "</xsl:text><xsl:value-of select="tei:idno[1]"/><xsl:text>", name: "</xsl:text>        
        <xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>"</xsl:text>
        <xsl:text>, type: "</xsl:text><xsl:choose>
          <xsl:when test="ancestor::tei:listPerson">people</xsl:when>
          <xsl:when test="ancestor::tei:listOrg">juridical_persons</xsl:when>
          <xsl:when test="ancestor::tei:listPlace[@type='estates']">estates</xsl:when>
          <xsl:when test="ancestor::tei:listPlace[@type='places']">places</xsl:when>
        </xsl:choose><xsl:text>"}</xsl:text>
        <!--<xsl:text>,position:{x:0,y:0}</xsl:text>--> <!-- *** -->
        <xsl:text>}</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>], edges:[</xsl:text>
      <xsl:for-each select="$all_items//tei:link[tokenize(concat(replace(@corresp, '#', ''), ' '), ' ')=$all_items//tei:idno][not(starts-with(@corresp, ' '))][not(ends-with(@corresp, ' '))]">
        <xsl:variable name="id" select="parent::tei:*/tei:idno[1]"/>
        <xsl:variable name="relation_type"><xsl:choose>
          <xsl:when test="@subtype='' or @subtype='link'"><xsl:text> </xsl:text></xsl:when>
          <xsl:otherwise><xsl:value-of select="@subtype"/></xsl:otherwise>
        </xsl:choose></xsl:variable>
        <xsl:variable name="cert" select="@cert"/>
        <xsl:variable name="color">
          <xsl:choose>
            <xsl:when test="ancestor::tei:person and @type='people'">
              <xsl:choose>
                <xsl:when test="$thesaurus//tei:catDesc[@n=$relation_type][@key='family']"><xsl:text>red</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>green</xsl:text></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::tei:person or @type='people'"><xsl:text>orange</xsl:text></xsl:when>
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
            <xsl:for-each select="tokenize(@corresp, ' ')[replace(., '#', '')=$all_items//tei:idno]">
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
      <xsl:for-each select="$people//tei:person[not(descendant::tei:persName='XXX')][descendant::tei:persName!=''][descendant::tei:idno!='']|$juridical_persons//tei:org[not(descendant::tei:orgName='XXX')][descendant::tei:orgName!=''][descendant::tei:idno!='']|$estates//tei:place[not(descendant::tei:geogName='XXX')][descendant::tei:geogName!=''][descendant::tei:idno!='']|$places//tei:place[not(descendant::tei:placeName='XXX')][descendant::tei:placeName!=''][descendant::tei:idno!='']">
        <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:*[1], ',', '; '))"/><xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    
    <div class="row network_box" id="mygraph_box">
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
          <br/>- Se un gruppo di elementi (People, Juridical persons, Estates, Places) viene selezionato o deselezionato più volte consecutive il sistema si blocca e occorre ricaricare la pagina.
          <br/>- Dopo aver deselezionato uno o più tipi di relazioni (Family relations, Interpersonal bonds...) per nasconderle nel grafico, occorre posizionarsi con il puntatore (o cliccare) su un punto qualsiasi del grafico affinché queste vengano effettivamente nascoste.
        </p>
        <p><span class="autocomplete"><input type="text" id="inputSearch" placeholder="Search"/></span><button id="btnSearch" class="button">Show</button> <button id="reset" class="button">Reset</button> <button onclick="openFullscreen();" class="button">Fullscreen</button> <a class="button" href="#help">Help</a></p>
      </div>
      
      <div id="mygraph"></div>
      <div class="legend">
        <p>
          <span class="people_label">People</span> <input type="checkbox" id="toggle_people" checked="true"/>
          <span class="jp_label">Juridical persons</span> <input type="checkbox" id="toggle_juridical_persons" checked="true"/>
          <span class="estates_label">Estates</span> <input type="checkbox" id="toggle_estates" checked="true"/>
          <span class="places_label">Places</span> <input type="checkbox" id="toggle_places" checked="true"/>
          <br/>
          <span class="red_label">➔</span> Family relations <input type="checkbox" id="toggle_red" checked="true"/> 
          <span class="green_label">➔</span> Interpersonal bonds <input type="checkbox" id="toggle_green" checked="true"/>
          <span class="orange_label">➔</span> Other personal links <input type="checkbox" id="toggle_orange" checked="true"/>
          <span class="blue_label">➔</span> Other links <input type="checkbox" id="toggle_blue" checked="true"/>
          <span class="alleged_label">⤑</span> Alleged relations <input type="checkbox" id="toggle_alleged" checked="true"/>
          <span class="relations_label"> Relation types </span> <input type="checkbox" id="toggle_labels" checked="true"/>
        </p>
      </div>
      
      <script type="text/javascript">
        var graph_items = <xsl:value-of select="$graph_items"/>, graph_labels = <xsl:value-of select="$graph_labels"/>, my_graph = "mygraph", box = "mygraph_box";
       </script>
      <script type="text/javascript" src="../../assets/scripts/networks.js"></script>
    </div>
  </xsl:template>
  
  <!-- MAP -->
  <xsl:template match="//tei:addSpan[@xml:id='map']">
    
    <!-- generate lists of places by type -->
    <xsl:variable name="map_polygons">
      <xsl:text>{</xsl:text>
      <xsl:for-each select="$places//tei:place[matches(descendant::tei:geo[not(@style='line')], '[\d+\.{0,1}\d+?,\s+?\d+\.{0,1}\d+;]+\s+\d+\.{0,1}\d+?,\s+\d+\.{0,1}\d+')][not(descendant::tei:placeName='XXX')]">
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
      <xsl:for-each select="$places//tei:place[matches(descendant::tei:geo[@style='line'], '[\d+\.{0,1}\d+?,\s+?\d+\.{0,1}\d+;]+\s+\d+\.{0,1}\d+?,\s+\d+\.{0,1}\d+')][not(descendant::tei:placeName='XXX')]">
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
      <xsl:for-each select="$places//tei:place[matches(descendant::tei:geo, '\d+[\.]{0,1}\d+?,\s+?\d+[\.]{0,1}\d+')][not(descendant::tei:placeName='XXX')]">
        <xsl:variable name="name" select="normalize-space(translate(tei:placeName[1], ',', '; '))"/>
        <xsl:variable name="id" select="substring-after(translate(tei:idno,'#',''), 'places/')"/>
        <xsl:variable name="idno" select="translate(translate(tei:idno, '#', ''), ' ', '')"/>
        <xsl:variable name="linked_keys"><xsl:for-each select="$keys//p[@class='place_keys'][@id=$id]"><xsl:value-of select="lower-case(.)"/><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
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
          <xsl:when test="contains(normalize-space(tei:geogName/tei:geo), ';')"><xsl:value-of select="substring-before(tei:geogName/tei:geo, ';')"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="normalize-space(tei:geogName/tei:geo)"/></xsl:otherwise>
          </xsl:choose><xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="map_labels">
      <xsl:text>[</xsl:text>
      <xsl:for-each select="$places//tei:place[not(descendant::tei:placeName='XXX')][matches(descendant::tei:geo, '\d+[\.]{0,1}\d+?,\s+?\d+[\.]{0,1}\d+') or matches(descendant::tei:geo, '[\d+\.{0,1}\d+?,\s+?\d+\.{0,1}\d+;]+\s+\d+\.{0,1}\d+?,\s+\d+\.{0,1}\d+')]">
        <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:placeName[1], ',', '; '))"/><xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    
    <!-- add map -->
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
        var polygons = <xsl:value-of select="$map_polygons"/>;
        var lines = <xsl:value-of select="$map_lines"/>;
        var points = <xsl:value-of select="$map_points"/>;
        var map_labels = <xsl:value-of select="$map_labels"/>;
      </script>
      <script type="text/javascript" src="../../assets/scripts/maps.js"></script>
      <script type="text/javascript">
        var mymap = L.map('mapid', { center: [44, 10.335], zoom: 6, fullscreenControl: true, layers: layers });
        L.control.layers(baseMaps, overlayMaps).addTo(mymap);
        L.control.scale().addTo(mymap);
        L.Control.geocoder().addTo(mymap);
        toggle_purple_places.addTo(mymap); 
        toggle_golden_places.addTo(mymap);
        toggle_polygons.addTo(mymap);
        toggle_lines.addTo(mymap); 
         
        <!--var sliderControl = L.control.sliderControl({layer: L.layerGroup(markers)});
        mymap.addControl(sliderControl);
        sliderControl.startSlider();-->
        <!-- to be fixed: what to put in $year; how to display date ranges; how to use legend filters (best to change approach and use separate arrays of places based on periods? Cf. https://github.com/svitkin/leaflet-timeline-slider) -->
      </script>
    </div>
  </xsl:template>
  
</xsl:stylesheet>