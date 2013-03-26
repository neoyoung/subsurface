<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="commonTemplates.xsl"/>
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>

  <xsl:template match="/divelog/dives">
    <uddf version="3.2.0">
      <generator>
        <manufacturer id="subsurface">
          <name>Subsurface Team</name>
          <contact>http://subsurface.hohndel.org/</contact>
        </manufacturer>
        <version>
          <xsl:value-of select="/divelog/@version"/>
        </version>
        <xsl:if test="/divelog/generator/@date != ''">
          <datetime>
            <xsl:value-of select="concat(/divelog/generator/@date, 'T', /divelog/generator/@time)"/>
          </datetime>
        </xsl:if>
      </generator>

      <diver>
        <owner id="1">
          <equipment>
            <xsl:for-each select="/divelog/settings/divecomputerid">
              <divecomputer id="{./@deviceid}">
                <name>
                  <xsl:choose>
                    <xsl:when test="./@nickname != ''">
                      <xsl:value-of select="./@nickname"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="./@model"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </name>
                <model>
                  <xsl:value-of select="./@model"/>
                </model>
              </divecomputer>
            </xsl:for-each>
          </equipment>
        </owner>
      </diver>

      <!-- Gas definitions is not yet working, so it is commented out
           -->
      <xsl:if test="'asdf' = ''">
        <gasdefinitions>
          <xsl:for-each select="dive/cylinder">
            <mix id="{generate-id(.)}">
              <name>
                <xsl:value-of select="concat(./@o2, '/', ./he)"/>
              </name>
              <o2>
                <xsl:value-of select="./@o2"/>
              </o2>
              <he>
                <xsl:value-of select="./@he"/>
              </he>
            </mix>
          </xsl:for-each>
        </gasdefinitions>
      </xsl:if>


      <profiledata>
        <xsl:for-each select="trip">
          <repetitiongroup id="{generate-id(.)}">
            <xsl:apply-templates select="dive"/>
          </repetitiongroup>
        </xsl:for-each>
        <xsl:for-each select="dive">
          <repetitiongroup id="{generate-id(.)}">
            <xsl:apply-templates select="."/>
          </repetitiongroup>
        </xsl:for-each>
      </profiledata>
    </uddf>
  </xsl:template>

  <xsl:template match="dive">
    <dive id="{generate-id(.)}">

      <informationbeforedive>
        <xsl:if test="node()/temperature/@air != ''">
          <airtemperature>
            <xsl:value-of select="format-number(substring-before(node()/temperature/@air, ' ') + 273.15, '0.00')"/>
          </airtemperature>
        </xsl:if>
        <datetime>
          <xsl:value-of select="concat(./@date, 'T', ./@time)"/>
        </datetime>
        <divenumber>
          <xsl:value-of select="./@number"/>
        </divenumber>
      </informationbeforedive>

      <samples>
        <xsl:for-each select="./divecomputer[1]/sample">
          <waypoint>
            <depth>
              <xsl:value-of select="substring-before(./@depth, ' ')"/>
            </depth>
            <divetime>
              <xsl:call-template name="time2sec">
                <xsl:with-param name="time">
                  <xsl:value-of select="./@time"/>
                </xsl:with-param>
              </xsl:call-template>
            </divetime>
            <xsl:if test="./@pressure != ''">
              <tankpressure>
                <xsl:value-of select="substring-before(./@pressure, ' ')"/>
              </tankpressure>
            </xsl:if>
            <xsl:if test="./@temp != ''">
              <temperature>
                <xsl:value-of select="format-number(substring-before(./@temp, ' ') + 273.15, '0.00')"/>
              </temperature>
            </xsl:if>
          </waypoint>
        </xsl:for-each>
      </samples>

      <tankdata>
        <xsl:if test="./cylinder[1]/@size">
          <tankvolume>
            <xsl:value-of select="substring-before(./cylinder[1]/@size, ' ')"/>
          </tankvolume>
        </xsl:if>
        <xsl:if test="./cylinder[1]/@start">
          <tankpressurebegin>
            <xsl:value-of select="substring-before(./cylinder[1]/@start, ' ')"/>
          </tankpressurebegin>
        </xsl:if>
        <xsl:if test="./cylinder[1]/@end">
          <tankpressureend>
            <xsl:value-of select="substring-before(./cylinder[1]/@end, ' ')"/>
          </tankpressureend>
        </xsl:if>
      </tankdata>

      <informationafterdive>
        <xsl:if test="node()/depth/@max != ''">
          <greatestdepth>
            <xsl:value-of select="substring-before(node()/depth/@max, ' ')"/>
          </greatestdepth>
        </xsl:if>
        <xsl:if test="node()/depth/@mean != ''">
          <averagedepth>
            <xsl:value-of select="substring-before(node()/depth/@mean, ' ')"/>
          </averagedepth>
        </xsl:if>
        <xsl:if test="./@duration != ''">
          <diveduration>
            <xsl:call-template name="time2sec">
              <xsl:with-param name="time">
                <xsl:value-of select="./@duration"/>
              </xsl:with-param>
            </xsl:call-template>
          </diveduration>
        </xsl:if>
        <xsl:if test="node()/temperature/@water != ''">
          <lowesttemperature>
            <xsl:value-of select="format-number(substring-before(node()/temperature/@water, ' ') + 273.15, '0.00')"/>
          </lowesttemperature>
        </xsl:if>
        <notes>
          <para>
            <xsl:value-of select="notes"/>
          </para>
        </notes>
        <rating>
          <ratingvalue>
            <xsl:choose>
              <xsl:when test="./@rating = 0">
                <xsl:value-of select="'1'"/>
              </xsl:when>
              <xsl:when test="./@rating != ''">
                <xsl:value-of select="./@rating * 2"/>
              </xsl:when>
            </xsl:choose>
          </ratingvalue>
        </rating>
      </informationafterdive>

    </dive>
  </xsl:template>
</xsl:stylesheet>