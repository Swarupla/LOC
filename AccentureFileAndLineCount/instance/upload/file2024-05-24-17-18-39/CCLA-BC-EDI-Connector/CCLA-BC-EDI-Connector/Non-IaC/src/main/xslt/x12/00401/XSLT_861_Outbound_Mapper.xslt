<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" exclude-result-prefixes="msxsl var userJScript"
                version="1.0" xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output omit-xml-declaration="yes" method="xml" version="1.0" />
    
    <xsl:template match="formatDate" name="formatDate">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring-before($date, 'T') , '-','')"/>
    </xsl:template>
    
    <xsl:template match="formatTime" name="formatTime">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring(substring-after($date,'T') , 0,9),':','')"/>
    </xsl:template>
    
    <xsl:template match="/result/isUpdate" name="checkBRA01">
        <xsl:choose>
            <xsl:when test="/isUpdate = true">
                <BRA03>04</BRA03>
            </xsl:when>
            <xsl:otherwise>
                <BRA03>00</BRA03>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
    var counter = 0;
    function increment(){
        counter = counter + 1;
        return counter
    }

    function today()
    {
          var d = new Date();
    return d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate())
           + 'T' 
           + pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes()) + ':' + pad(d.getUTCSeconds())
           + '.000Z';
    } 

    function pad(num) {
    return (num < 10) ? '0' + num : '' + num;
  }
]]>
    </msxsl:script>
    <xsl:template match="/result">
        <xsl:call-template name="dataset">
            <xsl:with-param name="data" select="data" />
        </xsl:call-template>
    </xsl:template>
    <!-- <xsl:import href="xsl-js.xsl"/> -->
    <xsl:template name="dataset">
        <xsl:param name="data" select="@data"/>
        <xsl:for-each select="$data">
            <xsl:choose>
                <xsl:when test="isDelete = 'true'">
                    <ns0:X12_00401_861>
                        <!-- TODO Update Payload for Delete -->
                        <ST>
                            <ST01>861</ST01>
                            <ST02>000000001</ST02>
                        </ST>
                        <ns0:BRA>
                            <!-- TODO , Update for LSP to be created for T2 -->
                            
                            <BRA01>
                                <xsl:value-of select="id" />
                            </BRA01>
                            <BRA02>
                                 <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="userJScript:today()" />
                                </xsl:call-template>
                            </BRA02>
                            <BRA03>03</BRA03>
                            <BRA04>2</BRA04>
                            <BRA05>0000</BRA05>
                        </ns0:BRA>
                        <ns0:DTM>
                                <DTM01>
                                    <xsl:value-of select="'050'" />
                                </DTM01>
                                <DTM02>
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="userJScript:today()" />
                                    </xsl:call-template>
                                </DTM02>
                                <DTM03>000000</DTM03>
                                <DTM04>UT</DTM04>
                        </ns0:DTM>  
                    </ns0:X12_00401_861>
                </xsl:when>
                <xsl:otherwise>
                    <ns0:X12_00401_861>
                        <!-- TODO Update Payload for Delete -->
                        <ST>
                            <ST01>861</ST01>
                            <ST02>000000001</ST02>
                        </ST>
                        <ns0:BRA>
                            
                            <!-- <BEG01>00</BEG01> -->
                            <BRA01>
                                <xsl:value-of select="grNumber" />
                            </BRA01>
                            <xsl:for-each select="dtm">
                                <xsl:if test="(dateQualf = '050')">
                                    <BRA02>
                                        <xsl:call-template name="formatDate">
                                            <xsl:with-param name="date" select="date" />
                                        </xsl:call-template>
                                    </BRA02>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:call-template name="checkBRA01">
                            </xsl:call-template>
                            <BRA04>2</BRA04>
                            <BRA05>0000</BRA05>
                        </ns0:BRA>
                        <xsl:for-each select="ref">
                            <xsl:choose>
                                <xsl:when test="(idQualf = 'AS')">
                                    <ns0:REF>
                                        <REF01>MA</REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <xsl:if test="(string-length(desc) != 0)">
                                            <REF03>
                                                <xsl:value-of select="desc" />
                                            </REF03>
                                        </xsl:if>
                                    </ns0:REF>
                                </xsl:when>
                                <xsl:when test="(idQualf = 'ZP')">
                                    <ns0:REF>
                                        <REF01>PE</REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <xsl:if test="(string-length(desc) != 0)">
                                            <REF03>
                                                <xsl:value-of select="desc" />
                                            </REF03>
                                        </xsl:if>
                                    </ns0:REF>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="idQualf != 'ZF'">
                                        <ns0:REF>
                                            <REF01>
                                                <xsl:value-of select="idQualf" />
                                            </REF01>
                                            <REF02>
                                                <xsl:value-of select="id" />
                                            </REF02>
                                            <xsl:if test="(string-length(desc) != 0)">
                                                <REF03>
                                                    <xsl:value-of select="desc" />
                                                </REF03>
                                            </xsl:if>
                                        </ns0:REF>
                                    </xsl:if>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:for-each select="dtm">
                            <ns0:DTM>
                                <DTM01>
                                    <xsl:value-of select="dateQualf" />
                                </DTM01>
                                <DTM02>
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="date" />
                                    </xsl:call-template>
                                </DTM02>
                                <DTM03>
                                    <xsl:variable name="time" select="date" />
                                    <xsl:call-template name="formatTime">
                                        <xsl:with-param name="date" select="$time" />
                                    </xsl:call-template>
                                </DTM03>
                                <DTM04>UT</DTM04>
                            </ns0:DTM>                            
                        </xsl:for-each>
                        
                        
                        
                        <xsl:for-each select="lineItems">
                            <ns0:RCDLoop1>
                                <ns0:RCD>
                                    <RCD01><xsl:value-of select="line"/></RCD01>
                                    <xsl:for-each select="qty">
                                        <RCD02><xsl:value-of select="value"/></RCD02>
                                        <ns0:C001_2>
                                            <C00101><xsl:value-of select="uom"/></C00101>
                                        </ns0:C001_2>
                                    </xsl:for-each>
                                    <RCD04><xsl:value-of select="qty/value"/></RCD04>
                                    <ns0:C001_3>
                                            <C00101><xsl:value-of select="uom"/></C00101>
                                        </ns0:C001_3>
                                    <RCD08><xsl:value-of select="grType"/></RCD08>
                                </ns0:RCD>
                                <ns0:LIN>
                                    <LIN01><xsl:value-of select="line"/></LIN01>
                                    <xsl:for-each select="product">
                                        <xsl:if test="productQualf = 'VP'">
                                            <LIN02>MG</LIN02>
                                            <LIN03>
                                                <xsl:value-of select="value"/>
                                            </LIN03>
                                        </xsl:if>
                                    </xsl:for-each>
                                    
                                    <xsl:for-each select="product">
                                        
                                        <xsl:if test="productQualf = 'BP'">
                                            <LIN04>BP</LIN04>
                                            <LIN05>
                                                <xsl:value-of select="value"/>
                                            </LIN05>
                                        </xsl:if>
                                    </xsl:for-each>
                                    
                                    <xsl:for-each select="product">
                                        
                                        <xsl:if test="productQualf = 'ZM'">
                                            <LIN06>ZZ</LIN06>
                                            <LIN07>
                                                <xsl:value-of select="value"/>
                                            </LIN07>
                                        </xsl:if>
                                    </xsl:for-each>
                                </ns0:LIN>
                                <xsl:for-each select="ref">
                                    <xsl:choose>
                                        <xsl:when test="(idQualf = 'AS')">
                                            <ns0:REF_3>
                                                <REF01>MA</REF01>
                                                <REF02>
                                                    <xsl:value-of select="id" />
                                                </REF02>
                                                <xsl:if test="(string-length(desc) != 0)">
                                                    <REF03>
                                                        <xsl:value-of select="desc" />
                                                    </REF03>
                                                </xsl:if>
                                            </ns0:REF_3>
                                        </xsl:when>
                                        <xsl:when test="(idQualf = 'ZP')">
                                            <ns0:REF_3>
                                                <REF01>PE</REF01>
                                                <REF02>
                                                    <xsl:value-of select="id" />
                                                </REF02>
                                                <xsl:if test="(string-length(desc) != 0)">
                                                    <REF03>
                                                        <xsl:value-of select="desc" />
                                                    </REF03>
                                                </xsl:if>
                                            </ns0:REF_3>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="idQualf != 'ZF'">
                                                <ns0:REF_3>
                                                    <REF01>
                                                        <xsl:value-of select="idQualf" />
                                                    </REF01>
                                                    <REF02>
                                                        <xsl:value-of select="id" />
                                                    </REF02>
                                                    <xsl:if test="(string-length(desc) != 0)">
                                                        <REF03>
                                                            <xsl:value-of select="desc" />
                                                        </REF03>
                                                    </xsl:if>
                                                </ns0:REF_3>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:call-template name="handlingUnits">
                                    <xsl:with-param name="data" select="$data" />
                                </xsl:call-template>
                            </ns0:RCDLoop1>
                        </xsl:for-each>
                    </ns0:X12_00401_861>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="handlingUnits">
        <xsl:param name="data" select="@data"/>
        <xsl:for-each select="$data">
            <xsl:for-each select="handlingUnits">
                <ns0:MAN>
                    
                    <xsl:choose>
                        <xsl:when test="huType='CARTON'">
                            <MAN01><xsl:value-of select="'MC'"/></MAN01>
                        </xsl:when>
                        <xsl:when test="huType='PALLET'">
                            <MAN01><xsl:value-of select="'W'"/></MAN01>
                        </xsl:when>
                    </xsl:choose>
                    
                    <MAN02><xsl:value-of select="huId"/></MAN02>
                    <MAN04><xsl:value-of select="huIdQualf"/></MAN04>
                </ns0:MAN>
                
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>