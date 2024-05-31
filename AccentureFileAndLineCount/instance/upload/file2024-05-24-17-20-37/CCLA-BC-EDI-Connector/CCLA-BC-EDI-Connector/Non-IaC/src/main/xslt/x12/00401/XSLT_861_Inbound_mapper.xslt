<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt" 
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				exclude-result-prefixes="msxsl var userJScript">

    <xsl:output method="text" indent="yes"/>
    <xsl:param name="input:participants"/>
    <xsl:param name="input:zfFilterID"/>
	<xsl:param name="input:sourcePartnQualf"/>
	<xsl:param name="input:sourcePartnerId"/>
	<xsl:param name="input:sourceNodeId"/>
    <xsl:param name="input:host"/>

    <msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
			var isPODocumentDate = 0;

			function dateFormatedDTM(inputDateFormat , inputTimeFormat){
				return inputDateFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T"+inputTimeFormat.substring(0, 2)+":" +inputTimeFormat.substring(2, 4) +":00.000Z" : "";
            }

            function dateFormated(inputDateFormat){
				return inputDateFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T00:00:00.000Z" : "";
            }

            var man02=[];
            function checkMan02(man02Value) { 
                if(man02.length == 0) {
                    man02.push(man02Value);
                    return 'false';
                 }
               for(var i=0 ; i< man02.length ;i++) {
                 if(man02Value == man02[i]) {
                    return 'true';
                 } else if(man02Value != man02[i] && i == man02.length-1){
                    man02.push(man02Value);
                    return 'false';
                 }
               }
            }

 		]]>
    </msxsl:script>
    <xsl:template match="/ns0:X12_00401_861">
    {
        <xsl:choose>
            <xsl:when test="ns0:BRA/BRA03 = '00'">
                "method": "POST",
                "url": "<xsl:value-of select="$input:host"/>/api/goodsreceipts",
                "payload": [
                    {
                        "txnGroup": {
                            "participants": [                        
                                <xsl:value-of select="$input:participants"/>
                            ]
                        },
                        "grNumber": "<xsl:value-of select="ns0:BRA/BRA01"/>",
                        "dtm": [		
                            <xsl:for-each select="ns0:DTM">
                                <xsl:if test="DTM01 = '050'">
                                    {
                                    "dateQualf": "<xsl:value-of select="DTM01"/>",
                                    "date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
                                    },
                                </xsl:if>
                            </xsl:for-each>
                        ],
                        "ref": [
                            {
                                "idQualf": "ZF",
                                "id": "<xsl:value-of select="$input:zfFilterID"/>",
                                "desc": ""
                            },
                            <xsl:for-each select="ns0:REF">
                                <xsl:choose>
                                    <xsl:when test="REF01 = 'MA'">
                                        {
                                        "idQualf": "<xsl:text>AS</xsl:text>",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                        },
                                    </xsl:when>
                                    <xsl:when test="REF01 = 'PE'">
                                        {
                                        "idQualf": "<xsl:text>ZP</xsl:text>",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                        },
                                    </xsl:when>
                                    <xsl:otherwise>
                                        {
                                        "idQualf": "<xsl:value-of select="REF01"/>",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                        },
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>       
                        ],
                        "lineItems": [
                            <xsl:for-each select="ns0:RCDLoop1">
                                {
                                "grType": "<xsl:value-of select="ns0:RCD/RCD08"/>",
                                "line": "<xsl:value-of select="ns0:RCD/RCD01"/>",
                                "qty": [
                                    {
                                        "type": "GR_QTY",
                                        "value": <xsl:value-of select="ns0:RCD/RCD02" />,
                                        "uom": "<xsl:value-of select="ns0:RCD/ns0:C001_2/C00101" />"
                                        <!-- "uom": "<xsl:value-of select="ns0:RCD/RCD03" />" -->
                                        <!-- "uom": "<xsl:value-of select="'EA'" />" -->
                                        
                                    }
                                ],
                                "ref": [
                                        {
                                        "idQualf": "ZF",
                                        "id": "<xsl:value-of select="$input:zfFilterID"/>",
                                        "desc": ""
                                    },
                                    <xsl:for-each select="ns0:REF_3">
                                        <xsl:choose>
                                            <xsl:when test="REF01 = 'MA'">
                                                {
                                                "idQualf": "<xsl:text>AS</xsl:text>",
                                                "id": "<xsl:value-of select="REF02"/>",
                                                "desc": "<xsl:value-of select="REF03"/>"
                                                },
                                            </xsl:when>
                                            <xsl:when test="REF01 = 'PE'">
                                                {
                                                "idQualf": "<xsl:text>ZP</xsl:text>",
                                                "id": "<xsl:value-of select="REF02"/>",
                                                "desc": "<xsl:value-of select="REF03"/>"
                                                },
                                            </xsl:when>
                                            <xsl:otherwise>
                                                {
                                                "idQualf": "<xsl:value-of select="REF01"/>",
                                                "id": "<xsl:value-of select="REF02"/>",
                                                "desc": "<xsl:value-of select="REF03"/>"
                                                },
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>   
                                ],
                                "product": [
                                    <xsl:for-each select="ns0:LIN">
                                    <xsl:if test="LIN02 = 'MG'">
                                        {
                                        "productQualf": "VP",
                                        "value": "<xsl:value-of select="LIN03"/>",
                                        "productDescription": ""
                                        },
                                    </xsl:if> 
                                    <xsl:if test="LIN04 = 'BP'">
                                        {
                                        "productQualf": "BP",
                                        "value": "<xsl:value-of select="LIN05"/>",
                                        "productDescription": ""
                                        },
                                    </xsl:if> 
                                    <xsl:if test="LIN06 = 'ZZ'">
                                        {
                                        "productQualf": "ZM",
                                        "value": "<xsl:value-of select="LIN07"/>",
                                        "productDescription": ""
                                        },
                                    </xsl:if> 
                                </xsl:for-each>
                                ]
                            },
                            </xsl:for-each>
                            
                        ],
                        "handlingUnits": [
                            <xsl:for-each select="ns0:RCDLoop1">
                                   <xsl:if test="ns0:MAN/MAN02">
                                        { 
                                            <xsl:choose>
                                                    <xsl:when test="ns0:MAN/MAN01 = 'MC'">
                                                        "huType": "<xsl:value-of select="'CARTON'"/>",
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        "huType": "<xsl:value-of select="'PALLET'"/>",
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                "huIdQualf": "<xsl:value-of select="ns0:MAN/MAN04"/>",
                                                "huId": "<xsl:value-of select="ns0:MAN/MAN02"/>",
                                                "quantity": <xsl:value-of select="ns0:RCD/RCD04"/>,
                                                "ref": [{
                                                                "idQualf": "M1",
                                                                <xsl:choose>
                                                                    <xsl:when test="ns0:RCD/RCD08 = '07'">
                                                                        "id": "<xsl:value-of select="'01'"/>",
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        "id": "<xsl:value-of select="'02'"/>",
                                                                    </xsl:otherwise>
                                                                </xsl:choose>    
                                                                "desc": "<xsl:value-of select="ns0:RCD/RCD08"/>"
                                            }]
                                        },
                                   </xsl:if>
                                    
                            </xsl:for-each>
                        ]
                    }
                ]
            </xsl:when>
            <xsl:when test="ns0:BRA/BRA03 = '03'">
                "method": "DELETE",
                <xsl:variable name="singleQuote">'</xsl:variable>
                "url": "<xsl:value-of select="$input:host"/>/api/goodsreceipts/<xsl:value-of select="ns0:BRA/BRA01"/>?participants=<xsl:value-of select="translate($input:participants, $singleQuote, '')" />&amp;deleteReason=4",
                "payload" : ""
            </xsl:when>
        </xsl:choose>
    }
    </xsl:template>

    <xsl:template name="dtmHeader">
        <xsl:param name = "dtmArr" />
        [
            <xsl:for-each select="$dtmArr">
                <xsl:if test="DTM02 != ''">
                {
                    "dateQualf": "<xsl:value-of select="DTM01"/>",
                    "date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
                },
                </xsl:if>
            </xsl:for-each>
        ]
    </xsl:template>
    <xsl:template match="dtmObj" name="dtmDate">
        <xsl:choose>
            <xsl:when test="DTM03 != ''">
                <xsl:choose>
                    <xsl:when test="string-length(DTM03) = 4">
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T<xsl:value-of select="substring(DTM03, 1, 2)"/>:<xsl:value-of select="substring(DTM03, 3, 2)"/>:00.000Z"
                    </xsl:when>
                    <xsl:when test="string-length(DTM03) = 6">
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T<xsl:value-of select="substring(DTM03, 1, 2)"/>:<xsl:value-of select="substring(DTM03, 3, 2)"/>:<xsl:value-of select="substring(DTM03, 5, 2)"/>.000Z"
                    </xsl:when>
                    <xsl:when test="string-length(DTM03) > 6">
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T<xsl:value-of select="substring(DTM03, 1, 2)"/>:<xsl:value-of select="substring(DTM03, 3, 2)"/>:<xsl:value-of select="substring(DTM03, 5, 2)"/>.000Z"
                    </xsl:when>
                    <xsl:otherwise>
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T00:00:00.000Z"
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T00:00:00.000Z"
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="ackDate">
        <xsl:param name = "dateStr" />
        "<xsl:value-of select="substring($dateStr, 1, 4)"/>-<xsl:value-of select="substring($dateStr, 5, 2)"/>-<xsl:value-of select="substring($dateStr, 7, 2)"/>T00:00:00.000Z"
    </xsl:template>
</xsl:stylesheet>