<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" exclude-result-prefixes="msxsl var userJScript"
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output method="text" indent="yes"/>
    
    <xsl:template match="formatDate" name="formatDate">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring-before($date, 'T') , '-','')"/>
    </xsl:template>
    
    <xsl:template match="formatTime" name="formatTime">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring(substring-after($date,'T') , 0,9),':','')"/>
    </xsl:template>
    
    <xsl:template match="/result/isUpdate" name="checkBAK01">
         <xsl:choose>
                            <xsl:when test="/isUpdate = true">
                                <BAK01>04</BAK01>
                            </xsl:when>
                            <xsl:otherwise>
                                   <BAK01>00</BAK01>
                            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- <xsl:import href="xsl-js.xsl"/> -->
   <xsl:template match="/result">
        <xsl:call-template name="dataset">
            <xsl:with-param name="data" select="data" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="dataset">
        <xsl:param name="data" select="@data"/>
        <xsl:for-each select="$data">
            <ns0:X12_00401_855>
                <ST>
                    <ST01>855</ST01>
                    <ST02>00001</ST02>
                </ST>
                <ns0:BAK>
                     <xsl:call-template name="checkBAK01">
                            </xsl:call-template>
                    <BAK02>AT</BAK02>
                    <BAK03>
                        <xsl:value-of select="orderNumber" />
                    </BAK03>
                
                    <xsl:for-each select="dtm">
                            <xsl:if test="(dateQualf = '004')">
                                <BAK04>
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="date" />
                                    </xsl:call-template>
                                </BAK04>
                            </xsl:if>
                        </xsl:for-each>
                </ns0:BAK>
                <xsl:for-each select="ref">
                    <xsl:if test="(idQualf = 'CO')">
                        <ns0:REF>
                                <REF01>
                                    <xsl:value-of select="idQualf" />
                                </REF01>
                                <REF02>
                                    <xsl:value-of select="id" />
                                </REF02>
                                <xsl:if test="(desc != '')">
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </xsl:if>
                            </ns0:REF>
                            </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="lineItems">
                <ns0:PO1Loop1>
                    <ns0:PO1>
                        <PO101>
                            <xsl:value-of select="line"/>
                        </PO101>
                    </ns0:PO1>                        
                    <ns0:LIN_2>
                            <LIN01>
                                <xsl:value-of select="line"/>
                            </LIN01>
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
                    </ns0:LIN_2>
                    <xsl:for-each select="prices">
                        <xsl:if test="type = 'CONF_UNIT_PRICE'">
                                <ns0:CTP_2>
                                    <CTP02>ACT</CTP02>
                                    <CTP03>
                                        <xsl:value-of select="value"/>
                                    </CTP03>
                                </ns0:CTP_2>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="ref">
                        <xsl:if test="(idQualf = 'CO')">
                        <ns0:REF_3>
                                <REF01>
                                    <xsl:value-of select="idQualf" />
                                </REF01>
                                <REF02>
                                    <xsl:value-of select="id" />
                                </REF02>
                                <xsl:if test="(desc != '')">
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </xsl:if>
                        </ns0:REF_3>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each select="dtm">
                        <!-- TODO:  CHeck for 055 -->
                        <xsl:if test="dateQualf = '055'">
                        <ns0:DTM_4>
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
                        </ns0:DTM_4> 

                            </xsl:if>
                    </xsl:for-each>   
                    <ns0:ACKLoop1>
                        <xsl:for-each select="confirmations">
                            <ns0:ACK>
                                <ACK01><xsl:value-of select="confQualf"/></ACK01>
                                <ACK02><xsl:value-of select="quantity"/></ACK02>
                                <ACK03>EA</ACK03>
                                <ACK04><xsl:value-of select="dtm/dateQualf"/></ACK04>
                                <ACK05>
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="dtm/date" />
                                    </xsl:call-template>
                                </ACK05>
                                <ACK06><xsl:value-of select="seqNr"/></ACK06>
                            </ns0:ACK>
                        </xsl:for-each>
                    </ns0:ACKLoop1>
                    <xsl:for-each select="prices">
                    <xsl:if test="type = 'CONF_AMOUNT'">
                            <ns0:AMTLoop2>  
                                <ns0:AMT_2>
                                    <AMT01>1</AMT01>
                                    <AMT02>
                                        <xsl:value-of select="value"/>
                                    </AMT02>
                                </ns0:AMT_2>
                            </ns0:AMTLoop2>
                        </xsl:if>
                    </xsl:for-each>   
                    </ns0:PO1Loop1>
                </xsl:for-each>
            </ns0:X12_00401_855>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>