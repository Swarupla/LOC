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
    
    <msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
    var counter = 0;
    function increment(){
        counter = counter + 1;
        return counter
    }

    var occ = 0
    function OPOccurance() {
       occ = occ + 1;
       return occ
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
    
    <!-- <xsl:import href="xsl-js.xsl"/> -->

     <xsl:template match="/result">
        <xsl:call-template name="dataset">
            <xsl:with-param name="data" select="data" />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="dataset">
        <xsl:param name="data" select="@data"/>
        <xsl:for-each select="$data">
            <xsl:choose>
                <!-- TODO: Remove delete condition. Not applicable for 860 -->
                <xsl:when test="isDelete = 'true'">
                    <ns0:X12_00401_860>
                            <ST>
                                <ST01>860</ST01>
                                <ST02>000000001</ST02>
                            </ST>
                            <ns0:BCH>
                                <BCH01>03</BCH01>
                                <BCH03>
                                    <xsl:value-of select="orderNumber" />
                                </BCH03>
                                <BCH06>
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="userJScript:today()" />
                                    </xsl:call-template>
                                </BCH06>
                            </ns0:BCH>
                    </ns0:X12_00401_860>
                </xsl:when>
                <xsl:otherwise>
                    <ns0:X12_00401_860>
                        <ST>
                            <ST01>860</ST01>
                            <ST02>000000001</ST02>
                        </ST>
                        <ns0:BCH>
                            <BCH01>04</BCH01>
                            <xsl:choose>
                            <xsl:when test="orderType = 'LP'">
                                <BCH02>
                                <xsl:value-of select="'SA'" />
                            </BCH02>
                            </xsl:when>
                            <xsl:otherwise>
                                <BCH02>
                                <xsl:value-of select="orderType" />
                            </BCH02>
                            </xsl:otherwise>
                        </xsl:choose>
                            
                            <BCH03>
                                <xsl:value-of select="orderNumber" />
                            </BCH03>
                            <BCH04>
                            </BCH04>
                            <xsl:for-each select="dtm">
                                <xsl:if test="(dateQualf = '004')">
                                    <BCH06>
                                        <xsl:call-template name="formatDate">
                                            <xsl:with-param name="date" select="date" />
                                        </xsl:call-template>
                                    </BCH06>
                                </xsl:if>
                            </xsl:for-each>
                        </ns0:BCH>
                        <ns0:CUR>
                            <CUR01>BY</CUR01>
                            <CUR02>
                                <xsl:value-of select="currency" />
                            </CUR02>
                        </ns0:CUR>
                        <xsl:for-each select="ref">
                            <xsl:choose>
                                <xsl:when test="(idQualf = 'ZL')">
                                    <ns0:REF>
                                        <REF01>LD</REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <xsl:if test="(desc != '')">
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
                                        <xsl:if test="(desc != '')">
                                            <REF03>
                                                <xsl:value-of select="desc" />
                                            </REF03>
                                        </xsl:if>
                                    </ns0:REF>
                                </xsl:when>
                                <xsl:when test="(idQualf = 'ZC')">
                                    <ns0:REF>
                                        <REF01>CT</REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <xsl:if test="(desc != '')">
                                            <REF03>
                                                <xsl:value-of select="desc" />
                                            </REF03>
                                        </xsl:if>
                                    </ns0:REF>
                                </xsl:when>
                                <xsl:when test="(idQualf = 'ZD')">
                                    <ns0:REF>
                                        <REF01>DD</REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <xsl:if test="(desc != '')">
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
                                        <xsl:if test="(desc != '')">
                                            <REF03>
                                                <xsl:value-of select="desc" />
                                            </REF03>
                                        </xsl:if>
                                        </ns0:REF>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:for-each select="incoTerms">
                            <ns0:FOB>
                                <FOB01><xsl:value-of select="'DF'"/></FOB01>
                                <FOB04>01</FOB04>
                                <FOB05>
                                    <xsl:choose>
                                        <xsl:when test="incoTerms1 = 'DAP'">
                                             <xsl:value-of select="'DAP'"/>
                                        </xsl:when>
                                        <xsl:when test="incoTerms1 = 'DPU'">
                                             <xsl:value-of select="'ZZZ'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="incoTerms1" />
                                            </xsl:otherwise>
                                    </xsl:choose>
                                </FOB05>
                                <!-- TODO: Add for FOB-06 as ZZ -->
                                <FOB06><xsl:value-of select="'ZZ'"/></FOB06>
                                <FOB07>
                                    <xsl:value-of select="incoTerms2" />
                                </FOB07>
                            </ns0:FOB>
                        </xsl:for-each>
                        
                        <xsl:if test="paymentTerms">
                        <ns0:ITD>
                            <ITD01></ITD01>
                            <ITD02>
                            <xsl:value-of select="paymentTerms/termsBasisDate" />
                            </ITD02>
                            <xsl:for-each select="paymentTerms/discountDetails">
                                <ITD03>
                                    <xsl:value-of select="termsDiscount" />
                                </ITD03>
                                <ITD04>
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="termsDiscountDate" />
                                    </xsl:call-template>
                                </ITD04>
                            </xsl:for-each>
                            <xsl:for-each select="paymentTerms/discountDetails">
                                <ITD05>
                                    <xsl:value-of select="termsDays" />
                                </ITD05>
                            </xsl:for-each>  
                            <ITD06>
                            <xsl:call-template name="formatDate">
                                        <xsl:with-param name="date" select="paymentTerms/termsDate" />
                                </xsl:call-template>
                            </ITD06>
                            <xsl:if test="paymentTerms/terms != ''">
                                <ITD07><xsl:value-of select="number(paymentTerms/terms)" /></ITD07>
                            </xsl:if>
                            <ITD12>
                                <xsl:value-of select="paymentTerms/termsDescription" />
                            </ITD12>
                        </ns0:ITD>
                        </xsl:if>

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
                        <xsl:for-each select="parties">
                            <xsl:if test="(partnQualf != 'Z2' and partnQualf != 'Z1') ">
                                <ns0:N1Loop1>
                                    <ns0:N1>
                                        <N101>
                                            <xsl:value-of select="partnQualf" />
                                        </N101>
                                        <N102>
                                            <xsl:value-of select="name1" />
                                        </N102>
                                        <!-- TODO: Add for N1-03 as ZZ -->
                                        <N103>ZZ</N103>
                                        <N104>
                                            <xsl:value-of select="partnerId" />
                                        </N104>
                                    </ns0:N1>
                                    <xsl:if test="name1 !='' or name2">
                                    <ns0:N2>
                                        <N201>
                                            <xsl:value-of select="name1" />
                                        </N201>
                                        <N202>
                                            <xsl:value-of select="name2" />
                                        </N202>
                                    </ns0:N2>
                                    </xsl:if>
                                    <xsl:if test="address/address1  !='' or address/address2">
                                         <ns0:N3>
                                        <N301>
                                            <xsl:value-of select="address/address1" />
                                        </N301>
                                        <N302>
                                            <xsl:value-of select="address/address2" />
                                        </N302>
                                    </ns0:N3>
                                    </xsl:if>
                                   <xsl:if test="address/city !='' or address/state !='' or address/zip !='' or address/country"> 
                                    <ns0:N4>
                                        <N401>
                                            <xsl:value-of select="address/city" />
                                        </N401>
                                        <N402>
                                            <xsl:if test="string-length(address/state) = 2">
                                                <xsl:value-of select="address/state" />
                                            </xsl:if>
                                        </N402>
                                        <N403>
                                            <xsl:value-of select="address/zip" />
                                        </N403>
                                        <N404>
                                            <xsl:value-of select="address/country" />
                                        </N404>
                                    </ns0:N4>
                                    </xsl:if>
                                    <xsl:if test="nodeId != null or nodeId != ''">
                                    <ns0:REF_3>
                                    <REF01>1W</REF01>
                                    <REF02><xsl:value-of select="nodeId"/></REF02>
                                </ns0:REF_3>
                                </xsl:if>
                                </ns0:N1Loop1>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="lineItems">
                        <ns0:POCLoop1>
                            <ns0:POC>
                                <POC01>
                                    <xsl:value-of select="line"/>
                                </POC01>
                                <POC02>
                                    <xsl:choose>
                                        <xsl:when test="action = '003'">
                                            <xsl:value-of select="'DI'"/>
                                        </xsl:when>
                                        <xsl:when test="action = '001'">
                                            <xsl:value-of select="'AI'"/>
                                        </xsl:when>
                                        <xsl:when test="action = '002'">
                                            <xsl:value-of select="'CA'"/>
                                        </xsl:when>
                                        <xsl:when test="action = ''">
                                            <xsl:value-of select="'NC'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </POC02>
                                <xsl:for-each select="qty">
                                    <xsl:if test="(type = 'PO_QTY') ">
                                        <POC03>
                                            <xsl:value-of select="value"/>
                                        </POC03>
                                        <ns0:C001_5>
                                            <C00101><xsl:value-of select="uom"/></C00101>
                                        </ns0:C001_5>
                                    </xsl:if>
                                </xsl:for-each>
                            </ns0:POC>
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
                                <xsl:if test="type = 'UNIT_PRICE'">
                                        <ns0:CTP_2>
                                            <CTP02>ACT</CTP02>
                                            <CTP03>
                                                <xsl:value-of select="value"/>
                                            </CTP03>
                                        </ns0:CTP_2>
                                </xsl:if>
                            </xsl:for-each>

                            <xsl:for-each select="dtm">
                                <ns0:DTM_7>
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
                                </ns0:DTM_7>                            
                            </xsl:for-each>
                            
                            <xsl:for-each select="prices">
                                <!--  moved line AMTLoop2 inside prices loop -->
                                <xsl:if test="type = 'AMOUNT'">
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
                            </ns0:POCLoop1>
                        </xsl:for-each>
                        <ns0:CTTLoop1>
                            <ns0:CTT>
                                        <!-- TODO: CTT-01 should be total po lines count -->
                                        <CTT01><xsl:value-of select="count(lineItems)"/></CTT01>
                            <xsl:for-each select="qty">
                                <!-- TODO: qty[].type should be PO_QTY, add if condition -->
                                <xsl:if test="type = 'PO_QTY'">
                                    
                                        <CTT02><xsl:value-of select="value"/></CTT02>
                                        <CTT04><xsl:value-of select="uom"/></CTT04>
                                   
                                </xsl:if>
                            </xsl:for-each>
                             </ns0:CTT>
                            <xsl:for-each select="prices">
                                <!-- TODO: prices[].type should be AMOUNT, add if condition -->
                                <xsl:if test="type = 'AMOUNT'">
                                    <ns0:AMT_3>
                                        <AMT01>TT</AMT01>
                                        <AMT02><xsl:value-of select="value"/></AMT02>
                                    </ns0:AMT_3>
                                </xsl:if>
                                
                            </xsl:for-each>
                        </ns0:CTTLoop1>
                    </ns0:X12_00401_860>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>