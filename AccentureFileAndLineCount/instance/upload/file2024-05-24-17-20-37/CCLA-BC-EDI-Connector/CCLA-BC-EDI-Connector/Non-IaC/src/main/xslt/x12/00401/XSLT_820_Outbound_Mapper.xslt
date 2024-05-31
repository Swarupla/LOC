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
                     <ns0:X12_00401_820>
                        <ST>
                            <ST01>820</ST01>
                            <ST02>000000001</ST02>
                        </ST>
                        <ns0:BPR>
                            <BPR01><xsl:value-of select="'C'"/></BPR01>
                            <xsl:for-each select="amount">
                                            <xsl:if test="type = 'PAID_AMT'">
                                                <BPR02><xsl:value-of select="value"/></BPR02>
                                            </xsl:if>                                            
                                        </xsl:for-each>
                            <BPR03>
                                <xsl:for-each select="lineItems">
                                    <xsl:variable name="i" select="position()"/>
                                    <xsl:if test="$i = 1">
                                         <xsl:for-each select="amount">
                                            <xsl:if test="type = 'PAID_AMT'">
                                               <xsl:value-of select="debitCreditFlag"/>
                                            </xsl:if>                                            
                                        </xsl:for-each> 
                                    </xsl:if>
                                    
                                </xsl:for-each>
                            </BPR03>
                            <BPR04>
                                <xsl:choose>
                                    <xsl:when test="paymentType = 'CHECK'">
                                        <xsl:value-of select="'CHK'"/>
                                    </xsl:when>
                                    <xsl:when test="paymentType = 'WIRE'">
                                        <xsl:value-of select="'CWT'"/>
                                    </xsl:when>
                                    <xsl:when test="paymentType = 'OTHER'">
                                        <xsl:value-of select="'ZZZ'"/>
                                    </xsl:when>
                                    <xsl:when test="paymentType = 'RECEIPT'">
                                        <xsl:value-of select="'CCH'"/>
                                    </xsl:when>
                                </xsl:choose>
                            </BPR04>
                        </ns0:BPR>
                        <ns0:TRN>
                            <TRN01>1</TRN01>
                            <TRN02><xsl:value-of select="paymentNumber"/></TRN02>
                        </ns0:TRN>
                        <ns0:CUR>
                            <CUR01>BY</CUR01>
                            <CUR02><xsl:value-of select="currency"/></CUR02>
                        </ns0:CUR>
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
                                <xsl:when test="(idQualf = 'CK')">
                                    <ns0:REF>
                                            <REF01>8H</REF01>
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
                                        <!-- TODO: Check -->
                                        <xsl:choose>
                                            <xsl:when test="N101 = 'ST'">
                                                 <N103><xsl:value-of select="'06'"/></N103>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <N103>ZZ</N103>
                                            </xsl:otherwise>
                                        </xsl:choose>
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
                                    <xsl:if test="address/address1 !='' or address/address2"> 
                                    
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
                                <ns0:REF_2>
                                    <REF01>1W</REF01>
                                    <REF02><xsl:value-of select="nodeId"/></REF02>
                                </ns0:REF_2>
                                </xsl:if>
                                </ns0:N1Loop1>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="lineItems">
                            <ns0:ENTLoop1>
                                <ns0:ENT>
                                    <ENT01><xsl:value-of select="line"/></ENT01>
                                </ns0:ENT>
                                <ns0:RMRLoop1>
                                    <ns0:RMR>
                                        <xsl:for-each select="amount">
                                            <xsl:if test="type = 'PAID_AMT'">
                                                <RMR04><xsl:value-of select="value"/></RMR04>
                                            </xsl:if>                                            
                                        </xsl:for-each>
                                    </ns0:RMR>
                                    <xsl:for-each select="ref">
                                                <xsl:choose>
                                                    <xsl:when test="(idQualf = 'AS')">
                                        <ns0:REF_7>

                                                            <REF01>MA</REF01>
                                                            <REF02>
                                                                <xsl:value-of select="id" />
                                                            </REF02>
                                                            <xsl:if test="(desc != '')">
                                                                <REF03>
                                                                    <xsl:value-of select="desc" />
                                                                </REF03>
                                                            </xsl:if>
                                        </ns0:REF_7>

                                                    </xsl:when>
                                                     <xsl:when test="(idQualf = 'CK')">
                                        <ns0:REF_7>

                                                            <REF01>8H</REF01>
                                                            <REF02>
                                                                <xsl:value-of select="id" />
                                                            </REF02>
                                                            <xsl:if test="(desc != '')">
                                                                <REF03>
                                                                    <xsl:value-of select="desc" />
                                                                </REF03>
                                                            </xsl:if>
                                        </ns0:REF_7>

                                                    </xsl:when>
                                                    <xsl:otherwise>

                                                      <xsl:if test="idQualf != 'ZF'">
                                        <ns0:REF_7>

                                                         <REF01> 
                                                            <xsl:value-of select="idQualf" />
                                                        </REF01>
                                                        <REF02>
                                                            <xsl:value-of select="id" />
                                                        </REF02>
                                                        <REF03><xsl:value-of select="desc" /></REF03>
                                        </ns0:REF_7>

                                                      </xsl:if>

                                                    </xsl:otherwise>
                                                </xsl:choose>
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
                                </ns0:RMRLoop1>
                            </ns0:ENTLoop1>
                       </xsl:for-each>
                </ns0:X12_00401_820>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>