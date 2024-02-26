<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:t="http://www.tei-c.org/ns/1.0">
    <ns uri="http://www.tei-c.org/ns/1.0" prefix="t"/>
    
    <!-- ITEMS NAMES -->
    <pattern  id="Test_names_not_to_be_empty">
        <rule context="//t:placeName[not(@type='other')][ancestor::t:listPlace[@type='places']]">
            <report test="normalize-space(.)=''">one or more place names are empty</report>
        </rule>
        <rule context="//t:geogName[not(@type='other')][ancestor::t:listPlace[@type='estates']]">
            <report test="normalize-space(.)=''">one or more estates names are empty</report>
        </rule>
        <rule context="//t:orgName[not(@type='other')][ancestor::t:listOrg]">
            <report test="normalize-space(.)=''">one or more juridical person names are empty</report>
        </rule>
        <rule context="//t:persName[not(@type='other')][ancestor::t:listPerson]">
            <report test="normalize-space(.)=''">one or more person names are empty</report>
        </rule>
    </pattern>
    
    <pattern  id="Test_names_not_to_contain_commas">
        <rule context="//t:placeName[not(@type='other')][ancestor::t:listPlace[@type='places']]">
            <report test="contains(., ',')">one or more place names contains commas (,): replace them with semicolons (;)</report>
        </rule>
        <rule context="//t:geogName[not(@type='other')][ancestor::t:listPlace[@type='estates']]">
            <report test="contains(., ',')">one or more estates names contains commas (,): replace them with semicolons (;)</report>
        </rule>
        <rule context="//t:orgName[not(@type='other')][ancestor::t:listOrg]">
            <report test="contains(., ',')">one or more juridical person names contains commas (,): replace them with semicolons (;)</report>
        </rule>
        <rule context="//t:persName[not(@type='other')][ancestor::t:listPerson]">
            <report test="contains(., ',')">one or more person names contains commas (,): replace them with semicolons (;)</report>
        </rule>
    </pattern>
    
    <pattern id="Test_presence_of_main_name">
        <rule context="//t:place[ancestor::t:listPlace[@type='places']]">
            <report test="not(descendant::t:placeName[not(@type='other')][.//text()])">one or more places are without (main) name</report>
        </rule>
        <rule context="//t:place[ancestor::t:listPlace[@type='estates']]">
            <report test="not(descendant::t:geogName[not(@type='other')][.//text()])">one or more estates are without (main) name</report>
        </rule>
        <rule context="//t:org[ancestor::t:listOrg]">
            <report test="not(descendant::t:orgName[not(@type='other')][.//text()])">one or more juridical persons are without (main) name</report>
        </rule>
        <rule context="//t:person[ancestor::t:listPerson]">
            <report test="not(descendant::t:persName[not(@type='other')][.//text()])">one or more persons are without (main) name</report>
        </rule>
    </pattern>
    
    <!-- ITEMS IDNOS -->
    <pattern id="Test_idno_correctness">
        <rule context="//t:idno[ancestor::t:listPlace or ancestor::t:listOrg or ancestor::t:listPerson]">
            <report test="substring-after(., '/')=''">one or more ID are emtpy</report>
            <report test="matches(substring-after(., '/'), '.*\D+?.*')">one or more ID are not in the correct form (because after the '/' they contain letters or symbols or spaces instead of only numbers)</report>
        </rule>
        <rule context="//t:idno[ancestor::t:listPlace[@type='places']]">
            <report test="not(starts-with(.,'places/'))">one or more places ID are not starting with 'places/'</report>
        </rule>
        <rule context="//t:idno[ancestor::t:listPlace[@type='estates']]">
            <report test="not(starts-with(.,'estates/'))">one or more estates ID are not starting with 'estates/'</report>
        </rule>
        <rule context="//t:idno[ancestor::t:listOrg]">
            <report test="not(starts-with(.,'juridical_persons/'))">one or more juridical persons ID are not starting with 'juridical_persons/'</report>
        </rule>
        <rule context="//t:idno[ancestor::t:listPerson]">
            <report test="not(starts-with(.,'people/'))">one or more persons ID are not starting with 'people/'</report>
        </rule>
    </pattern>
    
    <pattern id="Test_idno_uniqueness">
        <rule context="//t:place[ancestor::t:listPlace[@type='places']]">
            <report test="t:idno/text()=following-sibling::t:place/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=preceding-sibling::t:place/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listPlace/following-sibling::t:listPlace//t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listPlace/preceding-sibling::t:listPlace//t:idno/text()">one or more ID have duplicates</report>
        </rule>
        <rule context="//t:place[ancestor::t:listPlace[@type='estates']]">
            <report test="t:idno/text()=following-sibling::t:place/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=preceding-sibling::t:place/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listPlace/following-sibling::t:listPlace//t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listPlace/preceding-sibling::t:listPlace//t:idno/text()">one or more ID have duplicates</report>
        </rule>
        <rule context="//t:org[ancestor::t:listOrg]">
            <report test="t:idno/text()=following-sibling::t:org/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=preceding-sibling::t:org/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listOrg/following-sibling::t:listOrg//t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listOrg/preceding-sibling::t:listOrg//t:idno/text()">one or more ID have duplicates</report>
        </rule>
        <rule context="//t:person[ancestor::t:listPerson]">
            <report test="t:idno/text()=following-sibling::t:person/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=preceding-sibling::t:person/t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listPerson/following-sibling::t:listPerson//t:idno/text()">one or more ID have duplicates</report>
            <report test="t:idno/text()=parent::t:listPerson/preceding-sibling::t:listPerson//t:idno/text()">one or more ID have duplicates</report>
        </rule>
    </pattern>
    
    <!-- ITEMS LINKS -->
    <pattern id="Test_links_type_values_correctness">
        <rule context="//t:link[ancestor::t:listPlace or ancestor::t:listOrg or ancestor::t:listPerson]">
            <report test="not(@type)">one or more links are without @type</report>
            <report test="not(@subtype)">one or more links are without @subtype</report>
            <report test="not(@type='places' or @type='estates' or @type='people' or @type='juridical_persons')">one or more links have a wrong @type value</report>
        </rule>
    </pattern>
    
    <pattern id="Test_links_corresp_values_correctness">
        <rule context="//t:link[ancestor::t:listPlace or ancestor::t:listOrg or ancestor::t:listPerson]">
            <report test="not(@corresp)">one or more links are pointing to nothing</report>
            <report test="ends-with(@corresp, ' ')">one or more links have extra spaces</report>
            <!-- the following rules have been commented out because were causing issues on some Oxygen versions -->
            <!--<report test="@type='places' and not(matches(concat(' ', @corresp), '^(((\s+?)#places/(\d+?))+?)$'))">one or more links to places are not correct</report>
            <report test="@type='estates' and not(matches(concat(' ', @corresp), '^(((\s+?)#estates/(\d+?))+?)$'))">one or more links to estates are not correct</report>
            <report test="@type='people' and not(matches(concat(' ', @corresp), '^(((\s+?)#people/(\d+?))+?)$'))">one or more links to people are not correct</report>
            <report test="@type='juridical_persons' and not(matches(concat(' ', @corresp), '^(((\s+?)#juridical_persons/(\d+?))+?)$'))">one or more links to juridical persons are not correct</report>-->
            <!-- the following rules replace *partly* the commented-out rules above -->
            <report test="@type='places' and not(contains(@corresp, '#places/'))">one or more links to places are not correct</report>
            <report test="@type='estates' and not(contains(@corresp, '#estates/'))">one or more links to estates are not correct</report>
            <report test="@type='people' and not(contains(@corresp, '#people/'))">one or more links to people are not correct</report>
            <report test="@type='juridical_persons' and not(contains(@corresp, '#juridical_persons/'))">one or more links to juridical persons are not correct</report>
        </rule>
    </pattern>
    
    <pattern id="Test_links_corresp_to_point_to_existing_items">
        <!-- handling just the first item in multi-value @corresp, and just links to items that are in the same list;
            needed handling of following items in multi-value @corresp, of items from other lists, of placeholder 'XXX' items -->
        <rule context="//t:link[ancestor::t:listPlace[@type='estates']]">
            <report test="@type='estates' and not(contains(@corresp, ' ')) and not(substring-after(@corresp, '#')=ancestor::t:listPlace[@type='estates']//t:idno)">one or more links are pointing to an unexisting estate!</report>
            <report test="@type='estates' and contains(@corresp, ' ') and not(substring-after(substring-before(@corresp, ' '), '#')=ancestor::t:listPlace[@type='estates']//t:idno)">one or more links are pointing to an unexisting estate!</report>
        </rule>
        <rule context="//t:link[ancestor::t:listPlace[@type='places']]">
            <!-- The following has been commented because it was raising errors even with some correct links to existing places. TODO: investigate why -->
            <!--<report test="@type='places' and not(contains(@corresp, ' ')) and not(substring-after(@corresp, '#')=ancestor::t:listPlace[@type='places']//t:idno)">one or more links are pointing to an unexisting place!</report>-->
            <report test="@type='places' and contains(@corresp, ' ') and not(substring-after(substring-before(@corresp, ' '), '#')=ancestor::t:listPlace[@type='places']//t:idno)">one or more links are pointing to an unexisting place!</report>
        </rule>
        <rule context="//t:link[ancestor::t:listPerson]">
            <report test="@type='people' and not(contains(@corresp, ' ')) and not(substring-after(@corresp, '#')=ancestor::t:listPerson//t:idno)">one or more links are pointing to an unexisting person!</report>
            <report test="@type='people' and contains(@corresp, ' ') and not(substring-after(substring-before(@corresp, ' '), '#')=ancestor::t:listPerson//t:idno)">one or more links are pointing to an unexisting person!</report>
        </rule>
        <rule context="//t:link[ancestor::t:listOrg]">
            <report test="@type='juridical_persons' and not(contains(@corresp, ' ')) and not(substring-after(@corresp, '#')=ancestor::t:listOrg//t:idno)">one or more links are pointing to an unexisting juridical person!</report>
            <report test="@type='juridical_persons' and contains(@corresp, ' ') and not(substring-after(substring-before(@corresp, ' '), '#')=ancestor::t:listOrg//t:idno)">one or more links are pointing to an unexisting juridical person!</report>
        </rule>
    </pattern>
    
    <!-- PLACES COORDINATES -->
    <pattern id="Test_coordinates_correctness">
        <rule context="//t:geo[text()!=''][@style='line']|//t:geo[not(@style='line')][contains(., ';')]">
            <report test="not(matches(., '^(\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1};\s+?)+\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}$'))">The coordinates of one or more places are not correct. Examples: POINT: 43.575, 11.871 POLYGON/LINE: 45.351, 9.475; 45.345, 9.477; 45.346, 9.481</report>
        </rule>
        <rule context="//t:geo[text()!=''][not(@style='line')][not(contains(., ';'))]">
            <report test="not(matches(., '^\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}$'))">The coordinates of one or more places are not correct. Examples: POINT: 43.575, 11.871 POLYGON/LINE: 45.351, 9.475; 45.345, 9.477; 45.346, 9.481</report>
        </rule>
    </pattern>
    
    <!-- add checker for @key/@ref in documents? -->
    
</schema>
