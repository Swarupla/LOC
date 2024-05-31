<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" exclude-result-prefixes="msxsl var userJScript"
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output method="text" indent="yes"/>
    
    <xsl:template match="dateValidation" name="dateValidation">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring-before($date, 'T') , '-','')"/>
    </xsl:template>
    
    <xsl:template match="timeValidation" name="timeValidation">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring(substring-after($date,'T') , 0,9),':','')"/>
    </xsl:template>

    <msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
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

    <xsl:template name="dataset">
        <xsl:param name="data" select="@data"/>
        <xsl:for-each select="$data">
     <xsl:choose>
            <xsl:when test="isDelete = 'true'">
                 <ns0:X12_00401_810>
                    <ST>
                        <ST01>810</ST01>
                        <ST02>00001</ST02>
                    </ST>
                    <ns0:BIG>
                                <BIG01>
                                    <!-- <xsl:variable name="date1" select="date" />
                                        <xsl:value-of select="translate(substring-before($date1, 'T') , '-','')"/> -->
                                    <xsl:call-template name="dateValidation">
                                        <xsl:with-param name="date" select="userJScript:today()" />
                                     </xsl:call-template>
                                </BIG01>
                        <BIG02><xsl:value-of select="invNumber"/></BIG02>
                        <BIG04></BIG04>
                        <BIG07><xsl:value-of select="'DI'"/></BIG07>
                        <BIG08>03</BIG08>
                    </ns0:BIG>
                    <ns0:CUR>
                            <CUR01><xsl:value-of select="'BY'"/></CUR01>
                            <CUR02><xsl:value-of select="'USD'"/></CUR02>
                        </ns0:CUR>
                    <ns0:DTM>
                                <DTM01>
                                    <xsl:value-of select="'003'" />
                                </DTM01>
                                <DTM02>
                                    <xsl:call-template name="dateValidation">
                                        <xsl:with-param name="date" select="userJScript:today()" />
                                    </xsl:call-template>
                                </DTM02>
                                <DTM03>
                                    
                                        <xsl:value-of select="'000000'" />
                                    
                                </DTM03>
                                <DTM04>UT</DTM04>
                            </ns0:DTM>
                                <ns0:IT1Loop1>
                                    <ns0:IT1>
                                        <IT101>
                                            <xsl:value-of select="id"/>
                                        </IT101>                
                                                    <IT106>VP</IT106>
                                                    <IT107>
                                                        <xsl:value-of select="'VP Value'"/>
                                                    </IT107>                                                                  
                                    </ns0:IT1>
                                    <ns0:QTY>
                                        <xsl:if test="qty/type = 'BILLED_QTY'">
                                            <QTY01>D1</QTY01>
                                            <QTY02><xsl:value-of select="'200'"/></QTY02>
                                            <ns0:C001_4>
                                                <C00101><xsl:value-of select="'EA'"/></C00101>
                                            </ns0:C001_4>
                                        </xsl:if>
                                    </ns0:QTY>                                   
                                            <ns0:CTP>
                                                <CTP01></CTP01>
                                                <CTP02><xsl:value-of select="'ACT'"/></CTP02>
                                                <CTP03><xsl:value-of select="'50.5'"/></CTP03>                                               
                                                    <CTP09><xsl:value-of select="'PE'"/></CTP09>   
                                            </ns0:CTP>          
                            </ns0:IT1Loop1>
                           
                       
                    <ns0:TDS><TDS01><xsl:value-of select="'1'"/></TDS01></ns0:TDS>
                </ns0:X12_00401_810>
            </xsl:when>
            <xsl:otherwise>
                <ns0:X12_00401_810>
                <ST>
                        <ST01>810</ST01>
                        <ST02>330791782</ST02>
                </ST>
                <ns0:BIG>
                        <xsl:for-each select="dtm">
                            <xsl:if test="(dateQualf = '003')">
                                <BIG01>
                                    <!-- <xsl:variable name="date1" select="date" />
                                        <xsl:value-of select="translate(substring-before($date1, 'T') , '-','')"/> -->
                                    <xsl:call-template name="dateValidation">
                                        <xsl:with-param name="date" select="date" />
                                    </xsl:call-template>
                                </BIG01>
                            </xsl:if>
                        </xsl:for-each>
                        <BIG02><xsl:value-of select="invNumber"/></BIG02>
                        <!-- TODO: Pick id value from ref where idQualf = OP -->
                        <xsl:for-each select="ref">
                            <xsl:choose>
                                <xsl:when test="idQualf = 'OP'">
                                     <BIG04><xsl:value-of select="id"/></BIG04>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                        <BIG07><xsl:value-of select="invType"/></BIG07>
                        <BIG08>00</BIG08>
                </ns0:BIG>
                <xsl:if test="string-length(currency) != 0">
                    <ns0:CUR>
                        <CUR01><xsl:text>BY</xsl:text></CUR01>
                        <CUR02><xsl:value-of select="currency" /></CUR02>
                    </ns0:CUR>
                </xsl:if>
                <xsl:for-each select="ref">
                            <xsl:choose>
                                <xsl:when test="(idQualf = 'AS')">
                                    <ns0:REF>
                                        <REF01>MA</REF01>
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
                                        <REF03><xsl:value-of select="desc" /></REF03>
                                    </ns0:REF>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                </xsl:for-each>
                <xsl:for-each select="parties">
                            <xsl:if test="partnQualf != 'Z2'">
                        <ns0:N1Loop1>
                                <ns0:N1>
                                    <N101><xsl:value-of select= "partnQualf"/></N101>
                                    <N102><xsl:value-of select= "name1"/></N102>
                                    <N103>ZZ</N103>
                                    <N104><xsl:value-of select= "partnerId"/></N104>
                                </ns0:N1>
                                <xsl:if test="name1 !='' or name2">
                                <ns0:N2>
                                    <N201><xsl:value-of select= "name1"/></N201>
                                    <N202><xsl:value-of select= "name2"/></N202>
                                </ns0:N2>
                                </xsl:if>
                                <xsl:if test="address/address1 != '' or address/address2  != '' ">
                                <ns0:N3>
                                    <N301><xsl:value-of select= "address/address1"/></N301>
                                    <N302><xsl:value-of select= "address/address2"/></N302>
                                </ns0:N3>
                                </xsl:if>
                                <xsl:if test="address/city  != '' or address/state  != '' or address/zip  != '' or address/country != ''"> 
                                <ns0:N4>
                                    <N401><xsl:value-of select= "address/city"/></N401>
                                    <N402>
                                    <xsl:if test="string-length(address/state) = 2">
                                    <xsl:value-of select= "address/state"/>
                                    </xsl:if>
                                    </N402>
                                    <N403><xsl:value-of select= "address/zip"/></N403>
                                    <N404><xsl:value-of select= "address/country"/></N404>
                                </ns0:N4>
                                </xsl:if>
                                <xsl:if test="nodeId != null or nodeId != ''">
                                <ns0:REF_2>
                                    <REF01>1W</REF01>
                                    <REF02><xsl:value-of select="nodeId"/></REF02>
                                </ns0:REF_2>
                                </xsl:if>
                        </ns0:N1Loop1>
                            </xsl:if>
                    </xsl:for-each>

                    <xsl:if test="paymentTerms"> 
                    <ns0:ITD>
                        <ITD01></ITD01>
                        <ITD02><xsl:value-of select= "paymentTerms/termsBasisDate"/></ITD02>
                        <ITD03><xsl:value-of select= "paymentTerms/discountDetails/termsDiscount"/></ITD03>
                        <ITD04>
                            <xsl:call-template name="dateValidation">
                                <xsl:with-param name="date" select="paymentTerms/discountDetails/termsDiscountDate" />
                            </xsl:call-template> </ITD04>
                            <ITD05><xsl:value-of select= "paymentTerms/discountDetails/termsDays"/></ITD05>
                        <ITD06>
                        <xsl:call-template name="dateValidation">
                                <xsl:with-param name="date" select="paymentTerms/termsDate" />
                            </xsl:call-template> </ITD06>
                            <xsl:if test="paymentTerms/terms != ''">
                                <ITD07><xsl:value-of select= "number(paymentTerms/terms)"/></ITD07>
                            </xsl:if>
                        
                        <ITD12><xsl:value-of select= "paymentTerms/termsDescription"/></ITD12>
                    </ns0:ITD>
                    </xsl:if>
                    <xsl:for-each select="dtm">
                            <ns0:DTM>
                                <DTM01>
                                    <xsl:value-of select="dateQualf" />
                                </DTM01>
                                <DTM02>
                                    <xsl:call-template name="dateValidation">
                                        <xsl:with-param name="date" select="date" />
                                    </xsl:call-template>
                                </DTM02>
                                <DTM03>
                                    <xsl:variable name="time" select="date" />
                                    <xsl:call-template name="timeValidation">
                                        <xsl:with-param name="date" select="$time" />
                                    </xsl:call-template>
                                </DTM03>
                                <DTM04>UT</DTM04>
                            </ns0:DTM>                            
                    </xsl:for-each>
                    <xsl:for-each select="lineItems">
                        <ns0:IT1Loop1>
                            <ns0:IT1>
                                <IT101><xsl:value-of select="line"/>
                                </IT101>
                                <xsl:for-each select="product">
                                    <xsl:if test="productQualf = 'VP'">
                                            <IT106>VP</IT106>
                                            <IT107>
                                                <xsl:value-of select="value"/>
                                            </IT107>
                                        </xsl:if>
                                </xsl:for-each>   
                                <xsl:for-each select="product">
                                    <xsl:if test="productQualf = 'BP'">
                                        <IT108>BP</IT108>
                                        <IT109>
                                            <xsl:value-of select="value"/>
                                        </IT109>
                                    </xsl:if>
                                    </xsl:for-each>   
                                <xsl:for-each select="product">
                                    <xsl:if test="productQualf = 'ZM'">
                                        <IT110>ZZ</IT110>
                                        <IT111>
                                            <xsl:value-of select="value"/>
                                        </IT111>
                                    </xsl:if>
                                </xsl:for-each>
                            </ns0:IT1>
                            <ns0:QTY>
                                <xsl:if test="qty/type = 'BILLED_QTY'">
                                    <QTY01>D1</QTY01>
                                    <QTY02><xsl:value-of select="qty/value"/></QTY02>
                                    <ns0:C001_4>
                                        <C00101><xsl:value-of select="qty/uom"/></C00101>
                                    </ns0:C001_4>
                                </xsl:if>
                            </ns0:QTY>
                            
                                <xsl:for-each select="prices">
                                    <xsl:if test="type = 'UNIT_PRICE'">
                                    <ns0:CTP>
                                        <CTP01></CTP01>
                                        <CTP02><xsl:value-of select="'ACT'"/></CTP02>
                                        <CTP03><xsl:value-of select="value"/></CTP03>
                                        <xsl:if test="uom = 'EA'">
                                            <CTP09><xsl:value-of select="'PE'"/></CTP09>
                                        </xsl:if>
                                        <CTP11><xsl:value-of select="priceUnit"/></CTP11>
                                    </ns0:CTP>
                                    </xsl:if>
                                    <xsl:if test="type = 'AMOUNT'">
                                    <ns0:CTP>
                                        <CTP01></CTP01>
                                        <CTP02><xsl:value-of select="'TOT'"/></CTP02>
                                        <CTP03><xsl:value-of select="value"/></CTP03>
                                        <xsl:if test="uom = 'EA'">
                                            <CTP09><xsl:value-of select="'PE'"/></CTP09>
                                        </xsl:if>
                                        <CTP11><xsl:value-of select="priceUnit"/></CTP11>
                                    </ns0:CTP>
                                    </xsl:if>  
                                </xsl:for-each>
                            
                            <xsl:for-each select="ref">
                                        <xsl:choose>
                                        <xsl:when test="(idQualf = 'AS')">
                                        <ns0:REF_3>
                                                <REF01>MA</REF01>
                                                <REF02>
                                                    <xsl:value-of select="id" />
                                                </REF02>
                                                <xsl:if test="(desc != '')">
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
                                                <REF03><xsl:value-of select="desc" /></REF03>
                                            </ns0:REF_3>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                            </xsl:for-each>
                    </ns0:IT1Loop1>
                    </xsl:for-each>
                    <ns0:TDS>
                        <xsl:for-each select="prices">
                         <xsl:if test="type='TOTAL'">
                            <TDS01><xsl:value-of select="value"/></TDS01>
                        </xsl:if>
                        </xsl:for-each>
                    </ns0:TDS>
                    <xsl:for-each select="prices">
                                <xsl:if test="type = 'TAX'">
                                    <ns0:TXI_4>
                                        <TXI01><xsl:value-of select="'GS'"/></TXI01>
                                        <TXI02><xsl:value-of select="value"/></TXI02>
                                    </ns0:TXI_4>
                                </xsl:if>
                            </xsl:for-each>
                    <xsl:for-each select="prices">
                            <xsl:if test="type='TOTAL'">
                                <ns0:AMT>
                                    <AMT01><xsl:value-of select="5"/></AMT01>
                                    <AMT02><xsl:value-of select="value"/></AMT02>
                                </ns0:AMT>
                        </xsl:if>
                    </xsl:for-each>
                </ns0:X12_00401_810>
        </xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
