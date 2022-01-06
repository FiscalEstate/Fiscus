<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="response/result" mode="text-index">
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
    <table class="index tablesorter" style="width:100%">
      <thead>
        <tr style="height:3em">
          <th>ID</th>
          <th>Title</th>
          <th style="width:13em">Date</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates mode="text-index" select="doc">
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
  </xsl:template>

  <xsl:template match="result[not(doc)]" mode="text-index">
    <p>There are no files indexed from webapps/ROOT/content/xml/epidoc!
    Put some there, index them from the admin page, and this page will become much more interesting.</p>
  </xsl:template>

  <xsl:template match="result/doc" mode="text-index">
    <tr style="height:3em">
      <td><a href="{kiln:url-for-match($match_id, ($language, substring-after(str[@name='file_path'], '/')), 0)}"><xsl:value-of select="substring-after(substring-after(str[@name='file_path'], '/'), 'doc')" /></a></td>
      <td><xsl:value-of select="string-join(arr[@name='document_title']/str, '; ')" /></td>
      <td>
        <xsl:value-of select="str[@name='document_date']"/>
        </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
