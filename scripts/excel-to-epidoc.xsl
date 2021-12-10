<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.tei-c.org/ns/1.0" xml:space="preserve">
<xsl:output method="xml"/>
    
<xsl:template match="Row">
<?xml-model href="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader xml:lang="en">
        <fileDesc>
            <titleStmt>
                <title><xsl:apply-templates select="./Cell[2]/Data"/></title>
            </titleStmt>
            <editionStmt>
                <edition>Digital edition encoded for <ref target="http://fiscus.unibo.it">Fiscus Project</ref>
                    <date when="2021">2021</date>
                </edition>
            </editionStmt>
            <publicationStmt>
                <publisher>Fiscus - DISCI UniBo</publisher>
                <idno type="filename">doc<xsl:apply-templates select="substring-before(substring-after(./Cell[15]/Data, 'https://fiscus.unibo.it/en/documents/doc'), '.html')"/></idno>
                <availability xml:lang="en" status="free">
                    <licence target="http://creativecommons.org/licenses/by-sa/4.0/">Metadata and
                        texts are released as Creative Commons, Attribution-ShareAlike 4.0 (CC BY-SA
                        4.0)</licence>
                </availability>
                <date when="2021"/>
            </publicationStmt>
            <sourceDesc>
                <msDesc>
                    <msIdentifier>
                        <altIdentifier>
                            <idno type="uri"/>
                        </altIdentifier>
                    </msIdentifier>
                    <msContents>
                        <summary>
                            <rs type="text_type" ref="#"><xsl:apply-templates select="./Cell[8]/Data"/></rs>
                            <rs type="record_source" ref="#"></rs>
                            <rs type="document_tradition" ref="#"></rs>
                            <rs type="fiscal_property"/>
                        </summary>
                        <msItem xml:id="msItem1">
                            <textLang mainLang="" otherLangs=""/>
                        </msItem>
                    </msContents>
                    <history>
                        <origin>
                            <xsl:variable name="cell5">
                                <xsl:if test="string-length(substring-after(substring-after(./Cell[5]/Data/text(), '-'), '-'))=3"><xsl:text>0</xsl:text></xsl:if>
                                <xsl:value-of select="normalize-space(substring-after(substring-after(./Cell[5]/Data/text(), '-'), '-'))"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="normalize-space(substring-before(substring-after(./Cell[5]/Data/text(), '-'), '-'))"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="normalize-space(substring-before(./Cell[5]/Data/text(), '-'))"/>
                            </xsl:variable>
                            <xsl:variable name="cell6">
                                <xsl:if test="string-length(substring-after(substring-after(./Cell[6]/Data/text(), '-'), '-'))=3"><xsl:text>0</xsl:text></xsl:if>
                                <xsl:value-of select="normalize-space(substring-after(substring-after(./Cell[6]/Data/text(), '-'), '-'))"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="normalize-space(substring-before(substring-after(./Cell[6]/Data/text(), '-'), '-'))"/>
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="normalize-space(substring-before(./Cell[6]/Data/text(), '-'))"/>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="./Cell[6]/Data='-'">
                             <origDate when="{translate(translate(string-join($cell5), ' ', ''), '&#xA;', '')}">
                                <note type="displayed_date"><xsl:apply-templates select="./Cell[7]/Data"/></note>
                                <note type="dating_elements"></note>
                                <note type="topical_date"><xsl:apply-templates select="./Cell[13]/Data"/></note>
                                <note type="redaction_date"></note>
                            </origDate>
                                </xsl:when>
                                <xsl:otherwise>
                            <origDate notBefore="{translate(translate(string-join($cell5), ' ', ''), '&#xA;', '')}" notAfter="{translate(translate(string-join($cell6), ' ', ''), '&#xA;', '')}">
                                <note type="displayed_date"><xsl:apply-templates select="./Cell[7]/Data"/></note>
                                <note type="dating_elements"></note>
                                <note type="topical_date"><xsl:apply-templates select="./Cell[13]/Data"/></note>
                                <note type="redaction_date"></note>
                            </origDate>
                                </xsl:otherwise>
                            </xsl:choose>
                            <origPlace/>
                        </origin>
                        <provenance type="findspot">
                            <location>
                                <placeName/>
                            </location>
                        </provenance>
                    </history>
                </msDesc>
                <listPlace>
            <place></place>
        </listPlace>
        <listPerson>
            <person></person>
        </listPerson>
            </sourceDesc>
        </fileDesc>
        <profileDesc>
            <textClass>
                <keywords>
                    <term/>
                </keywords>
            </textClass>
        </profileDesc>
        <revisionDesc>
            <listChange>
                <change when="2021-09-07" who="emanarini">creation of record</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
    <text>
        <body>
            <div type="edition">
                <div type="textpart">
                    <ab><xsl:apply-templates select="./Cell[9]/Data"/></ab>
                    <ab>Autore: <xsl:apply-templates select="./Cell[10]/Data"/>. Destinatario: <xsl:apply-templates select="./Cell[11]/Data"/>. Antroponimi: <xsl:apply-templates select="./Cell[12]/Data"/>. Toponimi: <xsl:apply-templates select="./Cell[14]/Data"/>.</ab>
                </div>
            </div>
            <div type="bibliography" subtype="editions">
                <p></p>
            </div>
            <div type="bibliography" subtype="additional">
                <p></p>
            </div>
            <div type="bibliography" subtype="links">
                <p>Lodovico Media Library: <ref>https://lodovico.medialibrary.it/media/schedadl.aspx?id=<xsl:value-of select="./Cell[3]/Data"/></ref></p>
            </div>
            <div type="commentary">
                 <p><xsl:apply-templates select="./Cell[1]/Data"/>. <xsl:apply-templates select="./Cell[4]/Data"/>. <xsl:apply-templates select="substring-before(./Cell[15]/Data, 'https://fiscus.unibo.it/en/documents/')"/></p>
            </div>
        </body>
    </text>
</TEI>
</xsl:template>
</xsl:stylesheet>