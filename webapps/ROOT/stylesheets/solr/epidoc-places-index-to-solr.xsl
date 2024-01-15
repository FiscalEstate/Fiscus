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
  
  <xsl:template match="/">
    <xsl:variable name="root" select="." />
    <xsl:variable name="all_mentions">
      <xsl:for-each select="$root//tei:div[@type='edition']//tei:placeName/@ref"><xsl:value-of select="concat(' ', replace(normalize-space(.), '#', ''), ' ')"/></xsl:for-each>
    </xsl:variable>
    <xsl:variable name="not_mentioned" select="$places/tei:place/tei:placeName[not(@type='other')][not(.='XXX')][not(contains($all_mentions, concat(' ', normalize-space(following-sibling::tei:idno), ' ')))]"/>
    <xsl:variable name="id-values">
      <xsl:for-each select="//tei:placeName[ancestor::tei:div/@type='edition'][@ref!='']/@ref|$not_mentioned/following-sibling::tei:idno">
        <xsl:value-of select="normalize-space(translate(., '#', ''))" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="ids" select="distinct-values(tokenize(normalize-space($id-values), '\s+'))" /> 
    
    <add>
      <xsl:for-each select="$ids">
        <xsl:variable name="el-id" select="."/>
        <xsl:variable name="element-id" select="$places/tei:place[translate(translate(child::tei:idno, '#', ''), ' ', '')=$el-id][child::tei:placeName!=''][1]"/>
        <xsl:variable name="item" select="$root//tei:placeName[ancestor::tei:div/@type='edition'][@ref!=''][contains(concat(' ', translate(@ref, '#', ''), ' '), concat(' ', $el-id, ' '))]|$not_mentioned"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="$element-id/tei:placeName">
                <xsl:apply-templates mode="italics" select="$element-id/tei:placeName[1]"/>
              </xsl:when>
              <xsl:when test="$el-id and not($element-id)"><xsl:value-of select="$el-id" /></xsl:when>
            </xsl:choose>
          </field>
          <xsl:if test="$element-id/tei:placeName[@type='other']//text()">
            <field name="index_other_names">
              <xsl:apply-templates mode="italics" select="$element-id/tei:placeName[@type='other']"/>
            </field>
          </xsl:if>
          <xsl:if test="$element-id/tei:idno//text()">
          <field name="index_item_number">
            <xsl:value-of select="translate(translate($element-id/tei:idno[1],' ',''),'#','')"/>
          </field>
          </xsl:if>
          <xsl:if test="$element-id/tei:note//text()">
            <field name="index_notes">
              <xsl:apply-templates mode="italics" select="$element-id/tei:note"/>
            </field>
          </xsl:if>
          <xsl:if test="$element-id/tei:geogName[@type='coord']//text()">
          <field name="index_coordinates">
            <xsl:value-of select="$element-id/tei:geogName[@type='coord']"/>
          </field>
          </xsl:if>
          <xsl:if test="$element-id/tei:idno='places/1'"><!-- to prevent having this indexed for all instances -->
            <field name="index_total_items"><xsl:value-of select="string(count($places/tei:place[not(child::tei:placeName='XXX')]))"/></field>
          </xsl:if>
          
          <xsl:variable name="all_keys">
            <xsl:for-each select="$root//tei:placeName[translate(replace(@ref, ' #', '; '), '#', '')=$el-id][@key]">
              <xsl:value-of select="replace(replace(replace(lower-case(replace(@key, '([a-z]{1})([A-Z]{1})', '$1_$2')), '#', ''), ' ', ', '), '_', ' ')"/>
              <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="allkeys" select="distinct-values(tokenize($all_keys, ', '))"/>
          <xsl:variable name="all_keys_sorted">
            <xsl:for-each select="$allkeys[normalize-space(.)!='']">
              <xsl:sort order="ascending"/><xsl:value-of select="."/><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="$element-id and matches($all_keys_sorted, '.*[a-zA-Z].*')">
            <field name="index_linked_keywords">
              <xsl:value-of select="$all_keys_sorted"/>
          </field>
          </xsl:if>
          
          <!-- ### Linked items start ### -->
          <xsl:variable name="idno" select="translate(translate($element-id/tei:idno, '#', ''), ' ', '')"/>
          <xsl:variable name="links" select="$element-id/tei:link"/>
          <xsl:variable name="linked_people">
            <xsl:for-each select="$links[@type='people']/@corresp[.!='']"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
              <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/>
                <xsl:value-of select="$people/tei:person[child::tei:idno=$link][1]/tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linking_people">
            <xsl:for-each select="$people/tei:person/tei:link[@corresp[.!='']]">
              <xsl:if test="contains(concat(@corresp, ' '), concat($idno, ' '))"><xsl:value-of select="parent::tei:person/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linked_places">
            <xsl:for-each select="$links[@type='places']/@corresp[.!='']"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
              <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/>
                <xsl:value-of select="$places/tei:place[child::tei:idno=$link][1]/tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linking_places">
            <xsl:for-each select="$places/tei:place/tei:link[@corresp[.!='']]">
              <xsl:if test="contains(concat(@corresp, ' '), concat($idno, ' '))"><xsl:value-of select="parent::tei:place/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linked_jp">
            <xsl:for-each select="$links[@type='juridical_persons']/@corresp[.!='']"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
              <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/><xsl:value-of select="$juridical_persons/tei:org[child::tei:idno=$link][1]/tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linking_jp">
            <xsl:for-each select="$juridical_persons/tei:org/tei:link[@corresp[.!='']]">
              <xsl:if test="contains(concat(@corresp, ' '), concat($idno, ' '))"><xsl:value-of select="parent::tei:org/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linked_estates">
            <xsl:for-each select="$links[@type='estates']/@corresp[.!='']"><xsl:variable name="links1" select="distinct-values(tokenize(., '\s+'))"/>
              <xsl:for-each select="$links1"><xsl:variable name="link" select="translate(., '#', '')"/>
                <xsl:value-of select="$estates/tei:place[child::tei:idno=$link][1]/tei:idno"/><xsl:text> </xsl:text></xsl:for-each></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="linking_estates">
            <xsl:for-each select="$estates/tei:place/tei:link[@corresp[.!='']]">
              <xsl:if test="contains(concat(@corresp, ' '), concat($idno, ' '))"><xsl:value-of select="parent::tei:place/tei:idno"/><xsl:text> </xsl:text></xsl:if></xsl:for-each>
          </xsl:variable>
          <xsl:variable name="links_est"><xsl:for-each select="$linked_estates|$linking_estates"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
          <xsl:variable name="linkedest" select="distinct-values(tokenize(normalize-space($links_est), '\s+'))" />
          <xsl:variable name="links_jp"><xsl:for-each select="$linked_jp|$linking_jp"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
          <xsl:variable name="linkedjp" select="distinct-values(tokenize(normalize-space($links_jp), '\s+'))" />
          <xsl:variable name="links_people"><xsl:for-each select="$linked_people|$linking_people"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
          <xsl:variable name="linkedpeople" select="distinct-values(tokenize(normalize-space($links_people), '\s+'))" />
          <xsl:variable name="links_places"><xsl:for-each select="$linked_places|$linking_places"><xsl:value-of select="." /><xsl:text> </xsl:text></xsl:for-each></xsl:variable>
          <xsl:variable name="linkedplaces" select="distinct-values(tokenize(normalize-space($links_places), '\s+'))" />
          
          <xsl:if test="$element-id and $linkedjp!=''">
            <field name="index_linked_juridical_persons">
              <xsl:for-each select="$linkedjp"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
                <xsl:value-of select="substring-after($key, 'juridical_persons/')"/><xsl:text>#</xsl:text>
                <xsl:apply-templates mode="italics" select="$juridical_persons/tei:org[child::tei:idno=$key][1]/tei:orgName[1]"/><xsl:text>@</xsl:text>
                <xsl:variable name="subtype">
                    <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                      <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:if>
                  <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!=''] and $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                    <xsl:if test="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                      <xsl:for-each select="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))]/@subtype">
                        <xsl:variable name="reverse" select="."/>
                        <xsl:choose>
                          <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:when test="$link_subtypes//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$link_subtypes//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:otherwise><xsl:text>reverse_of_</xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                      </xsl:for-each>
                    </xsl:if>
                  <xsl:if test="not($links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']) and not($all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!=''])">
                    <xsl:text>linked_to_another_linked_item</xsl:text>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$subtype!=''"><xsl:text> (</xsl:text><xsl:value-of select="replace(replace(replace(lower-case(replace($subtype, '([a-z]{1})([A-Z]{1})', '$1_$2')), '#', ''), ' ', ', '), '_', ' ')"/><xsl:text>)</xsl:text></xsl:if>
                <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
                <xsl:if test="position()!=last()"><xsl:text>£</xsl:text></xsl:if>
              </xsl:for-each>
            </field>
          </xsl:if>
          
          <xsl:if test="$element-id and $linkedest!=''">
            <field name="index_linked_estates">
              <xsl:for-each select="$linkedest"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
                <xsl:value-of select="substring-after($key, 'estates/')"/><xsl:text>#</xsl:text>
                <xsl:apply-templates mode="italics" select="$estates/tei:place[child::tei:idno=$key][1]/tei:geogName[1]"/><xsl:text>@</xsl:text>
                <xsl:variable name="subtype">
                    <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                      <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:if>
                  <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!=''] and $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                    <xsl:if test="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                      <xsl:for-each select="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))]/@subtype">
                        <xsl:variable name="reverse" select="."/>
                        <xsl:choose>
                          <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:when test="$link_subtypes//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$link_subtypes//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:otherwise><xsl:text>reverse_of_</xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                      </xsl:for-each>
                    </xsl:if>
                  <xsl:if test="not($links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']) and not($all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!=''])">
                    <xsl:text>linked_to_another_linked_item</xsl:text>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$subtype!=''"><xsl:text> (</xsl:text><xsl:value-of select="replace(replace(replace(lower-case(replace($subtype, '([a-z]{1})([A-Z]{1})', '$1_$2')), '#', ''), ' ', ', '), '_', ' ')"/><xsl:text>)</xsl:text></xsl:if>
                <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
                <xsl:if test="position()!=last()"><xsl:text>£</xsl:text></xsl:if>
              </xsl:for-each>
            </field>
          </xsl:if>
          
          <xsl:if test="$element-id and $linkedplaces!=''">
            <field name="index_linked_places">
              <xsl:value-of select="concat('map.html#select#',translate(string-join($linkedplaces, '#'),'places/',''),'#')"/><xsl:text>~</xsl:text>
              <xsl:for-each select="$linkedplaces"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
                <xsl:value-of select="substring-after($key, 'places/')"/><xsl:text>#</xsl:text>
                <xsl:apply-templates mode="italics" select="$places/tei:place[child::tei:idno=$key][1]/tei:placeName[1]"/><xsl:text>@</xsl:text>
                <xsl:variable name="subtype">
                    <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                      <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:if>
                  <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!=''] and $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                    <xsl:if test="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                      <xsl:for-each select="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))]/@subtype">
                        <xsl:variable name="reverse" select="."/>
                        <xsl:choose>
                          <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:when test="$link_subtypes//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$link_subtypes//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:otherwise><xsl:text>reverse_of_</xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                      </xsl:for-each>
                    </xsl:if>
                  <xsl:if test="not($links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']) and not($all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!=''])">
                    <xsl:text>linked_to_another_linked_item</xsl:text>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$subtype!=''"><xsl:text> (</xsl:text><xsl:value-of select="replace(replace(replace(lower-case(replace($subtype, '([a-z]{1})([A-Z]{1})', '$1_$2')), '#', ''), ' ', ', '), '_', ' ')"/><xsl:text>)</xsl:text></xsl:if>
                <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
                <xsl:text>€</xsl:text>
                <!-- check if at least one of the linked places has coordinates, in order to display the 'see on map' button -->
                <xsl:if test="$all_items/tei:*[child::tei:idno=$key][1]/tei:geogName[@type='coord']/tei:geo//text()"><xsl:text>coord</xsl:text></xsl:if>
                <xsl:if test="position()!=last()"><xsl:text>£</xsl:text></xsl:if>
              </xsl:for-each>
            </field>
          </xsl:if>
          
          <xsl:if test="$element-id and $linkedpeople!=''">
            <field name="index_linked_people">
              <xsl:for-each select="$linkedpeople"><xsl:variable name="key" select="translate(translate(.,' ',''), '#', '')"/>
                <xsl:value-of select="substring-after($key, 'people/')"/><xsl:text>#</xsl:text>
                <xsl:apply-templates mode="italics" select="$people/tei:person[child::tei:idno=$key][1]/tei:persName[1]"/><xsl:text>@</xsl:text>
                <xsl:variable name="subtype">
                    <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']">
                      <xsl:value-of select="$links[contains(concat(@corresp, ' '), concat($key, ' '))]/@subtype"/></xsl:if>
                  <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!=''] and $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                    <xsl:if test="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!='']">
                      <xsl:for-each select="$all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))]/@subtype">
                        <xsl:variable name="reverse" select="."/>
                        <xsl:choose>
                          <xsl:when test="$thesaurus//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$thesaurus//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:when test="$link_subtypes//tei:catDesc[@n=$reverse][@corresp!='']"><xsl:value-of select="$link_subtypes//tei:catDesc[@n=$reverse]/@corresp"/></xsl:when>
                          <xsl:otherwise><xsl:text>reverse_of_</xsl:text><xsl:value-of select="$reverse"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                      </xsl:for-each>
                    </xsl:if>
                  <xsl:if test="not($links[contains(concat(@corresp, ' '), concat($key, ' '))][@subtype!='']) and not($all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@subtype!=''])">
                    <xsl:text>linked_to_another_linked_item</xsl:text>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$subtype!=''"><xsl:text> (</xsl:text><xsl:value-of select="replace(replace(replace(lower-case(replace($subtype, '([a-z]{1})([A-Z]{1})', '$1_$2')), '#', ''), ' ', ', '), '_', ' ')"/><xsl:text>)</xsl:text></xsl:if>
                <xsl:if test="$links[contains(concat(@corresp, ' '), concat($key, ' '))][@cert='low'] or $all_items/tei:*[child::tei:idno=$key][1]/tei:link[contains(concat(translate(@corresp, '#', ''), ' '), concat($idno, ' '))][@cert='low']"><xsl:text> [</xsl:text>from uncertain tradition<xsl:text>]</xsl:text></xsl:if>
                <xsl:if test="position()!=last()"><xsl:text>£</xsl:text></xsl:if>
              </xsl:for-each>
            </field>
          </xsl:if>
          <!-- ### Linked items end ### -->
          <xsl:apply-templates select="$item" />
        </doc>
      </xsl:for-each>
    
      <xsl:for-each-group select="//tei:placeName[ancestor::tei:div/@type='edition'][not(@ref) or @ref='']" group-by="lower-case(.)">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
                <xsl:text>~ </xsl:text>
                <xsl:choose>
                  <xsl:when test="starts-with(normalize-space(.), '\s')"><xsl:value-of select="substring(normalize-space(.), 2)"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                </xsl:choose>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:placeName[ancestor::tei:div[@type='edition']]">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
