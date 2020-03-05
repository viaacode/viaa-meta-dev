<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mm="http://www.meemoo.be/namespaces"
  exclude-result-prefixes="xs mm" version="2.0">

  <xsl:output omit-xml-declaration="yes" />

  <!-- Vul hier verschillende EXIF dates in om te testen -->
  <xsl:variable name="test-date" select="'2014:07:29 15:32:34'" as="xs:string" />

  <xsl:function name="mm:exif-to-iso-datetime" as="xs:date">
    <xsl:param name="exif-input" as="xs:string" />
    <xsl:variable name="date-part" select="xs:string(tokenize($exif-input, ' ')[1])" />
    <xsl:variable name="date" select="xs:date(concat(
        tokenize($date-part, ':')[1],'-',
        tokenize($date-part, ':')[2],'-',
        tokenize($date-part, ':')[3]))" />
    <xsl:value-of select="$date"/>
  </xsl:function>

  <xsl:function name="mm:exif-to-iso-datestring" as="xs:string">
    <xsl:param name="exif-input" as="xs:string" />
    <xsl:variable name="date-part" select="xs:string(tokenize($exif-input, ' ')[1])" />
    <xsl:variable name="date" select="xs:string(concat(
        tokenize($date-part, ':')[1],'-',
        tokenize($date-part, ':')[2],'-',
        tokenize($date-part, ':')[3]))" />
    <xsl:value-of select="$date"/>
  </xsl:function>

  <xsl:template match="/">
    <iso-date>
      <!-- Switch hier tss de functies:
        - mm:exif-to-iso-datetime: dan moet de input effectief een valid date zijn
        - mm:exif-to-iso-datestring: dan moet de input simpelweg voldoen aan 'xxxx:xx:xx'
      -->
      <xsl:value-of select="mm:exif-to-iso-datetime($test-date)" />
    </iso-date>
  </xsl:template>

</xsl:stylesheet>
