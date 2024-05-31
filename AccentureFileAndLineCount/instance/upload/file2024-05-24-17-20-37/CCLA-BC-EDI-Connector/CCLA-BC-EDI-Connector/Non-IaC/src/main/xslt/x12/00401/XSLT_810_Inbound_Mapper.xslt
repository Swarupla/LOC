<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt" 
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output method="text" indent="yes"/>
    <xsl:param name="input:participants"/>
    <xsl:param name="input:host"/>
    <xsl:param name="input:zfFilterID"/>
    <xsl:param name="input:sourcePartnQualf"/>
	<xsl:param name="input:sourcePartnerId"/>
	<xsl:param name="input:sourceNodeId"/>
    <xsl:template match="/ns0:X12_00401_810">
    {
        <xsl:choose>
            <xsl:when test="ns0:BIG/BIG08 = '00'">
                "method": "POST",
                "url": "<xsl:value-of select="$input:host"/>/api/invoices",
                "payload": [
                    {
                        "txnGroup": {
                        "participants": [                        
                            <xsl:value-of select="$input:participants"/>
                        ]
                    },
                    "invNumber": "<xsl:value-of select="ns0:BIG/BIG02"/>",
                    "invType": "<xsl:value-of select="ns0:BIG/BIG07"/>",
                    "ref": [
                        <!-- TODO: Pick OP reference from BIG-04, if available. Otherwise, REF. -->
                        {
                                    "idQualf": "<xsl:text>ZF</xsl:text>",
                                    "id": "<xsl:value-of select="$input:zfFilterID"/>",
                                    "desc": ""
                                },
                        <xsl:for-each select="ns0:REF">
                        <xsl:choose>
                            <xsl:when test="REF01 = 'MA'">
                                {
                                "idQualf": "<xsl:value-of select="'AS'"/>",
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
                    "paymentTerms": {
                        <!-- TODO: Keep terms as Black. Not required -->
                        "terms": "<xsl:value-of select="ns0:ITD/ITD07"/>",
                        <xsl:if test="string-length(ns0:ITD/ITD06) != 0">
                        "termsDate": <xsl:call-template name="termdate"><xsl:with-param name="dtmObj" select="ns0:ITD/ITD06" /></xsl:call-template>,
                        </xsl:if>
                        "termsBasisDate": <xsl:value-of select="ns0:ITD/ITD02"/>,
                        "termsDescription": "<xsl:value-of select="ns0:ITD/ITD12"/>",
                        "discountDetails": [
                            {
                            "termsDiscount": <xsl:value-of select="ns0:ITD/ITD03"/>,
                            "termsDays": <xsl:value-of select="ns0:ITD/ITD05"/>,
                            <xsl:if test="string-length(ns0:ITD/ITD04) != 0">
                            "termsDiscountDate": <xsl:call-template name="termdate"><xsl:with-param name="dtmObj" select="ns0:ITD/ITD04" /></xsl:call-template>
                            </xsl:if>
                            }
                        ]
                    },
                    "prices": [
                    <xsl:if test="ns0:TXI_4/TXI01 = 'GS'">
                        {
                            "type": "TAX",
                            "value": <xsl:value-of select="ns0:TXI_4/TXI02"/>
                        },
                    </xsl:if>
                        <xsl:if test="ns0:AMT/AMT01 = '1'">
                        {
                            "type": "SUB_TOTAL",
                            "value": <xsl:value-of select="ns0:AMT/AMT02"/>
                        },
                    </xsl:if>
                    {
                            "type": "TOTAL",
                            "value": <xsl:value-of select="ns0:TDS/TDS01"/>
                        }
                    ],
                    <!-- TODO: Pick CUR-02, if CUR-01 is BY - Buying Party -->
                    "currency": "<xsl:value-of select="ns0:CUR/CUR02"/>",
                    <!-- Date to be converted into Loop-->
                "dtm": <xsl:call-template name="dtmHeader"><xsl:with-param name="dtmArr" select="ns0:DTM" /></xsl:call-template>,
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
                        <xsl:for-each select="ns0:REF_2">
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
                    <xsl:for-each select="ns0:IT1Loop1">
                        {
                        
                        "line": "<xsl:value-of select="ns0:IT1/IT101"/>",
                        "product": [
                        <xsl:if test="ns0:IT1/IT106 = 'VP'">
                            {
                            "productQualf": "<xsl:value-of select="ns0:IT1/IT106"/>",
                            "value": "<xsl:value-of select="ns0:IT1/IT107"/>",
                            "productDescription": ""
                            },
                        </xsl:if>
                        <xsl:if test="ns0:IT1/IT108 = 'BP'">
                            {
                            "productQualf": "<xsl:value-of select="ns0:IT1/IT108"/>",
                            "value": "<xsl:value-of select="ns0:IT1/IT109"/>",
                            "productDescription": ""
                            },
                        </xsl:if>
                        <xsl:if test="ns0:IT1/IT110 = 'ZZ'">
                            {
                            "productQualf": "<xsl:text>ZM</xsl:text>",
                            "value": "<xsl:value-of select="ns0:IT1/IT111"/>",
                            "productDescription": ""
                            },
                        </xsl:if>
                        ],
                        "ref": [
                            {
                                        "idQualf": "<xsl:text>ZF</xsl:text>",
                                        "id": "<xsl:value-of select="$input:zfFilterID"/>",
                                        "desc": ""
                            },
                            <xsl:for-each select="ns0:REF_3">
                            <xsl:choose>
                                <xsl:when test="REF01 = 'MA'">
                                    {
                                    "idQualf": "<xsl:value-of select="'AS'"/>",
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
                        "qty": [
                            <!-- TODO: Set BILLED_QTY object based on condition, if QTY-01 = D1 -->
                            <xsl:for-each select="ns0:QTY">
                                <xsl:if test="QTY01 = 'D1'">
                                    {
                                        "type": "BILLED_QTY",
                                        "value": <xsl:value-of select="QTY02"/>,        
                                        "uom": "<xsl:value-of select="ns0:C001_4/C00101"/>"
                                    },
                                </xsl:if>
                            </xsl:for-each>
                        ],
                        "prices": [
                            {
                                <xsl:if test="ns0:CTP/CTP02 = 'ACT'">
                                    "type": "UNIT_PRICE",
                                    "value": <xsl:value-of select="ns0:CTP[CTP02 = 'ACT']/CTP03"/>,
                                    <xsl:if test="ns0:CTP/CTP09 = 'PE'">
                                    "uom": "<xsl:value-of select="'EA'"/>",
                                    <xsl:if test="ns0:CTP[CTP02 = 'TOT']/CTP11">
                                    "priceUnit": <xsl:value-of select="ns0:CTP[CTP02 = 'TOT']/CTP11"/>
                                    </xsl:if>
                                    </xsl:if>
                                </xsl:if>
                            },
                            <xsl:if test="ns0:CTP/CTP02 = 'TOT'">
                            {
                                    "type": "AMOUNT",
                                    "value": <xsl:value-of select="ns0:CTP[CTP02 = 'TOT']/CTP03"/>,
                                    <xsl:if test="ns0:CTP/CTP09 = 'PE'">
                                    "uom": "<xsl:value-of select="'EA'"/>",
                                    </xsl:if>
                                    <xsl:if test="ns0:CTP[CTP02 = 'TOT']/CTP11">
                                    "priceUnit": <xsl:value-of select="ns0:CTP[CTP02 = 'TOT']/CTP11"/>
                                    </xsl:if>
                               
                            }
                            </xsl:if>
                        ]
                        },
                    </xsl:for-each>
                    ]}
                ]
            </xsl:when>
            <xsl:when test="ns0:BIG/BIG08 = '03'">
                "method": "DELETE",
                <xsl:variable name="singleQuote">'</xsl:variable>
                "url": "<xsl:value-of select="$input:host"/>/api/invoices/<xsl:value-of select="ns0:BIG/BIG02"/>?participants=<xsl:value-of select="translate($input:participants, $singleQuote, '')" />&amp;deleteReason=<xsl:value-of select="'1'"/>",
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
