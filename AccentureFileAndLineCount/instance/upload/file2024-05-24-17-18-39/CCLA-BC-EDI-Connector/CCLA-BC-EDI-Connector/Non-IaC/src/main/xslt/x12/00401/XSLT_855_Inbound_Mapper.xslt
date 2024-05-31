<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt" 
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output method="text" indent="yes"/>
    <xsl:param name="input:participants"/>
    <xsl:param name="input:host"/>
    <xsl:template match="/ns0:X12_00401_855">
    {
        <xsl:choose>
            <xsl:when test="ns0:BAK/BAK01 = '00' or ns0:BAK/BAK01 = '04'">
                "method": "PUT",
                "url": "<xsl:value-of select="$input:host"/>/api/purchaseorders/confirmations",
            </xsl:when>
        </xsl:choose>
        "payload": [
            {
                "txnGroup": {
                    "participants": [                        
                        <xsl:value-of select="$input:participants"/>
                    ]
                },
                "orderNumber": "<xsl:value-of select="ns0:BAK/BAK03"/>",
                <!-- Need a Input on ref validation -->
                "ref": [
                    <xsl:for-each select="ns0:REF">
                        <xsl:if test="REF01 = 'CO'">
                        {
                                "idQualf": "<xsl:value-of select="REF01"/>",
                                "id": "<xsl:value-of select="REF02"/>",
                                "desc": "<xsl:value-of select="REF03"/>"
                            },  
                        </xsl:if>
                    </xsl:for-each>
                ],
                "lineItems": [
                    <xsl:for-each select="ns0:PO1Loop1">
                    {
                        "line": "<xsl:value-of select="ns0:PO1/PO101"/>",
                        "dtm": <xsl:call-template name="dtmHeader"><xsl:with-param name="dtmArr" select="ns0:DTM_4" /></xsl:call-template>,
                        "ref": [
                            <xsl:for-each select="ns0:REF_3">
                               <xsl:if test="REF01 = 'CO'">
                                    {
                                            "idQualf": "<xsl:value-of select="REF01"/>",
                                            "id": "<xsl:value-of select="REF02"/>",
                                            "desc": "<xsl:value-of select="REF03"/>"
                                        },  
                            </xsl:if>
                            </xsl:for-each>
                        ],
                        <!-- TODO : Update Prices based on Input Recived  , ADD condition for CTP02 and AMT01-->
                        <xsl:if test="string-length(ns0:CTP_2/CTP03) != 0 or string-length(ns0:AMT/AMT02) != 0">
                        "prices": [
                            <xsl:if test="string-length(ns0:CTP_2/CTP03) != 0">
                                {
                                    "type": "CONF_UNIT_PRICE",
                                    "value": <xsl:value-of select="number(ns0:CTP_2/CTP03)"/>
                                },
                            </xsl:if>
                            <xsl:if test="string-length(ns0:AMT/AMT02) != 0">
                                {
                                    "type": "CONF_AMOUNT",
                                    "value": <xsl:value-of select="number(ns0:AMT/AMT02)"/>
                                }
                            </xsl:if>
                        ], 
                        </xsl:if>

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
                        "confirmations": [
                            <xsl:for-each select="ns0:ACKLoop1">
                            {
                                "confQualf": "<xsl:value-of select="ns0:ACK/ACK01"/>",
                                "seqNr": "<xsl:value-of select="ns0:ACK/ACK06"/>",
                                "quantity": <xsl:value-of select="ns0:ACK/ACK02"/>,
                                "dtm": {
                                    "dateQualf": "<xsl:value-of select="ns0:ACK/ACK04"/>",
                                    <!-- "dateQualf": "069", -->
                                    "date": <xsl:call-template name="ackDate"><xsl:with-param name="dateStr" select="ns0:ACK/ACK05" /></xsl:call-template>
                                }
                            },
                            </xsl:for-each>
                        ]
                    },
                    </xsl:for-each>
                ]
            }
        ]
    }
    </xsl:template>
    <xsl:template name="dtmHeader">
        <xsl:param name = "dtmArr" />
        [
            <xsl:for-each select="$dtmArr">
                <xsl:if test="DTM02 != ''">
                {
                    "dateQualf": "<xsl:value-of select="DTM01"/>",
                    <!-- "dateQualf": "055", -->
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