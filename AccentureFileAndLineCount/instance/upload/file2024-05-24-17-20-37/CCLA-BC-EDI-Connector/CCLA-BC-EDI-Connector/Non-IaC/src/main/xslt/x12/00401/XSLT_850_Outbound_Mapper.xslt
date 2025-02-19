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
    
    <xsl:template match="/result/isUpdate" name="checkBEG01">
        <xsl:choose>
            <xsl:when test="/isUpdate = true">
                <BEG01>04</BEG01>
            </xsl:when>
            <xsl:otherwise>
                <BEG01>00</BEG01>
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
                    <ns0:X12_00401_850>
                        <!-- TODO Update Payload for Delete -->
                        <ST>
                            <ST01>850</ST01>
                            <ST02>000000001</ST02>
                        </ST>
                        <ns0:BEG>
                            <!-- TODO , Update for LSP to be created for T2 -->
                            <BEG01>03</BEG01>
                            <BEG02><xsl:value-of select="'SA'"/></BEG02>
                            <BEG03>
                                <xsl:value-of select="id" />
                            </BEG03>
                            <BEG05>
                                <xsl:call-template name="formatDate">
                                    <xsl:with-param name="date" select="userJScript:today()" />
                                </xsl:call-template>
                            </BEG05>
                        </ns0:BEG>
                        <ns0:CUR>
                            <CUR01><xsl:value-of select="'BY'"/></CUR01>
                            <CUR02><xsl:value-of select="'USD'"/></CUR02>
                        </ns0:CUR>
                        <ns0:N1Loop1>
                            <ns0:N1>
                                <N101>
                                    <xsl:value-of select="'VN'" />
                                </N101>
                                    <N103>ZZ</N103>
                                    <N104>
                                        <xsl:value-of select="'partnerId'" />
                                    </N104>
                            </ns0:N1>
                        </ns0:N1Loop1>     
                        <ns0:PO1Loop1>
                            <ns0:PO1>
                                <PO101>
                                    <xsl:value-of select="id"/>
                                </PO101>						
                                <PO102>
                                    <xsl:value-of select="'10'"/>
                                </PO102>
                                <PO103>
                                    <xsl:value-of select="'EA'"/>
                                </PO103>
                            </ns0:PO1>	
                        </ns0:PO1Loop1>     
                    </ns0:X12_00401_850>
                </xsl:when>
                <xsl:otherwise>
                    <ns0:X12_00401_850>
                        <ST>
                            <ST01>850</ST01>
                            <ST02>000000001</ST02>
                        </ST>
                        <ns0:BEG>
                            <xsl:call-template name="checkBEG01">
                            </xsl:call-template>
                            <!-- <BEG01>00</BEG01> -->
                            <xsl:choose>
                                <xsl:when test="orderType = 'LP'">
                                    <BEG02><xsl:value-of select="'SA'" /></BEG02>
                                </xsl:when>
                                <xsl:otherwise>
                                    <BEG02><xsl:value-of select="orderType"/></BEG02>
                                </xsl:otherwise>
                            </xsl:choose>
                            <BEG03>
                                <xsl:value-of select="orderNumber" />
                            </BEG03>
                            <xsl:for-each select="dtm">
                                <xsl:if test="(dateQualf = '004')">
                                    <BEG05>
                                        <xsl:call-template name="formatDate">
                                            <xsl:with-param name="date" select="date" />
                                        </xsl:call-template>
                                    </BEG05>
                                </xsl:if>
                            </xsl:for-each>
                        </ns0:BEG>
                        <!-- TODO : IF currency is available then Populate CUR -->
                        <xsl:if test="currency != null or currency != ''">
                            <ns0:CUR>
                                <CUR01>BY</CUR01>
                                <CUR02>
                                    <xsl:value-of select="currency" />
                                </CUR02>
                            </ns0:CUR>
                        </xsl:if>
                        
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
                            <xsl:if test="(string-length(incoTerms1) != 0 or string-length(incoTerms2) != 0)">
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
                                    <FOB06><xsl:value-of select="'ZZ'"/></FOB06>
                                    <FOB07>
                                        <xsl:value-of select="incoTerms2" />
                                    </FOB07>
                                </ns0:FOB>
                            </xsl:if>
                            
                        </xsl:for-each>
                        
                        <xsl:if test="paymentTerms"> 
                        <ns0:ITD>
                            <!-- <ITD01>
                                 <xsl:value-of select="paymentTerms/terms" />
                                 </ITD01> -->
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
                                <ITD05><xsl:value-of select= "termsDays"/></ITD05>
                            </xsl:for-each>
                            <ITD06>
                                <xsl:call-template name="formatDate">
                                    <xsl:with-param name="date" select="paymentTerms/termsDate" />
                                </xsl:call-template>
                            </ITD06> 
                            <xsl:if test="paymentTerms/terms != ''">
                                <ITD07>
                                    <xsl:value-of select="number(paymentTerms/terms)" />
                                </ITD07>
                            </xsl:if>
                            <ITD12>
                                <xsl:value-of select="paymentTerms/termsDescription" />
                            </ITD12>
                        </ns0:ITD>
                        </xsl:if>

                        <!-- TODO: Add DTM at Header level -->
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
                            <xsl:variable name="i" select="position()" />
                            <!-- TODO: Don't use index instaed use N101-->
                            <xsl:if test="(partnQualf != 'Z2' and partnQualf != 'Z1') ">
                                <ns0:N1Loop1>
                                    <ns0:N1>
                                        <N101>
                                            <xsl:value-of select="partnQualf" />
                                        </N101>
                                        <N102>
                                            <xsl:value-of select="name1" />
                                        </N102>
                                        <xsl:if test="partnerId != null or partnerId != ''">
                                            <N103>ZZ</N103>
                                            <N104>
                                                <xsl:value-of select="partnerId" />
                                            </N104>
                                        </xsl:if>
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
                                    <xsl:if test="address/address1 != ''  or address/address2 != ''">
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
                            <ns0:PO1Loop1>
                                <ns0:PO1>
                                    <PO101>
                                        <xsl:value-of select="line"/>
                                    </PO101>						
                                    <xsl:for-each select="qty">
                                        <xsl:if test="(type = 'PO_QTY') ">
                                            <PO102>
                                                <xsl:value-of select="value"/>
                                            </PO102>
                                            <PO103>
                                                <xsl:value-of select="uom"/>
                                            </PO103>
                                        </xsl:if>
                                    </xsl:for-each>
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
                                    <xsl:if test="type = 'UNIT_PRICE'">
                                        <ns0:CTPLoop1>
                                            <ns0:CTP_2>
                                                <CTP02>ACT</CTP02>
                                                <CTP03>
                                                    <xsl:value-of select="value"/>
                                                </CTP03>
                                            </ns0:CTP_2>
                                        </ns0:CTPLoop1>
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
                                <!--TODO: CHange to loop -->
                                <xsl:for-each select="prices"> 
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
                            </ns0:PO1Loop1>
                        </xsl:for-each>
                        
                        <ns0:CTTLoop1>
                            <ns0:CTT>
                                <CTT01><xsl:value-of select="count(lineItems)"/></CTT01>
                                <xsl:for-each select="qty">                                    
                                    <!-- TODO : UpdateCTT to Number of Line items -->
                                    <CTT02><xsl:value-of select="value"/></CTT02>
                                    <CTT04><xsl:value-of select="uom"/></CTT04>
                                </xsl:for-each>
                            </ns0:CTT>
                            <xsl:for-each select="prices">
                                <xsl:if test="type = 'AMOUNT'">
                                    <ns0:AMT_3>
                                        <AMT01>TT</AMT01>
                                        <AMT02><xsl:value-of select="value"/></AMT02>
                                    </ns0:AMT_3>
                                </xsl:if>
                                
                            </xsl:for-each>
                        </ns0:CTTLoop1>
                    </ns0:X12_00401_850>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet> 