<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt" 
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				exclude-result-prefixes="msxsl var userJScript"
                >
    <xsl:output method="text" indent="yes"/>
    <xsl:param name="input:participants"/>
    <xsl:param name="input:host"/>
    <xsl:param name="input:zfFilterID"/>
    <xsl:param name="input:nodeid"/>
    <xsl:param name="input:sourcePartnQualf"/>
	<xsl:param name="input:sourcePartnerId"/>
	<xsl:param name="input:sourceNodeId"/>
    <xsl:param name="input:vendorPartyNodeId"/>
	<xsl:param name="input:shipToNodeId"/>
	<xsl:param name="input:shipFromNodeId"/>
	<xsl:param name="input:billToNodeId"/>
    <xsl:template match="formatDate" name="formatDate">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring-before($date, 'T') , '-','')"/>
    </xsl:template>
    
    <xsl:template match="formatTime" name="formatTime">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring(substring-after($date,'T') , 0,6),':','')"/>
    </xsl:template>
<msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
			var isPODocumentDate = 0;
			function updatePODocumentDateFlag(){
				isPODocumentDate = 1;
				return isPODocumentDate
			}
			function getIsPODocumentDateFlag(){
				return isPODocumentDate;
			}
			function dateFormated(inputDateFormat){
				return inputDateFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T00:00:00.000Z" : "";
            }
            function dateFormatedDTM(inputDateFormat , inputTimeFormat){
				return inputDateFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T"+inputTimeFormat.substring(0, 2)+":" +inputTimeFormat.substring(2, 4) +":"+ inputTimeFormat.substring(4, 6) +".000Z" : "";
            }

		]]>
    </msxsl:script>
    <xsl:template match="/ns0:X12_00401_860">
    {
        <xsl:choose>
            <xsl:when test="ns0:BCH/BCH01 = '04'">
                "method": "PUT",
                "url": "<xsl:value-of select="$input:host"/>/api/purchaseorders",
            </xsl:when>
        </xsl:choose>
        "payload": [
        {
            "txnGroup": {
            "participants": [                        
                <xsl:value-of select="$input:participants"/>
            ]
        },
        "orderType": "<xsl:value-of select="ns0:BCH/BCH02"/>",
        "orderNumber": "<xsl:value-of select="ns0:BCH/BCH03"/>",
        "currency":"<xsl:value-of select="ns0:CUR/CUR02"/>",
        "qty": [
            <xsl:for-each select="ns0:CTTLoop1">
                <xsl:if test="ns0:CTT/CTT02 != ''">
                    {
                    "type": "PO_QTY",
                    "value": <xsl:value-of select="ns0:CTT/CTT02"/>,
                    "uom": "<xsl:value-of select="ns0:CTT/CTT04"/>"
                    },
                </xsl:if>
            </xsl:for-each>
        ],
		"prices": [
            <xsl:for-each select="ns0:CTTLoop1">
                <xsl:if test="ns0:AMT_3/AMT01 = 'TT'">
                    {
                    "type": "AMOUNT",
                    "value": <xsl:value-of select="ns0:AMT_3/AMT02"/>
                    },
                </xsl:if>
            </xsl:for-each>
		],
        <xsl:if test="ns0:FOB/FOB04 = '01'">
        "incoTerms": {
            <xsl:choose>
                            <xsl:when test="ns0:FOB/FOB05 = 'DAP'">
                                "incoTerms1": "<xsl:value-of select="'DAP'" />",
                            </xsl:when>
                            <xsl:when test="ns0:FOB/FOB05 = 'ZZZ'">
                                "incoTerms1": "<xsl:value-of select="'DPU'" />",
                            </xsl:when>
                            <xsl:otherwise>
                                "incoTerms1": "<xsl:value-of select="ns0:FOB/FOB05" />",
                                </xsl:otherwise>
             </xsl:choose>
            
            "incoTerms2": "<xsl:value-of select="ns0:FOB/FOB07" />"
        },
		</xsl:if>
        "paymentTerms": {
            "terms": "<xsl:value-of select="ns0:ITD/ITD07"/>",
            <xsl:if test="ns0:ITD/ITD06 != ''">
            "termsDate": <xsl:call-template name="termdate"><xsl:with-param name="dtmObj" select="ns0:ITD/ITD06" /></xsl:call-template>,
            </xsl:if>
            <xsl:if test="ns0:ITD/ITD02 != ''">
            "termsBasisDate": <xsl:value-of select="ns0:ITD/ITD02"/>,
             </xsl:if>
            "termsDescription": "<xsl:value-of select="ns0:ITD/ITD12"/>",
            "discountDetails": [
                {
                "termsDiscount": <xsl:value-of select="ns0:ITD/ITD03"/>,
                "termsDays": <xsl:value-of select="ns0:ITD/ITD05"/>,
                <xsl:if test="ns0:ITD/ITD04 != ''">
                "termsDiscountDate": <xsl:call-template name="termdate"><xsl:with-param name="dtmObj" select="ns0:ITD/ITD04" /></xsl:call-template>
                </xsl:if>
                }
            ]
        },

        <!-- TODO : Add for Incoterms at header -->
       "dtm": [
		
            <xsl:for-each select="ns0:DTM">
                <xsl:if test="DTM01 = '004'">
                    <xsl:variable name="isPODocumentDate" select='userJScript:updatePODocumentDateFlag()'/>
                </xsl:if>
                {
                "dateQualf": "<xsl:value-of select="DTM01"/>",
                "date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
                },
            </xsl:for-each>
            <xsl:if test="userJScript:getIsPODocumentDateFlag() = '0'">
                {
                "dateQualf": "004",
                "date": "<xsl:value-of select='userJScript:dateFormated(string(ns0:BCH/BCH06))' />"
                },
            </xsl:if>
        ],
        "ref": [
                {
                        "idQualf": "<xsl:text>ZF</xsl:text>",
                        "id": "<xsl:value-of select="$input:zfFilterID"/>",
                        "desc": ""
                    },
             <xsl:for-each select="ns0:REF">
             <xsl:choose>
                <xsl:when test="REF01 = 'LD'">
                    {
                    "idQualf": "<xsl:value-of select="'ZL'"/>",
                    "id": "<xsl:value-of select="REF02"/>",
                    "desc": "<xsl:value-of select="REF03"/>"
                    },
                </xsl:when>
                <xsl:when test="REF01 = 'PE'">
                    {
                    "idQualf": "<xsl:value-of select="'ZP'"/>",
                    "id": "<xsl:value-of select="REF02"/>",
                    "desc": "<xsl:value-of select="REF03"/>"
                    },
                </xsl:when>
                <xsl:when test="REF01 = 'CT'">
                    {
                    "idQualf": "<xsl:value-of select="'ZC'"/>",
                    "id": "<xsl:value-of select="REF02"/>",
                    "desc": "<xsl:value-of select="REF03"/>"
                    },
                </xsl:when>
                <xsl:when test="REF01 = 'DD'">
                    {
                    "idQualf": "<xsl:value-of select="'ZD'"/>",
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
        "parties": [
        {
		"partnQualf": "<xsl:value-of select="$input:sourcePartnQualf"/>",
		"partnerId": "<xsl:value-of select="$input:sourcePartnerId"/>",
		"nodeId": "<xsl:value-of select="$input:sourceNodeId"/>"
		},
        <xsl:for-each select="ns0:N1Loop1">
            {
            "partnQualf": "<xsl:value-of select="ns0:N1/N101"/>",
            "partnerId": "<xsl:value-of select="ns0:N1/N104"/>",
            <!-- <xsl:choose>
				<xsl:when test="ns0:N1/N101 = 'VN'">
					"nodeId": "<xsl:value-of select="$input:vendorPartyNodeId"/>",
				</xsl:when>
				<xsl:when test="ns0:N1/N101 = 'ST'">
					"nodeId": "<xsl:value-of select="$input:shipToNodeId"/>",
				</xsl:when>
				<xsl:when test="ns0:N1/N101 = 'BT'">
					"nodeId": "<xsl:value-of select="$input:billToNodeId"/>",
				</xsl:when>
                <xsl:when test="ns0:N1/N101 = 'SF'">
					"nodeId": "<xsl:value-of select="$input:shipFromNodeId"/>",
				</xsl:when>
				<xsl:otherwise>
					"nodeId": "",
				</xsl:otherwise>
			</xsl:choose> -->
            <xsl:for-each select="ns0:REF_3">
				<xsl:if test="REF01 = '1W'">
					"nodeId": "<xsl:value-of select="REF02"/>",
				</xsl:if>
			</xsl:for-each>
            <xsl:choose>
                <xsl:when test="ns0:N1/N102 != ''">
                    "name1": "<xsl:value-of select="ns0:N1/N102"/>",
                </xsl:when>
                <xsl:otherwise>
                    "name1": "<xsl:value-of select="ns0:N2/N201"/>",
                </xsl:otherwise>
            </xsl:choose>
            "name2": "<xsl:value-of select="ns0:N2/N202"/>",
            <xsl:choose>
                <xsl:when test="ns0:N1/N102 != ''">
                    "description": "<xsl:value-of select="ns0:N1/N102"/>",
                </xsl:when>
                <xsl:otherwise>
                    "description": "<xsl:value-of select="ns0:N2/N201"/>",
                </xsl:otherwise>
            </xsl:choose>
            "address": {
                "address1": "<xsl:value-of select="ns0:N3/N301"/>",
                "address2": "<xsl:value-of select="ns0:N3/N302"/>",
                "houseNum": "",
                "city": "<xsl:value-of select="ns0:N4/N401"/>",
                "state": "<xsl:value-of select="ns0:N4/N402"/>",
                "zip": "<xsl:value-of select="ns0:N4/N403"/>",
                "country": "<xsl:value-of select="ns0:N4/N404"/>"
            }
            },
        </xsl:for-each>
        ],
        "lineItems": [
             <xsl:for-each select="ns0:POCLoop1">
            {
                <xsl:choose>
                    <xsl:when test="ns0:POC/POC02 = 'AI'">
                        "action": "<xsl:value-of select="'001'"/>",
                    </xsl:when>
                    <xsl:when test="ns0:POC/POC02 = 'CA'">
                        "action": "<xsl:value-of select="'002'"/>",
                    </xsl:when>
                    <xsl:when test="ns0:POC/POC02 = 'DI'">
                        "action": "<xsl:value-of select="'003'"/>",
                    </xsl:when>
                    <xsl:when test="ns0:POC/POC02 = 'NC'">
                        "action": "<xsl:value-of select="'004'"/>",
                    </xsl:when>
                </xsl:choose>
                
                "line": "<xsl:value-of select="ns0:POC/POC01"/>",
                "dtm": <xsl:call-template name="dtmHeader"><xsl:with-param name="dtmArr" select="ns0:DTM_7" /></xsl:call-template>,
                <!-- "qty":<xsl:call-template name="qty"></xsl:call-template> -->
                <xsl:if test="ns0:POC/POC03 != ''">
                "qty" :[
                    {
                        "type": "<xsl:value-of select="'PO_QTY'"/>",
                        "value": <xsl:value-of select="ns0:POC/POC03"/>,
                        "uom": "<xsl:value-of select="ns0:POC/ns0:C001_5/C00101"/>"
                    }
                ],
                </xsl:if>
                "prices": [
                        <xsl:if test="ns0:CTP_2/CTP02 = 'ACT'">
                        {
                        "type": "UNIT_PRICE",
                        "value":<xsl:value-of select="ns0:CTP_2/CTP03"/>
                        },
                        </xsl:if>
                        <xsl:for-each select="ns0:AMTLoop2">
                        {
                            "type": "AMOUNT",
                            "value":<xsl:value-of select="ns0:AMT_2/AMT02"/>
                        }, 
                        </xsl:for-each>
                    <!-- TODO Addd for Amount , Refer Amt01, AMt02 -->
                ],
                "currency":"<xsl:value-of select="CUR02"/>",
                "product": [
                            <xsl:for-each select="ns0:LIN_2">
                                <xsl:if test="LIN02 = 'MG'">
                                {
                                    "productQualf": "VP",
                                    "value": "<xsl:value-of select="LIN03"/>",
                                    "productDescription": ""
                                },
                                </xsl:if>
                                <xsl:if test="LIN04 = 'BP'">
                                {
                                    "productQualf": "<xsl:value-of select="LIN04"/>",
                                    "value": "<xsl:value-of select="LIN05"/>",
                                    "productDescription": ""
                                },
                                </xsl:if>
                                <xsl:if test="LIN06 = 'ZZ'">
                                {
                                    "productQualf": "<xsl:text>ZM</xsl:text>",
                                    "value": "<xsl:value-of select="LIN07"/>",
                                    "productDescription": ""
                                },
                                </xsl:if>
                            </xsl:for-each>
                        ],
                        <!-- TODO : IGnore REF for Line items -->
                "ref": [
                    {
                        "idQualf": "<xsl:text>ZF</xsl:text>",
                        "id": "<xsl:value-of select="$input:zfFilterID"/>",
                        "desc": ""
                    },
                    <xsl:for-each select="ns0:REF">
                        <xsl:choose>
                            <xsl:when test="REF01 = 'LD'">
                                {
                                "idQualf": "<xsl:value-of select="'ZL'"/>",
                                "id": "<xsl:value-of select="REF02"/>",
                                "desc": "<xsl:value-of select="REF03"/>"
                                },
                            </xsl:when>
                            <xsl:when test="REF01 = 'PE'">
                                {
                                "idQualf": "<xsl:value-of select="'ZP'"/>",
                                "id": "<xsl:value-of select="REF02"/>",
                                "desc": "<xsl:value-of select="REF03"/>"
                                },
                            </xsl:when>
                            <xsl:when test="REF01 = 'CT'">
                                {
                                "idQualf": "<xsl:value-of select="'ZC'"/>",
                                "id": "<xsl:value-of select="REF02"/>",
                                "desc": "<xsl:value-of select="REF03"/>"
                                },
                            </xsl:when>
                            <xsl:when test="REF01 = 'DD'">
                                {
                                "idQualf": "<xsl:value-of select="'ZD'"/>",
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
                ]
            },
             </xsl:for-each>
        ]
    }]}
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
    <xsl:template name="qty" match="/ns0:X12_00401_860/ns0:CTTLoop1">
        [
            <xsl:for-each select="ns0:CTT">
            {
                        "type": "<xsl:value-of select="CTT01"/>",
                        "value": <xsl:value-of select="CTT02"/>,
                        "uom": "<xsl:value-of select="CTT04"/>"
                    },
        </xsl:for-each>
        ],
                    
    </xsl:template>
     <xsl:template match="dtmObj" name="dtmDate">
     <xsl:param name = "dtmObj" />
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
    <xsl:template match="dtmObj" name="termdate">
     <xsl:param name = "dtmObj" />
                "<xsl:value-of select="substring($dtmObj, 1, 4)"/>-<xsl:value-of select="substring($dtmObj, 5, 2)"/>-<xsl:value-of select="substring($dtmObj, 7, 2)"/>T00:00:00.000Z"
    </xsl:template>
</xsl:stylesheet>  